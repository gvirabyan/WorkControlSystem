import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/services/firebase_messaging_service.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final users = FirebaseFirestore.instance.collection('users');
  final promoCodes = FirebaseFirestore.instance.collection('promoCodes');

  /// Хэширование пароля
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Генерация уникального промокода для компании
  Future<String> generateUniquePromoCode() async {
    final random = Random();
    String code;
    bool exists = true;

    do {
      code = (100000 + random.nextInt(900000)).toString(); // 6-значный код
      final query = await promoCodes.where('promoCode', isEqualTo: code).get();
      exists = query.docs.isNotEmpty;
    } while (exists);

    return code;
  }

  /// Регистрация пользователя
  /// Возвращает `userId`, который сгенерировал Firestore
  Future<String> register(
      String emailOrPhone,
      String password,
      String type, {
        required String name,
        String? promoCodeForEmployee,
      }) async {

    // Проверка на существование пользователя
    final query = await users.where('emailOrPhone', isEqualTo: emailOrPhone).get();
    if (query.docs.isNotEmpty) throw Exception("User already exists");

    final hashedPassword = hashPassword(password);

    Map<String, dynamic> userData = {
      'name': name,
      'emailOrPhone': emailOrPhone,
      'password': hashedPassword,
      'type': type,
      'created_at': FieldValue.serverTimestamp(),
    };

    if (type == 'company') {
      // Компания → генерируем promoCode
      String promoCode = await generateUniquePromoCode();
      userData['promoCode'] = promoCode;

      await promoCodes.add({
        'company': name,
        'companyContact': emailOrPhone,
        'promoCode': promoCode,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else if (type == 'employee') {
      if (promoCodeForEmployee == null) {
        throw Exception("Promo code is required for employee registration");
      }

      // Находим компанию по промокоду
      final companyQuery = await users
          .where('promoCode', isEqualTo: promoCodeForEmployee)
          .where('type', isEqualTo: 'company')
          .get();

      if (companyQuery.docs.isEmpty) {
        throw Exception("Company not found");
      }

      final companyDoc = companyQuery.docs.first;
      final companyData = companyDoc.data();

      // Определяем лимит сотрудников для плана компании
      final planLimits = {
        'free': 2,
        'basic': 5,
        'standard': 10,
        'business': 15,
        'ultimate': 1000, // или кастом
      };

      final companyPlan = companyData['plan'] as String? ?? 'free';
      final employeeCountQuery = await users
          .where('promoCode', isEqualTo: promoCodeForEmployee)
          .where('type', isEqualTo: 'employee')
          .get();

      final currentEmployees = employeeCountQuery.docs.length;
      final limit = planLimits[companyPlan] ?? 2;

      if (currentEmployees >= limit) {
        throw Exception("This company has reached its employee limit for the current plan.");
      }

      userData['promoCode'] = promoCodeForEmployee;

      // Дефолтные данные сотрудника
      userData.addAll({
        'startDate': '09:00',
        'endDate': '18:00',
        'status': 'Not started',
        'task': 'No task assigned',
        'workedHours': '0',
        'weeklyHours': '40',
      });
    }

    // Создаём пользователя
    final docRef = users.doc();
    await docRef.set(userData);

    // Создаём документ в vacations для нового сотрудника
    if (type == 'employee') {
      await FirebaseFirestore.instance.collection('vacations').add({
        'userId': docRef.id,
        'name': name,
        'emailOrPhone': emailOrPhone,
        'vacationStartDate': '',
        'vacationEndDate': '',
        'vacationReason': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', docRef.id);
    await prefs.setString('userType', type);

    return docRef.id;
  }



  Future<bool> promoCodeExists(String code) async {
    final query = await promoCodes.where('promoCode', isEqualTo: code).get();
    return query.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserData(
      String emailOrPhone,
      String password,
      ) async {
    final query = await users.where('emailOrPhone', isEqualTo: emailOrPhone).get();
    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    if (data['password'] != hashPassword(password)) return null;

    final prefs = await SharedPreferences.getInstance();
    final userId = query.docs.first.id;
    await prefs.setString('userId', userId);
    await prefs.setString('userType', data['type']);

    // Save FCM token
    final FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService();
    final String? token = await firebaseMessagingService.getToken();
    if (token != null) {
      await users.doc(userId).update({'fcmToken': token});
    }

    // If the user is a company, send a notification to all employees
    if (data['type'] == 'company') {
      try {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendTestNotification');
        final result = await callable.call(<String, dynamic>{
          'promoCode': data['promoCode'],
          'title': 'Company Login',
          'body': '${data['name']} has logged in.',
        });
        print(result.data);
      } catch (e) {
        print(e);
      }
    }

    // Добавляем userId в возвращаемый Map
    return {
      'userId': userId,
      ...data,
    };
  }

  /// Проверка текущего пользователя
  Future<Map<String, String>?> checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userType = prefs.getString('userType');

    if (userId != null && userType != null) {
      return {'userId': userId, 'userType': userType};
    }
    return null;
  }

  /// Выход из системы
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userType');
  }

  /// Смена пароля
  Future<void> changePassword(
      String userId, String oldPassword, String newPassword) async {
    final docRef = users.doc(userId);
    final doc = await docRef.get();

    if (!doc.exists) throw Exception("User not found");

    final data = doc.data();
    if (data!['password'] != hashPassword(oldPassword)) {
      throw Exception("Incorrect old password");
    }

    final hashedNewPassword = hashPassword(newPassword);
    await docRef.update({'password': hashedNewPassword});
  }
}

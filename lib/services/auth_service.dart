import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

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
    // Проверяем, не зарегистрирован ли уже этот email/phone
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

      // Сохраняем promoCode отдельно
      await promoCodes.add({
        'company': name,
        'companyContact': emailOrPhone,
        'promoCode': promoCode,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else if (promoCodeForEmployee != null) {
      // Сотрудник → сохраняем promoCode
      userData['promoCode'] = promoCodeForEmployee;
    }

    // Создаём уникальный doc ID
    final docRef = users.doc();
    await docRef.set(userData);

    // Возвращаем ID документа
    return docRef.id;
  }

  /// Проверка промокода
  Future<bool> promoCodeExists(String code) async {
    final query = await promoCodes.where('promoCode', isEqualTo: code).get();
    return query.docs.isNotEmpty;
  }

  /// Логин (по email или телефону)
  Future<Map<String, dynamic>?> getUserData(
      String emailOrPhone,
      String password,
      ) async {
    final query = await users.where('emailOrPhone', isEqualTo: emailOrPhone).get();
    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    if (data['password'] != hashPassword(password)) return null;

    // Добавляем userId в возвращаемый Map
    return {
      'userId': query.docs.first.id,
      ...data,
    };
  }
}

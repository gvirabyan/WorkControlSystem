import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // <--- НОВЫЙ ИМПОРТ

import '../../models/UserModel.dart';
import '../../ui_elements/user_item.dart';

class CompanyEmployeesPage extends StatelessWidget {
  final String companyId;

  const CompanyEmployeesPage({super.key, required this.companyId});

  Future<String?> _getCompanyPromoCode() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(companyId).get();
    if (doc.exists) {
      return doc.data()?['promoCode'] as String?;
    }
    return null;
  }

  // --- ОБНОВЛЕННАЯ ФУНКЦИЯ: Отправка уведомлений ---
  Future<void> _sendNotificationToEmployees(BuildContext context, String companyPromoCode) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка уведомлений...')),
    );

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendTestNotification');

      final results = await callable.call(<String, dynamic>{
        'promoCode': companyPromoCode,
        'title': 'Важное объявление от компании',
        'body': 'Пожалуйста, проверьте последние новости в приложении.',
      });

      // 3. Обрабатываем результат
      final resultData = results.data as Map<String, dynamic>;
      final isSuccess = resultData['success'] as bool? ?? false;
      final message = resultData['message'] as String? ?? 'Unknown error';

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Уведомления успешно отправлены сотрудникам!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка отправки: $message')),
        );
      }

    } on FirebaseFunctionsException catch (e) {
      // Обработка ошибок Cloud Function (например, 'invalid-argument')
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка вызова функции: ${e.message}')),
      );
      print('Cloud Function Error: ${e.code} / ${e.message}');
    } catch (e) {
      // Общая ошибка
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла непредвиденная ошибка: $e')),
      );
    }
  }
  // --- КОНЕЦ ОБНОВЛЕННОЙ ФУНКЦИИ ---


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCompanyPromoCode(),
      builder: (context, promoSnapshot) {
        if (promoSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final companyPromoCode = promoSnapshot.data;

        if (companyPromoCode == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Employees')),
            body: const Center(child: Text('Company promo code not found')),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          // ... (логика StreamBuilder остается прежней)
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('type', isEqualTo: 'employee')
              .where('promoCode', isEqualTo: companyPromoCode)
              .snapshots(),
          builder: (context, snapshot) {

            // ... (логика загрузки и пустого состояния)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: Text('Employees')),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final users = snapshot.data?.docs
                .map((doc) => UserModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ))
                .toList() ?? [];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Company Employees'),
                actions: [
                  // --- КНОПКА, ВЫЗЫВАЮЩАЯ CLOUD FUNCTION ---
                  IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: 'Send Notifications to Employees',
                    onPressed: users.isEmpty
                        ? null
                        : () => _sendNotificationToEmployees(context, companyPromoCode),
                  ),
                  // --- КОНЕЦ КНОПКИ ---
                ],
              ),
              body: users.isEmpty
                  ? const Center(child: Text('No staff found'))
                  : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: UserItem(user: users[index]),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
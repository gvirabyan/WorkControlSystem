import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/UserModel.dart';
import '../../ui_elements/user_item.dart';

class CompanyEmployeesPage extends StatelessWidget {
  final String companyId; // ✅ сохраняем companyId

  const CompanyEmployeesPage({super.key, required this.companyId});

  Future<String?> _getCompanyPromoCode() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(companyId).get();
    if (doc.exists) {
      return doc.data()?['promoCode'] as String?;
    }
    return null;
  }

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

        if (!promoSnapshot.hasData || promoSnapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Company promo code not found')),
          );
        }

        final companyPromoCode = promoSnapshot.data!;

        return Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('type', isEqualTo: 'employee')
                .where('promoCode', isEqualTo: companyPromoCode)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No employees found'));
              }

              final users = snapshot.data!.docs
                  .map((doc) => UserModel.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: UserItem(user: users[index]),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

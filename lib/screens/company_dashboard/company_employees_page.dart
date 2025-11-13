import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:pot/screens/company_dashboard/reports_page.dart';

import '../../models/UserModel.dart';
import '../../ui_elements/user_item.dart';

class CompanyEmployeesPage extends StatelessWidget {
  final String companyId;

  const CompanyEmployeesPage({super.key, required this.companyId});

  Future<String?> _getCompanyPromoCode() async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(companyId).get();
    if (doc.exists) {
      return doc.data()?['promoCode'] as String?;
    }
    return null;
  }

  Future<void> _sendNotificationToEmployees(
      BuildContext context, String companyPromoCode) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('sending_notifications'))),
    );

    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('sendTestNotification');

      final results = await callable.call(<String, dynamic>{
        'promoCode': companyPromoCode,
        'title': AppLocalizations.of(context)!
            .translate('important_announcement_from_the_company'),
        'body': AppLocalizations.of(context)!
            .translate('please_check_the_latest_news_in_the_app'),
      });

      final resultData = results.data as Map<String, dynamic>;
      final isSuccess = resultData['success'] as bool? ?? false;
      final message = resultData['message'] as String? ?? 'Unknown error';

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .translate('notifications_sent_successfully'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.translate('sending_error')}$message')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.translate('function_call_error')}${e.message}')),
      );
      print('Cloud Function Error: ${e.code} / ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.translate('an_unexpected_error_occurred')}$e')),
      );
    }
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

        final companyPromoCode = promoSnapshot.data;

        if (companyPromoCode == null) {
          return Scaffold(
            appBar: AppBar(
                title:
                Text(AppLocalizations.of(context)!.translate('employees'))),
            body: Center(
                child: Text(AppLocalizations.of(context)!
                    .translate('company_promo_code_not_found'))),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('type', isEqualTo: 'employee')
              .where('promoCode', isEqualTo: companyPromoCode)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                    title: Text(
                        AppLocalizations.of(context)!.translate('employees'))),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final users = snapshot.data?.docs
                .map((doc) => UserModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ))
                .toList() ??
                [];

            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!
                    .translate('company_employees')),
                actions: [
                  // Reports button
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined),
                    tooltip: 'Reports',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportsPage(
                            companyId: companyId,
                            companyPromoCode: companyPromoCode,
                          ),
                        ),
                      );
                    },
                  ),
                  // Notification button (commented out)
                  // IconButton(
                  //   icon: const Icon(Icons.send),
                  //   tooltip: AppLocalizations.of(context)!
                  //       .translate('send_notifications_to_employees'),
                  //   onPressed: users.isEmpty
                  //       ? null
                  //       : () => _sendNotificationToEmployees(
                  //           context, companyPromoCode),
                  // ),
                ],
              ),
              body: users.isEmpty
                  ? Center(
                  child: Text(AppLocalizations.of(context)!
                      .translate('no_staff_found')))
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

// Placeholder Reports Page

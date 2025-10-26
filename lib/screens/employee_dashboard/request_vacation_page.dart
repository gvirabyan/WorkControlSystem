import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'vacation_request_form.dart';

class RequestVacationPage extends StatelessWidget {
  final String userId;

  const RequestVacationPage({super.key, required this.userId});

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd.MM.yyyy').format(date.toDate());
    }
    return date.toString();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'vacation':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('my_vacation_requests')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('vacations')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
                    '${localizations.translate('error_loading_data')}: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child:
                    Text(localizations.translate('no_vacation_requests_found')));
          }

          final vacations = snapshot.data!.docs;
          vacations.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            final aTimestamp = aData['createdAt'] as Timestamp?;
            final bTimestamp = bData['createdAt'] as Timestamp?;
            if (aTimestamp == null && bTimestamp == null) return 0;
            if (aTimestamp == null) return 1;
            if (bTimestamp == null) return -1;
            return bTimestamp.compareTo(aTimestamp);
          });

          final hasActiveOrPending = vacations.any(
            (doc) {
              final status =
                  (doc.data()['status'] ?? 'unknown').toString().toLowerCase();
              return status == 'pending' ||
                  status == 'approved' ||
                  status == 'vacation';
            },
          );

          return Column(
            children: [
              if (!hasActiveOrPending)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VacationRequestForm(userId: userId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_box),
                    label: Text(
                        localizations.translate('create_vacation_request'),
                        style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    localizations.translate(
                        'you_already_have_an_active_or_pending_vacation_request'),
                    style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: vacations.isEmpty
                    ? Center(
                        child: Text(localizations
                            .translate('no_vacation_requests_found')))
                    : ListView.builder(
                        itemCount: vacations.length,
                        itemBuilder: (context, index) {
                          final doc = vacations[index];
                          final data = doc.data();
                          final startDate = data['startDate'];
                          final endDate = data['endDate'];
                          final reason = data['reason'] ??
                              localizations
                                  .translate('reason_not_specified');
                          final status = (data['status'] ?? 'unknown')
                              .toString()
                              .toLowerCase();
                          final color = _getStatusColor(status);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.beach_access,
                                  color: color, size: 30),
                              title: Text(
                                '${localizations.translate('from')} ${_formatDate(startDate)} ${localizations.translate('to')} ${_formatDate(endDate)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  '${localizations.translate('reason')}: $reason'),
                              trailing: Chip(
                                label: Text(
                                  status[0].toUpperCase() +
                                      status.substring(1),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: color,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
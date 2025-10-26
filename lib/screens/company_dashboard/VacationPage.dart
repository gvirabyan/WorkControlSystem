import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pot/l10n/app_localizations.dart';

class VacationPage extends StatelessWidget {
  final String userId;

  const VacationPage({super.key, required this.userId});

  String _formatTimestamp(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd.MM.yyyy').format(date.toDate());
    }
    return 'N/A';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'vacation':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
      case 'prematurely_ended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String docId, String newStatus,
      {DateTime? newEndDate}) async {
    final localizations = AppLocalizations.of(context)!;
    final updateData = <String, dynamic>{'status': newStatus};

    if (newEndDate != null) {
      updateData['endDate'] = Timestamp.fromDate(newEndDate);
      updateData['prematurelyEnded'] = true;
    }

    try {
      await FirebaseFirestore.instance
          .collection('vacations')
          .doc(docId)
          .update(updateData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${localizations.translate('status_updated_to')} "${newStatus.replaceAll('_', ' ')}"')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${localizations.translate('failed_to_update_status')}: $e')),
        );
      }
    }
  }

  Future<void> _showEarlyReturnDialog(BuildContext context, String docId,
      DateTime currentStartDate, DateTime currentEndDate) async {
    final localizations = AppLocalizations.of(context)!;
    DateTime? selectedDate = DateTime.now();
    if (selectedDate.isBefore(currentStartDate)) {
      selectedDate = currentStartDate;
    }
    if (selectedDate.isAfter(currentEndDate)) selectedDate = currentEndDate;

    final TextEditingController dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(selectedDate),
    );

    Future<void> pickDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: currentStartDate,
        lastDate: currentEndDate,
      );
      if (picked != null) {
        selectedDate = picked;
        dateController.text = DateFormat('dd.MM.yyyy').format(picked);
        (context as Element).markNeedsBuild();
      }
    }

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.translate('end_vacation_early')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(localizations
                  .translate('select_new_date_employee_returned')),
              const SizedBox(height: 10),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: localizations.translate('return_date'),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: pickDate,
                  ),
                ),
                onTap: pickDate,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.translate('cancel')),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(localizations.translate('confirm_early_end')),
              onPressed: () {
                if (selectedDate != null) {
                  Navigator.of(dialogContext).pop();
                  _updateStatus(
                    context,
                    docId,
                    'prematurely_ended',
                    newEndDate: selectedDate,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('employee_vacations')),
        backgroundColor: Colors.orange,
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                localizations.translate('no_vacation_records_found'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final vacations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vacations.length,
            itemBuilder: (context, index) {
              final doc = vacations[index];
              final data = doc.data();
              final startDateTimestamp = data['startDate'] as Timestamp?;
              final endDateTimestamp = data['endDate'] as Timestamp?;
              final reason = data['reason'] ?? 'N/A';
              final status =
                  (data['status'] ?? 'unknown').toString().toLowerCase();

              final formattedStartDate = _formatTimestamp(startDateTimestamp);
              final formattedEndDate = _formatTimestamp(endDateTimestamp);

              final currentStartDate =
                  startDateTimestamp?.toDate() ?? DateTime.now();
              final currentEndDate =
                  endDateTimestamp?.toDate() ?? DateTime.now();

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _getStatusColor(status),
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${localizations.translate('from')} $formattedStartDate ${localizations.translate('to')} $formattedEndDate',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${localizations.translate('reason')}: $reason'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${localizations.translate('status')}: ${status.replaceAll('_', ' ')[0].toUpperCase()}${status.replaceAll('_', ' ').substring(1)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(status),
                            ),
                          ),
                          if (status == 'pending') ...[
                            ElevatedButton(
                              onPressed: () =>
                                  _updateStatus(context, doc.id, 'approved'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white),
                              child: Text(localizations.translate('accept')),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _updateStatus(context, doc.id, 'declined'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              child: Text(localizations.translate('decline')),
                            ),
                          ] else if (status == 'vacation' ||
                              status == 'approved') ...[
                            ElevatedButton.icon(
                              onPressed: () => _showEarlyReturnDialog(context,
                                  doc.id, currentStartDate, currentEndDate),
                              icon: const Icon(Icons.logout),
                              label: Text(localizations.translate('end_early')),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

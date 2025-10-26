import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/l10n/app_localizations.dart';

class DailyReportPage extends StatelessWidget {
  final String userId;
  const DailyReportPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '📅 ${localizations.translate('todays_report')}')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('employee_action_history')
            .where('userId', isEqualTo: userId)
            .where('datetimeStart', isGreaterThanOrEqualTo: startOfDay)
            .where('datetimeStart', isLessThanOrEqualTo: endOfDay)
            .orderBy('datetimeStart', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final workEntries = snapshot.data?.docs ?? [];

          if (workEntries.isEmpty) {
            return Center(
              child: Text(
                '${localizations.translate('no_work_recorded_for')} $formattedDate',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...workEntries.map((entry) {
                        final data = entry.data();
                        final start = _formatDateTime(data['datetimeStart']);
                        final end = _formatDateTime(data['datetimeEnd']);
                        final task = data['task'] ?? '-';
                        final duration = _calculateDuration(
                            data['datetimeStart'], data['datetimeEnd']);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${localizations.translate('start')}: $start\n'
                                  '${localizations.translate('end')}: $end\n'
                                  '${localizations.translate('task')}: $task',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                '⏱ $duration',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatDateTime(Timestamp? timestamp) {
  if (timestamp == null) return '-';
  final date = timestamp.toDate();
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _calculateDuration(Timestamp? start, Timestamp? end) {
  if (start == null || end == null) return '-';
  final duration = end.toDate().difference(start.toDate());
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  return '${hours}h ${minutes}m';
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeeklyHistoryPage extends StatefulWidget {
  final String userId;

  const WeeklyHistoryPage({super.key, required this.userId});

  @override
  State<WeeklyHistoryPage> createState() => _WeeklyHistoryPageState();
}

class _WeeklyHistoryPageState extends State<WeeklyHistoryPage> {
  late List<DateTime> _last7Days;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _last7Days = List.generate(7, (i) => now.subtract(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗓 Weekly Work History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _last7Days.length,
        itemBuilder: (context, index) {
          final day = _last7Days[index];
          final startOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
          final endOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day, 23, 59, 59));
          final formattedDate =
              '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('employee_action_history')
                .where('userId', isEqualTo: widget.userId)
                .where('datetimeStart', isGreaterThanOrEqualTo: startOfDay)
                .where('datetimeStart', isLessThanOrEqualTo: endOfDay)
                .orderBy('datetimeStart', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final workEntries = snapshot.data?.docs ?? [];

              // If no work entries for the day
              if (workEntries.isEmpty) {
                return Card(
                  color: Colors.grey.shade100,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('No work recorded'),
                  ),
                );
              }

              return Card(
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
                                  'Start: $start\nEnd: $end\nTask: $task',
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
              );
            },
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


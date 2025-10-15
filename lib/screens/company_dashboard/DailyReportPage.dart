import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReportPage extends StatelessWidget {
  final String userId;
  const DailyReportPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('📅 Today\'s Report')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('workHistory')
            .where('date', isEqualTo: formattedDate)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final workEntries = snapshot.data?.docs ?? [];

          if (workEntries.isEmpty) {
            return Center(
              child: Text(
                'No work recorded for $formattedDate',
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
                        final start = data['startTime'] ?? '-';
                        final end = data['endTime'] ?? '-';
                        final task = data['taskName'] ?? '-';
                        final duration = data['duration'] ?? '-';
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
              ),
            ],
          );
        },
      ),
    );
  }
}

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
          final formattedDate =
              '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .collection('workHistory')
                .where('date', isEqualTo: formattedDate)
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
              );
            },
          );
        },
      ),
    );
  }
}


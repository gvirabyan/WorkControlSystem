import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  final String promoCode; // <-- promoCode пользователя

  const HistoryPage({super.key, required this.promoCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work History'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('employee_action_history')
            .where('promoCode', isEqualTo: promoCode)
            //.orderBy('datetimeStart', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No history records found'),
            );
          }

          final docs = snapshot.data!.docs;

          // Группируем записи по дате (yyyy-MM-dd)
          final Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['datetimeStart'] as Timestamp?;
            final dateKey = timestamp != null
                ? DateFormat('yyyy-MM-dd').format(timestamp.toDate())
                : 'Unknown Date';
            groupedByDate.putIfAbsent(dateKey, () => []).add(doc);
          }

          final sortedDates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              return ListTile(
                title: Text(date),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryDetailPage(
                        date: date,
                        records: groupedByDate[date]!,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final String date;
  final List<QueryDocumentSnapshot> records;

  const HistoryDetailPage({
    super.key,
    required this.date,
    required this.records,
  });

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = timestamp.toDate();
      return DateFormat('HH:mm:ss').format(date);
    } catch (e) {
      return '-';
    }
  }

  String _calculateDuration(Timestamp? start, Timestamp? end) {
    if (start == null || end == null) return '-';
    try {
      final duration = end.toDate().difference(start.toDate());
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History for $date'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.grey[300],
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Start', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('End', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final data = records[index].data() as Map<String, dynamic>;
                final start = data['datetimeStart'] as Timestamp?;
                final end = data['datetimeEnd'] as Timestamp?;
                final duration = _calculateDuration(start, end);

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(data['action'] ?? '-')),
                      Expanded(flex: 3, child: Text(_formatDateTime(start))),
                      Expanded(flex: 3, child: Text(_formatDateTime(end))),
                      Expanded(flex: 2, child: Text(duration)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmployeeActionHistoryTable extends StatelessWidget {
  final String promoCode; // <-- получаем промокод снаружи

  const EmployeeActionHistoryTable({super.key, required this.promoCode});

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
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
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('employee_action_history')
          .where('promoCode', isEqualTo: promoCode) // <-- фильтр по promoCode
          .orderBy('datetimeStart', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No employee action records found',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  color: Colors.grey[300],
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 3, child: Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 3, child: Text('End Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                ),

                // Table rows
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final start = data['datetimeStart'] as Timestamp?;
                  final end = data['datetimeEnd'] as Timestamp?;

                  final startStr = _formatDateTime(start);
                  final endStr = _formatDateTime(end);
                  final duration = _calculateDuration(start, end);

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: Text(data['name'] ?? '-', style: const TextStyle(fontSize: 12))),
                        Expanded(flex: 2, child: Text(data['action'] ?? '-', style: const TextStyle(fontSize: 12))),
                        Expanded(flex: 3, child: Text(startStr, style: const TextStyle(fontSize: 12))),
                        Expanded(flex: 3, child: Text(endStr, style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}

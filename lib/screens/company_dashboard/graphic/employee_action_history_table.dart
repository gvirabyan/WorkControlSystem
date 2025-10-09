import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmployeeActionHistoryTable extends StatelessWidget {
  const EmployeeActionHistoryTable({super.key});

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
    if (start == null) return '-';
    if (end == null) return '-';
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('employee_action_history')
          .orderBy('datetimeStart', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No action records found',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 14,
            headingRowHeight: 34,
            dataRowHeight: 30,
            columns: const [
              DataColumn(label: Text('Name', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('Contact', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('Action', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('Start Time', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('End Time', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('Duration', style: TextStyle(fontSize: 12))),
            ],
            rows: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final start = data['datetimeStart'] as Timestamp?;
              final end = data['datetimeEnd'] as Timestamp?;

              final startStr = _formatDateTime(start);
              final endStr = _formatDateTime(end);
              final duration = _calculateDuration(start, end);

              return DataRow(
                cells: [
                  DataCell(FittedBox(child: Text(data['name'] ?? '-', style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(data['contact'] ?? '-', style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(data['action'] ?? '-', style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(startStr, style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(endStr, style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(duration, style: const TextStyle(fontSize: 12)))),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

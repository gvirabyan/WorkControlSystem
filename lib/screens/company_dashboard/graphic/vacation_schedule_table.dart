import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VacationScheduleTable extends StatelessWidget {
  const VacationScheduleTable({super.key});

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null || startDate.isEmpty || endDate.isEmpty) {
      return '-';
    }
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final days = end.difference(start).inDays + 1;
      return '$days day${days > 1 ? 's' : ''}';
    } catch (e) {
      return '-';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vacations')
          .orderBy('createdAt', descending: false) // сортировка по дате создания
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No vacation records found',
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
              DataColumn(label: Text('Start Date', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('End Date', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('Duration', style: TextStyle(fontSize: 12))),
              DataColumn(label: Text('Reason', style: TextStyle(fontSize: 12))),
            ],
            rows: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final startDate = _formatDate(data['vacationStartDate']?.toString());
              final endDate = _formatDate(data['vacationEndDate']?.toString());
              final duration = _calculateDuration(
                  data['vacationStartDate']?.toString(),
                  data['vacationEndDate']?.toString());

              return DataRow(
                cells: [
                  DataCell(FittedBox(child: Text(data['name'] ?? '', style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(data['emailOrPhone'] ?? '', style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(startDate, style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(endDate, style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(duration, style: const TextStyle(fontSize: 12)))),
                  DataCell(FittedBox(child: Text(data['vacationReason'] ?? '-', style: const TextStyle(fontSize: 12)))),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

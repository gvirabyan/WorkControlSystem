import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkScheduleTable extends StatelessWidget {
  const WorkScheduleTable({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No employees found',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        String debugStatuses = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['status']?.toString() ?? 'null';
        }).join(', ');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12,
                  headingRowHeight: 32,
                  dataRowHeight: 28,
                  columns: const [
                    DataColumn(label: Text('Name', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Start Time', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('End Time', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Current status', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Task', style: TextStyle(fontSize: 12))),
                 ],
                  rows: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? '').toString().toLowerCase();

                    Color? rowColor;
                    // 🔹 Посмотрим что реально хранится в статусе

                    // 👇 Исправляем проверку — Firestore хранит точный регистр
                    if (status == 'Working' || status == 'working') {
                      rowColor = Colors.green.withOpacity(0.2);
                    } else if (status == 'On break' || status == 'on break') {
                      rowColor = Colors.yellow.withOpacity(0.3);
                    } else if (status == 'Not working' || status == 'not working' || status == 'not started') {
                      rowColor = Colors.grey.withOpacity(0.3);
                    }

                    return DataRow(
                      color: WidgetStatePropertyAll(rowColor),
                      cells: [
                        DataCell(FittedBox(child: Text(data['name'] ?? '', style: const TextStyle(fontSize: 12)))),
                        DataCell(FittedBox(child: Text(data['startDate'] ?? '', style: const TextStyle(fontSize: 12)))),
                        DataCell(FittedBox(child: Text(data['endDate'] ?? '', style: const TextStyle(fontSize: 12)))),
                        DataCell(FittedBox(child: Text(data['status'] ?? '', style: const TextStyle(fontSize: 12)))),
                        DataCell(FittedBox(child: Text(data['task'] ?? '', style: const TextStyle(fontSize: 12)))),
                     ],
                    );
                  }).toList(),
                ),
              ),
            ),

          ],
        );
      },
    );
  }
}

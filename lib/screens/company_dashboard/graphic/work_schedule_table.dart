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
            child: Text('No employees found', style: TextStyle(fontSize: 16)),
          );
        }

        final docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2), // Name
                  1: FlexColumnWidth(2), // Start
                  2: FlexColumnWidth(2), // End
                  3: FlexColumnWidth(2), // Status
                  4: FlexColumnWidth(3), // Task
                },
                children: [
                  // Table header
                  _buildHeaderRow(),
                  // Table rows
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? '').toString().toLowerCase();

                    Color? bgColor;
                    if (status.contains('working')) {
                      bgColor = Colors.green.withOpacity(0.2);
                    } else if (status.contains('break')) {
                      bgColor = Colors.yellow.withOpacity(0.3);
                    } else {
                      bgColor = Colors.red.withOpacity(0.3);
                    }

                    return _buildDataRow(
                      name: data['name'] ?? '',
                      start: data['startDate'] ?? '',
                      end: data['endDate'] ?? '',
                      status: data['status'] ?? '',
                      task: data['task'] ?? '',
                      color: bgColor,
                      small: isSmallScreen,
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  TableRow _buildHeaderRow() {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFEDEDED)),
      children: [
        Padding(padding: EdgeInsets.all(6), child: Text('Name', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('Start Time', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('End Time', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('Current Status', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('Task', style: style)),
      ],
    );
  }

  TableRow _buildDataRow({
    required String name,
    required String start,
    required String end,
    required String status,
    required String task,
    required Color color,
    required bool small,
  }) {
    final style = TextStyle(fontSize: small ? 11 : 13);
    return TableRow(
      decoration: BoxDecoration(color: color),
      children: [
        _cell(name, style),
        _cell(start, style),
        _cell(end, style),
        _cell(status, style),
        _cell(task, style),
      ],
    );
  }

  Widget _cell(String text, TextStyle style) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
    ),
  );
}

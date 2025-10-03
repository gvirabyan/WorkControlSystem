import 'package:flutter/material.dart';

class EmployeeDataTable extends StatelessWidget {
  const EmployeeDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Avatar')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Start Time')),
        DataColumn(label: Text('End Time')),
        DataColumn(label: Text('Break Time')),
        DataColumn(label: Text('Vacation Time')),
      ],
      rows: const [],
    );
  }
}
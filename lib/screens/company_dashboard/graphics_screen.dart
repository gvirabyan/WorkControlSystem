import 'package:flutter/material.dart';
import 'package:pot/screens/company_dashboard/employee_data_table.dart';

class GraphicsScreen extends StatelessWidget {
  const GraphicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphics'),
      ),
      body: const EmployeeDataTable(),
    );
  }
}
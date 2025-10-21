import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pot/screens/company_dashboard/graphic/vacation_schedule_table.dart';
import 'package:pot/screens/company_dashboard/graphic/work_schedule_table.dart';

import 'employee_action_history_table.dart';

// Placeholder for EmployeeDataTable. Replace with your actual table.
class EmployeeDataTable extends StatelessWidget {
  final String scheduleType;
  const EmployeeDataTable({super.key, required this.scheduleType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Table: $scheduleType',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 20),
            // Replace with your actual data table
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),

            ),
          ],
        ),
      ),
    );
  }
}


class ScheduleDashboardScreen extends StatefulWidget {
  final String companyId;

  const ScheduleDashboardScreen({super.key, required this.companyId});

  @override
  State<ScheduleDashboardScreen> createState() => _ScheduleDashboardScreenState();
}

class _ScheduleDashboardScreenState extends State<ScheduleDashboardScreen> {
  int _selectedIndex = 0;
  String? _promoCode;

  @override
  void initState() {
    super.initState();
    _loadCompanyPromoCode();
  }

  Future<void> _loadCompanyPromoCode() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.companyId)
          .get();
      if (doc.exists) {
        setState(() {
          _promoCode = doc.data()?['promoCode'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching promoCode: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_promoCode == null) {
      // Пока promoCode загружается
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pages = [
      WorkScheduleTable(companyPromoCode: _promoCode!),
      VacationScheduleTable(companyPromoCode: _promoCode!),
      EmployeeActionHistoryTable(promoCode: _promoCode!),
    ];

    const List<String> pageTitles = [
      'Work Schedule',
      'Vacation Schedule',
      'Break Schedule',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex]),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Work Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.beach_access), label: 'Vacation Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Break Schedule'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:pot/screens/company_dashboard/profile/profile_items.dart';
import 'package:pot/ui_elements/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'company_employees_page.dart';
import 'profile/company_profile_page.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  int _selectedIndex = 0;
  String? _companyId;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  void _loadCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    setState(() {
      _companyId = id;
      _pages = [
        if (_companyId != null) CompanyEmployeesPage(companyId: _companyId!),
        const Center(child: Text('Documents Page')),
        if (_companyId != null) ProfileItems(companyId: _companyId!),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: "Company Dashboard"),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
          BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

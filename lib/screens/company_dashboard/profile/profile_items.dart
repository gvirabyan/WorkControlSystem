import 'package:flutter/material.dart';
import 'package:pot/screens/company_dashboard/profile/plans_page.dart';
import 'package:pot/screens/company_dashboard/profile/privacy_policy_page.dart';
import 'package:pot/screens/company_dashboard/profile/settings_page.dart';
import 'package:pot/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'company_profile_page.dart';
import 'help_page.dart';

class ProfileItems extends StatefulWidget {
  final String companyId;
  const ProfileItems({super.key, required this.companyId});

  @override
  State<ProfileItems> createState() => _ProfileItemsState();
}

class _ProfileItemsState extends State<ProfileItems> {
  Widget? _selectedPage;
  String? _selectedPageTitle;
  String? _companyName;

  // Меню с иконкой, заголовком и страницей
  late final List<Map<String, dynamic>> _menuItems;

  @override
  void initState() {
    super.initState();

    _menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Profile',
        'page': ProfilePage(companyId: widget.companyId),
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Privacy Policy',
        'page': const PrivacyPolicyPage(),
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'page': const SettingsPage(),
      },
      {
        'icon': Icons.add_chart_sharp,
        'title': 'Plans',
        'page': const PlansPage(),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help',
        'page': const HelpPage(),
      },
    ];

    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.companyId)
          .get();

      if (doc.exists && doc.data()!.containsKey('name')) {
        setState(() {
          _companyName = doc['name'];
        });
      }
    } catch (e) {
      debugPrint("Ошибка при загрузке компании: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (_selectedPage == null) ...[
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.business, size: 50, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                _companyName ?? "Loading...",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
        Expanded(
          child: _selectedPage == null
              ? ListView(
            children: [
              ..._menuItems.map((item) => _buildMenuItem(
                icon: item['icon'],
                text: item['title'],
                onTap: () => _openPage(item['page'], item['title']),
              )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red, size: 28),
                title: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                onTap: _logout,
              ),
            ],
          )
              : _buildDetailPage(),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _openPage(Widget page, String title) {
    setState(() {
      _selectedPage = page;
      _selectedPageTitle = title;
    });
  }

  Widget _buildDetailPage() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back, color: Colors.blue),
          title: Text(
            _selectedPageTitle ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onTap: () => setState(() {
            _selectedPage = null;
            _selectedPageTitle = null;
          }),
        ),
        const Divider(),
        Expanded(child: _selectedPage!),
      ],
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
      );
    }
  }
}

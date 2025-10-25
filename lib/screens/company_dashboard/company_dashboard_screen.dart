import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pot/screens/company_dashboard/profile/profile_items.dart';
import 'package:pot/ui_elements/custom_app_bar.dart';
import 'note/company_notes_page.dart';
import 'document/company_documents_page.dart';
import 'company_employees_page.dart';
import 'graphic/graphics_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  int _selectedIndex = 0;
  String? _companyId;
  String? _promoCode;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadCompanyIdAndPromoCode();
  }

  Future<void> _loadCompanyIdAndPromoCode() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id == null) return;

    // 🔹 Получаем promoCode из Firestore
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    final promo = doc.data()?['promoCode'] as String?;

    setState(() {
      _companyId = id;
      _promoCode = promo;

      _pages = [
        CompanyEmployeesPage(companyId: _companyId!),
        ScheduleDashboardScreen(companyId: _companyId!),
        const CompanyDocumentsPage(),
        if (_promoCode != null)
          CompanyNotesPage(companyPromoCode: _promoCode!), // ✅ передаём promoCode
        ProfileItems(companyId: _companyId!),
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
        appBar: CustomAppBar(
            title: AppLocalizations.of(context)!
                .translate('company_dashboard')),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // чтобы все кнопки помещались
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.people),
                label: AppLocalizations.of(context)!.translate('staff')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart),
                label: AppLocalizations.of(context)!.translate('graphics')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.file_copy),
                label: AppLocalizations.of(context)!.translate('documents')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.note_alt),
                label: AppLocalizations.of(context)!.translate('notes')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: AppLocalizations.of(context)!.translate('profile')),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.cyan,
          onTap: _onItemTapped,
        ));
  }
}

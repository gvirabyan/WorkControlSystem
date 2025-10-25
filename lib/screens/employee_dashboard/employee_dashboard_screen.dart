import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:pot/screens/employee_dashboard/profile/employee_profile_items.dart';
import 'package:pot/screens/welcome_screen.dart';
import 'package:pot/services/auth_service.dart';
import 'package:pot/ui_elements/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'documents_page.dart';
import 'home_page.dart';
import 'history_page.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  String? _userId;
  String? _promoCode;

  List<Widget> _pages = [];
  bool _isLoading = true; // Добавлено для явного управления состоянием загрузки

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Переименовал в _loadUserData, чтобы отразить загрузку обоих полей
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('userId');
    String? promoCode = prefs.getString('promoCode');

    // 1. Попытка получить userId, если отсутствует в кеше
    if (userId == null) {
      final userData = await _authService.checkCurrentUser();
      userId = userData?['userId'];

      if (userId != null) {
        await prefs.setString('userId', userId);
      }
    }

    // --- 2. Получение promoCode из Firestore, если отсутствует в кеше ---
    if (userId != null && promoCode == null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          // Безопасное извлечение поля 'promoCode'
          promoCode = userDoc.data()?['promoCode'] as String?;

          if (promoCode != null) {
            await prefs.setString('promoCode', promoCode);
          }
        }
      } catch (e) {
        print('Ошибка при загрузке promoCode из Firestore: $e');
        // Ошибка Firestore не должна блокировать вход, если это не критично.
        // Но здесь мы будем считать, что он нужен.
      }
    }
    // --------------------------------------------------------------------

    // --- 3. Проверка аутентификации и перенаправление ---
    if (userId == null || promoCode == null) {
      // Если данные не получены, пользователь не аутентифицирован или данные неполные.
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
      return; // Прерываем дальнейшее выполнение
    }

    // --- 4. Успешная загрузка и инициализация ---
    setState(() {
      _userId = userId;
      _promoCode = promoCode; // Теперь у нас есть оба поля

      _pages = [
        HomePage(userId: _userId!),
        HistoryPage(
            promoCode: _promoCode!), // <-- Передаем promoCode в HistoryPage
        DocumentsPage(),
        ProfileItems(companyId: _userId!),
      ];
      _isLoading = false; // Загрузка завершена
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('promoCode'); // Удаляем и promoCode при выходе

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Используем _isLoading для отображения индикатора
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Если загрузка завершена, _pages гарантированно инициализирован
    return Scaffold(
      appBar: CustomAppBar(
        title:
            AppLocalizations.of(context)!.translate('employee_dashboard'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.translate('home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: AppLocalizations.of(context)!.translate('history')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.file_copy),
              label: AppLocalizations.of(context)!.translate('documents')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppLocalizations.of(context)!.translate('profile')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.cyan,
        onTap: _onItemTapped,
      ),
    );
  }
}

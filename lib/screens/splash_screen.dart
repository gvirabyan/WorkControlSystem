import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pot/screens/company_dashboard/company_dashboard_screen.dart';
import 'package:pot/screens/employee_dashboard/employee_dashboard_screen.dart';
import 'package:pot/services/auth_service.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );

    _controller.forward();
    _audioPlayer.play(AssetSource('sound.mp3'));

    _checkSession();
  }

  void _checkSession() async {
    await Future.delayed(const Duration(seconds: 5));

    // Проверка, авторизован ли пользователь
    final user = await _authService.checkCurrentUser();

    if (mounted) { // Проверка, что виджет все еще в дереве
      if (user != null) {
        final userType = user['userType'];
        if (userType == 'company') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CompanyDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmployeeDashboard()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: SvgPicture.asset(
            'assets/logo.svg',
            width: 150,
            height: 150,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

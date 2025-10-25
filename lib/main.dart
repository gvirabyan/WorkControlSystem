import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:pot/screens/splash_screen.dart';
import 'package:pot/screens/welcome_screen.dart';
import 'package:pot/screens/login_screen.dart';
import 'package:pot/screens/register_screen.dart';
import 'package:pot/screens/company_dashboard/company_dashboard_screen.dart';
import 'package:pot/screens/employee_dashboard/employee_dashboard_screen.dart';
import 'package:pot/screens/company_dashboard/graphic/employee_data_table.dart';
import 'package:pot/services/firebase_messaging_service.dart';

/// Обработчик background уведомлений (должен быть top-level!)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Регистрация background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // App Check защита


  // Инициализация Firebase Messaging
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();

  // Получение токена
  final String? token = await firebaseMessagingService.getToken();
  debugPrint('🔥 Firebase Messaging Token: $token');



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skin Firts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegisterScreen(),
        '/company': (context) => const CompanyDashboard(),
        '/employee': (context) => const EmployeeDashboard(),
        '/graphics': (context) => const GraphicsScreen(),
      },
    );
  }
}

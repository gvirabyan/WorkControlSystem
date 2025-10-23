import 'package:pot/screens/company_dashboard/company_dashboard_screen.dart';
import 'package:pot/screens/company_dashboard/graphic/employee_data_table.dart';
import 'package:pot/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/employee_dashboard/employee_dashboard_screen.dart';
import 'package:pot/services/firebase_messaging_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Инициализация Firebase Messaging
  // final FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService();
  // await firebaseMessagingService.initialize();
  //
  // // Получение токена устройства
  // final String? token = await firebaseMessagingService.getToken();
  // print('Firebase Messaging Token: $token');

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

      // ✅ маршруты
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

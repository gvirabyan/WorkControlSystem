import 'package:pot/screens/company_dashboard/company_dashboard_screen.dart';
import 'package:pot/screens/company_dashboard/graphics_screen.dart';
import 'package:pot/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/employee_dashboard/employee_dashboard_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://vfeyzxfbyrdffnvabfms.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmZXl6eGZieXJkZmZudmFiZm1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2ODU4OTUsImV4cCI6MjA3NTI2MTg5NX0.9c1aFHXS4QSQTcazpRYE80LxPGhCSNFkc6Tdcl1dfbo',        // вставь сюда anon public key
  );
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

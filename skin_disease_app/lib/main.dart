import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/firebase_options.dart';
import 'package:skin_disease_app/screens/splash_screen.dart';
import 'package:skin_disease_app/screens/login_screen.dart';
import 'package:skin_disease_app/screens/register_screen.dart';
import 'package:skin_disease_app/screens/home_screen.dart';
import 'package:skin_disease_app/screens/test_login_screen.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/services/disease_service.dart';
import 'package:skin_disease_app/services/appointment_service.dart';
import 'package:skin_disease_app/services/article_service.dart';
import 'package:skin_disease_app/utils/theme.dart';
import 'package:skin_disease_app/wrappers/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue with limited functionality
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DiseaseService()),
        ChangeNotifierProvider(create: (_) => AppointmentService()),
        ChangeNotifierProvider(create: (_) => ArticleService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'DermAssist',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/auth': (context) => const AuthWrapper(),
              '/test_login': (context) => const TestLoginScreen(),
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/firebase_options.dart';
import 'package:skin_disease_app/screens/splash_screen.dart';
import 'package:skin_disease_app/screens/login_screen.dart';
import 'package:skin_disease_app/screens/register_screen.dart';
import 'package:skin_disease_app/screens/home_screen.dart';
import 'package:skin_disease_app/screens/profile_screen.dart';
import 'package:skin_disease_app/screens/appointments_screen.dart';
import 'package:skin_disease_app/screens/medical_history_screen.dart';
import 'package:skin_disease_app/screens/article_screen.dart';
import 'package:skin_disease_app/screens/article_detail_screen.dart';
import 'package:skin_disease_app/screens/dermatologist_screen.dart';
import 'package:skin_disease_app/screens/disease_detection_screen.dart';
import 'package:skin_disease_app/screens/chatbot_screen.dart';
import 'package:skin_disease_app/screens/saved_articles_screen.dart';
import 'package:skin_disease_app/screens/settings_screen.dart';
import 'package:skin_disease_app/screens/privacy_policy_screen.dart';
import 'package:skin_disease_app/screens/terms_of_service_screen.dart';
import 'package:skin_disease_app/screens/doctor_detail_screen.dart';
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
    // Show a user-friendly message or fallback to local data
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
            debugShowCheckedModeBanner: false, // No debug banner in UI
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
              '/profile': (context) => const ProfileScreen(),
              '/appointments': (context) => const AppointmentsScreen(),
              '/medical_history': (context) => const MedicalHistoryScreen(),
              '/articles': (context) => const ArticleScreen(),
              '/saved_articles': (context) => const SavedArticlesScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/privacy_policy': (context) => const PrivacyPolicyScreen(),
              '/terms_of_service': (context) => const TermsOfServiceScreen(),
              '/dermatologists': (context) => const DermatologistScreen(),
              '/disease_detection': (context) => const DiseaseDetectionScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/article_detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(
                    articleId: args['articleId'],
                  ),
                );
              } else if (settings.name == '/doctor_detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => DoctorDetailScreen(
                    doctorId: args['doctorId'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

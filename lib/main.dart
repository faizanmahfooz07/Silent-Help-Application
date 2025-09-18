import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_application/contact_setup_screen.dart';
import 'package:silent_application/history_screen.dart';
import 'package:silent_application/home_screen.dart';
import 'package:silent_application/location_screen.dart';
import 'package:silent_application/login_screen.dart';
import 'package:silent_application/register_screen.dart';
import 'package:silent_application/settings_screen.dart';
import 'package:silent_application/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool runInBackground = prefs.getBool('run_in_background') ?? true;

  if (runInBackground) {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Silent Help Active",
      notificationText: "Listening for emergency commands...",
      notificationImportance: AndroidNotificationImportance.high,
      enableWifiLock: true,
    );

    final hasPermission = await FlutterBackground.initialize(androidConfig: androidConfig);
    if (hasPermission) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }

  runApp(const SilentHelpApp());
}

class SilentHelpApp extends StatelessWidget {
  const SilentHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent Help',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/contacts': (context) => const ContactSetupScreen(),
        '/location': (context) => const LocationScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

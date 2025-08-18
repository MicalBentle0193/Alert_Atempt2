import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wynford_weather_alerts/screens/home_screen.dart';
import 'package:wynford_weather_alerts/screens/login_screen.dart';
import 'package:wynford_weather_alerts/services/alert_service.dart';
import 'package:wynford_weather_alerts/services/auth_service.dart';
import 'package:wynford_weather_alerts/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const WynfordApp());
}

class WynfordApp extends StatelessWidget {
  const WynfordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.grey,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1C1C1C),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF111111),
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AlertService()),
      ],
      child: MaterialApp(
        title: 'Wynford Weather Alerts',
        theme: darkTheme,
        home: const RootRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (_, auth, __) {
        if (auth.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

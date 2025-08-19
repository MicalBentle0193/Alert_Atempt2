import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/alert_provider.dart';
import 'services/api_service.dart';
import 'services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WynfordApp());
}

class WynfordApp extends StatelessWidget {
  const WynfordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService(serverBase: 'http://localhost:8080');
    final storage = LocalStorageService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlertProvider(api: api, storage: storage)),
      ],
      child: MaterialApp(
        title: 'Wynford Weather Mission',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

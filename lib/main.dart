import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/services/firebase_service.dart';
import 'src/services/notification_service.dart';
import 'src/services/auth_service.dart';
import 'src/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services
  await FirebaseService.initialize();
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService.instance),
        Provider<FirestoreService>(create: (_) => FirestoreService.instance),
        Provider<NotificationService>(create: (_) => NotificationService.instance),
      ],
      child: const WynfordApp(),
    ),
  );
}

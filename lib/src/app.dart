import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/public_dashboard.dart';

class WynfordApp extends StatelessWidget {
  const WynfordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wynford Weather Mission',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const Root(),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snap.data;
        if (user == null) {
          return const LoginScreen();
        }

        // For demo: use a simple custom claim-like field via Firestore user doc
        // The FirestoreService will fetch the role; for simplicity we read a field in the user doc.
        return FutureBuilder<String?>(
          future: _getRole(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final role = roleSnap.data ?? 'public';
            if (role == 'admin') {
              return const AdminDashboard();
            } else {
              return const PublicDashboard();
            }
          },
        );
      },
    );
  }

  Future<String?> _getRole(String uid) async {
    // Read simple role from Firestore users collection
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    } catch (_) {}
    return 'public';
  }
}

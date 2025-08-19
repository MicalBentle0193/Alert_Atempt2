import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'user_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  static const adminPin = '4729'; // Hardcoded admin PIN per requirements

  bool _isAdmin = false;
  String? _error;

  void _tryAdminLogin() {
    setState(() {
      _error = null;
    });
    if (_pinController.text.trim() == adminPin) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboard()));
    } else {
      setState(() {
        _error = 'Incorrect PIN';
      });
    }
  }

  void _guestContinue() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserHome()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wynford Weather Mission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Welcome to Wynford Weather Mission',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _guestContinue,
              icon: const Icon(Icons.location_on),
              label: const Text('Continue as Guest (Set ZIPs)'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Admin Access', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter admin PIN',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _tryAdminLogin,
              child: const Text('Login as Admin'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Admins can issue warnings, schedule alerts, and view statistics.\nGuests receive alerts by ZIP code.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

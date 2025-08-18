import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isRegister = false;
  bool _loading = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Wynford Weather Mission')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_isRegister ? 'Register' : 'Sign In', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onSaved: (v) => _email = v?.trim() ?? '',
                      validator: (v) => (v?.contains('@') ?? false) ? null : 'Enter valid email',
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (v) => _password = v ?? '',
                      validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
                    ),
                    const SizedBox(height: 12),
                    if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : () async {
                        if (!_form.currentState!.validate()) return;
                        _form.currentState!.save();
                        setState(() { _loading = true; _error = ''; });
                        try {
                          if (_isRegister) {
                            await auth.registerWithEmail(_email, _password);
                          } else {
                            await auth.signInWithEmail(_email, _password);
                          }
                        } on FirebaseAuthException catch (e) {
                          setState(() { _error = e.message ?? 'Auth error'; });
                        } finally {
                          setState(() { _loading = false; });
                        }
                      },
                      child: _loading ? const CircularProgressIndicator() : Text(_isRegister ? 'Register' : 'Sign In'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() { _isRegister = !_isRegister; }),
                      child: Text(_isRegister ? 'Have an account? Sign in' : 'No account? Register'),
                    ),
                    const Divider(),
                    const SizedBox(height: 6),
                    Text('Phone Verification', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: _startPhoneFlow,
                      child: const Text('Verify/Sign in with Phone'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startPhoneFlow() {
    showDialog(
      context: context,
      builder: (context) {
        String phone = '';
        String code = '';
        String verificationId = '';
        return AlertDialog(
          title: const Text('Phone Verification'),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone (E.164, e.g. +15551234567)'),
                  onChanged: (v) => phone = v.trim(),
                ),
                const SizedBox(height: 8),
                if (verificationId.isNotEmpty)
                  TextField(
                    decoration: const InputDecoration(labelText: 'Code'),
                    onChanged: (v) => code = v.trim(),
                  ),
              ],
            );
          }),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            TextButton(onPressed: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              if (verificationId.isEmpty) {
                // start verification
                await auth.verifyPhone(
                  phoneNumber: phone,
                  verificationCompleted: (cred) async {
                    try {
                      await auth.signInWithCredential(cred);
                      if (mounted) Navigator.pop(context);
                    } catch (_) {}
                  },
                  verificationFailed: (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
                  },
                  codeSent: (id, token) {
                    verificationId = id;
                    // Rebuild dialog by popping and reopening simpler; for simplicity show a snack
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code sent. Please enter it.')));
                  },
                  codeAutoRetrievalTimeout: (id) {},
                );
              } else {
                // sign in with code
                try {
                  final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                  await auth.signInWithCredential(credential);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
                }
              }
            }, child: const Text('Proceed')),
          ],
        );
      },
    );
  }
}

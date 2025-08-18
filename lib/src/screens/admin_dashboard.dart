import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/warning_model.dart';
import 'warning_management_screen.dart';
import '../widgets/warning_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: () => auth.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WarningManagementScreen())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<WarningModel>>(
        stream: firestore.streamWarnings(onlyActive: false),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final warnings = snap.data ?? [];
          if (warnings.isEmpty) return const Center(child: Text('No warnings yet.'));
          return ListView.builder(
            itemCount: warnings.length,
            itemBuilder: (context, index) {
              final w = warnings[index];
              return WarningCard(
                warning: w,
                onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WarningManagementScreen(edit: w))),
                onDelete: () async {
                  await firestore.deleteWarning(w.id!);
                },
              );
            },
          );
        },
      ),
    );
  }
}

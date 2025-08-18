import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/warning_model.dart';
import '../widgets/warning_card.dart';
import 'radar_screen.dart';

class PublicDashboard extends StatelessWidget {
  const PublicDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wynford - Public'),
        actions: [
          IconButton(onPressed: () => auth.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RadarScreen())),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.map, size: 48),
                    SizedBox(height: 8),
                    Text('View Real-time Radar', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 4),
                    Text('Tap to open the interactive radar map'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: StreamBuilder<List<WarningModel>>(
              stream: firestore.streamWarnings(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final warnings = snap.data ?? [];
                if (warnings.isEmpty) return const Center(child: Text('No active warnings'));
                return ListView.builder(
                  itemCount: warnings.length,
                  itemBuilder: (context, index) {
                    final w = warnings[index];
                    return WarningCard(warning: w);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wynford_weather_alerts/models/alert_model.dart';
import 'package:wynford_weather_alerts/services/alert_service.dart';
import 'package:wynford_weather_alerts/services/auth_service.dart';
import 'package:wynford_weather_alerts/screens/create_alert_screen.dart';
import 'package:wynford_weather_alerts/widgets/alert_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wynford Weather Alerts'),
        actions: [
          if (auth.isLoggedIn)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await auth.logout();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _HeaderBar(isAuthorized: auth.isLoggedIn),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<AlertService>(
                builder: (_, service, __) {
                  final List<WeatherAlert> alerts = service.alerts;
                  if (alerts.isEmpty) {
                    return Center(
                      child: Text(
                        'No alerts yet.\nAuthorized users can create warnings.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, idx) => AlertTile(alert: alerts[idx]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: auth.isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateAlertScreen()),
                );
              },
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.add_alert),
            )
          : null,
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final bool isAuthorized;
  const _HeaderBar({required this.isAuthorized});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Active Warnings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Icon(Icons.fiber_manual_record,
                color: isAuthorized ? Colors.redAccent : Colors.grey, size: 12),
            const SizedBox(width: 6),
            Text(
              isAuthorized ? 'Authorized' : 'View only',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        )
      ],
    );
  }
}

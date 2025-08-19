import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert_model.dart';
import '../widgets/alert_card.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  late AlertProvider provider;
  final _zipController = TextEditingController();
  final _notif = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Initialize provider manually when widget opens
    provider = AlertProvider(
      api: ApiService(serverBase: 'http://localhost:8080'),
      storage: LocalStorageService(),
    );
    provider.init();
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notif.initialize(const InitializationSettings(android: android, iOS: ios));
    // listen via provider already
    provider.addListener(() async {
      if (provider.activeAlerts.isNotEmpty) {
        final newest = provider.activeAlerts.first;
        // send local notification for relevant alerts
        await _notif.show(
          newest.id.hashCode,
          '${newest.type} • ${newest.level}',
          '${newest.confidence} confidence — ${newest.message}',
          const NotificationDetails(
            android: AndroidNotificationDetails('wynford_channel', 'Wynford Alerts', importance: Importance.max, priority: Priority.high),
          ),
          payload: newest.id,
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    provider.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _addZip() {
    final z = _zipController.text.trim();
    if (z.isEmpty) return;
    final list = List<String>.from(provider.subscribedZips);
    if (!list.contains(z)) list.add(z);
    provider.updateZips(list);
    _zipController.clear();
  }

  void _removeZip(String z) {
    final list = List<String>.from(provider.subscribedZips);
    list.remove(z);
    provider.updateZips(list);
  }

  @override
  Widget build(BuildContext context) {
    final zips = provider.subscribedZips;
    final relevant = provider.activeAlerts.where((a) => a.zipCodes.any((z) => zips.contains(z))).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wynford — User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refresh(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: Text('Your ZIP codes', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: zips.map((z) => Chip(label: Text(z), onDeleted: () => _removeZip(z))).toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _zipController,
                            decoration: const InputDecoration(hintText: 'Add ZIP code (e.g., 66002)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(onPressed: _addZip, icon: const Icon(Icons.add)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Text('Active Warnings', style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(height: 6),
            Expanded(
              child: relevant.isEmpty
                  ? const Center(child: Text('No active warnings for your ZIP codes.'))
                  : RefreshIndicator(
                      onRefresh: () async => provider.refresh(),
                      child: ListView.builder(
                        itemCount: relevant.length,
                        itemBuilder: (_, i) => AlertCard(alert: relevant[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

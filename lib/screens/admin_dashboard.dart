import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart';
import '../widgets/alert_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _typeCtrl = TextEditingController(text: 'Tornado');
  final _level = ValueNotifier<String>('Warning');
  final _severity = ValueNotifier<String>('High');
  final _confidence = ValueNotifier<String>('High');
  final _zipsCtrl = TextEditingController();
  final _leadMinCtrl = TextEditingController(text: '0');
  final _messageCtrl = TextEditingController();
  final _server = 'http://localhost:8080';
  static const adminPin = '4729';

  List<WynfordAlert> active = [];

  @override
  void initState() {
    super.initState();
    _fetchActive();
    _messageCtrl.text = _defaultPresetMessage('Tornado');
  }

  String _defaultPresetMessage(String type) {
    switch (type.toLowerCase()) {
      case 'tornado':
        return 'Move to lowest interior floor, away from windows; lie flat in ditch if outside; do not drive.';
      case 'severe thunderstorm':
        return 'Stay indoors, away from windows; avoid electrical appliances; protect from hail.';
      case 'extreme heat':
        return 'Stay indoors during peak hours; hydrate; check on vulnerable neighbors.';
      case 'winter storm':
        return 'Stay indoors; dress in layers; winterize vehicles; avoid ice.';
      case 'flood':
        return 'Move to higher ground; avoid driving in flooded areas; monitor alerts.';
      default:
        return '';
    }
  }

  Future<void> _fetchActive() async {
    final res = await http.get(Uri.parse('$_server/alerts'));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body) as List;
      setState(() {
        active = list.map((e) => WynfordAlert.fromMap(e as Map<String, dynamic>)).toList();
      });
    }
  }

  Future<void> _issueAlert({DateTime? sendAt}) async {
    final zips = _zipsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (zips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one ZIP code')));
      return;
    }
    final body = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': _typeCtrl.text,
      'level': _level.value,
      'severity': _severity.value,
      'confidence': _confidence.value,
      'zipCodes': zips,
      'message': _messageCtrl.text,
      'issuedAt': DateTime.now().toIso8601String(),
      'leadTimeSec': (int.tryParse(_leadMinCtrl.text) ?? 0) * 60,
      'active': true,
      if (sendAt != null) 'sendAt': sendAt.toIso8601String(),
    };
    final res = await http.post(
      Uri.parse('$_server/admin/create'),
      headers: {'Content-Type': 'application/json', 'x-admin-pin': adminPin},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert scheduled/issued successfully')));
      _fetchActive();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${res.body}')));
    }
  }

  Future<void> _pickScheduleAndIssue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 7)));
    if (picked == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
    await _issueAlert(sendAt: dt);
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _zipsCtrl.dispose();
    _messageCtrl.dispose();
    _leadMinCtrl.dispose();
    _level.dispose();
    _severity.dispose();
    _confidence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetTypes = ['Tornado', 'Severe Thunderstorm', 'Extreme Heat', 'Winter Storm', 'Flood'];
    final levels = ['Warning', 'Watch'];
    final severities = ['High', 'Medium', 'Low'];
    final confidences = ['High', 'Medium', 'Low'];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: Text('Issue / Schedule Alert', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _typeCtrl.text,
                      items: presetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          _typeCtrl.text = v;
                          _messageCtrl.text = _defaultPresetMessage(v);
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Alert Type'),
                    ),
                    Row(
                      children: [
                        Expanded(child: DropdownButtonFormField<String>(value: _level.value, items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(), onChanged: (v) => _level.value = v ?? 'Warning', decoration: const InputDecoration(labelText: 'Level'))),
                        const SizedBox(width: 8),
                        Expanded(child: DropdownButtonFormField<String>(value: _severity.value, items: severities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => _severity.value = v ?? 'High', decoration: const InputDecoration(labelText: 'Severity'))),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: _confidence.value,
                      items: confidences.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => _confidence.value = v ?? 'High',
                      decoration: const InputDecoration(labelText: 'Confidence'),
                    ),
                    TextField(controller: _zipsCtrl, decoration: const InputDecoration(labelText: 'Affected ZIPs (comma separated)')),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _leadMinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Lead time (minutes)'))),
                        const SizedBox(width: 8),
                        Expanded(child: ElevatedButton(onPressed: _pickScheduleAndIssue, child: const Text('Schedule'))),
                      ],
                    ),
                    TextField(controller: _messageCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Safety message / details')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: () => _issueAlert(), icon: const Icon(Icons.send), label: const Text('Issue Now')),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: _fetchActive, child: const Text('Refresh Dashboard')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Active Warnings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...active.map((a) => AlertCard(alert: a)).toList(),
          ],
        ),
      ),
    );
  }
}

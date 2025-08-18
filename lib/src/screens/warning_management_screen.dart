import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warning_model.dart';
import '../services/firestore_service.dart';

class WarningManagementScreen extends StatefulWidget {
  final WarningModel? edit;
  const WarningManagementScreen({super.key, this.edit});

  @override
  State<WarningManagementScreen> createState() => _WarningManagementScreenState();
}

class _WarningManagementScreenState extends State<WarningManagementScreen> {
  final _form = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _severity = 'warning';
  bool _active = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) {
      final e = widget.edit!;
      _title = e.title;
      _description = e.description;
      _severity = e.severity;
      _active = e.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.edit == null ? 'Create Warning' : 'Edit Warning')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (v) => _title = v ?? '',
                validator: (v) => (v?.isNotEmpty ?? false) ? null : 'Enter title',
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                onSaved: (v) => _description = v ?? '',
                validator: (v) => (v?.isNotEmpty ?? false) ? null : 'Enter description',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _severity,
                items: const [
                  DropdownMenuItem(value: 'info', child: Text('Info')),
                  DropdownMenuItem(value: 'advisory', child: Text('Advisory')),
                  DropdownMenuItem(value: 'watch', child: Text('Watch')),
                  DropdownMenuItem(value: 'warning', child: Text('Warning')),
                ],
                onChanged: (v) => setState(() { _severity = v ?? 'warning'; }),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
              SwitchListTile(
                value: _active,
                onChanged: (v) => setState(() { _active = v; }),
                title: const Text('Active'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : () async {
                  if (!_form.currentState!.validate()) return;
                  _form.currentState!.save();
                  setState(() { _loading = true; });
                  final w = WarningModel(
                    id: widget.edit?.id,
                    title: _title,
                    description: _description,
                    severity: _severity,
                    timestamp: DateTime.now().toUtc(),
                    active: _active,
                  );
                  try {
                    if (widget.edit == null) {
                      await firestore.createWarning(w);
                      // Also write to notifications collection for Cloud Function to pick up
                      await firestore.sendNotificationPayload({
                        'title': w.title,
                        'body': w.description,
                        'severity': w.severity,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    } else {
                      await firestore.updateWarning(w);
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                  } finally {
                    setState(() { _loading = false; });
                  }
                },
                child: _loading ? const CircularProgressIndicator() : Text(widget.edit == null ? 'Create & Notify' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

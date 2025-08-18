import 'package:flutter/material.dart';
import '../models/warning_model.dart';
import 'package:intl/intl.dart';

class WarningCard extends StatelessWidget {
  final WarningModel warning;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WarningCard({super.key, required this.warning, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color severityColor() {
      switch (warning.severity) {
        case 'warning':
          return Colors.red.shade700;
        case 'watch':
          return Colors.orange.shade700;
        case 'advisory':
          return Colors.yellow.shade800;
        default:
          return Colors.blueGrey;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: severityColor(), child: const Icon(Icons.warning, color: Colors.white)),
        title: Text(warning.title),
        subtitle: Text(warning.description),
        trailing: Wrap(
          spacing: 8,
          children: [
            Text(DateFormat.yMd().add_jm().format(warning.timestamp.toLocal())),
            if (onEdit != null) IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            if (onDelete != null) IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

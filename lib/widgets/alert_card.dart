import 'package:flutter/material.dart';
import '../models/alert_model.dart';

Color _colorForSeverity(String severity) {
  switch (severity.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.yellow.shade700;
    default:
      return Colors.grey;
  }
}

class AlertCard extends StatelessWidget {
  final WynfordAlert alert;
  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _colorForSeverity(alert.severity);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(alert.level.substring(0, 1)),
        ),
        title: Text('${alert.type} • ${alert.level}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confidence: ${alert.confidence}'),
            const SizedBox(height: 4),
            Text(
              alert.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: alert.zipCodes.map((z) => Chip(label: Text(z))).toList(),
            ),
          ],
        ),
        trailing: Text(
          '${alert.issuedAt.toLocal()}'.split('.')[0],
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}

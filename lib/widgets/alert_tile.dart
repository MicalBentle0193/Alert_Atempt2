import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wynford_weather_alerts/models/alert_model.dart';

class AlertTile extends StatelessWidget {
  final WeatherAlert alert;
  const AlertTile({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().add_jm().format(alert.createdAt);
    return Card(
      color: const Color(0xFF161616),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('By ${alert.author}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

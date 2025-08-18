import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Center over continental US as example
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Radar')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(39.8283, -98.5795),
          zoom: 4.0,
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.wynford_weather_mission',
          ),
          // Example radar overlay using RainViewer tiles.
          // RainViewer requires building correct timestamps for real data; this example uses the newest layer (0)
          TileLayer(
            urlTemplate: 'https://tilecache.rainviewer.com/v2/radar/0/256/{z}/{x}/{y}/2/1_1.png',
            opacity: 0.6,
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

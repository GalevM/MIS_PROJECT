import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeoapifyMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const GeoapifyMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_KEY'];
    return Scaffold(
      appBar: AppBar(title: const Text("Geoapify Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude), // исправено
          initialZoom: 14,                            // исправено
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=$apiKey",
            userAgentPackageName: 'com.example.mis_project',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 40,
                height: 40,
                child: const Icon( // исправено: child наместо builder
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

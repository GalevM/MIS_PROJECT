import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class PublicMapPage extends StatefulWidget {
  const PublicMapPage({super.key});

  @override
  State<PublicMapPage> createState() => _PublicMapPageState();
}

class _PublicMapPageState extends State<PublicMapPage> {
  final List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("reports")
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lat = data["latitude"];
      final lng = data["longitude"];

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: Tooltip(
            message: "${data["category"]} - ${data["status"]}",
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_KEY'];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Јавна Мапа"),
        leading: BackButton(
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(41.9981, 21.4254), // Скопје како default
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=$apiKey",
            userAgentPackageName: 'finki.uki.mk.mis_project',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

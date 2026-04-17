import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String geoapifyKey;

  const MapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.geoapifyKey,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  String? mapUrl;

  @override
  void initState() {
    super.initState();
    mapUrl =
        "https://maps.geoapify.com/v1/staticmap?style=osm-carto&width=600&height=400&center=lonlat:${widget.longitude},${widget.latitude}&zoom=14&apiKey=${widget.geoapifyKey}";
  }

  @override
  Widget build(BuildContext context) {
    return mapUrl != null ? Image.network(mapUrl!) : const SizedBox.shrink();
  }
}

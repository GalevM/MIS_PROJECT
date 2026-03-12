import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class ReportProblemPage extends ConsumerStatefulWidget {
  const ReportProblemPage({super.key});

  @override
  ConsumerState<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends ConsumerState<ReportProblemPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _category;
  double? latitude;
  double? longitude;
  final TextEditingController _descriptionController = TextEditingController();

  String? get staticMapUrl {
    if (latitude == null || longitude == null) return null;
    final apiKey = dotenv.env['GEOAPIFY_KEY'];
    return "https://maps.geoapify.com/v1/staticmap"
        "?style=osm-carto&width=600&height=400"
        "&center=lonlat:$longitude,$latitude"
        "&zoom=14"
        "&marker=lonlat:$longitude,$latitude;color:%23ff0000;size:medium"
        "&apiKey=$apiKey";
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<String> uploadImage(File image) async {
    final id = const Uuid().v4();
    final ref = FirebaseStorage.instance.ref().child("reports/$id.jpg");
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> submitReport() async {
    final description = _descriptionController.text;
    if (_category == null || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Пополнете ги сите полиња")));
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? imageUrl;
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      final id = const Uuid().v4();
      await FirebaseFirestore.instance.collection("reports").doc(id).set({
        "id": id,
        "userId": user?.uid,
        "category": _category,
        "description": description,
        "imageUrl": imageUrl ?? "",
        "status": "received",
        "latitude": latitude,
        "longitude": longitude,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пријавата е успешно испратена")),
      );

      setState(() {
        _image = null;
        _category = null;
        _descriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Грешка: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEOAPIFY_KEY'];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Пријави проблем"),
        leading: BackButton(
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 200),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Додади слика"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: "pothole", child: Text("Дупка на пат")),
                DropdownMenuItem(value: "garbage", child: Text("Губре")),
                DropdownMenuItem(value: "light", child: Text("Улично светло")),
                DropdownMenuItem(value: "dump", child: Text("Дива депонија")),
              ],
              onChanged: (value) => setState(() => _category = value),
              decoration: const InputDecoration(
                labelText: "Категорија",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Опис на проблемот",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Geoapify Map
            if (latitude != null && longitude != null)
              SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude!, longitude!),
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=$apiKey",
                      userAgentPackageName: 'finki.uki.mk.mis_project',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude!, longitude!),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitReport,
                child: const Text("Поднеси"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

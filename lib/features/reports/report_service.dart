import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import 'report_model.dart';

class ReportService {
  final _firestore = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryPublic(
    'dyaslvgbs',
    'mis_project',
    cache: false,
  );

  Future<String> uploadImage(File file) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'reports',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadImages(List<File> files) async {
    final List<String> imageUrls = [];

    for (final file in files) {
      final url = await uploadImage(file);
      imageUrls.add(url);
    }

    return imageUrls;
  }

  Future<void> submitReport(ReportModel report) async {
    await _firestore.collection('reports').doc(report.id).set(report.toMap());
  }

  Stream<List<ReportModel>> getUserReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReportModel.fromMap(doc.data()))
              .toList();
        });
  }
}

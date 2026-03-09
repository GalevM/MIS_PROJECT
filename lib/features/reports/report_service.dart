import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'report_model.dart';

class ReportService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadImage(File file) async {
    final id = _uuid.v4();

    final ref = _storage.ref().child('reports/$id.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
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
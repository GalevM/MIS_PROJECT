import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/report_model.dart';
import '../../core/themes/app_constants.dart';
import '../auth/auth_provider.dart';

// All public reports (for map)
final allReportsProvider = StreamProvider<List<ReportModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ReportModel.fromFirestore).toList());
});

// My reports
final myReportsProvider = StreamProvider<List<ReportModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ReportModel.fromFirestore).toList());
});

// Single report
final reportByIdProvider = StreamProvider.family<ReportModel?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? ReportModel.fromFirestore(s) : null);
});

// Stats
final reportsStatsProvider = StreamProvider<Map<String, int>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .snapshots()
      .map((s) {
    int received = 0, inProgress = 0, resolved = 0;
    for (final doc in s.docs) {
      final status = doc.data()['status'] as String? ?? '';
      if (status == 'received') received++;
      else if (status == 'in_progress') inProgress++;
      else if (status == 'resolved') resolved++;
    }
    return {'received': received, 'in_progress': inProgress, 'resolved': resolved};
  });
});

// Report category filter
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final statusFilterProvider = StateProvider<String?>((ref) => null);

// Filtered reports for map
final filteredReportsProvider = Provider<AsyncValue<List<ReportModel>>>((ref) {
  final all = ref.watch(allReportsProvider);
  final catFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  return all.whenData((reports) => reports.where((r) {
    if (catFilter != null && r.category != catFilter) return false;
    if (statusFilter != null && r.status != statusFilter) return false;
    return true;
  }).toList());
});

// Submit report action
class ReportNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> submitReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required List<File> images,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Не сте најавени.');

      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCol)
          .doc(user.uid)
          .get();
      final fullName = userDoc.data()?['fullName'] ?? 'Анонимен';

      // Upload images
      final imageUrls = <String>[];
      for (final img in images) {
        final fileName = '${const Uuid().v4()}.jpg';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child(AppConstants.reportImagesPath) // e.g. "reports/images"
            .child(fileName);

        final uploadTask = storageRef.putFile(
          img,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final snapshot = await uploadTask.whenComplete(() {});
        if (snapshot.state != TaskState.success) {
          throw Exception('Upload не успеа за ${img.path}');
        }
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Create report doc
      final docRef = FirebaseFirestore.instance.collection(AppConstants.reportsCol).doc();
      final report = ReportModel(
        id: docRef.id,
        userId: user.uid,
        userFullName: fullName,
        category: category,
        description: description,
        status: AppConstants.statusReceived,
        latitude: latitude,
        longitude: longitude,
        address: address,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );
      await docRef.set(report.toFirestore());

      // Award points
      await addPoints(user.uid, AppConstants.pointsReport);

      state = const AsyncData(null);
      return docRef.id;
    } catch (e, s) {
      state = AsyncError(e, s);
      rethrow;
    }
  }
}

final reportNotifierProvider = AsyncNotifierProvider<ReportNotifier, void>(ReportNotifier.new);

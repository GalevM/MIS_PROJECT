import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../../core/models/report_model.dart';
import '../../core/themes/app_constants.dart';
import '../auth/auth_provider.dart';

final allReportsProvider = StreamProvider<List<ReportModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ReportModel.fromFirestore).toList());
});

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

final reportByIdProvider = StreamProvider.family<ReportModel?, String>((
  ref,
  id,
) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? ReportModel.fromFirestore(s) : null);
});

final reportsStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final col = FirebaseFirestore.instance.collection(AppConstants.reportsCol);
  final results = await Future.wait([
    col.where('status', isEqualTo: 'received').count().get(),
    col.where('status', isEqualTo: 'in_progress').count().get(),
    col.where('status', isEqualTo: 'resolved').count().get(),
  ]);
  return {
    'received': results[0].count ?? 0,
    'in_progress': results[1].count ?? 0,
    'resolved': results[2].count ?? 0,
  };
});

final categoryFilterProvider = StateProvider<String?>((ref) => null);
final statusFilterProvider = StateProvider<String?>((ref) => null);

final filteredReportsProvider = Provider<AsyncValue<List<ReportModel>>>((ref) {
  final all = ref.watch(allReportsProvider);
  final catFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  return all.whenData(
    (reports) => reports.where((r) {
      if (catFilter != null && r.category != catFilter) return false;
      if (statusFilter != null && r.status != statusFilter) return false;
      return true;
    }).toList(),
  );
});

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

      final imageUrls = <String>[];

      if (images.isNotEmpty) {
        final cloudinary = CloudinaryPublic(
          'dyaslvgbs',
          'mis_project',
          cache: false,
        );

        for (final img in images) {
          final response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              img.path,
              resourceType: CloudinaryResourceType.Image,
              folder: 'reports',
            ),
          );
          imageUrls.add(response.secureUrl);
        }
      }

      final docRef = FirebaseFirestore.instance
          .collection(AppConstants.reportsCol)
          .doc();
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

      await addPoints(user.uid, AppConstants.pointsReport);

      state = const AsyncData(null);
      return docRef.id;
    } catch (e, s) {
      state = AsyncError(e, s);
      rethrow;
    }
  }
}

final reportNotifierProvider = AsyncNotifierProvider<ReportNotifier, void>(
  ReportNotifier.new,
);

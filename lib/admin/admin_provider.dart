import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/report_model.dart';
import '../../core/themes/app_constants.dart';
import '../features/auth/auth_provider.dart';

// ─── Role guard ───────────────────────────────────────────────────────────────

final isAdminProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(false);
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCol)
      .doc(user.uid)
      .snapshots()
      .map((s) => s.data()?['role'] == 'admin');
});

// ─── Stats ────────────────────────────────────────────────────────────────────

class AdminStats {
  final int received, inProgress, resolved, totalUsers, totalReports;
  const AdminStats({
    required this.received,
    required this.inProgress,
    required this.resolved,
    required this.totalUsers,
    required this.totalReports,
  });
}

final adminStatsProvider = StreamProvider<AdminStats>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .snapshots()
      .asyncMap((snap) async {
    int received = 0, inProgress = 0, resolved = 0;
    for (final doc in snap.docs) {
      switch (doc.data()['status'] as String? ?? '') {
        case 'received':
          received++;
          break;
        case 'in_progress':
          inProgress++;
          break;
        case 'resolved':
          resolved++;
          break;
      }
    }
    final usersSnap = await FirebaseFirestore.instance
        .collection(AppConstants.usersCol)
        .count()
        .get();
    return AdminStats(
      received: received,
      inProgress: inProgress,
      resolved: resolved,
      totalUsers: usersSnap.count ?? 0,
      totalReports: snap.docs.length,
    );
  });
});

// ─── All reports ──────────────────────────────────────────────────────────────

final adminAllReportsProvider = StreamProvider<List<ReportModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ReportModel.fromFirestore).toList());
});

// ─── Users ────────────────────────────────────────────────────────────────────

final adminUsersProvider =
StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCol)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) =>
      s.docs.map((d) => <String, dynamic>{'id': d.id, ...d.data()}).toList());
});

Future<void> updateUserRole(String uid, String role) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.usersCol)
      .doc(uid)
      .update({'role': role});
}

// ─── Report status update ─────────────────────────────────────────────────────

Future<void> adminUpdateReport({
  required String reportId,
  required String status,
  String? adminNote,
}) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.reportsCol)
      .doc(reportId)
      .update({
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
    if (adminNote != null && adminNote.isNotEmpty) 'adminNote': adminNote,
  });
}

// ─── Notifications ────────────────────────────────────────────────────────────

Future<void> adminCreateNotification({
  required String title,
  required String body,
  required String type,
}) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.notificationsCol)
      .add({
    'title': title,
    'body': body,
    'type': type,
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> adminDeleteNotification(String id) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.notificationsCol)
      .doc(id)
      .delete();
}

// ─── Polls ────────────────────────────────────────────────────────────────────

Future<void> adminCreatePoll({
  required String question,
  required List<String> options,
}) async {
  await FirebaseFirestore.instance.collection(AppConstants.pollsCol).add({
    'question': question,
    'options': options.asMap().entries.map((e) => {
      'id': 'opt${e.key}',
      'text': e.value,
      'votes': 0,
    }).toList(),
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
    'endsAt': null,
  });
}

Future<void> adminTogglePoll(String pollId, bool isActive) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.pollsCol)
      .doc(pollId)
      .update({'isActive': isActive});
}

Future<void> adminDeletePoll(String pollId) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.pollsCol)
      .doc(pollId)
      .delete();
}

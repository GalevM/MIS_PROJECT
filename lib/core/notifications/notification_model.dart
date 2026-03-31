import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../themes/app_constants.dart';


class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // water, traffic, event, general
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: d['type'] ?? 'general',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: d['isRead'] ?? false,
    );
  }

  String get typeEmoji => switch (type) {
    'water' => '💧',
    'traffic' => '🚗',
    'event' => '📅',
    'electricity' => '⚡',
    _ => '📢',
  };
}

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.notificationsCol)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(NotificationModel.fromFirestore).toList());
});

final unreadNotifCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).valueOrNull
      ?.where((n) => !n.isRead).length ?? 0;
});
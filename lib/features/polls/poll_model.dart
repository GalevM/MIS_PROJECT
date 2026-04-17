import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/app_constants.dart';
import '../auth/auth_provider.dart';

class PollOption {
  final String id;
  final String text;
  final int votes;

  const PollOption({required this.id, required this.text, required this.votes});

  factory PollOption.fromMap(Map<String, dynamic> m) => PollOption(
    id: m['id'] ?? '',
    text: m['text'] ?? '',
    votes: (m['votes'] ?? 0) as int,
  );

  Map<String, dynamic> toMap() => {'id': id, 'text': text, 'votes': votes};
}

class PollModel {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endsAt;

  const PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.isActive,
    required this.createdAt,
    this.endsAt,
  });

  factory PollModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PollModel(
      id: doc.id,
      question: d['question'] ?? '',
      options: (d['options'] as List<dynamic>? ?? [])
          .map((o) => PollOption.fromMap(o as Map<String, dynamic>))
          .toList(),
      isActive: d['isActive'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endsAt: (d['endsAt'] as Timestamp?)?.toDate(),
    );
  }

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);
}

final pollsProvider = StreamProvider<List<PollModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.pollsCol)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(PollModel.fromFirestore).toList());
});

final pollByIdProvider = StreamProvider.family<PollModel?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(AppConstants.pollsCol)
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? PollModel.fromFirestore(s) : null);
});

final hasVotedProvider = FutureProvider.family<String?, String>((
  ref,
  pollId,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance
      .collection(AppConstants.pollsCol)
      .doc(pollId)
      .collection(AppConstants.pollVotesCol)
      .doc(user.uid)
      .get();
  if (!doc.exists) return null;
  return doc.data()?['optionId'] as String?;
});

Future<void> voteOnPoll({
  required String pollId,
  required String optionId,
  required String uid,
}) async {
  final batch = FirebaseFirestore.instance.batch();

  final voteRef = FirebaseFirestore.instance
      .collection(AppConstants.pollsCol)
      .doc(pollId)
      .collection(AppConstants.pollVotesCol)
      .doc(uid);
  batch.set(voteRef, {
    'optionId': optionId,
    'votedAt': FieldValue.serverTimestamp(),
  });

  await batch.commit();

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final pollRef = FirebaseFirestore.instance
        .collection(AppConstants.pollsCol)
        .doc(pollId);
    final pollSnap = await tx.get(pollRef);
    final data = pollSnap.data()!;
    final options = (data['options'] as List<dynamic>)
        .map((o) => Map<String, dynamic>.from(o as Map))
        .toList();
    for (final o in options) {
      if (o['id'] == optionId) {
        o['votes'] = (o['votes'] as int) + 1;
      }
    }
    tx.update(pollRef, {'options': options});
  });

  await addPoints(uid, AppConstants.pointsVote);
}

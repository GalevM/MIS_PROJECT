import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/themes/app_constants.dart';

// Current user stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user (sync)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Auth notifier
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    });
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = cred.user!.uid;
      await FirebaseFirestore.instance.collection(AppConstants.usersCol).doc(uid).set({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'role': AppConstants.roleUser,
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'fcmToken': null,
      });
      return cred.user;
    });
  }

  Future<void> loginAnonymous() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      return cred.user;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

// User Firestore data
final userDocProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCol)
      .doc(uid)
      .snapshots()
      .map((s) => s.data());
});

// Current user Firestore data
final currentUserDocProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCol)
      .doc(user.uid)
      .snapshots()
      .map((s) => s.data());
});

// Add points helper
Future<void> addPoints(String uid, int points) async {
  await FirebaseFirestore.instance
      .collection(AppConstants.usersCol)
      .doc(uid)
      .update({'points': FieldValue.increment(points)});
}

// Friendly error messages
String friendlyAuthError(FirebaseAuthException e) {
  return switch (e.code) {
    'email-already-in-use' => 'Веќе постои акаунт со тој e-маил.',
    'invalid-email' => 'Невалидна e-маил адреса.',
    'weak-password' => 'Лозинката е премногу слаба (мин. 6 знаци).',
    'user-not-found' => 'Не постои корисник со тој e-маил.',
    'wrong-password' => 'Погрешна лозинка.',
    'invalid-credential' => 'Погрешен e-маил или лозинка.',
    'user-disabled' => 'Овој акаунт е деактивиран.',
    'too-many-requests' => 'Премногу обиди. Обидете се подоцна.',
    'operation-not-allowed' => 'Операцијата не е дозволена.',
    _ => 'Настана грешка. Обидете се повторно.',
  };
}
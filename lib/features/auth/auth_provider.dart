import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authState;
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
      (ref) => AuthNotifier(ref.watch(authServiceProvider)),
    );

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signIn(email, password);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.register(fullName, email, password);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  final userDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  });
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});
//
//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   String? _errorMessage;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   String _friendlyError(FirebaseAuthException e) {
//     return switch (e.code) {
//       'email-already-in-use' => 'Веќе постои акаунт со тој e-маил.',
//       'invalid-email' => 'Невалидна e-маил адреса.',
//       'weak-password' => 'Лозинката е премногу слаба (мин. 6 знаци).',
//       'operation-not-allowed' => 'Регистрацијата не е овозможена.',
//       _ => 'Регистрацијата неуспешна. Обидете се повторно.',
//     };
//   }
//
//   Future<void> _register() async {
//     setState(() => _errorMessage = null);
//
//     if (_nameController.text.trim().isEmpty) {
//       setState(() => _errorMessage = 'Внесете име и презиме.');
//       return;
//     }
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() => _errorMessage = 'Лозинките не се совпаѓаат.');
//       return;
//     }
//
//     try {
//       final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
//         'fullName': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       if (mounted) {
//         context.go('/home');
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _errorMessage = _friendlyError(e);
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Настана грешка. Обидете се повторно.';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Регистрација',
//           style: GoogleFonts.roboto(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onPrimary,
//           ),
//         ),
//         leading: BackButton(onPressed: () => context.pop()),
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset('lib/assets/logo.png', height: 100),
//               const SizedBox(height: 20),
//
//               Text(
//                 'Регистрација',
//                 style: GoogleFonts.roboto(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Име и презиме',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: theme.cardColor,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'E-маил',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: theme.cardColor,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Лозинка',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: theme.cardColor,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 16),
//
//               TextField(
//                 controller: _confirmPasswordController,
//                 decoration: InputDecoration(
//                   labelText: 'Потврди лозинка',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: theme.cardColor,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 12),
//
//               if (_errorMessage != null)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red.shade200),
//                   ),
//                   child: Text(
//                     _errorMessage!,
//                     style: GoogleFonts.roboto(
//                       color: Colors.red.shade700,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//
//               const SizedBox(height: 20),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: _register,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.secondary,
//                     foregroundColor: theme.colorScheme.onSecondary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 4,
//                     textStyle: GoogleFonts.roboto(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   child: const Text('Регистрирај се'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               TextButton(
//                 onPressed: () => context.push('/login'),
//                 child: Text(
//                   'Веќе имате кориснички профил? Најавете се',
//                   style: GoogleFonts.roboto(
//                     color: theme.colorScheme.primary,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_provider.dart';


class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _error = null);
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Внесете име и презиме.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Лозинките не се совпаѓаат.');
      return;
    }
    await ref.read(authNotifierProvider.notifier).register(
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
    final state = ref.read(authNotifierProvider);
    state.whenOrNull(
      error: (e, _) => setState(() {
        _error = e is FirebaseAuthException ? friendlyAuthError(e) : 'Настана грешка.';
      }),
      data: (u) { if (u != null && mounted) context.go('/home'); },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрација'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Креирајте нов профил', style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ))),
              Center(child: Text('Пополнете ги следните полиња', style: GoogleFonts.nunito(
                fontSize: 14, color: Colors.grey[600],
              ))),
              const SizedBox(height: 28),

              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Име и презиме',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-маил',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Лозинка',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                onSubmitted: (_) => _register(),
                decoration: const InputDecoration(
                  labelText: 'Потврди лозинка',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 14),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: GoogleFonts.nunito(
                        color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w600,
                      ))),
                    ],
                  ),
                ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Регистрирај се'),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Веќе имате профил? ', style: GoogleFonts.nunito(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text('Најавете се', style: GoogleFonts.nunito(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

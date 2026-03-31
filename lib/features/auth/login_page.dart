// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import 'auth_provider.dart';
//
// class LoginPage extends ConsumerStatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   ConsumerState<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends ConsumerState<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   String? _errorMessage;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   String _friendlyError(FirebaseAuthException e) {
//     return switch (e.code) {
//       'user-not-found' => 'Не постои корисник со тој e-маил.',
//       'wrong-password' => 'Погрешна лозинка.',
//       'invalid-email' => 'Невалидна e-маил адреса.',
//       'invalid-credential' => 'Погрешен e-маил или лозинка.',
//       'user-disabled' => 'Овој акаунт е деактивиран.',
//       'too-many-requests' => 'Премногу обиди. Обидете се подоцна.',
//       _ => 'Најавата неуспешна. Обидете се повторно.',
//     };
//   }
//
//   Future<void> _login() async {
//     setState(() => _errorMessage = null);
//
//     await ref
//         .read(authNotifierProvider.notifier)
//         .login(_emailController.text, _passwordController.text);
//
//     final authState = ref.read(authNotifierProvider);
//     authState.whenOrNull(
//       error: (e, _) {
//         setState(() {
//           _errorMessage = e is FirebaseAuthException
//               ? _friendlyError(e)
//               : 'Настана грешка. Обидете се повторно.';
//         });
//       },
//       data: (_) => context.go('/home'),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isLoading = ref.watch(authNotifierProvider).isLoading;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Најава',
//           style: GoogleFonts.roboto(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onPrimary,
//           ),
//         ),
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset('lib/assets/logo.png', height: 120),
//               const SizedBox(height: 20),
//               Text(
//                 'Добредојдовте!',
//                 style: GoogleFonts.roboto(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'E-маил',
//                   labelStyle: GoogleFonts.roboto(color: Colors.grey[700]),
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
//                   labelStyle: GoogleFonts.roboto(color: Colors.grey[700]),
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
//                   onPressed: isLoading ? null : _login,
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
//                   child: isLoading
//                       ? const SizedBox(
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text('Најави се'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               TextButton(
//                 onPressed: () => context.push('/register'),
//                 child: Text(
//                   'Немате кориснички профил? Регистрирајте се',
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


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = null);
    await ref.read(authNotifierProvider.notifier).login(_emailCtrl.text, _passCtrl.text);
    final state = ref.read(authNotifierProvider);
    state.whenOrNull(
      error: (e, _) => setState(() {
        _error = e is FirebaseAuthException ? friendlyAuthError(e) : 'Настана грешка.';
      }),
      data: (u) { if (u != null && mounted) context.go('/home'); },
    );
  }

  Future<void> _loginAnonymous() async {
    setState(() => _error = null);
    await ref.read(authNotifierProvider.notifier).loginAnonymous();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(height: 1),
                Text('Граѓани + Општина = Решение', style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                )),
                const SizedBox(height: 6),
                Text('Добредојдовте!', style: GoogleFonts.nunito(
                  fontSize: 15, color: Colors.grey[600],
                )),
                const SizedBox(height: 30),

                // Email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-маил',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Лозинка',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Error
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

                const SizedBox(height: 20),

                // Login button
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Најави се'),
                  ),
                ),

                const SizedBox(height: 12),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Немате профил? ', style: GoogleFonts.nunito(color: Colors.grey[600])),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text('Регистрирајте се', style: GoogleFonts.nunito(
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
      ),
    );
  }
}

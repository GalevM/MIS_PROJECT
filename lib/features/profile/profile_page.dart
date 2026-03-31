// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:go_router/go_router.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../auth/auth_provider.dart';
//
// final userDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return null;
//   final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//   return doc.data();
// });
//
//
// class ProfilePage extends ConsumerWidget {
//   const ProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final userData = ref.watch(userDataProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Мој Профил"),
//         leading: BackButton(onPressed: () => context.pop()),
//         centerTitle: true,
//         backgroundColor: theme.colorScheme.primary,
//         foregroundColor: theme.colorScheme.onPrimary,
//         elevation: 2,
//       ),
//       body: userData.when(
//         data: (data) {
//           if (data == null) {
//             return const Center(child: Text("Нема податоци за корисникот"));
//           }
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
//                   child: const Icon(
//                     Icons.person,
//                     size: 60,
//                     color: Color(0xFF006064),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   data['fullName'] ?? '',
//                   style: GoogleFonts.roboto(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   FirebaseAuth.instance.currentUser?.email ?? '',
//                   style: GoogleFonts.roboto(fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//
//                 Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _infoTile("Поени", "120", Colors.blue),
//                         _infoTile("Ранг", "Активен граѓанин", Colors.green),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Историја на Активности",
//                     style: GoogleFonts.roboto(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//
//                 _activityItem("Пријава: Дупка на пат"),
//                 _activityItem("Гласано: Нови канти за ѓубре"),
//
//                 const SizedBox(height: 40),
//
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton.icon(
//                     onPressed: () async {
//                       await ref.read(authNotifierProvider.notifier).logout();
//                       context.go('/login');
//                     },
//                     icon: const Icon(Icons.logout),
//                     label: Text(
//                       'Одјави се',
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red.shade600,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, _) => Center(child: Text("Грешка: $err")),
//       ),
//     );
//   }
//
//   Widget _infoTile(String title, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
//
//   Widget _activityItem(String text) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         leading: const Icon(Icons.check_circle, color: Colors.green),
//         title: Text(
//           text,
//           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/themes/app_theme.dart';
import '../auth/auth_provider.dart';
import '../reports/report_provider.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  String _rankLabel(int points) {
    if (points >= 500) return '🏆 Шампион на општината';
    if (points >= 200) return '⭐ Активен граѓанин';
    if (points >= 50) return '🌱 Почетник';
    return '👤 Нов корисник';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userDoc = ref.watch(currentUserDocProvider);
    final myReports = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мој Профил')),
      body: userDoc.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Грешка: $e')),
        data: (data) {
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('Не сте најавени', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Најави се'),
                  ),
                ],
              ),
            );
          }

          final fullName = data['fullName'] ?? 'Корисник';
          final email = data['email'] ?? '';
          final points = (data['points'] ?? 0) as int;
          final initials = fullName.split(' ')
              .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(child: Text(initials, style: GoogleFonts.nunito(
                          fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                        ))),
                      ),
                      const SizedBox(height: 12),
                      Text(fullName, style: GoogleFonts.nunito(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                      const SizedBox(height: 4),
                      Text(email, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),

                // Points + rank card
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: AppTheme.primary.withOpacity(0.15),
                        blurRadius: 16, offset: const Offset(0, 4),
                      )],
                    ),
                    child: Row(
                      children: [
                        // Points
                        Expanded(
                          child: Column(
                            children: [
                              Text('Поени', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('$points', style: GoogleFonts.nunito(
                                fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary,
                              )),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 50, color: const Color(0xFFECEFF1)),
                        // Rank
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ранг', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(_rankLabel(points), style: GoogleFonts.nunito(
                                  fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                                )),
                                const SizedBox(height: 6),
                                // Progress to next rank
                                _PointsProgress(points: points),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats row
                myReports.when(
                  data: (reports) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _StatMini(label: 'Вкупно', value: reports.length, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        _StatMini(label: 'Решени', value: reports.where((r) => r.status == 'resolved').length, color: AppTheme.success),
                        const SizedBox(width: 10),
                        _StatMini(label: 'Во тек', value: reports.where((r) => r.status == 'in_progress').length, color: AppTheme.secondary),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // Activity history
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Историја на активности', style: GoogleFonts.nunito(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted, letterSpacing: 0.5,
                    )),
                  ),
                ),
                const SizedBox(height: 10),

                myReports.when(
                  data: (reports) {
                    if (reports.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Нема активности', style: GoogleFonts.nunito(color: AppTheme.textMuted)),
                      );
                    }
                    return Column(
                      children: reports.take(5).map((r) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                        ),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: r.status.statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text(r.category.categoryEmoji, style: const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Пријава: ${r.category.categoryLabel}', style: GoogleFonts.nunito(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                )),
                                if (r.address.isNotEmpty)
                                  Text(r.address, style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: r.status.statusBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(r.status.statusLabel, style: GoogleFonts.nunito(
                              fontSize: 10, fontWeight: FontWeight.w800, color: r.status.statusColor,
                            )),
                          ),
                        ]),
                      )).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Settings / actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _ProfileAction(
                        icon: Icons.list_alt_outlined,
                        label: 'Мои пријави',
                        onTap: () => context.go('/my-reports'),
                      ),
                      _ProfileAction(
                        icon: Icons.poll_outlined,
                        label: 'Анкети',
                        onTap: () => context.push('/polls'),
                      ),
                      _ProfileAction(
                        icon: Icons.notifications_outlined,
                        label: 'Известувања',
                        onTap: () => context.go('/notifications'),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(authNotifierProvider.notifier).logout();
                            if (context.mounted) context.go('/login');
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Одјави се'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PointsProgress extends StatelessWidget {
  final int points;
  const _PointsProgress({required this.points});

  @override
  Widget build(BuildContext context) {
    int next;
    if (points < 50) next = 50;
    else if (points < 200) next = 200;
    else if (points < 500) next = 500;
    else return Text('Максимален ранг! 🏆', style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.success));

    final progress = points / next;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: const Color(0xFFECEFF1),
            valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
          ),
        ),
        const SizedBox(height: 3),
        Text('$points / $next поени', style: GoogleFonts.nunito(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text('$value', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
        ]),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700))),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
        ]),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:go_router/go_router.dart';
//
// class PollsPage extends StatefulWidget {
//   const PollsPage({super.key});
//
//   @override
//   State<PollsPage> createState() => _PollsPageState();
// }
//
// class _PollsPageState extends State<PollsPage> {
//   String? _selectedOption;
//
//   final List<String> options = [
//     "Поправка на улици",
//     "Нови канти за ѓубре",
//     "Детски игралишта",
//   ];
//
//   void _submitVote() {
//     if (_selectedOption == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Изберете една опција пред да гласате")),
//       );
//       return;
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Гласот е запишан: $_selectedOption")),
//     );
//
//     setState(() {
//       _selectedOption = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Анкети"),
//         leading: BackButton(
//           onPressed: () {
//             context.pop();
//           },
//         ),
//         centerTitle: true,
//         backgroundColor: theme.colorScheme.primary,
//         foregroundColor: theme.colorScheme.onPrimary,
//         elevation: 2,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Гласај во Анкетата!",
//               style: GoogleFonts.roboto(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Што е приоритет овој месец?",
//               style: GoogleFonts.roboto(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Опции
//             ...options.map((option) {
//               return RadioListTile<String>(
//                 title: Text(option),
//                 value: option,
//                 groupValue: _selectedOption,
//                 activeColor: theme.colorScheme.primary,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedOption = value;
//                   });
//                 },
//               );
//             }).toList(),
//
//             const Spacer(),
//
//             // Vote button
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: _submitVote,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.secondary,
//                   foregroundColor: theme.colorScheme.onSecondary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 4,
//                   textStyle: GoogleFonts.roboto(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 child: const Text("Гласај"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mis_project/features/polls/poll_model.dart';import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/themes/app_theme.dart';



class PollsPage extends ConsumerWidget {
  const PollsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polls = ref.watch(pollsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Анкети'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: polls.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Грешка: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.poll_outlined, size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('Нема активни анкети', style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMuted,
                  )),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final poll = list[i];
              return GestureDetector(
                onTap: () => context.push('/polls/${poll.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: poll.isActive ? AppTheme.primary : AppTheme.textMuted,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.how_to_vote_outlined, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(poll.question, style: GoogleFonts.nunito(
                                fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
                              )),
                            ),
                          ],
                        ),
                      ),
                      // Body
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Options preview (first 2)
                            ...poll.options.take(2).map((o) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(o.text, style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textMuted)),
                                ],
                              ),
                            )),
                            if (poll.options.length > 2)
                              Text('+ ${poll.options.length - 2} повеќе...', style: GoogleFonts.nunito(
                                fontSize: 12, color: AppTheme.textMuted,
                              )),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.how_to_vote_outlined, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text('${poll.totalVotes} гласови', style: GoogleFonts.nunito(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted,
                                )),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: poll.isActive ? AppTheme.successLight : const Color(0xFFECEFF1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    poll.isActive ? 'Активна' : 'Затворена',
                                    style: GoogleFonts.nunito(
                                      fontSize: 11, fontWeight: FontWeight.w800,
                                      color: poll.isActive ? AppTheme.success : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
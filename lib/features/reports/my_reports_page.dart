import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mis_project/features/reports/report_provider.dart';

import '../../core/themes/app_theme.dart';
import '../auth/auth_provider.dart';

class MyReportsPage extends ConsumerWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(myReportsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои Пријави'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/new-report'),
        icon: const Icon(Icons.add),
        label: const Text('Нова пријава'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? _notLoggedIn(context)
          : reports.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Грешка: $e')),
              data: (list) {
                if (list.isEmpty) return _emptyState(context);
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(myReportsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = list[i];
                      final statusColor = r.status.statusColor;
                      final statusBg = r.status.statusBgColor;
                      return GestureDetector(
                        onTap: () => context.push('/report/${r.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border(
                              left: BorderSide(color: statusColor, width: 4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Text(
                                  r.category.categoryEmoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.category.categoryLabel,
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (r.address.isNotEmpty)
                                        Text(
                                          r.address,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: AppTheme.textMuted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              r.status.statusLabel,
                                              style: GoogleFonts.nunito(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat(
                                              'dd.MM.yyyy',
                                            ).format(r.createdAt),
                                            style: GoogleFonts.nunito(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (r.imageUrls.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      r.imageUrls.first,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        Text(
          'Немате пријави',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Притиснете + за да поднесете нова пријава',
          style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    ),
  );

  Widget _notLoggedIn(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outlined, size: 64, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        Text(
          'Треба да сте најавени',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Најави се'),
        ),
      ],
    ),
  );
}

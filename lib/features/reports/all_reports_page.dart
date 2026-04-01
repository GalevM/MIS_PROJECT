import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/themes/app_theme.dart';
import '../auth/auth_provider.dart';
import 'report_provider.dart';

class AllReportsPage extends ConsumerWidget {
  const AllReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сите Пријави'),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Грешка при вчитување: $e'),
              ),
            ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('Нема пријави во моментов'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allReportsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final report = list[index];

                return GestureDetector(
                  onTap: () => context.push('/report/${report.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(
                        color: report.status.statusColor,
                        width: 4,
                      )),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Text(
                            report.category.categoryEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.category.categoryLabel,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (report.address.isNotEmpty)
                                  Text(
                                    report.address,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: AppTheme.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: report.status.statusBgColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        report.status.statusLabel,
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: report.status.statusColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      DateFormat('dd.MM.yyyy').format(
                                          report.createdAt),
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (report.imageUrls.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                report.imageUrls.first,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const SizedBox(width: 56, height: 56),
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
}
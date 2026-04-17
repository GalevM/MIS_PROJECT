import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mis_project/core/themes/app_theme.dart';

import 'admin_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final reports = ref.watch(adminAllReportsProvider);
    final now = DateTime.now();

    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'mk').format(now);

    final date = formattedDate.replaceFirst(
      formattedDate[0],
      formattedDate[0].toUpperCase(),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Преглед на општинaта',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/logo.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: stats.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Грешка: $e'),
              data: (s) {
                final total = s.totalReports == 0 ? 1 : s.totalReports;
                return Row(
                  children: [
                    _StatusCard(
                      label: 'Примено',
                      value: s.received,
                      pct: s.received / total,
                      color: AppTheme.warning,
                      bgColor: AppTheme.warningLight,
                      icon: Icons.inbox_outlined,
                    ),
                    const SizedBox(width: 10),
                    _StatusCard(
                      label: 'Во тек',
                      value: s.inProgress,
                      pct: s.inProgress / total,
                      color: AppTheme.secondary,
                      bgColor: AppTheme.inProgressLight,
                      icon: Icons.timelapse_outlined,
                    ),
                    const SizedBox(width: 10),
                    _StatusCard(
                      label: 'Решено',
                      value: s.resolved,
                      pct: s.resolved / total,
                      color: AppTheme.success,
                      bgColor: AppTheme.successLight,
                      icon: Icons.check_circle_outlined,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionLabel('Брз пристап'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: [
                _ActionTile(
                  icon: Icons.report_outlined,
                  label: 'Пријави',
                  sub: 'Промени статус',
                  color: AppTheme.warning,
                  onTap: () => context.go('/admin/reports'),
                ),
                _ActionTile(
                  icon: Icons.add_alert_outlined,
                  label: 'Известувања',
                  sub: 'До сите граѓани',
                  color: AppTheme.primary,
                  onTap: () => context.go('/admin/notifications'),
                ),
                _ActionTile(
                  icon: Icons.poll_outlined,
                  label: 'Анкети',
                  sub: 'Создај / затвори',
                  color: Colors.purple,
                  onTap: () => context.go('/admin/polls'),
                ),
                _ActionTile(
                  icon: Icons.people_outlined,
                  label: 'Корисници',
                  sub: 'Улоги и поени',
                  color: AppTheme.success,
                  onTap: () => context.go('/admin/users'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('Нови пријави'),
                TextButton(
                  onPressed: () => context.go('/admin/reports'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Сите',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          reports.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Грешка: $e'),
            ),
            data: (all) {
              final pending = all
                  .where((r) => r.status == 'received')
                  .take(6)
                  .toList();
              if (pending.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: AppTheme.success,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Одлично!',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.success,
                              ),
                            ),
                            Text(
                              'Нема нерешени пријави',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: AppTheme.success.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pending.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final r = pending[i];
                  return _PendingCard(
                    emoji: r.category.categoryEmoji,
                    title: r.category.categoryLabel,
                    address: r.address.isNotEmpty ? r.address : 'Нема адреса',
                    name: r.userFullName,
                    date: DateFormat('dd.MM.yyyy · HH:mm').format(r.createdAt),
                    onTap: () => context.push('/admin/report/${r.id}'),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _sectionLabel(String t) => Text(
    t,
    style: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: AppTheme.textMuted,
      letterSpacing: 0.8,
    ),
  );

  static Widget _vDivider() => Container(
    width: 1,
    height: 32,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white24,
  );
}

class _BannerStat extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 16),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int value;
  final double pct;
  final Color color, bgColor;
  final IconData icon;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.pct,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).round()}%',
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PendingCard extends StatelessWidget {
  final String emoji, title, address, name, date;
  final VoidCallback onTap;

  const _PendingCard({
    required this.emoji,
    required this.title,
    required this.address,
    required this.name,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppTheme.warning, width: 4),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 12,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      name,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      date,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Реши',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mis_project/core/models/report_model.dart';
import 'package:mis_project/core/themes/app_theme.dart';

import 'admin_provider.dart';

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});

  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Пребарај пријави...',
              prefixIcon: Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
          ),
        ),
        // Tabs
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle:           GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800),
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: 13),
          tabs: const [
            Tab(text: 'Сите'),
            Tab(text: '🟡 Примено'),
            Tab(text: '🔵 Во тек'),
            Tab(text: '🟢 Решено'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ReportsList(statusFilter: null,          search: _search),
              _ReportsList(statusFilter: 'received',    search: _search),
              _ReportsList(statusFilter: 'in_progress', search: _search),
              _ReportsList(statusFilter: 'resolved',    search: _search),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportsList extends ConsumerWidget {
  final String? statusFilter;
  final String search;
  const _ReportsList({required this.statusFilter, required this.search});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(adminAllReportsProvider);

    return all.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Грешка: $e')),
      data: (list) {
        var items = list;
        if (statusFilter != null) {
          items = items.where((r) => r.status == statusFilter).toList();
        }
        if (search.isNotEmpty) {
          items = items.where((r) =>
          r.category.categoryLabel.toLowerCase().contains(search) ||
              r.address.toLowerCase().contains(search) ||
              r.description.toLowerCase().contains(search) ||
              r.userFullName.toLowerCase().contains(search),
          ).toList();
        }

        if (items.isEmpty) {
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 12),
              Text('Нема пријави', style: GoogleFonts.nunito(color: AppTheme.textMuted, fontSize: 15)),
            ],
          ));
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminAllReportsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) => _ReportTile(
              report: items[i],
              onTap: () => context.push('/admin/report/${items[i].id}'),
            ),
          ),
        );
      },
    );
  }
}

class _ReportTile extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;
  const _ReportTile({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sc = report.status.statusColor;
    final sb = report.status.statusBgColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: sc, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(report.category.categoryEmoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(child: Text(report.category.categoryLabel,
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: sb, borderRadius: BorderRadius.circular(10)),
                  child: Text(report.status.statusLabel,
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: sc)),
                ),
              ]),
              const SizedBox(height: 5),
              if (report.address.isNotEmpty)
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 3),
                  Expanded(child: Text(report.address,
                      style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.person_outline, size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Text(report.userFullName,
                    style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textMuted)),
                const Spacer(),
                Text(DateFormat('dd.MM.yyyy').format(report.createdAt),
                    style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textMuted)),
              ]),
              if (report.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(report.imageUrls[i],
                          width: 54, height: 54, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

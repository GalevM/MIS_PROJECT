import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mis_project/core/themes/app_theme.dart';
import '../../admin/admin_provider.dart';
import '../../core/models/report_model.dart';
import '../../core/themes/app_constants.dart';
import '../reports/report_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _mapController = MapController();
  static const _initialCenter = LatLng(41.9981, 21.4254);

  Color _markerColor(String status) => switch (status) {
    'received' => AppTheme.warning,
    'in_progress' => AppTheme.secondary,
    'resolved' => AppTheme.success,
    _ => AppTheme.textMuted,
  };

  List<Marker> _buildMarkers(List<ReportModel> reports) {
    return reports.map((r) {
      final color = _markerColor(r.status);
      return Marker(
        point: LatLng(r.latitude, r.longitude),
        width: 40,
        height: 50,
        child: GestureDetector(
          onTap: () => _showReportSheet(r),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    r.category.categoryEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Container(width: 2, height: 8, color: color),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showReportSheet(ReportModel r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    r.category.categoryEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.category.categoryLabel,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
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
                            maxLines: 2,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: r.status.statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      r.status.statusLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: r.status.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (r.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  r.description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/report/${r.id}');
                  },
                  child: const Text('Види детали'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(filteredReportsProvider);
    final catFilter = ref.watch(categoryFilterProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Јавна Мапа'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_outlined),
              onPressed: () => context.go('/admin'),
            ),
        ],),

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LegendItem(color: AppTheme.warning, label: 'Примено'),
            _LegendItem(color: AppTheme.secondary, label: 'Во тек'),
            _LegendItem(color: AppTheme.success, label: 'Решено'),
          ],
        ),
      ),

      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: catFilter == null
                      ? 'Сите категории'
                      : catFilter.categoryLabel,
                  icon: Icons.category_outlined,
                  active: catFilter != null,
                  onTap: () => _showCategoryFilter(context, ref),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: statusFilter == null
                      ? 'Сите статуси'
                      : statusFilter.statusLabel,
                  icon: Icons.filter_list_outlined,
                  active: statusFilter != null,
                  onTap: () => _showStatusFilter(context, ref),
                ),
                if (catFilter != null || statusFilter != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ref.read(categoryFilterProvider.notifier).state = null;
                      ref.read(statusFilterProvider.notifier).state = null;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.clear,
                            size: 14,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Исчисти',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: reportsAsync.when(
              data: (reports) => FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 13,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.opstina_app',
                    maxZoom: 19,
                  ),
                  MarkerLayer(markers: _buildMarkers(reports)),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Грешка: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (_, scrollController) => SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Избери категорија',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Text('🔍', style: TextStyle(fontSize: 20)),
                      title: Text(
                        'Сите',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        ref.read(categoryFilterProvider.notifier).state = null;
                        Navigator.pop(context);
                      },
                    ),
                    ...AppConstants.categories.map(
                      (cat) => ListTile(
                        leading: Text(
                          cat['emoji']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          cat['label']!,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () {
                          ref.read(categoryFilterProvider.notifier).state =
                              cat['value'];
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Избери статус',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ListTile(
              leading: const Text('🔍', style: TextStyle(fontSize: 20)),
              title: Text(
                'Сите',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            for (final s in ['received', 'in_progress', 'resolved'])
              ListTile(
                leading: Text(
                  s.statusEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                title: Text(
                  s.statusLabel,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  ref.read(statusFilterProvider.notifier).state = s;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppTheme.primary : const Color(0xFFCFD8DC),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mis_project/core/themes/app_theme.dart';
import 'package:mis_project/features/reports/report_provider.dart';


class ReportDetailPage extends ConsumerWidget {
  final String reportId;
  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(reportByIdProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали за пријава'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Грешка: $e')),
        data: (r) {
          if (r == null) return const Center(child: Text('Пријавата не е пронајдена'));
          final statusColor = r.status.statusColor;
          final statusBg = r.status.statusBgColor;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(r.status.statusEmoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Статус на пријавата', style: GoogleFonts.nunito(
                            fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700,
                          )),
                          Text(r.status.statusLabel, style: GoogleFonts.nunito(
                            fontSize: 18, fontWeight: FontWeight.w800, color: statusColor,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Status timeline
                _StatusTimeline(status: r.status),

                const SizedBox(height: 14),

                // Images
                if (r.imageUrls.isNotEmpty) ...[
                  Text('Слики', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.imageUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(r.imageUrls[i], width: 200, height: 160, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Details card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(icon: Icons.category_outlined, label: 'Категорија',
                          value: '${r.category.categoryEmoji} ${r.category.categoryLabel}'),
                      const Divider(),
                      _DetailRow(icon: Icons.description_outlined, label: 'Опис', value: r.description),
                      const Divider(),
                      _DetailRow(icon: Icons.location_on_outlined, label: 'Локација', value: r.address),
                      const Divider(),
                      _DetailRow(icon: Icons.person_outlined, label: 'Пријавил', value: r.userFullName),
                      const Divider(),
                      _DetailRow(icon: Icons.calendar_today_outlined, label: 'Датум',
                          value: DateFormat('dd.MM.yyyy HH:mm').format(r.createdAt)),
                      if (r.adminNote != null && r.adminNote!.isNotEmpty) ...[
                        const Divider(),
                        _DetailRow(icon: Icons.admin_panel_settings_outlined, label: 'Белешка на општини',
                            value: r.adminNote!),
                      ],
                    ],
                  ),
                ),

                // Map — lazy loaded after page transition to avoid Maps SDK crash
                if (r.latitude != 0 && r.longitude != 0) ...[
                  const SizedBox(height: 14),
                  Text('Локација на мапа', style: GoogleFonts.nunito(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  _LazyMap(lat: r.latitude, lng: r.longitude),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['received', 'in_progress', 'resolved'];
    final currentIndex = steps.indexOf(status);

    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final done = i <= currentIndex;
        final active = i == currentIndex;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0) Expanded(child: Container(height: 2, color: done ? AppTheme.primary : const Color(0xFFCFD8DC))),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppTheme.primary : const Color(0xFFECEFF1),
                      border: active ? Border.all(color: AppTheme.primary, width: 2) : null,
                    ),
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Center(child: Text('${i + 1}', style: GoogleFonts.nunito(
                      fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700,
                    ))),
                  ),
                  if (i < steps.length - 1) Expanded(child: Container(height: 2, color: i < currentIndex ? AppTheme.primary : const Color(0xFFCFD8DC))),
                ],
              ),
              const SizedBox(height: 4),
              Text(s.statusLabel, style: GoogleFonts.nunito(
                fontSize: 10, fontWeight: done ? FontWeight.w800 : FontWeight.w600,
                color: done ? AppTheme.primary : AppTheme.textMuted,
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Map preview using flutter_map + OpenStreetMap (no API key needed)
class _LazyMap extends StatefulWidget {
  final double lat;
  final double lng;
  const _LazyMap({required this.lat, required this.lng});

  @override
  State<_LazyMap> createState() => _LazyMapState();
}

class _LazyMapState extends State<_LazyMap> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    // Short delay so the map renders after page transition completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _show = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final point = LatLng(widget.lat, widget.lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.opstina_app',
            ),
            MarkerLayer(markers: [
              Marker(
                point: point,
                width: 40, height: 50,
                child: Column(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 6)],
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                  ),
                  Container(width: 2, height: 8, color: AppTheme.primary),
                ]),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

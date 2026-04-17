import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mis_project/core/themes/app_theme.dart';
import 'package:mis_project/features/reports/report_provider.dart';

import 'admin_provider.dart';

class AdminReportDetailPage extends ConsumerStatefulWidget {
  final String reportId;
  const AdminReportDetailPage({super.key, required this.reportId});

  @override
  ConsumerState<AdminReportDetailPage> createState() =>
      _AdminReportDetailPageState();
}

class _AdminReportDetailPageState
    extends ConsumerState<AdminReportDetailPage> {
  final _noteCtrl = TextEditingController();
  bool _saving = false;
  bool _notePrefilled = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(String status) async {
    setState(() => _saving = true);
    try {
      await adminUpdateReport(
        reportId: widget.reportId,
        status: status,
        adminNote: _noteCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Зачувано — статус: ${status.statusLabel}'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Грешка: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rAsync = ref.watch(reportByIdProvider(widget.reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали — Admin'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: rAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Грешка: $e')),
        data: (r) {
          if (r == null) {
            return const Center(child: Text('Пријавата не е пронајдена'));
          }

          if (!_notePrefilled) {
            _noteCtrl.text = r.adminNote ?? '';
            _notePrefilled = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: r.status.statusBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: r.status.statusColor.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Text(r.status.statusEmoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Тековен статус',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w700)),
                          Text(r.status.statusLabel,
                              style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: r.status.statusColor)),
                        ]),
                  ]),
                ),

                const SizedBox(height: 16),

                _secLabel('Промени статус'),
                const SizedBox(height: 10),
                Row(children: [
                  _StatusBtn(
                    label: 'Примено', emoji: '🟡',
                    color: AppTheme.warning,
                    active: r.status == 'received',
                    onTap: _saving ? null : () => _save('received'),
                  ),
                  const SizedBox(width: 8),
                  _StatusBtn(
                    label: 'Во тек', emoji: '🔵',
                    color: AppTheme.secondary,
                    active: r.status == 'in_progress',
                    onTap: _saving ? null : () => _save('in_progress'),
                  ),
                  const SizedBox(width: 8),
                  _StatusBtn(
                    label: 'Решено', emoji: '🟢',
                    color: AppTheme.success,
                    active: r.status == 'resolved',
                    onTap: _saving ? null : () => _save('resolved'),
                  ),
                ]),

                const SizedBox(height: 16),

                _secLabel('Белешка за граѓанинот'),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                    'Пр. Екипата е испратена, решавање до петок...',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : () => _save(r.status),
                    icon: _saving
                        ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 16),
                    label: Text(_saving ? 'Зачувување...' : 'Зачувај белешка'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _secLabel('Детали'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 6)
                    ],
                  ),
                  child: Column(children: [
                    _Row(icon: Icons.category_outlined, label: 'Категорија',
                        value: '${r.category.categoryEmoji} ${r.category.categoryLabel}'),
                    const Divider(height: 16),
                    _Row(icon: Icons.description_outlined, label: 'Опис', value: r.description),
                    const Divider(height: 16),
                    _Row(icon: Icons.location_on_outlined, label: 'Локација', value: r.address),
                    const Divider(height: 16),
                    _Row(icon: Icons.person_outlined, label: 'Пријавил', value: r.userFullName),
                    const Divider(height: 16),
                    _Row(icon: Icons.calendar_today_outlined, label: 'Датум',
                        value: DateFormat('dd.MM.yyyy HH:mm').format(r.createdAt)),
                    if (r.updatedAt != null) ...[
                      const Divider(height: 16),
                      _Row(icon: Icons.update_outlined, label: 'Последна промена',
                          value: DateFormat('dd.MM.yyyy HH:mm').format(r.updatedAt!)),
                    ],
                  ]),
                ),

                if (r.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _secLabel('Слики (${r.imageUrls.length})'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.imageUrls.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 10),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _fullscreen(context, r.imageUrls[i]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(r.imageUrls[i],
                              width: 220, height: 180, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],

                if (r.latitude != 0 && r.longitude != 0) ...[
                  const SizedBox(height: 16),
                  _secLabel('Локација на мапа'),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 220,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(r.latitude, r.longitude),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'finki.uki.mk.misProject',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: LatLng(r.latitude, r.longitude),
                              width: 40, height: 50,
                              child: Column(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: r.status.statusColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [BoxShadow(
                                      color: r.status.statusColor.withOpacity(0.4),
                                      blurRadius: 6,
                                    )],
                                  ),
                                  child: Center(child: Text(
                                    r.category.categoryEmoji,
                                    style: const TextStyle(fontSize: 18),
                                  )),
                                ),
                                Container(width: 2, height: 8, color: r.status.statusColor),
                              ]),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _secLabel(String t) => Text(t, style: GoogleFonts.nunito(
    fontSize: 13, fontWeight: FontWeight.w800,
    color: AppTheme.textMuted, letterSpacing: 0.5,
  ));

  void _fullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(children: [
          Center(child: InteractiveViewer(child: Image.network(url))),
          Positioned(
            top: 40, right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label, emoji;
  final Color color;
  final bool active;
  final VoidCallback? onTap;
  const _StatusBtn({required this.label, required this.emoji,
    required this.color, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: active ? 0 : 1.5),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.nunito(
              fontSize: 11, fontWeight: FontWeight.w800,
              color: active ? Colors.white : color,
            )),
          ]),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AppTheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(
              fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
          Text(value, style: GoogleFonts.nunito(
              fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      )),
    ],
  );
}

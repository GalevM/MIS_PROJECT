import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mis_project/core/themes/app_theme.dart';
import '../core/notifications/notification_model.dart';
import 'admin_provider.dart';

class AdminNotificationsPage extends ConsumerStatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  ConsumerState<AdminNotificationsPage> createState() =>
      _AdminNotificationsPageState();
}

class _AdminNotificationsPageState
    extends ConsumerState<AdminNotificationsPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  String _type = 'general';
  bool _sending = false;

  static const _types = [
    {'value': 'general',     'label': 'Општо',     'emoji': '📢'},
    {'value': 'water',       'label': 'Вода',      'emoji': '💧'},
    {'value': 'electricity', 'label': 'Струја',    'emoji': '⚡'},
    {'value': 'traffic',     'label': 'Сообраќај', 'emoji': '🚗'},
    {'value': 'event',       'label': 'Настан',    'emoji': '📅'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Пополнете наслов и содржина')));
      return;
    }
    setState(() => _sending = true);
    try {
      await adminCreateNotification(
        title: _titleCtrl.text.trim(),
        body:  _bodyCtrl.text.trim(),
        type:  _type,
      );
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() => _type = 'general');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Известувањето е испратено ✅')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Грешка: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Избриши', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text('Сигурни сте?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Откажи')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await adminDeleteNotification(id);
            },
            child: Text('Избриши', style: GoogleFonts.nunito(
                color: Colors.red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifs = ref.watch(notificationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.add_alert_outlined, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Ново известување', style: GoogleFonts.nunito(
                      fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                ]),
                const SizedBox(height: 14),

                Text('Тип', style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _types.map((t) {
                    final sel = _type == t['value'];
                    return GestureDetector(
                      onTap: () => setState(() => _type = t['value']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? AppTheme.primary : const Color(0xFFCFD8DC),
                            width: 1.5,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(t['emoji']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(t['label']!, style: GoogleFonts.nunito(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : AppTheme.textPrimary,
                          )),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text('Наслов', style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Пр. Прекин на водоснабдување'),
                ),
                const SizedBox(height: 12),
                Text('Содржина', style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Пр. Прекин во периодот 09:00 – 14:00...'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_outlined, size: 16),
                    label: Text(_sending ? 'Испраќање...' : 'Испрати'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Испратени известувања', style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: AppTheme.textMuted, letterSpacing: 0.5,
          )),
          const SizedBox(height: 10),

          notifs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Грешка: $e'),
            data: (list) {
              if (list.isEmpty) {
                return Center(child: Text('Нема известувања',
                    style: GoogleFonts.nunito(color: AppTheme.textMuted)));
              }
              return Column(
                children: list.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: const BorderSide(color: AppTheme.primary, width: 3)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.typeEmoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(n.body, style: GoogleFonts.nunito(
                              fontSize: 12, color: AppTheme.textMuted),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(DateFormat('dd.MM.yyyy HH:mm').format(n.createdAt),
                              style: GoogleFonts.nunito(
                                  fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      )),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () => _confirmDelete(n.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

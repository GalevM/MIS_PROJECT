import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mis_project/core/themes/app_theme.dart';
import 'package:mis_project/features/polls/poll_model.dart';

import 'admin_provider.dart';

class AdminPollsPage extends ConsumerStatefulWidget {
  const AdminPollsPage({super.key});

  @override
  ConsumerState<AdminPollsPage> createState() => _AdminPollsPageState();
}

class _AdminPollsPageState extends ConsumerState<AdminPollsPage> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optCtrls = [
    TextEditingController(), TextEditingController(),
  ];
  bool _creating = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optCtrls) c.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_optCtrls.length >= 6) return;
    setState(() => _optCtrls.add(TextEditingController()));
  }

  void _removeOption(int i) {
    if (_optCtrls.length <= 2) return;
    setState(() {
      _optCtrls[i].dispose();
      _optCtrls.removeAt(i);
    });
  }

  Future<void> _create() async {
    final q = _questionCtrl.text.trim();
    final opts = _optCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    if (q.isEmpty) {
      _snack('Внесете прашање'); return;
    }
    if (opts.length < 2) {
      _snack('Потребни се минимум 2 опции'); return;
    }

    setState(() => _creating = true);
    try {
      await adminCreatePoll(question: q, options: opts);
      _questionCtrl.clear();
      for (final c in _optCtrls) c.clear();
      if (mounted) _snack('Анкетата е создадена ✅');
    } catch (e) {
      if (mounted) _snack('Грешка: $e');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Избриши анкета', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text('Сите гласови ќе се изгубат. Сигурни сте?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Откажи')),
          TextButton(
            onPressed: () async { Navigator.pop(context); await adminDeletePoll(id); },
            child: Text('Избриши', style: GoogleFonts.nunito(
                color: Colors.red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final polls = ref.watch(pollsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Create form ───────────────────────────────────────────────
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
                  const Icon(Icons.poll_outlined, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Нова анкета', style: GoogleFonts.nunito(
                      fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                ]),
                const SizedBox(height: 14),

                Text('Прашање', style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _questionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: 'Пр. Што е приоритет за овој месец?'),
                ),

                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Опции (мин. 2, макс. 6)', style: GoogleFonts.nunito(
                        fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                    if (_optCtrls.length < 6)
                      TextButton.icon(
                        onPressed: _addOption,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Додади'),
                        style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary, padding: EdgeInsets.zero),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                ...List.generate(_optCtrls.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                          color: AppTheme.primaryLight, shape: BoxShape.circle),
                      child: Center(child: Text('${i + 1}', style: GoogleFonts.nunito(
                          fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(
                      controller: _optCtrls[i],
                      decoration: InputDecoration(hintText: 'Опција ${i + 1}'),
                    )),
                    if (_optCtrls.length > 2) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeOption(i),
                        child: const Icon(Icons.close, color: Colors.red, size: 20),
                      ),
                    ],
                  ]),
                )),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _creating ? null : _create,
                    icon: _creating
                        ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_circle_outline, size: 16),
                    label: Text(_creating ? 'Создавање...' : 'Создади анкета'),
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

          Text('Постоечки анкети', style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: AppTheme.textMuted, letterSpacing: 0.5,
          )),
          const SizedBox(height: 10),

          polls.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Грешка: $e'),
            data: (list) {
              if (list.isEmpty) {
                return Center(child: Text('Нема анкети',
                    style: GoogleFonts.nunito(color: AppTheme.textMuted)));
              }
              return Column(
                children: list.map((p) => _PollTile(
                  poll: p,
                  onToggle: () => adminTogglePoll(p.id, !p.isActive),
                  onDelete: () => _confirmDelete(p.id),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PollTile extends StatelessWidget {
  final PollModel poll;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _PollTile({required this.poll, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: poll.isActive ? AppTheme.primary : AppTheme.textMuted,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Expanded(child: Text(poll.question, style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                child: Text(poll.isActive ? 'Активна' : 'Затворена', style: GoogleFonts.nunito(
                    fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ]),
          ),

          // Results bars
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              ...poll.options.map((opt) {
                final pct = poll.totalVotes > 0 ? opt.votes / poll.totalVotes : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(opt.text, style: GoogleFonts.nunito(
                            fontSize: 12, fontWeight: FontWeight.w700))),
                        Text('${opt.votes} (${(pct * 100).round()}%)',
                            style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textMuted)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct, minHeight: 7,
                          backgroundColor: const Color(0xFFECEFF1),
                          valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 4),
              Row(children: [
                Text('Вкупно: ${poll.totalVotes} гласа', style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    poll.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 14,
                  ),
                  label: Text(poll.isActive ? 'Затвори' : 'Активирај',
                      style: GoogleFonts.nunito(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: poll.isActive ? AppTheme.warning : AppTheme.success,
                    side: BorderSide(color: poll.isActive ? AppTheme.warning : AppTheme.success),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: Text('Избриши', style: GoogleFonts.nunito(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

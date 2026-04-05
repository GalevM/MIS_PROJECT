import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mis_project/core/themes/app_theme.dart';

import 'admin_provider.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  String _search = '';

  void _confirmRole(String uid, String name, String newRole) {
    final label = newRole == 'admin' ? 'Admin' : 'Граѓанин';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Промени улога', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text('Постави го $name за $label?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Откажи')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await updateUserRole(uid, newRole);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Улогата на $name е сменета на $label')),
                );
              }
            },
            child: Text('Потврди', style: GoogleFonts.nunito(
                color: AppTheme.primary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Пребарај корисници...',
              prefixIcon: Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
          ),
        ),

        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Грешка: $e')),
            data: (users) {
              final filtered = _search.isEmpty
                  ? users
                  : users.where((u) =>
              (u['fullName'] as String? ?? '').toLowerCase().contains(_search) ||
                  (u['email'] as String? ?? '').toLowerCase().contains(_search),
              ).toList();

              if (filtered.isEmpty) {
                return Center(child: Text('Нема корисници',
                    style: GoogleFonts.nunito(color: AppTheme.textMuted)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final u   = filtered[i];
                  final uid = u['id'] as String;
                  final isAdmin = u['role'] == 'admin';
                  final name = (u['fullName'] as String?)?.trim() ?? '';
                  final email  = u['email'] as String? ?? '';
                  final points = u['points'] as int? ?? 0;
                  final ts = u['createdAt'];
                  DateTime? created;
                  try { created = (ts as Timestamp).toDate(); } catch (_) {}

                  final initials = name.isNotEmpty
                      ? name.split(' ').take(2)
                      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                      .join()
                      : '?';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isAdmin
                          ? Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5)
                          : null,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    ),
                    child: Row(children: [
                      // Avatar
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: isAdmin ? AppTheme.primary : AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text(initials, style: GoogleFonts.nunito(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: isAdmin ? Colors.white : AppTheme.primary,
                        ))),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(child: Text(name.isNotEmpty ? name : 'Анонимен',
                                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis)),
                            if (isAdmin)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                    color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                                child: Text('ADMIN', style: GoogleFonts.nunito(
                                    fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                          ]),
                          if (email.isNotEmpty)
                            Text(email, style: GoogleFonts.nunito(
                                fontSize: 12, color: AppTheme.textMuted),
                                overflow: TextOverflow.ellipsis),
                          Row(children: [
                            const Icon(Icons.star_outline, size: 13, color: AppTheme.warning),
                            const SizedBox(width: 2),
                            Text('$points поени', style: GoogleFonts.nunito(
                                fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                            if (created != null) ...[
                              const SizedBox(width: 8),
                              Text(DateFormat('dd.MM.yyyy').format(created),
                                  style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ]),
                        ],
                      )),

                      // Menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                        onSelected: (role) => _confirmRole(uid, name.isNotEmpty ? name : 'корисникот', role),
                        itemBuilder: (_) => [
                          if (!isAdmin)
                            PopupMenuItem(
                              value: 'admin',
                              child: Row(children: [
                                const Icon(Icons.admin_panel_settings_outlined,
                                    size: 16, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text('Постави за Admin',
                                    style: GoogleFonts.nunito(fontSize: 13)),
                              ]),
                            ),
                          if (isAdmin)
                            PopupMenuItem(
                              value: 'user',
                              child: Row(children: [
                                const Icon(Icons.person_outline,
                                    size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text('Отстрани Admin',
                                    style: GoogleFonts.nunito(fontSize: 13)),
                              ]),
                            ),
                        ],
                      ),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

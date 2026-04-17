import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mis_project/core/themes/app_theme.dart';
import 'package:mis_project/features/auth/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  final String title;

  const AdminShell({super.key, required this.child, required this.title});

  static const _routes = [
    '/admin',
    '/admin/reports',
    '/admin/notifications',
    '/admin/polls',
    '/admin/users',
  ];

  int _routeToIndex(String loc) {
    for (int i = 0; i < _routes.length; i++) {
      if (loc == _routes[i]) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final index = _routeToIndex(loc);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Граѓанска апп',
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Одјави се',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    'Одјава',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                  ),
                  content: Text('Сигурни сте?', style: GoogleFonts.nunito()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Откажи'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Одјави се',
                        style: GoogleFonts.nunito(
                          color: Colors.red,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Преглед',
                  index: 0,
                  current: index,
                  onTap: () => context.go('/admin'),
                ),
                _NavItem(
                  icon: Icons.report_outlined,
                  activeIcon: Icons.report,
                  label: 'Пријави',
                  index: 1,
                  current: index,
                  onTap: () => context.go('/admin/reports'),
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Известувања',
                  index: 2,
                  current: index,
                  onTap: () => context.go('/admin/notifications'),
                ),
                _NavItem(
                  icon: Icons.poll_outlined,
                  activeIcon: Icons.poll,
                  label: 'Анкети',
                  index: 3,
                  current: index,
                  onTap: () => context.go('/admin/polls'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  active ? activeIcon : icon,
                  key: ValueKey(active),
                  size: 22,
                  color: active ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppTheme.primary : AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

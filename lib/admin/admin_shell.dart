//So drawer meni od stranata
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mis_project/core/themes/app_theme.dart';
// import 'package:mis_project/features/auth/auth_provider.dart';
//
// class AdminShell extends ConsumerWidget {
//   final Widget child;
//   final String title;
//   const AdminShell({super.key, required this.child, required this.title});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userDoc = ref.watch(currentUserDocProvider);
//     final name = userDoc.valueOrNull?['fullName'] ?? 'Admin';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         backgroundColor: AppTheme.primaryDark,
//         foregroundColor: Colors.white,
//         titleTextStyle: GoogleFonts.nunito(
//           fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             tooltip: 'Излези од Admin',
//             onPressed: () => context.go('/home'),
//           ),
//         ],
//       ),
//       drawer: _AdminDrawer(name: name),
//       body: child,
//     );
//   }
// }
//
// class _AdminDrawer extends ConsumerWidget {
//   final String name;
//   const _AdminDrawer({required this.name});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final loc = GoRouterState.of(context).matchedLocation;
//
//     return Drawer(
//       child: Column(
//         children: [
//           // Header
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.fromLTRB(
//                 20, MediaQuery.of(context).padding.top + 24, 20, 24),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppTheme.primaryDark, AppTheme.primary],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 58, height: 58,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.18),
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: const Icon(
//                     Icons.admin_panel_settings,
//                     color: Colors.white, size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(name, style: GoogleFonts.nunito(
//                   fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
//                 )),
//                 Text('Администратор', style: GoogleFonts.nunito(
//                   fontSize: 12, color: Colors.white70,
//                 )),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 6),
//
//           _Item(icon: Icons.dashboard_outlined,      label: 'Преглед',        route: '/admin',               current: loc),
//           _Item(icon: Icons.report_outlined,         label: 'Пријави',        route: '/admin/reports',       current: loc),
//           _Item(icon: Icons.notifications_outlined,  label: 'Известувања',    route: '/admin/notifications', current: loc),
//           _Item(icon: Icons.poll_outlined,           label: 'Анкети',         route: '/admin/polls',         current: loc),
//           _Item(icon: Icons.people_outlined,         label: 'Корисници',      route: '/admin/users',         current: loc),
//
//           const Divider(height: 20),
//
//           _Item(icon: Icons.home_outlined, label: 'Граѓанска апп', route: '/home', current: loc),
//
//           const Spacer(),
//
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: () async {
//                   await ref.read(authNotifierProvider.notifier).logout();
//                   if (context.mounted) context.go('/login');
//                 },
//                 icon: const Icon(Icons.logout, size: 16),
//                 label: const Text('Одјави се'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red,
//                   side: const BorderSide(color: Colors.red),
//                   minimumSize: const Size(double.infinity, 44),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Item extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String route;
//   final String current;
//   const _Item({
//     required this.icon, required this.label,
//     required this.route, required this.current,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final active = current == route;
//     return ListTile(
//       leading: Icon(icon,
//           color: active ? AppTheme.primary : AppTheme.textMuted, size: 22),
//       title: Text(label, style: GoogleFonts.nunito(
//         fontSize: 14,
//         fontWeight: active ? FontWeight.w800 : FontWeight.w600,
//         color: active ? AppTheme.primary : AppTheme.textPrimary,
//       )),
//       tileColor: active ? AppTheme.primaryLight : null,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//       onTap: () {
//         Navigator.pop(context);
//         context.go(route);
//       },
//     );
//   }
// }
//


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
    final loc   = GoRouterState.of(context).matchedLocation;
    final index = _routeToIndex(loc);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
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
                  title: Text('Одјава', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                  content: Text('Сигурни сте?', style: GoogleFonts.nunito()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Откажи')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Одјави се', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w800)),
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
                _NavItem(icon: Icons.dashboard_outlined,     activeIcon: Icons.dashboard,            label: 'Преглед',      index: 0, current: index, onTap: () => context.go('/admin')),
                _NavItem(icon: Icons.report_outlined,        activeIcon: Icons.report,               label: 'Пријави',      index: 1, current: index, onTap: () => context.go('/admin/reports')),
                _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications,        label: 'Известувања',  index: 2, current: index, onTap: () => context.go('/admin/notifications')),
                _NavItem(icon: Icons.poll_outlined,          activeIcon: Icons.poll,                 label: 'Анкети',       index: 3, current: index, onTap: () => context.go('/admin/polls')),
                _NavItem(icon: Icons.people_outlined,        activeIcon: Icons.people,               label: 'Корисници',    index: 4, current: index, onTap: () => context.go('/admin/users')),
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
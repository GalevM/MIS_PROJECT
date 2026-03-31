// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// class AppShell extends StatelessWidget {
//   final Widget child;
//
//   const AppShell({super.key, required this.child});
//
//   int _selectedIndex(BuildContext context) {
//     final location = GoRouterState.of(context).uri.toString();
//     if (location.startsWith('/map')) return 1;
//     if (location.startsWith('/myReports')) return 2;
//     if (location.startsWith('/myProfile')) return 3;
//     return 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: child,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex(context),
//         selectedItemColor: Theme.of(context).colorScheme.primary,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               context.go('/home');
//               break;
//             case 1:
//               context.go('/map');
//               break;
//             case 2:
//               context.go('/myReports');
//               break;
//             case 3:
//               context.go('/myProfile');
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Почетна"),
//           BottomNavigationBarItem(icon: Icon(Icons.map), label: "Мапа"),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: "Мои пријави"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профил"),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/my-reports')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/map');
            case 2: context.go('/my-reports');
            case 3: context.go('/notifications');
            case 4: context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Почетна'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Мапа'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Пријави'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Вести'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Профил'),
        ],
      ),
    );
  }
}

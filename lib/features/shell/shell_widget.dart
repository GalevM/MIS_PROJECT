import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/myReports')) return 2;
    if (location.startsWith('/myProfile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex(context),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/map');
              break;
            case 2:
              context.go('/myReports');
              break;
            case 3:
              context.go('/myProfile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Почетна"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Мапа"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Мои пријави"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профил"),
        ],
      ),
    );
  }
}

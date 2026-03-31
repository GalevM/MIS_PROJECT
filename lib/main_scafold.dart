import 'package:flutter/material.dart';

import 'features/home/home_page.dart';
import 'features/map/public_map_page.dart';
import 'features/reports/my_reports_page.dart';
import 'features/profile/profile_page.dart';
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const MyReportsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

import 'package:flutter/material.dart';
import 'package:njangi/dashboard_admin.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tresorerie/tresorerie_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 1; // "Trésorerie" active par défaut pour les tests

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const TresorerieScreen(),
    const Center(child: Text("Membres (Écran en développement)")),
    const Center(child: Text("Profil (Écran en développement)")),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E5E4E);
    const lightGreenBg = Color(0xFFE8F3EF);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Tableau de Bord',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _currentIndex == 1 ? lightGreenBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history),
            ),
            label: 'Trésorerie',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Membres',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

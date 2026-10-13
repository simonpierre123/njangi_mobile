import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/common/basewidget/app_bottom_nav_bar.dart';

void main() {
  testWidgets('notification badge only appears for unread notifications', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: _ignoreTap,
            items: [
              AppNavItem(icon: Icons.home, label: 'Accueil'),
              AppNavItem(
                icon: Icons.notifications,
                label: 'Notifications',
                badgeCount: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('0'), findsNothing);
    expect(find.text('Notifications'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: _ignoreTap,
            items: [
              AppNavItem(icon: Icons.home, label: 'Accueil'),
              AppNavItem(
                icon: Icons.notifications,
                label: 'Notifications',
                badgeCount: 3,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
  });
}

void _ignoreTap(int index) {}

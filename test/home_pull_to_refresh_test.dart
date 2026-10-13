import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_model.dart';
import 'package:njangi/common/basewidget/app_bottom_nav_bar.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/home/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pulling down on home refreshes its data', (tester) async {
    await AppLocalizations.load();
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: HomePage(
            userName: 'Utilisateur',
            userPhotoUrl: null,
            greetingSubtitleKey: 'greeting_subtitle',
            communities: const [],
            isProfileComplete: true,
            onIdentify: () {},
            onCommunityTap: (_) {},
            onRefresh: () async => refreshCount++,
            onLock: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 350));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshCount, 1);
  });

  testWidgets('home search filters communities by name', (tester) async {
    await AppLocalizations.load();
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: HomePage(
            userName: 'Utilisateur',
            userPhotoUrl: null,
            greetingSubtitleKey: 'greeting_subtitle',
            communities: [
              _community('group-1', 'Spar Groupe'),
              _community('group-2', 'BND Teams'),
            ],
            isProfileComplete: true,
            onIdentify: () {},
            onCommunityTap: (_) {},
            onRefresh: () async {},
            onLock: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'bNd');
    await tester.pump();

    expect(find.text('BND Teams'), findsOneWidget);
    expect(find.text('Spar Groupe'), findsNothing);

    await tester.enterText(find.byType(TextField), 'introuvable');
    await tester.pump();
    expect(
      find.text('Aucune communauté ne correspond à cette recherche.'),
      findsOneWidget,
    );
  });

  testWidgets('notification badge shows unread count and hides at zero', (
    tester,
  ) async {
    await AppLocalizations.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              AppNavItem(icon: Icons.home_outlined, label: 'Accueil'),
              AppNavItem(
                icon: Icons.notifications_none_outlined,
                label: 'Notifications',
                badgeCount: 3,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              AppNavItem(icon: Icons.home_outlined, label: 'Accueil'),
              AppNavItem(
                icon: Icons.notifications_none_outlined,
                label: 'Notifications',
                badgeCount: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('0'), findsNothing);
  });
}

CommunityModel _community(String id, String name) => CommunityModel(
  id: id,
  name: name,
  icon: Icons.groups_outlined,
  cycleCurrent: 1,
  cycleTotal: 6,
  memberCount: 4,
  contributionAmount: '10000 FCFA',
  contributionFrequency: 'Mensuel',
  progressPercent: 0.25,
  lastUpdateLabel: 'Aujourd’hui',
);

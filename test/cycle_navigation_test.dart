import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_model.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/routes/app_router.dart';
import 'package:njangi/screens/home/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping a group without cycles opens cycle setup step two', (
    tester,
  ) async {
    await AppLocalizations.load();
    final community = CommunityModel(
      id: 'group-uuid',
      name: 'Groupe sans cycle',
      description: 'Description',
      type: 'FAMILLE',
      groupCode: 'GRP-TEST',
      icon: Icons.home_outlined,
      role: 'ADMIN',
      cycleCurrent: 0,
      cycleTotal: 0,
      memberCount: 1,
      contributionAmount: '',
      contributionFrequency: '',
      progressPercent: 0.6,
      lastUpdateLabel: '',
      cyclesLoaded: true,
      hasCycle: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        onGenerateRoute: AppRouter.onGenerateRoute,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(
          userName: 'Gaston',
          userPhotoUrl: null,
          greetingSubtitleKey: 'greeting_subtitle',
          communities: [community],
          isProfileComplete: true,
          onIdentify: () {},
          onCommunityTap: AppRouter.openCommunity,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final groupName = find.text('Groupe sans cycle').first;
    await tester.ensureVisible(groupName);
    await tester.tap(groupName);
    await tester.pumpAndSettle();

    expect(
      find.text(AppLocalizations.t('financial_config_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppLocalizations.t('contribution_amount_label').toUpperCase()),
      findsOneWidget,
    );
  });
}

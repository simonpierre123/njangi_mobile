import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/routes/app_router.dart';
import 'package:njangi/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('step two keeps the chosen start date and due day', (
    tester,
  ) async {
    await AppLocalizations.load();
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () => Navigator.of(context).pushNamed(
                      AppRoutes.createCommunityStep2,
                      arguments: const CommunityDraft(),
                    ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('jj/mm/aaaa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('jj/mm/aaaa'), findsNothing);
    expect(find.textContaining(RegExp(r'^15/\d{2}/\d{4}$')), findsOneWidget);

    await tester.tap(find.text('Chaque lundi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chaque mercredi').last);
    await tester.pumpAndSettle();
    expect(find.text('Chaque mercredi'), findsOneWidget);
  });
}

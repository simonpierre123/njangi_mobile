import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/creation/create_community_step2_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('monthly cycle draft captures nth weekday payout rule', (
    tester,
  ) async {
    await AppLocalizations.load();
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    CommunityDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CreateCommunityStep2Page(
          draft: CommunityDraft(
            frequency: ContributionFrequency.mensuelle,
            startDate: DateTime(2026, 11, 8),
          ),
          onBack: () {},
          onContinue: (draft) => submittedDraft = draft,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.text(AppLocalizations.t('tontine_calendar_fixed_date')),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(
      find.text(AppLocalizations.t('tontine_calendar_nth_weekday')).last,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text(AppLocalizations.t('continue_button')).first);
    await tester.pump();

    expect(submittedDraft?.tontineCalendarMode, 'NIEME_JOUR_SEMAINE');
    expect(submittedDraft?.tontineWeekOrdinal, 2);
    expect(submittedDraft?.tontineWeekday, 7);
    expect(submittedDraft?.startDate, DateTime(2026, 11, 8));
  });
}

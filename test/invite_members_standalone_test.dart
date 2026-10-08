import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Models/create_community_model.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/creation/create_community_step4_page.dart';

Future<void> _pump(WidgetTester tester, {required bool standalone}) async {
  await AppLocalizations.load();
  tester.view.physicalSize = const Size(1080, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  Future<List<InvitedMember>?> none() async => null;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CreateCommunityStep4Page(
        standalone: standalone,
        draft: const CommunityDraft(),
        onBack: () {},
        onContinue: (_) {},
        onGenerateLink: none,
        onShowQrCode: none,
        onInviteByNumber: none,
        onChooseContacts: none,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('standalone mode hides the step header and wizard buttons', (
    tester,
  ) async {
    await _pump(tester, standalone: true);

    expect(find.textContaining(AppLocalizations.t('step_word')), findsNothing);
    expect(find.text(AppLocalizations.t('continue_button')), findsNothing);
    expect(find.text(AppLocalizations.t('invite_later_button')), findsNothing);
    expect(find.text(AppLocalizations.t('invite_done_button')), findsOneWidget);
  });

  testWidgets('wizard mode keeps the step header and its buttons', (
    tester,
  ) async {
    await _pump(tester, standalone: false);

    expect(
      find.textContaining(AppLocalizations.t('step_word')),
      findsOneWidget,
    );
    expect(find.text(AppLocalizations.t('continue_button')), findsOneWidget);
    expect(find.text(AppLocalizations.t('invite_done_button')), findsNothing);
  });
}

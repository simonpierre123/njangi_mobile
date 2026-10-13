import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Models/Invitation.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/datasource/invitation_repository.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/creation/invite/invite_join_page.dart';
import 'package:njangi/screens/community/creation/invite/invite_phone_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SimulatedInvitationRepository', () {
    final repository = SimulatedInvitationRepository(latency: Duration.zero);

    test('searches registered users by phone digits only', () async {
      expect(await repository.searchUsersByPhone(''), isEmpty);
      expect(await repository.searchUsersByPhone('+237 690'), hasLength(1));
      expect(await repository.searchUsersByPhone('000'), hasLength(5));
      expect(await repository.searchUsersByPhone('9999999'), isEmpty);
    });

    test('invites a registered user as pending', () async {
      final user = SimulatedInvitationRepository.registry.first;
      final invitation = await repository.inviteUser(
        groupId: 'g1',
        groupName: 'Groupe test',
        user: user,
      );

      expect(invitation.status, InvitationStatus.pending);
      expect(invitation.method, InvitationMethod.phone);
      expect(invitation.phone, user.phone);
    });

    test('join tokens are unique and become joined members', () async {
      final a = await repository.createJoinToken(
        groupId: 'g1',
        method: InvitationMethod.link,
      );
      final b = await repository.createJoinToken(
        groupId: 'g1',
        method: InvitationMethod.qr,
      );

      expect(a.token, isNot(b.token));
      expect(a.link, endsWith(a.token!));
      expect(
        (await repository.simulateJoin(a)).status,
        InvitationStatus.joined,
      );
    });
  });

  group('invite pages', () {
    setUp(() {
      InvitationRepository.instance = SimulatedInvitationRepository(
        latency: Duration.zero,
      );
    });

    Future<void> pumpPage(WidgetTester tester, Widget page) async {
      await AppLocalizations.load();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('phone page filters while typing and invites on tap', (
      tester,
    ) async {
      List<InvitedMember>? done;
      await pumpPage(
        tester,
        InvitePhonePage(
          groupId: 'g1',
          groupName: 'Groupe test',
          onBack: () {},
          onDone: (m) => done = m,
        ),
      );

      await tester.enterText(find.byType(TextField), '69');
      await tester.pumpAndSettle();
      expect(find.text('Marie Ndzié'), findsNothing);

      await tester.enterText(find.byType(TextField), '690');
      await tester.pumpAndSettle();
      expect(find.text('Marie Ndzié'), findsOneWidget);

      await tester.tap(find.text('Marie Ndzié'));
      await tester.pumpAndSettle();
      expect(
        find.text('Invitation enregistrée et notification envoyée.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terminer'));
      expect(done, hasLength(1));
      expect(done!.single.status, InvitationStatus.pending);

      await tester.enterText(find.byType(TextField), '999999');
      await tester.pumpAndSettle();
      expect(
        find.text('Aucun utilisateur inscrit avec ce numéro.'),
        findsOneWidget,
      );
    });

    testWidgets('link page shows a link and simulates a join', (tester) async {
      List<InvitedMember>? done;
      await pumpPage(
        tester,
        InviteJoinPage(
          groupId: 'g1',
          method: InvitationMethod.link,
          onBack: () {},
          onDone: (m) => done = m,
        ),
      );

      expect(find.textContaining('https://njangi.app/join/'), findsWidgets);

      await tester.tap(find.text("Simuler l'ouverture du lien"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('A rejoint'), findsOneWidget);

      await tester.tap(find.text('Terminer'));
      expect(done!.single.status, InvitationStatus.joined);
    });
  });
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/regles/cycle_rules_page.dart';
import 'package:njangi/screens/community/creation/widgets/frequency_option_grid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'admin edits cycle rules with the creation form and submits a proposal',
    (tester) async {
      await AppLocalizations.load();
      final adapter = _CycleRulesAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CycleRulesPage(
            args: CycleRulesRouteArgs(cycleId: 'cycle-id', isAdmin: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editAction = find.text(AppLocalizations.t('cycle_rules_edit'));
      await tester.scrollUntilVisible(
        editAction,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(editAction);
      await tester.pumpAndSettle();

      expect(
        find.text(AppLocalizations.t('contribution_section')),
        findsOneWidget,
      );
      expect(find.byType(FrequencyOptionGrid), findsOneWidget);
      expect(
        find.text(AppLocalizations.t('cycle_modules_section')),
        findsOneWidget,
      );
      expect(find.byType(SegmentedButton<String>), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '15000');
      final submitButton = find.text(AppLocalizations.t('cycle_rules_submit'));
      for (var attempt = 0; attempt < 6; attempt++) {
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
      }
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      final proposalRequest = adapter.requests.singleWhere(
        (request) => request.method == 'POST',
      );
      final requestData =
          proposalRequest.data is String
              ? jsonDecode(proposalRequest.data as String)
              : proposalRequest.data as Map;
      expect(
        proposalRequest.uri.path,
        '/api/cycles/cycle-id/regles/propositions',
      );
      expect((requestData as Map)['changes'], {'montant_cotisation': 15000});
      expect(
        find.text(AppLocalizations.t('cycle_rules_proposal_sent')),
        findsOneWidget,
      );
    },
  );
}

class _CycleRulesAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  bool _proposalSubmitted = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (options.method == 'POST') {
      _proposalSubmitted = true;
      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'data': {'id': 'proposal-id'},
        }),
        201,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'cycle': {
            'id': 'cycle-id',
            'numero': 1,
            'nombre_membres': 12,
            'nombre_admin': 2,
            'montant_cotisation': 10000,
            'devise': 'XAF',
            'frequence_cycle': 'MENSUEL',
            'date_debut': '2026-11-01',
            'date_fin': '2027-10-31',
            'statut': 'EN_ATTENTE',
            'module_pret_actif': '0',
            'validation_pret_colectif': '1',
            'appliquer_penalites': '1',
            'epargne_active': true,
            'epargne_mode': 'FIXE',
            'epargne_montant_fixe': 5000,
            'epargne_calendrier_mode': 'MEME_QUE_TONTINE',
            'caisse_secours_active': false,
            'secours_inclure_beneficiaire': true,
            'tontine_active': true,
            'tontine_prochain_visible': false,
          },
          'is_admin': true,
          'pending_proposal':
              _proposalSubmitted ? {'id': 'proposal-id', 'changes': {}} : null,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

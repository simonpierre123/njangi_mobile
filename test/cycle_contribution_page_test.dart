import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleSavingsContributionController.dart';
import 'package:njangi/Controllers_distant/CycleTontineContributionController.dart';
import 'package:njangi/ModeView/community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/tresorerie/cycle_contribution_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'loads tontine details and allows deposits during the window before cycle start',
    (tester) async {
      await AppLocalizations.load();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final adapter = _ContributionContextAdapter(
        tontineCycleStatus: null,
        tontineWindowOpen: true,
      );
      ApiService.dio.httpClientAdapter = adapter;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CycleContributionPage(
            community: CommunityModel(
              id: 'group-1',
              name: 'Groupe secours',
              icon: Icons.groups,
              cycleCurrent: 1,
              cycleTotal: 1,
              memberCount: 4,
              contributionAmount: '25000',
              contributionFrequency: 'MENSUEL',
              progressPercent: 0,
              lastUpdateLabel: '',
              cycleId: 'cycle-1',
            ),
            onBack: () {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Tontine'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        adapter.request?.uri.path,
        '/api/cycles/cycle-1/tontine/cotisations',
      );
      expect(find.text('Groupe secours'), findsOneWidget);
      expect(find.text('Cycle 1'), findsOneWidget);
      expect(find.textContaining('25'), findsNWidgets(2));
      expect(find.text('Orange Money'), findsNothing);
      expect(find.text('+237 699 000 111'), findsOneWidget);
      expect(find.text('Marie Njoya'), findsOneWidget);
      expect(find.text('TOUR-0'), findsOneWidget);
      expect(find.text('Mobile Money'), findsOneWidget);
      expect(
        find.text(
          'Les dépôts s’ouvrent automatiquement pendant la période de cotisation de la tontine.',
        ),
        findsNothing,
      );
      await tester.tap(find.text('Paiement de test dans l’application'));
      await tester.pump();
      expect(
        find.textContaining('aucun paiement réel ne sera débité'),
        findsOneWidget,
      );
      expect(find.text('Enregistrer le paiement de test'), findsOneWidget);
    },
  );

  testWidgets('a pending test payment prevents another tontine deposit', (
    tester,
  ) async {
    await AppLocalizations.load();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _ContributionContextAdapter(
      tontineCycleStatus: null,
      tontineWindowOpen: true,
      hasPendingTontineOperation: true,
    );
    ApiService.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CycleContributionPage(
          community: CommunityModel(
            id: 'group-1',
            name: 'Groupe secours',
            icon: Icons.groups,
            cycleCurrent: 1,
            cycleTotal: 1,
            memberCount: 4,
            contributionAmount: '25000',
            contributionFrequency: 'MENSUEL',
            progressPercent: 0,
            lastUpdateLabel: '',
            cycleId: 'cycle-1',
          ),
          onBack: () {},
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Tontine'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PAIEMENT DE TEST'), findsOneWidget);
    expect(find.text('Paiement de test dans l’application'), findsNothing);
    expect(find.text('Enregistrer le paiement de test'), findsNothing);
  });

  test('builds a payload with the period and configured amount', () async {
    final form =
        await CycleTontineContributionController.buildSubmissionFormData(
          period: 'TOUR-2',
          amount: 25000,
          paymentMode: 'MOBILE_MONEY',
          operator: 'MTN',
          paymentReference: 'MM-REF-02',
        );

    final fields = form.fields;
    final payload = {for (final field in fields) field.key: field.value};
    expect(payload['periode'], 'TOUR-2');
    expect(payload['montant'], '25000');
    expect(payload['mode_paiement'], 'MOBILE_MONEY');
    expect(payload['operateur'], 'MTN');
    expect(payload['reference_paiement'], 'MM-REF-02');
  });

  testWidgets('loads savings balance and rules from the savings API', (
    tester,
  ) async {
    await AppLocalizations.load();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _ContributionContextAdapter(
      savingsCycleStatus: 'EN_ATTENTE',
      tontineWindowOpen: true,
    );
    ApiService.dio.httpClientAdapter = adapter;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CycleContributionPage(
          community: CommunityModel(
            id: 'group-1',
            name: 'Groupe secours',
            icon: Icons.groups,
            cycleCurrent: 1,
            cycleTotal: 1,
            memberCount: 4,
            contributionAmount: '25000',
            contributionFrequency: 'MENSUEL',
            progressPercent: 0,
            lastUpdateLabel: '',
            cycleId: 'cycle-1',
          ),
          onBack: () {},
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Épargne'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    final renderedText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? '')
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    expect(
      adapter.request?.uri.path,
      '/api/cycles/cycle-1/epargne/cotisations',
    );
    expect(find.text('Groupe secours'), findsOneWidget);
    expect(find.text('Libre'), findsOneWidget);
    expect(find.text('Mobile Money'), findsOneWidget);
    expect(renderedText, contains('1 000 – 50 000 XAF'));
    expect(renderedText, contains('12 000 XAF'));
    expect(find.text('Soumettre le dépôt'), findsNothing);
  });

  test('builds an epargne deposit payload with payment details', () async {
    final form =
        await CycleSavingsContributionController.buildSubmissionFormData(
          period: '2026-10',
          amount: 15000,
          paymentMode: 'MOBILE_MONEY',
          operator: 'ORANGE',
          paymentReference: 'SAVINGS-001',
        );

    final payload = {for (final field in form.fields) field.key: field.value};
    expect(payload['type'], 'EPARGNE');
    expect(payload['periode'], '2026-10');
    expect(payload['montant'], '15000');
    expect(payload['mode_paiement'], 'MOBILE_MONEY');
    expect(payload['operateur'], 'ORANGE');
    expect(payload['reference_paiement'], 'SAVINGS-001');
  });
}

class _ContributionContextAdapter implements HttpClientAdapter {
  _ContributionContextAdapter({
    this.tontineCycleStatus = 'EN_COURS',
    this.savingsCycleStatus = 'EN_COURS',
    this.tontineWindowOpen = true,
    this.hasPendingTontineOperation = false,
  });

  final String? tontineCycleStatus;
  final String savingsCycleStatus;
  final bool tontineWindowOpen;
  final bool hasPendingTontineOperation;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final isSavings = options.uri.path.contains('/epargne/cotisations');
    final responseData =
        isSavings
            ? {
              'success': true,
              'data': {
                'cycle': {
                  'numero': 1,
                  'statut': savingsCycleStatus,
                  'groupe': {'nom': 'Groupe secours'},
                },
                'devise': 'XAF',
                'epargne_mode': 'LIBRE',
                'epargne_montant_fixe': null,
                'epargne_montant_min': 1000,
                'epargne_montant_max': 50000,
                'solde_disponible': 12000,
                'telephone_tresorier': '+237 699 000 111',
                'paiement_simulation_active': true,
                'cotisation_tontine_ouverte': tontineWindowOpen,
                'periodes_disponibles': [
                  {'value': '2026-10', 'date_echeance': '2026-10-01'},
                ],
                'recent_epargne_operations': [],
              },
            }
            : {
              'success': true,
              'data': {
                'cycle': {
                  'numero': 1,
                  if (tontineCycleStatus != null)
                    'statut': tontineCycleStatus,
                  'groupe': {'nom': 'Groupe secours'},
                },
                'montant_cotisation': 25000,
                'devise': 'XAF',
                'periode': 'TOUR-1',
                'date_echeance': '2026-10-31',
                'date_ouverture_cotisation': '2026-10-26',
                'date_fermeture_cotisation': '2026-10-31',
                'cotisation_ouverte': tontineWindowOpen,
                'etat_fenetre_cotisation':
                    tontineWindowOpen ? 'OUVERTE' : 'AVANT_OUVERTURE',
                'telephone_tresorier': '+237 699 000 111',
                'paiement_simulation_active': true,
                'prochain_beneficiaire': {
                  'nom': 'Njoya',
                  'prenom': 'Marie',
                  'ordre': 1,
                },
                'current_period_operation':
                    hasPendingTontineOperation
                        ? {
                          'id': 'test-1',
                          'type': 'TONTINE',
                          'montant': 25000,
                          'periode': 'TOUR-1',
                          'statut': 'EN_ATTENTE',
                          'is_simulation': true,
                          'operateur': 'TEST',
                        }
                        : null,
                'recent_tontine_operations': [
                  {'montant': 25000, 'periode': 'TOUR-0', 'statut': 'VALIDE'},
                ],
              },
            };
    return ResponseBody.fromString(
      jsonEncode(responseData),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

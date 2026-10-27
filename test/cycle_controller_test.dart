import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleController.dart';
import 'package:njangi/Controllers_distant/CycleFinanceController.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates a cycle from the financial and rules draft', () async {
    AppLocalizations.locale.value = 'fr';
    await AppLocalizations.load();
    final adapter = _CycleApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await CycleController.createForGroup(
      groupId: 'group-uuid',
      draft: CommunityDraft(
        contributionAmount: '50 000',
        frequency: ContributionFrequency.mensuelle,
        startDate: DateTime(2026, 8, 9),
        dueDayLabel: 'Chaque 5 du mois',
        tontineCalendarMode: 'NIEME_JOUR_SEMAINE',
        tontineWeekOrdinal: 2,
        tontineWeekday: 7,
        expectedMemberCount: '12',
        allowLoans: true,
        maxLoanAmount: '500 000',
        maxLoanDurationMonths: '3',
        maxSimultaneousLoans: '2',
        maxAdminCount: 2,
        collectiveValidation: true,
        penaltiesEnabled: false,
        savingsActive: true,
        savingsMode: 'LIBRE',
        savingsMinAmount: '1000',
        savingsMaxAmount: '50000',
        emergencyFundActive: true,
        tontineActive: true,
        tontineNextVisible: false,
      ),
    );

    expect(result['success'], isTrue);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.uri.path, '/api/groupes/group-uuid/cycles');
    expect(adapter.request!.data, {
      'numero': 1,
      'nom': 'Cycle 1',
      'nombre_membres': 12,
      'nombre_admin': 2,
      'montant_cotisation': 50000,
      'devise': 'XAF',
      'montant_max_pret': 500000,
      'duree_max_pret': 3,
      'nombre_max_pret_simultane': 2,
      'frequence_cycle': 'MENSUEL',
      'jour_echeance': AppLocalizations.t('due_day_sunday'),
      'tontine_calendrier_mode': 'NIEME_JOUR_SEMAINE',
      'tontine_ordinal_semaine': 2,
      'tontine_jour_semaine': 7,
      'date_debut': '2026-08-09',
      'date_fin': '2027-08-08',
      'statut': 'EN_ATTENTE',
      'module_pret_actif': '1',
      'validation_pret_colectif': '1',
      'appliquer_penalites': '0',
      'epargne_active': true,
      'epargne_mode': 'LIBRE',
      'epargne_montant_fixe': null,
      'epargne_montant_min': 1000,
      'epargne_montant_max': 50000,
      'epargne_frequence': null,
      'epargne_jour_echeance': null,
      'epargne_calendrier_mode': 'MEME_QUE_TONTINE',
      'caisse_secours_active': true,
      'secours_inclure_beneficiaire': true,
      'tontine_active': true,
      'tontine_prochain_visible': false,
    });
  });

  test('loan module is opt-in and serialized in the API enum format', () async {
    AppLocalizations.locale.value = 'fr';
    await AppLocalizations.load();
    final adapter = _CycleApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await CycleController.createForGroup(
      groupId: 'group-uuid',
      draft: CommunityDraft(
        contributionAmount: '10 000',
        frequency: ContributionFrequency.mensuelle,
        startDate: DateTime(2026, 8, 9),
      ),
    );

    expect(result['success'], isTrue);
    expect(CommunityDraft().allowLoans, isFalse);
    expect(adapter.request!.data['module_pret_actif'], '0');
    expect(adapter.request!.data['montant_max_pret'], isNull);
  });

  test(
    'rejects inconsistent calendars and incomplete custom schedules',
    () async {
      AppLocalizations.locale.value = 'fr';
      await AppLocalizations.load();
      final adapter = _CycleApiAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final invalidWeekly = await CycleController.createForGroup(
        groupId: 'group-uuid',
        draft: CommunityDraft(
          contributionAmount: '1000',
          frequency: ContributionFrequency.hebdomadaire,
          startDate: DateTime(2026, 11, 2),
          tontineWeekday: 3,
        ),
      );
      final incompleteCustom = await CycleController.createForGroup(
        groupId: 'group-uuid',
        draft: CommunityDraft(
          contributionAmount: '1000',
          frequency: ContributionFrequency.personnalisee,
          startDate: DateTime(2026, 11, 2),
        ),
      );

      expect(invalidWeekly['success'], isFalse);
      expect(
        invalidWeekly['message'],
        AppLocalizations.t('tontine_start_date_rule_mismatch'),
      );
      expect(incompleteCustom['success'], isFalse);
      expect(
        incompleteCustom['message'],
        AppLocalizations.t('cycle_custom_member_count_required'),
      );
      expect(adapter.request, isNull);
    },
  );

  test(
    'sends cycle emergency, operation, decision, and closure requests',
    () async {
      final adapter = _CycleFinanceApiAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final results = [
        await CycleFinanceController.createEmergencyRequest(
          cycleId: 'cycle-uuid',
          motif: 'Urgence familiale',
          montantDemande: 50000,
        ),
        await CycleFinanceController.decideEmergencyRequest(
          cycleId: 'cycle-uuid',
          demandeId: 'request-uuid',
          decision: 'APPROUVEE',
          montantAlloue: 50000,
        ),
        await CycleFinanceController.submitOperation(
          cycleId: 'cycle-uuid',
          type: 'VERSEMENT',
          utilisateurId: 'member-uuid',
          montant: 10000,
          description: 'Cotisation du mois',
        ),
        await CycleFinanceController.decideOperation(
          cycleId: 'cycle-uuid',
          operationId: 'operation-uuid',
          decision: 'VALIDE',
          commentaire: 'Cotisation validée',
        ),
        await CycleFinanceController.closeCycle('cycle-uuid'),
      ];

      expect(results.map((result) => result['success']), everyElement(isTrue));
      expect(adapter.requests.map((request) => request.uri.path), [
        '/api/cycles/cycle-uuid/secours/demandes',
        '/api/cycles/cycle-uuid/secours/demandes/request-uuid/decision',
        '/api/cycles/cycle-uuid/operations',
        '/api/cycles/cycle-uuid/operations/operation-uuid/decision',
        '/api/cycles/cycle-uuid/cloture',
      ]);
      expect(adapter.requests[0].data, {
        'motif': 'Urgence familiale',
        'montant_demande': 50000,
      });
      expect(adapter.requests[1].data, {
        'decision': 'APPROUVEE',
        'montant_alloue': 50000,
      });
      expect(adapter.requests[2].data, {
        'type': 'VERSEMENT',
        'utilisateur_id': 'member-uuid',
        'montant': 10000,
        'description': 'Cotisation du mois',
        'statut': 'EN_ATTENTE',
      });
      expect(adapter.requests[3].data, {
        'decision': 'VALIDE',
        'commentaire': 'Cotisation validée',
      });
      expect(adapter.requests[4].data, isNull);
    },
  );
}

class _CycleApiAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'message': 'Cycle créé avec succès.',
        'data': {
          'id': 'cycle-uuid',
          'groupe_id': 'group-uuid',
          'numero': 1,
          'nombre_membres': 12,
          'nombre_admin': 2,
          'montant_cotisation': 50000,
          'devise': 'XAF',
          'frequence_cycle': 'MENSUEL',
          'jour_echeance': 'Chaque 5 du mois',
          'date_debut': '2026-08-01',
          'date_fin': '2027-07-31',
          'statut': 'EN_ATTENTE',
        },
      }),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CycleFinanceApiAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {'id': 'response-uuid'},
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleController.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/datasource/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates a cycle from the financial and rules draft', () async {
    final adapter = _CycleApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await CycleController.createForGroup(
      groupId: 'group-uuid',
      draft: CommunityDraft(
        contributionAmount: '50 000',
        frequency: ContributionFrequency.mensuelle,
        startDate: DateTime(2026, 8, 1),
        dueDayLabel: 'Chaque 5 du mois',
        expectedMemberCount: '12',
        allowLoans: true,
        maxLoanAmount: '500 000',
        maxLoanDurationMonths: '3',
        maxSimultaneousLoans: '2',
        maxAdminCount: 2,
        collectiveValidation: true,
        penaltiesEnabled: false,
      ),
    );

    expect(result['success'], isTrue);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.uri.path, '/api/groupes/group-uuid/cycles');
    expect(adapter.request!.data, {
      'nombre_membres': 12,
      'nombre_admin': 2,
      'montant_cotisation': 50000,
      'devise': 'XAF',
      'montant_max_pret': 500000,
      'duree_max_pret': 3,
      'nombre_max_pret_simultane': 2,
      'frequence_cycle': 'MENSUEL',
      'jour_echeance': 'Chaque 5 du mois',
      'date_debut': '2026-08-01',
      'date_fin': '2027-07-31',
      'statut': 'EN_ATTENTE',
      'module_pret_actif': '1',
      'validation_pret_colectif': '1',
      'appliquer_penalites': '0',
    });
  });
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleTontineTourController.dart';
import 'package:njangi/ModeView/beneficiary_model.dart';
import 'package:njangi/datasource/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads tour members and persists their reordered membership IDs',
    () async {
      final adapter = _TontineToursAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final loaded = await CycleTontineTourController.getForCycle('cycle-uuid');
      final entries = loaded['entries'] as List<PassageOrderEntry>;

      expect(loaded['success'], isTrue);
      expect(entries.map((entry) => entry.name), ['Awa Njoya', 'Paul Mbida']);
      expect(entries.first.photoUrl, endsWith('/storage/photos/awa.jpg'));
      expect(entries.last.photoUrl, isNull);
      expect(entries.map((entry) => entry.membershipId), [
        'membership-1',
        'membership-2',
      ]);
      expect(entries.map((entry) => entry.order), [1, 2]);

      final reordered = reorderPassageOrder(entries, 0, 2);
      expect(reordered.map((entry) => entry.name), ['Paul Mbida', 'Awa Njoya']);
      expect(reordered.map((entry) => entry.order), [1, 2]);
      final saved = await CycleTontineTourController.setOrder(
        cycleId: 'cycle-uuid',
        entries: reordered,
      );

      expect(saved['success'], isTrue);
      expect(adapter.requests.map((request) => request.method), ['GET', 'PUT']);
      expect(
        adapter.requests.last.uri.path,
        '/api/cycles/cycle-uuid/tontine/ordre',
      );
      expect(adapter.requests.last.data, {
        'membre_ids': ['membership-2', 'membership-1'],
      });
    },
  );
}

class _TontineToursAdapter implements HttpClientAdapter {
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
        'data': [
          {
            'beneficiaire_membre_id': 'membership-2',
            'ordre': 2,
            'date_echeance': '2026-11-20',
            'statut': 'A_VENIR',
            'beneficiaire': {
              'id': 'membership-2',
              'utilisateur_id': 'user-2',
              'utilisateur_nom': 'Paul Mbida',
            },
          },
          {
            'beneficiaire_membre_id': 'membership-1',
            'ordre': 1,
            'date_echeance': '2026-11-06',
            'statut': 'A_VENIR',
            'beneficiaire': {
              'id': 'membership-1',
              'utilisateur_id': 'user-1',
              'utilisateur_nom': 'Awa Njoya',
              'utilisateur': {
                'prenom': 'Awa',
                'nom': 'Njoya',
                'photo': 'photos/awa.jpg',
              },
            },
          },
        ],
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

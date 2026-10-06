import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/MembreGroupeController.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'adds the stored user to the created group with the requested role',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode({
          'id': 'user-uuid',
          'telephone': '+237600000000',
          'statut': 1,
          'active': '1',
          'delete': '0',
        }),
      });
      final adapter = _MembershipApiAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final result = await MembreGroupeController.addCurrentUser(
        groupeId: 'group-uuid',
      );

      expect(result['success'], isTrue);
      expect(adapter.request!.method, 'POST');
      expect(adapter.request!.uri.path, '/api/groupes/group-uuid/membres');
      expect(adapter.request!.data, {
        'utilisateur_id': 'user-uuid',
        'role': 'ADMIN',
        'statut': 'ACTIF',
        'active': '1',
      });
      expect((result['membre'] as dynamic).utilisateurId, 'user-uuid');
      expect((result['membre'] as dynamic).role, 'ADMIN');
    },
  );
}

class _MembershipApiAdapter implements HttpClientAdapter {
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
        'message': 'Membre ajouté au groupe avec succès.',
        'data': {
          'id': 'membership-uuid',
          'utilisateur_id': 'user-uuid',
          'groupe_id': 'group-uuid',
          'utilisateur_nom': 'Utilisateur test',
          'groupe_nom': 'Groupe test',
          'role': 'ADMIN',
          'statut': 'ACTIF',
          'active': '1',
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

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/MembreGroupeController.dart';
import 'package:njangi/Controllers_distant/MembreGroupeCycleController.dart';
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

  test('adds an invitee to the group with the INVITE role', () async {
    final adapter = _InvitationApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await MembreGroupeController.addUserAsInvite(
      groupeId: 'group-uuid',
      utilisateurId: 'invitee-uuid',
    );

    expect(result['success'], isTrue);
    expect(adapter.postRequest!.uri.path, '/api/groupes/group-uuid/membres');
    expect(adapter.postRequest!.data, {
      'utilisateur_id': 'invitee-uuid',
      'role': 'INVITE',
      'statut': 'ACTIF',
      'active': '0',
    });
    expect(adapter.methods, ['POST']);
    expect((result['membre'] as dynamic).role, 'INVITE');
  });

  test('adds an invitee to the cycle with the INVITE role', () async {
    final adapter = _CycleInvitationApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await MembreGroupeCycleController.addUserAsInvite(
      cycleId: 'cycle-uuid',
      utilisateurId: 'invitee-uuid',
    );

    expect(result['success'], isTrue);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.uri.path, '/api/cycles/cycle-uuid/membres');
    expect(adapter.request!.data, {
      'utilisateur_id': 'invitee-uuid',
      'role': 'INVITE',
      'date_adhesion': DateTime.now().toIso8601String().substring(0, 10),
      'statut': 'ACTIF',
    });
    expect((result['member'] as dynamic).role, 'INVITE');
  });

  test(
    'accepts group and cycle invites using utilisateur_id in update URLs',
    () async {
      ApiService.dio.httpClientAdapter = _AcceptInvitationApiAdapter();

      final groupResult = await MembreGroupeController.acceptInvite(
        groupeId: 'group-uuid',
        utilisateurId: 'invitee-uuid',
      );
      final cycleResult = await MembreGroupeCycleController.acceptInvite(
        cycleId: 'cycle-uuid',
        utilisateurId: 'invitee-uuid',
      );

      expect(groupResult['success'], isTrue);
      expect(cycleResult['success'], isTrue);
      final updates =
          (ApiService.dio.httpClientAdapter as _AcceptInvitationApiAdapter)
              .updates;
      expect(
        updates[0].uri.path,
        '/api/groupes/group-uuid/membres/update/invitee-uuid',
      );
      expect(updates[0].data, {
        'role': 'MEMBRE',
        'statut': 'VALIDEE',
        'active': '1',
      });
      expect(
        updates[1].uri.path,
        '/api/cycles/cycle-uuid/membres/update/invitee-uuid',
      );
      expect(updates[1].data, {'role': 'MEMBRE', 'statut': 'VALIDEE'});
    },
  );

  test(
    'rejects API success when the group membership remains an invitee',
    () async {
      ApiService.dio.httpClientAdapter = _AcceptInvitationApiAdapter(
        staleUpdate: true,
      );

      final result = await MembreGroupeController.acceptInvite(
        groupeId: 'group-uuid',
        utilisateurId: 'invitee-uuid',
      );

      expect(result['success'], isFalse);
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

class _InvitationApiAdapter implements HttpClientAdapter {
  RequestOptions? postRequest;
  final methods = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    methods.add(options.method);
    if (options.method == 'POST') postRequest = options;
    final isPost = options.method == 'POST';
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data':
            isPost
                ? {
                  'id': 'membership-uuid',
                  'utilisateur_id': 'invitee-uuid',
                  'groupe_id': 'group-uuid',
                  'role': 'INVITE',
                  'statut': 'ACTIF',
                  'active': '1',
                }
                : [],
      }),
      isPost ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CycleInvitationApiAdapter implements HttpClientAdapter {
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
        'data': {
          'id': 'cycle-membership-uuid',
          'utilisateur_id': 'invitee-uuid',
          'cycle_id': 'cycle-uuid',
          'groupe_id': 'group-uuid',
          'role': 'INVITE',
          'date_adhesion': options.data['date_adhesion'],
          'statut': 'ACTIF',
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

class _AcceptInvitationApiAdapter implements HttpClientAdapter {
  _AcceptInvitationApiAdapter({this.staleUpdate = false});

  final bool staleUpdate;
  final updates = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final isUpdate = options.method == 'PUT';
    final isCycle = options.uri.path.contains('/cycles/');
    if (isUpdate) updates.add(options);
    return ResponseBody.fromString(
      jsonEncode(
        isUpdate
            ? {
              'success': true,
              'data': {
                'id': isCycle ? 'cycle-member-uuid' : 'group-member-uuid',
                'utilisateur_id': 'invitee-uuid',
                'role': staleUpdate ? 'INVITE' : 'MEMBRE',
                'statut': staleUpdate ? 'SUSPENDU' : 'VALIDEE',
                'active': '1',
              },
            }
            : {
              'success': true,
              'data': [
                {
                  'id': isCycle ? 'cycle-member-uuid' : 'group-member-uuid',
                  'utilisateur_id': 'invitee-uuid',
                  'role': 'INVITE',
                  'statut': 'SUSPENDU',
                  'active': '1',
                },
              ],
            },
      ),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/MembreGroupeController.dart';
import 'package:njangi/Controllers_distant/MembreGroupeCycleController.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
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

  test(
    'rejects creator membership when the API responds with INVITE',
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
      ApiService.dio.httpClientAdapter = _MembershipApiAdapter(role: 'INVITE');

      final result = await MembreGroupeController.addCurrentUser(
        groupeId: 'group-uuid',
      );

      expect(result['success'], isFalse);
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

  test('creates a cycle invitation using invitee_id', () async {
    final adapter = _CycleInvitationWorkflowApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await MembreGroupeCycleController.createCycleInvitation(
      cycleId: 'cycle-uuid',
      inviteeId: 'invitee-uuid',
    );

    expect(result['success'], isTrue);
    expect(
      adapter.requests.single.uri.path,
      '/api/cycles/cycle-uuid/invitations',
    );
    expect(adapter.requests.single.data, {'invitee_id': 'invitee-uuid'});
    expect(result['invitationId'], 'invitation-uuid');
  });

  test('creates a cycle invitation using telephone', () async {
    final adapter = _CycleInvitationWorkflowApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await MembreGroupeCycleController.createCycleInvitation(
      cycleId: 'cycle-uuid',
      telephone: '+237612345678',
    );

    expect(result['success'], isTrue);
    expect(
      adapter.requests.single.uri.path,
      '/api/cycles/cycle-uuid/invitations',
    );
    expect(adapter.requests.single.data, {'telephone': '+237612345678'});
  });

  test(
    'localizes the response when a cycle invitation is already pending',
    () async {
      await AppLocalizations.load();
      final originalLocale = AppLocalizations.locale.value;
      final adapter = _PendingInvitationApiAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      AppLocalizations.locale.value = 'fr';
      final frenchResult =
          await MembreGroupeCycleController.createCycleInvitation(
            cycleId: 'cycle-uuid',
            inviteeId: 'invitee-uuid',
          );
      expect(frenchResult['message'], 'Une invitation est déjà en attente.');

      AppLocalizations.locale.value = 'en';
      final englishResult =
          await MembreGroupeCycleController.createCycleInvitation(
            cycleId: 'cycle-uuid',
            inviteeId: 'invitee-uuid',
          );
      expect(englishResult['message'], 'An invitation is already pending.');
      AppLocalizations.locale.value = originalLocale;
    },
  );

  test(
    'accepts and refuses invitations through their dedicated routes',
    () async {
      final adapter = _CycleInvitationWorkflowApiAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final accepted = await MembreGroupeCycleController.respondToInvitation(
        invitationId: 'invitation-uuid',
        decision: 'ACCEPTE',
      );
      final refused = await MembreGroupeCycleController.respondToInvitation(
        invitationId: 'invitation-uuid',
        decision: 'REFUSE',
      );

      expect(accepted['success'], isTrue);
      expect(refused['success'], isTrue);
      expect(adapter.requests.map((request) => request.uri.path), [
        '/api/invitations/invitation-uuid/accepter',
        '/api/invitations/invitation-uuid/refuser',
      ]);
      expect(adapter.requests.map((request) => request.data), [null, null]);
    },
  );

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
  _MembershipApiAdapter({this.role = 'ADMIN'});

  final String role;
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
          'role': role,
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

class _CycleInvitationWorkflowApiAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final isCreation =
        options.uri.path.endsWith('/invitations') &&
        !options.uri.path.contains('/invitations/');
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data':
            isCreation ? {'id': 'invitation-uuid'} : {'id': 'invitation-uuid'},
      }),
      isCreation ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _PendingInvitationApiAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode({'message': 'Une invitation est déjà en attente.'}),
    409,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

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

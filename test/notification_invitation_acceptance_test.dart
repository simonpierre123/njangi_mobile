import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/NotificationController.dart';
import 'package:njangi/Models/Notification.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'accepts one cycle invitation and notifies each unique member once',
    () async {
      await AppLocalizations.load();
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode({
          'id': 'joining-user',
          'telephone': '+237600000000',
          'statut': 1,
          'active': '1',
          'delete': '0',
        }),
      });
      final adapter = _InvitationAcceptanceAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final result = await NotificationController.acceptInvitation(
        const Notification(
          id: 'invitation-notification',
          userId: 'joining-user',
          scope: 'UTILISATEUR',
          groupId: 'group-uuid',
          cycleId: 'cycle-uuid',
          title: 'Invitation',
          description: 'Invitation au groupe',
          eventType: 'INVITATION_PROCHAINS_CYCLES',
          payload: {'invitation_id': 'cycle-invitation-uuid'},
        ),
      );

      expect(result['success'], isTrue);
      final acceptRequests = adapter.requests.where(
        (request) => request.uri.path.endsWith('/accepter'),
      );
      expect(acceptRequests, hasLength(1));
      expect(
        acceptRequests.single.uri.path,
        '/api/invitations/cycle-invitation-uuid/accepter',
      );
      expect(adapter.membershipUpdates, isEmpty);
      expect(
        adapter.requests.any(
          (request) =>
              request.uri.path.endsWith(
                '/notifications/invitation-notification/marquer-lu',
              ) &&
              request.method == 'PATCH',
        ),
        isTrue,
      );
      expect(adapter.memberNotificationRequests, hasLength(1));
      expect(
        adapter.memberNotificationRequests.single.data['utilisateur_id'],
        'existing-member',
      );
    },
  );

  test('does not use a notification UUID as an invitation UUID', () {
    const notification = Notification(
      id: 'notification-uuid',
      userId: 'user-uuid',
      scope: 'CYCLE',
      title: 'Invitation',
      description: 'Invitation au cycle',
      eventType: 'INVITATION_PROCHAINS_CYCLES',
    );

    expect(notification.isInvitation, isTrue);
    expect(NotificationController.extractInvitationId(notification), isNull);
  });

  test(
    'recognizes proposal and final cycle rule notifications as actionable',
    () {
      const proposal = Notification(
        userId: 'admin-uuid',
        scope: 'CYCLE',
        title: 'Validation requise',
        description: 'Proposition de règles',
        eventType: 'ALERTE',
        payload: {'action': 'CYCLE_RULE_PROPOSAL'},
      );
      const applied = Notification(
        userId: 'member-uuid',
        scope: 'CYCLE',
        title: 'Règles mises à jour',
        description: 'Les règles sont appliquées',
        eventType: 'ALERTE',
        payload: {'action': 'CYCLE_RULES_APPLIED'},
      );

      expect(proposal.isActionable, isTrue);
      expect(applied.isActionable, isTrue);
    },
  );

  test('decodes the JSON-string payload sent in FCM data', () {
    final notification = Notification.fromJson({
      'id': 'notification-uuid',
      'utilisateur_id': 'user-uuid',
      'portee': 'CYCLE',
      'titre': 'Invitation',
      'description': 'Invitation au cycle',
      'type_evenement': 'INVITATION_PROCHAINS_CYCLES',
      'payload': jsonEncode({
        'invitation_id': 'cycle-invitation-uuid',
        'groupe_id': 'group-uuid',
        'cycle_id': 'cycle-uuid',
      }),
    });

    expect(notification.isInvitation, isTrue);
    expect(
      NotificationController.extractInvitationId(notification),
      'cycle-invitation-uuid',
    );
    expect(notification.groupId, 'group-uuid');
    expect(notification.cycleId, 'cycle-uuid');
  });

  test(
    'loads pending invitations and deduplicates existing notifications',
    () async {
      await AppLocalizations.load();
      final adapter = _PendingInvitationFeedAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      final result = await NotificationController.getForUser('user-uuid');
      final notifications = result['notifications'] as List<Notification>;

      expect(result['success'], isTrue);
      expect(notifications, hasLength(2));
      expect(
        notifications.map(NotificationController.extractInvitationId).toSet(),
        {'invitation-existing', 'invitation-phone'},
      );
      final phoneInvitation = notifications.singleWhere(
        (notification) =>
            NotificationController.extractInvitationId(notification) ==
            'invitation-phone',
      );
      expect(phoneInvitation.groupId, 'group-uuid');
      expect(phoneInvitation.cycleId, 'cycle-uuid');
      expect(phoneInvitation.id, isNull);
    },
  );

  test(
    'does not notify members again when backend says already processed',
    () async {
      await AppLocalizations.load();
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode({
          'id': 'joining-user',
          'telephone': '+237600000000',
          'statut': 1,
          'active': '1',
          'delete': '0',
        }),
      });
      final adapter = _InvitationAcceptanceAdapter(alreadyProcessed: true);
      ApiService.dio.httpClientAdapter = adapter;

      final result = await NotificationController.acceptInvitation(
        const Notification(
          id: 'invitation-notification',
          userId: 'joining-user',
          scope: 'CYCLE',
          groupId: 'group-uuid',
          cycleId: 'cycle-uuid',
          title: 'Invitation',
          description: 'Invitation au cycle',
          eventType: 'INVITATION_PROCHAINS_CYCLES',
          payload: {'invitation_id': 'cycle-invitation-uuid'},
        ),
      );

      expect(result['success'], isTrue);
      expect(adapter.memberNotificationRequests, isEmpty);
    },
  );

  test('reloads pending invitations after accept returns 409', () async {
    await AppLocalizations.load();
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 'joining-user',
        'telephone': '+237600000000',
        'statut': 1,
        'active': '1',
        'delete': '0',
      }),
    });
    final adapter = _InvitationAcceptanceAdapter(acceptStatusCode: 409);
    ApiService.dio.httpClientAdapter = adapter;

    final result = await NotificationController.acceptInvitation(
      const Notification(
        id: 'invitation-notification',
        userId: 'joining-user',
        scope: 'CYCLE',
        groupId: 'group-uuid',
        cycleId: 'cycle-uuid',
        title: 'Invitation',
        description: 'Invitation au cycle',
        eventType: 'INVITATION_PROCHAINS_CYCLES',
        payload: {'invitation_id': 'cycle-invitation-uuid'},
      ),
    );

    expect(result['success'], isFalse);
    expect(result['refreshRequired'], isTrue);
    expect(
      adapter.requests.where(
        (request) => request.uri.path.endsWith('/accepter'),
      ),
      hasLength(1),
    );
    expect(
      adapter.requests.any((request) => request.uri.path == '/api/invitations'),
      isTrue,
    );
  });
}

class _InvitationAcceptanceAdapter implements HttpClientAdapter {
  _InvitationAcceptanceAdapter({
    this.alreadyProcessed = false,
    this.acceptStatusCode = 200,
  });

  final bool alreadyProcessed;
  final int acceptStatusCode;
  final requests = <RequestOptions>[];
  final memberNotificationRequests = <RequestOptions>[];
  final membershipUpdates = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = options.uri.path;

    if (path.endsWith('/invitations/cycle-invitation-uuid/accepter')) {
      if (acceptStatusCode == 409) {
        return _jsonResponse({
          'message': 'Cette invitation a déjà reçu une réponse.',
        }, statusCode: 409);
      }
      return _jsonResponse({
        'success': true,
        'message': 'Invitation acceptée.',
        'already_processed': alreadyProcessed,
      });
    }

    if (path == '/api/invitations') {
      return _jsonResponse({'success': true, 'data': []});
    }

    if (path.endsWith('/membres/update/joining-user')) {
      membershipUpdates.add(options);
      return _jsonResponse({
        'success': true,
        'data': {
          'utilisateur_id': 'joining-user',
          'role': 'MEMBRE',
          'statut': 'VALIDEE',
          'active': '1',
        },
      });
    }

    if (path.endsWith('/notifications/invitation-notification/marquer-lu')) {
      return _jsonResponse({'success': true});
    }

    if (path.endsWith('/cycles/cycle-uuid')) {
      return _jsonResponse({'success': false});
    }

    if (path.endsWith('/groupes/group-uuid/membres') ||
        path.endsWith('/cycles/cycle-uuid/membres')) {
      return _jsonResponse({
        'success': true,
        'data': [
          {'utilisateur_id': 'joining-user', 'role': 'MEMBRE', 'active': '1'},
          {
            'utilisateur_id': 'existing-member',
            'role': 'MEMBRE',
            'active': '1',
          },
        ],
      });
    }

    if (path.endsWith('/notifications') && options.method == 'POST') {
      memberNotificationRequests.add(options);
      final payload = Map<String, dynamic>.from(options.data as Map);
      return _jsonResponse({
        'success': true,
        'data': {'id': 'member-notification', ...payload, 'push_envoye': true},
      });
    }

    return _jsonResponse({'success': false, 'message': 'Unexpected request'});
  }

  ResponseBody _jsonResponse(
    Map<String, dynamic> body, {
    int statusCode = 200,
  }) => ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _PendingInvitationFeedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final isInvitationList = options.uri.path.endsWith('/invitations');
    return ResponseBody.fromString(
      jsonEncode(
        isInvitationList
            ? {
              'success': true,
              'data': [
                {
                  'id': 'invitation-existing',
                  'groupe_id': 'group-uuid',
                  'cycle_id': 'cycle-uuid',
                  'invitee_id': 'user-uuid',
                  'telephone': '+237600000000',
                  'statut': 'EN_ATTENTE',
                },
                {
                  'id': 'invitation-phone',
                  'groupe_id': 'group-uuid',
                  'cycle_id': 'cycle-uuid',
                  'invitee_id': null,
                  'telephone': '+237611111111',
                  'statut': 'EN_ATTENTE',
                },
              ],
            }
            : {
              'success': true,
              'data': {
                'data': [
                  {
                    'id': 'notification-existing',
                    'utilisateur_id': 'user-uuid',
                    'portee': 'CYCLE',
                    'groupe_id': 'group-uuid',
                    'cycle_id': 'cycle-uuid',
                    'titre': 'Invitation',
                    'description': 'Invitation au cycle',
                    'type_evenement': 'INVITATION_PROCHAINS_CYCLES',
                    'payload': {
                      'invitation_id': 'invitation-existing',
                      'groupe_id': 'group-uuid',
                      'cycle_id': 'cycle-uuid',
                    },
                  },
                ],
              },
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

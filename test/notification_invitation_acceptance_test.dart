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
    'updates group and cycle memberships then deduplicates recipients',
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
          eventType: 'INVITATION_GROUPE',
        ),
      );

      expect(result['success'], isTrue);
      expect(
        adapter.membershipUpdates[0].uri.path,
        '/api/groupes/group-uuid/membres/update/joining-user',
      );
      expect(adapter.membershipUpdates[0].data, {
        'role': 'MEMBRE',
        'statut': 'VALIDEE',
        'active': '1',
      });
      expect(
        adapter.membershipUpdates[1].uri.path,
        '/api/cycles/cycle-uuid/membres/update/joining-user',
      );
      expect(adapter.membershipUpdates[1].data, {
        'role': 'MEMBRE',
        'statut': 'VALIDEE',
      });
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
      expect(
        adapter.requests.where(
          (request) =>
              request.method == 'POST' &&
              request.uri.path.endsWith('/accepter'),
        ),
        isEmpty,
      );
      expect(adapter.memberNotificationRequests, hasLength(1));
      expect(
        adapter.memberNotificationRequests.single.data['utilisateur_id'],
        'existing-member',
      );
    },
  );
}

class _InvitationAcceptanceAdapter implements HttpClientAdapter {
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

  ResponseBody _jsonResponse(Map<String, dynamic> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

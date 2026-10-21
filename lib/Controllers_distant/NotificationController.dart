import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Controllers_distant/MembreGroupeCycleController.dart';
import 'package:njangi/Models/Notification.dart';
import 'package:njangi/api/firebase_api.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class NotificationController {
  static String? extractInvitationId(Notification notification) {
    final payload = notification.payload;
    final payloadId =
        payload?['invitation_id']?.toString() ??
        payload?['invitationId']?.toString();
    if (payloadId != null && payloadId.isNotEmpty) return payloadId;
    return null;
  }

  static Future<Map<String, dynamic>> getForUser(String userId) async {
    try {
      final response = await ApiService.dio.get(
        'notifications/utilisateur/$userId',
      );
      final body = response.data;
      if (body is! Map) {
        debugPrint('[API] User notifications response is not an object: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('notification_load_error'),
        };
      }

      final page = body['success'] == true ? body['data'] : body;
      final rows = page is Map ? page['data'] : page;
      if (rows is! List) {
        debugPrint('[API] User notifications response has no list: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('notification_load_error'),
        };
      }

      final now = DateTime.now();
      final notifications =
          rows
              .whereType<Map>()
              .map(
                (row) => Notification.fromJson(Map<String, dynamic>.from(row)),
              )
              .where(
                (notification) =>
                    notification.active == '1' &&
                    (notification.expiresAt == null ||
                        notification.expiresAt!.isAfter(now)),
              )
              .toList();

      final invitationIds =
          notifications.map(extractInvitationId).whereType<String>().toSet();
      try {
        final invitationsResponse = await ApiService.dio.get('invitations');
        final invitationRows = _rowsFromEnvelope(invitationsResponse.data);
        for (final row in invitationRows ?? const <Map<String, dynamic>>[]) {
          if (row['statut']?.toString().toUpperCase() != 'EN_ATTENTE') continue;
          final invitationId = row['id']?.toString();
          final groupId = row['groupe_id']?.toString();
          final cycleId = row['cycle_id']?.toString();
          if (invitationId == null ||
              invitationId.isEmpty ||
              groupId == null ||
              groupId.isEmpty ||
              cycleId == null ||
              cycleId.isEmpty ||
              !invitationIds.add(invitationId)) {
            continue;
          }

          final group = row['groupe'];
          final groupName =
              row['groupe_nom']?.toString() ??
              (group is Map ? group['nom']?.toString() : null) ??
              AppLocalizations.t('the_community');
          notifications.add(
            Notification(
              userId: userId,
              scope: 'CYCLE',
              groupId: groupId,
              cycleId: cycleId,
              title: AppLocalizations.t('invitation_notification_title'),
              description: AppLocalizations.t(
                'invitation_notification_body',
                args: [groupName],
              ),
              eventType: 'INVITATION_PROCHAINS_CYCLES',
              notifiableType: 'App\\Models\\CycleInvitation',
              notifiableId: invitationId,
              payload: {
                'screen': 'INVITATION_DETAILS',
                'invitation_id': invitationId,
                'groupe_id': groupId,
                'cycle_id': cycleId,
                'groupe_nom': groupName,
              },
              expiresAt: DateTime.tryParse(row['expires_at']?.toString() ?? ''),
              createdAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
            ),
          );
        }
      } catch (error) {
        debugPrint(
          '[API] Pending cycle invitations could not be loaded: $error',
        );
      }

      notifications.sort((left, right) {
        final leftDate =
            left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate =
            right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });

      return {'success': true, 'notifications': notifications};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'notification_load_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Loading user notifications failed: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('notification_load_error'),
      };
    }
  }

  static List<Map<String, dynamic>>? _rowsFromEnvelope(dynamic body) {
    if (body is! Map ||
        !(body['success'] == true || body['status'] == 'success')) {
      return null;
    }
    final data = body['data'];
    final rows =
        data is List
            ? data
            : data is Map && data['data'] is List
            ? data['data'] as List
            : null;
    return rows
        ?.whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.dio.patch(
        'notifications/$notificationId/marquer-lu',
      );
      final body = response.data;
      final success =
          body is Map &&
          (body['success'] == true || body['status'] == 'success');
      if (!success) {
        debugPrint('[API] Mark notification as read failed: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('notification_mark_read_error'),
        };
      }
      return {'success': true};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'notification_mark_read_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Mark notification as read failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('notification_mark_read_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> acceptInvitation(
    Notification notification,
  ) async {
    final groupId =
        notification.groupId ?? notification.payload?['groupe_id']?.toString();
    final cycleId =
        notification.cycleId ?? notification.payload?['cycle_id']?.toString();
    final invitationId = extractInvitationId(notification);
    var stage = 'chargement de la session';
    var alreadyProcessed = false;
    try {
      final user = await StorageManager.getUser();
      final invalidInvitation =
          !notification.isInvitation ||
          (groupId == null || groupId.isEmpty) ||
          (cycleId == null || cycleId.isEmpty) ||
          (invitationId == null || invitationId.isEmpty) ||
          user == null ||
          user.id.isEmpty;
      if (invalidInvitation) {
        debugPrint(
          '[INVITATION] Acceptation interrompue: données manquantes '
          '(isInvitation=${notification.isInvitation}, '
          'hasGroupId=${groupId != null && groupId.isNotEmpty}, '
          'hasCycleId=${cycleId != null && cycleId.isNotEmpty}, '
          'hasUser=${user != null && user.id.isNotEmpty}).',
        );
        return {
          'success': false,
          'message': AppLocalizations.t('invitation_accept_error'),
        };
      }

      stage = 'acceptation de l\'invitation cycle';
      final invitationResult =
          await MembreGroupeCycleController.respondToInvitation(
            invitationId: invitationId,
            decision: 'ACCEPTE',
          );
      if (invitationResult['success'] != true) {
        debugPrint('[INVITATION] Échec étape invitation: $invitationResult');
        if (invitationResult['statusCode'] == 409) {
          await MembreGroupeCycleController.getPendingInvitations();
          return {
            'success': false,
            'refreshRequired': true,
            'message': AppLocalizations.t('invitation_state_changed'),
          };
        }
        if (invitationResult['code'] == 'PROFILE_COMPLETION_REQUIRED') {
          return {
            'success': false,
            'requiresProfileCompletion': true,
            'message': AppLocalizations.t('invitation_profile_required'),
          };
        }
        return {
          'success': false,
          'message':
              invitationResult['message']?.toString() ??
              AppLocalizations.t('invitation_accept_error'),
        };
      }
      final acceptanceData = invitationResult['data'];
      alreadyProcessed =
          acceptanceData is Map && acceptanceData['already_processed'] == true;

      stage = 'marquage de la notification comme lue';
      if (notification.id != null && notification.id!.isNotEmpty) {
        final readResult = await markAsRead(notification.id!);
        if (readResult['success'] != true) {
          debugPrint('[INVITATION] Échec $stage: $readResult');
          return {
            'success': false,
            'message': AppLocalizations.t('notification_mark_read_error'),
          };
        }
      }

      if (alreadyProcessed) {
        return {
          'success': true,
          'message': AppLocalizations.t('invitation_accept_success'),
        };
      }

      stage = 'notification des membres';
      final notificationsResult = await notifyMembersOfJoin(
        groupId: groupId,
        cycleId: cycleId,
        joiningUserId: user.id,
        joiningUserName: [user.prenom, user.nom]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .join(' '),
        groupName: notification.payload?['groupe_nom']?.toString() ?? '',
      );

      final notificationStatusKey =
          notificationsResult['success'] != true
              ? 'invitation_accept_notifications_pending'
              : notificationsResult['pushSent'] == true
              ? 'invitation_accept_success'
              : 'invitation_accept_push_pending';

      return {
        'success': true,
        'message': AppLocalizations.t(notificationStatusKey),
      };
    } on DioException catch (error) {
      debugPrint('[INVITATION] Exception HTTP pendant $stage.');
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'invitation_accept_error',
        ),
      };
    } catch (error, stackTrace) {
      debugPrint('[INVITATION] Exception inattendue pendant $stage: $error');
      debugPrintStack(stackTrace: stackTrace);
      return {
        'success': false,
        'message': AppLocalizations.t('invitation_accept_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> notifyMembersOfJoin({
    required String groupId,
    required String cycleId,
    required String joiningUserId,
    required String joiningUserName,
    required String groupName,
  }) async {
    try {
      final responses = await Future.wait([
        ApiService.dio.get('groupes/$groupId/membres'),
        ApiService.dio.get('cycles/$cycleId/membres'),
      ]);
      final groupMembers = _membershipRows(responses[0].data);
      final cycleMembers = _membershipRows(responses[1].data);
      if (groupMembers == null || cycleMembers == null) {
        debugPrint(
          '[API] Member-joined notifications skipped: invalid member lists.',
        );
        return {'success': false, 'pushSent': false};
      }
      _debugLogCycleMemberTokens(cycleMembers);
      final notificationsByUser = <String, Notification>{};
      final tokensByUser = <String, String?>{};
      for (final member in groupMembers) {
        if (_shouldNotifyMember(member, joiningUserId)) {
          final memberId = member['utilisateur_id'].toString();
          tokensByUser[memberId] = _firebaseTokenFromMember(member);
          notificationsByUser.putIfAbsent(
            memberId,
            () => _buildMemberJoinedNotification(
              memberId: member['utilisateur_id'].toString(),
              groupId: groupId,
              cycleId: cycleId,
              joiningUserName: joiningUserName,
              groupName: groupName,
              scope: 'GROUPE',
            ),
          );
        }
      }
      for (final member in cycleMembers) {
        if (_shouldNotifyMember(member, joiningUserId)) {
          final memberId = member['utilisateur_id'].toString();
          tokensByUser.putIfAbsent(
            memberId,
            () => _firebaseTokenFromMember(member),
          );
          notificationsByUser.putIfAbsent(
            memberId,
            () => _buildMemberJoinedNotification(
              memberId: member['utilisateur_id'].toString(),
              groupId: groupId,
              cycleId: cycleId,
              joiningUserName: joiningUserName,
              groupName: groupName,
              scope: 'CYCLE',
            ),
          );
        }
      }

      final results = await Future.wait(
        notificationsByUser.values.map(
          (notification) => _createMemberJoinedNotification(
            notification,
            deviceToken: tokensByUser[notification.userId],
          ),
        ),
      );
      final allCreated = results.every((result) => result['success'] == true);
      final allPushSent =
          allCreated && results.every((result) => result['pushSent'] == true);
      return {'success': allCreated, 'pushSent': allPushSent};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {'success': false, 'pushSent': false};
    } catch (error) {
      debugPrint('[API] Member-joined notification fan-out failed: $error');
      return {'success': false, 'pushSent': false};
    }
  }

  static List<Map<String, dynamic>>? _membershipRows(dynamic response) {
    if (response is! Map || response['success'] != true) return null;
    final data = response['data'];
    final rows =
        data is List
            ? data
            : data is Map && data['data'] is List
            ? data['data'] as List
            : null;
    if (rows == null) return null;
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  static bool _shouldNotifyMember(
    Map<String, dynamic> member,
    String joiningUserId,
  ) {
    final userId = member['utilisateur_id']?.toString();
    final role = member['role']?.toString().trim().toUpperCase();
    return userId != null &&
        userId.isNotEmpty &&
        userId != joiningUserId &&
        (member['active']?.toString() ?? '1') == '1' &&
        role != 'INVITE';
  }

  static String? _firebaseTokenFromMember(Map<String, dynamic> member) {
    final user = member['utilisateur'];
    final token =
        member['token_firebase']?.toString() ??
        (user is Map ? user['token_firebase']?.toString() : null);
    final normalized = token?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static void _debugLogCycleMemberTokens(List<Map<String, dynamic>> members) {
    if (!kDebugMode) return;

    debugPrint(
      '[FCM][ACCEPTATION_CYCLE] Tokens de ${members.length} membre(s):',
    );
    for (final member in members) {
      final user = member['utilisateur'];
      final token =
          member['token_firebase']?.toString() ??
          (user is Map ? user['token_firebase']?.toString() : null);
      final userId = member['utilisateur_id']?.toString() ?? '(id absent)';
      debugPrint(
        '[FCM][ACCEPTATION_CYCLE] utilisateur_id=$userId '
        'token_firebase=${token?.trim().isNotEmpty == true ? token : '(absent)'}.',
      );
    }
  }

  static Notification _buildMemberJoinedNotification({
    required String memberId,
    required String groupId,
    required String cycleId,
    required String joiningUserName,
    required String groupName,
    required String scope,
  }) {
    final isCycle = scope == 'CYCLE';
    return Notification(
      userId: memberId,
      scope: scope,
      groupId: groupId,
      cycleId: isCycle ? cycleId : null,
      title: AppLocalizations.t(
        isCycle
            ? 'notification_member_joined_cycle_title'
            : 'notification_member_joined_group_title',
      ),
      description: AppLocalizations.t(
        isCycle
            ? 'notification_member_joined_cycle_body'
            : 'notification_member_joined_group_body',
        args: [joiningUserName, groupName],
      ),
      eventType: 'MEMBRE_REJOINT',
      notifiableType:
          isCycle ? 'App\\Models\\Cycle' : 'App\\Models\\GroupeNjangi',
      notifiableId: isCycle ? cycleId : groupId,
      payload: {
        'screen': isCycle ? 'CYCLE_MEMBERS' : 'GROUP_MEMBERS',
        'groupe_id': groupId,
        if (isCycle) 'cycle_id': cycleId,
      },
    );
  }

  static Future<Map<String, dynamic>> _createMemberJoinedNotification(
    Notification notification, {
    required String? deviceToken,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'notifications',
        data: notification.toCreateJson(),
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final success =
          body is Map &&
          (body['success'] == true || body['status'] == 'success') &&
          data is Map;
      if (!success) {
        debugPrint('[API] Member-joined notification creation failed: $body');
        return {'success': false, 'pushSent': false};
      }

      final created = Notification.fromJson(Map<String, dynamic>.from(data));
      var pushSent = created.pushSent;
      final fcmToken = deviceToken?.trim();
      if (!pushSent && fcmToken != null && fcmToken.isNotEmpty) {
        try {
          pushSent = await FirebaseApi().sendPushNotification(
            deviceToken: fcmToken,
            title: notification.title,
            body: notification.description,
            data: {
              'type_evenement': notification.eventType,
              'screen': notification.payload?['screen']?.toString() ?? '',
              'notification_id': created.id ?? '',
              'groupe_id': notification.groupId ?? '',
              'cycle_id': notification.cycleId ?? '',
            },
          );
        } catch (error, stackTrace) {
          debugPrint(
            '[FCM][MEMBRE_REJOINT] Envoi direct échoué '
            'pour ${notification.userId}: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }
      }
      return {'success': true, 'pushSent': pushSent};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {'success': false, 'pushSent': false};
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Controllers_distant/CycleController.dart';
import 'package:njangi/Controllers_distant/MembreGroupeController.dart';
import 'package:njangi/Controllers_distant/MembreGroupeCycleController.dart';
import 'package:njangi/Models/Notification.dart';
import 'package:njangi/api/firebase_api.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class NotificationController {
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
      final notifications = rows
          .whereType<Map>()
          .map((row) => Notification.fromJson(Map<String, dynamic>.from(row)))
          .where(
            (notification) =>
                notification.active == '1' &&
                (notification.expiresAt == null ||
                    notification.expiresAt!.isAfter(now)),
          )
          .toList(growable: false);

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
    var stage = 'chargement de la session';
    try {
      final user = await StorageManager.getUser();
      final invalidInvitation =
          !notification.isInvitation ||
          notification.id == null ||
          groupId == null ||
          cycleId == null ||
          user == null ||
          user.id.isEmpty;
      if (invalidInvitation) {
        debugPrint(
          '[INVITATION] Acceptation interrompue: données manquantes '
          '(isInvitation=${notification.isInvitation}, '
          'hasNotificationId=${notification.id != null}, '
          'hasGroupId=${groupId != null}, hasCycleId=${cycleId != null}, '
          'hasUser=${user != null && user.id.isNotEmpty}).',
        );
        return {
          'success': false,
          'message': AppLocalizations.t('invitation_accept_error'),
        };
      }

      stage = 'acceptation dans le groupe';
      final groupResult = await MembreGroupeController.acceptInvite(
        groupeId: groupId,
        utilisateurId: user.id,
      );
      if (groupResult['success'] != true) {
        debugPrint('[INVITATION] Échec étape groupe: $groupResult');
        return {
          'success': false,
          'message':
              groupResult['message']?.toString() ??
              AppLocalizations.t('invitation_accept_error'),
        };
      }

      stage = 'acceptation dans le cycle';
      final cycleResult = await MembreGroupeCycleController.acceptInvite(
        cycleId: cycleId,
        utilisateurId: user.id,
      );
      if (cycleResult['success'] != true) {
        debugPrint('[INVITATION] Échec étape cycle: $cycleResult');
        return {
          'success': false,
          'message':
              cycleResult['message']?.toString() ??
              AppLocalizations.t('invitation_accept_error'),
        };
      }

      stage = 'marquage de la notification comme lue';
      final readResult = await markAsRead(notification.id!);
      if (readResult['success'] != true) {
        debugPrint('[INVITATION] Échec $stage: $readResult');
        return {
          'success': false,
          'message': AppLocalizations.t('notification_mark_read_error'),
        };
      }

      stage = 'notification des membres';
      final cycle = await CycleController.getById(cycleId);
      final notificationsResult = await notifyMembersOfJoin(
        groupId: groupId,
        cycleId: cycleId,
        joiningUserId: user.id,
        joiningUserName: [user.prenom, user.nom]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .join(' '),
        groupName:
            cycle?.groupName ??
            notification.payload?['groupe_nom']?.toString() ??
            '',
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
      _debugLogMemberFcmTokens('GROUPE', groupMembers);
      _debugLogMemberFcmTokens('CYCLE', cycleMembers);

      final notificationsByUser = <String, Notification>{};
      final tokensByUser = <String, String?>{};
      for (final member in groupMembers) {
        if (_shouldNotifyMember(member, joiningUserId)) {
          final memberId = member['utilisateur_id'].toString();
          final token = _firebaseTokenFromMember(member);
          if (token != null) tokensByUser[memberId] = token;
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
          final token = _firebaseTokenFromMember(member);
          if (token != null) tokensByUser.putIfAbsent(memberId, () => token);
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

  static void _debugLogMemberFcmTokens(
    String scope,
    List<Map<String, dynamic>> members,
  ) {
    if (!kDebugMode) return;

    debugPrint(
      '[FCM][DEBUG][$scope] Tokens reçus pour ${members.length} membre(s):',
    );
    for (final member in members) {
      final userId = member['utilisateur_id']?.toString() ?? '(id absent)';
      final token = _firebaseTokenFromMember(member) ?? '(absent)';
      debugPrint(
        '[FCM][DEBUG][$scope] utilisateur_id=$userId token_firebase=$token',
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
      if (!pushSent) {
        if (fcmToken == null || fcmToken.isEmpty) {
          debugPrint(
            '[FCM][MEMBRE_REJOINT] Aucun token FCM pour '
            'userId=${notification.userId}.',
          );
        } else {
          try {
            pushSent = await FirebaseApi().sendPushNotification(
              deviceToken: fcmToken,
              title: notification.title,
              body: notification.description,
              data: {
                'type': notification.eventType,
                'screen': notification.payload?['screen']?.toString() ?? '',
                'notification_id': created.id ?? '',
                'groupe_id': notification.groupId ?? '',
                'cycle_id': notification.cycleId ?? '',
              },
            );
            debugPrint(
              '[FCM][MEMBRE_REJOINT] userId=${notification.userId}: '
              '${pushSent ? 'envoyé' : 'échec'}.',
            );
          } catch (error, stackTrace) {
            debugPrint(
              '[FCM][MEMBRE_REJOINT] Erreur pour '
              'userId=${notification.userId}: $error',
            );
            debugPrintStack(stackTrace: stackTrace);
          }
        }
      }
      return {'success': true, 'pushSent': pushSent};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {'success': false, 'pushSent': false};
    }
  }

  static Future<Map<String, dynamic>> createInvitation({
    required String userId,
    required String? tokenFirebase,
    required String groupId,
    required String cycleId,
    required String groupName,
  }) async {
    final notification = Notification(
      userId: userId,
      scope: 'UTILISATEUR',
      groupId: groupId,
      cycleId: cycleId,
      title: AppLocalizations.t('invitation_notification_title'),
      description: AppLocalizations.t(
        'invitation_notification_body',
        args: [groupName],
      ),
      eventType: 'INVITATION_GROUPE',
      notifiableType: 'App\\Models\\GroupeNjangi',
      notifiableId: groupId,
      payload: {
        'screen': 'INVITATION_DETAILS',
        'groupe_id': groupId,
        'cycle_id': cycleId,
      },
    );

    try {
      final response = await ApiService.dio.post(
        'notifications',
        data: notification.toCreateJson(),
      );
      final body = response.data;
      debugPrint(
        '[INVITATION][NOTIFICATION] POST ${response.requestOptions.uri} '
        'status=${response.statusCode} response=$body',
      );
      final succeeded =
          body is Map &&
          (body['success'] == true || body['status'] == 'success');
      final data = body is Map ? body['data'] : null;

      if (!succeeded || data is! Map) {
        debugPrint('[API] Invitation notification creation failed: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('invite_notification_error'),
        };
      }

      final created = Notification.fromJson(Map<String, dynamic>.from(data));
      var pushSent = created.pushSent;
      if (!pushSent &&
          (tokenFirebase == null || tokenFirebase.trim().isEmpty)) {
        debugPrint(
          '[INVITATION][FCM] Envoi impossible: aucun token FCM pour '
          'userId=$userId.',
        );
      }
      if (!pushSent &&
          tokenFirebase != null &&
          tokenFirebase.trim().isNotEmpty) {
        try {
          pushSent = await FirebaseApi().sendPushNotification(
            deviceToken: tokenFirebase,
            title: created.title,
            body: created.description,
            data: {
              'type': created.eventType,
              'screen': 'INVITATION_DETAILS',
              'notification_id': created.id ?? '',
              'groupe_id': groupId,
              'cycle_id': cycleId,
            },
          );
          debugPrint(
            '[INVITATION][FCM] Envoi direct via FirebaseApi: '
            '${pushSent ? 'succès' : 'échec'} (userId=$userId).',
          );
        } catch (error, stackTrace) {
          debugPrint('[INVITATION][FCM] Exception pendant l’envoi: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      return {
        'success': true,
        'notification': created.copyWith(pushSent: pushSent),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'invite_notification_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Creating invitation notification failed: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('invite_notification_error'),
      };
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Models/MembreGroupe.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class MembreGroupeController {
  static Future<Map<String, dynamic>> acceptInvite({
    required String groupeId,
    required String utilisateurId,
  }) async {
    try {
      final payload = {'role': 'MEMBRE', 'statut': 'ACTIF', 'active': '1'};
      final endpoint =
          '${AppConstants.groupes}/$groupeId/membres/update/$utilisateurId';
      debugPrint(
        '[API] PUT ${ApiService.dio.options.baseUrl}$endpoint payload=$payload',
      );
      final update = await ApiService.dio.put(endpoint, data: payload);
      final updateBody = update.data;
      debugPrint('[API] Group invite acceptance response: $updateBody');
      final responseData = updateBody is Map ? updateBody['data'] : null;
      final roleUpdated =
          responseData is Map &&
          responseData['role']?.toString().trim().toUpperCase() == 'MEMBRE';
      final statusUpdated =
          responseData is Map &&
          responseData['statut']?.toString().trim().toUpperCase() == 'ACTIF';
      final activeUpdated =
          responseData is Map && responseData['active']?.toString() == '1';
      final apiSucceeded =
          updateBody is Map &&
          (updateBody['success'] == true ||
              updateBody['status']?.toString().toLowerCase() == 'success');
      final succeeded =
          apiSucceeded && roleUpdated && statusUpdated && activeUpdated;
      if (!succeeded) {
        debugPrint(
          '[API] Group invite acceptance was not applied: '
          'success=$apiSucceeded role=$roleUpdated status=$statusUpdated '
          'active=$activeUpdated',
        );
      }
      return {'success': succeeded};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'invitation_accept_error',
        ),
      };
    } catch (error, stackTrace) {
      debugPrint('[API] Accepting group invite failed unexpectedly: $error');
      debugPrintStack(stackTrace: stackTrace);
      return {
        'success': false,
        'message': AppLocalizations.t('invitation_accept_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> addUserAsInvite({
    required String groupeId,
    required String utilisateurId,
  }) async {
    try {
      final endpoint = '${AppConstants.groupes}/$groupeId/membres';
      final payload = {
        'utilisateur_id': utilisateurId,
        'role': 'INVITE',
        'statut': 'ACTIF',
        'active': '0',
      };
      debugPrint(
        '[INVITATION][GROUPE] POST ${ApiService.dio.options.baseUrl}'
        '$endpoint payload=$payload',
      );
      final response = await ApiService.dio.post(endpoint, data: payload);
      final body = response.data;
      debugPrint('[INVITATION][GROUPE] Réponse HTTP: $body');
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Group invitation returned failure: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('invite_persist_error'),
        };
      }

      return {
        'success': true,
        'membre': MembreGroupe.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        ),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'invite_persist_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Adding invitee to group failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('invite_persist_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> addCurrentUser({
    required String groupeId,
  }) async {
    final utilisateur = await StorageManager.getUser();
    if (utilisateur == null || utilisateur.id.isEmpty) {
      return {
        'success': false,
        'message': AppLocalizations.t('community_member_add_error'),
      };
    }

    try {
      final response = await ApiService.dio.post(
        '${AppConstants.groupes}/$groupeId/membres',
        data: {
          'utilisateur_id': utilisateur.id,
          'role': 'ADMIN',
          'statut': 'ACTIF',
          'active': '1',
        },
      );
      final body = response.data;

      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        return {
          'success': false,
          'message':
              body is Map
                  ? body['message']?.toString() ??
                      AppLocalizations.t('community_member_add_error')
                  : AppLocalizations.t('community_member_add_error'),
        };
      }

      final member = MembreGroupe.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
      if (member.role.trim().toUpperCase() != 'ADMIN' ||
          member.active.trim() != '1' ||
          member.statut.trim().toUpperCase() != 'ACTIF') {
        debugPrint(
          '[API] Creator membership returned unexpected values: '
          'role=${member.role}, active=${member.active}, statut=${member.statut}',
        );
        return {
          'success': false,
          'message': AppLocalizations.t('community_member_add_error'),
        };
      }

      return {
        'success': true,
        'message': body['message']?.toString(),
        'membre': member,
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      final responseData = error.response?.data;
      return {
        'success': false,
        'message':
            responseData is Map
                ? responseData['message']?.toString() ??
                    ApiService.localizedErrorMessage(
                      error,
                      fallbackKey: 'community_member_add_error',
                    )
                : ApiService.localizedErrorMessage(
                  error,
                  fallbackKey: 'community_member_add_error',
                ),
      };
    } catch (error) {
      debugPrint('[API] Adding creator to group failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('community_member_add_error'),
      };
    }
  }
}

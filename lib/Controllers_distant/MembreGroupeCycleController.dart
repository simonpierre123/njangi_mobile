import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Models/MembreGroupeCycle.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class MembreGroupeCycleController {
  static Future<Map<String, dynamic>> acceptInvite({
    required String cycleId,
    required String utilisateurId,
  }) async {
    try {
      final payload = {'role': 'MEMBRE', 'statut': 'ACTIF'};
      final endpoint =
          '${AppConstants.cycles}/$cycleId/membres/update/$utilisateurId';
      debugPrint(
        '[API] PUT ${ApiService.dio.options.baseUrl}$endpoint payload=$payload',
      );
      final update = await ApiService.dio.put(endpoint, data: payload);
      final updateBody = update.data;
      debugPrint('[API] Cycle invite acceptance response: $updateBody');
      final responseData = updateBody is Map ? updateBody['data'] : null;
      final roleUpdated =
          responseData is Map &&
          responseData['role']?.toString().trim().toUpperCase() == 'MEMBRE';
      final statusUpdated =
          responseData is Map &&
          responseData['statut']?.toString().trim().toUpperCase() == 'ACTIF';
      final apiSucceeded =
          updateBody is Map &&
          (updateBody['success'] == true ||
              updateBody['status']?.toString().toLowerCase() == 'success');
      final succeeded = apiSucceeded && roleUpdated && statusUpdated;
      if (!succeeded) {
        debugPrint(
          '[API] Cycle invite acceptance was not applied: '
          'success=$apiSucceeded role=$roleUpdated status=$statusUpdated',
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
      debugPrint('[API] Accepting cycle invite failed unexpectedly: $error');
      debugPrintStack(stackTrace: stackTrace);
      return {
        'success': false,
        'message': AppLocalizations.t('invitation_accept_error'),
      };
    }
  }

  static Future<List<MembreGroupeCycle>?> getForCycle(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        '${AppConstants.cycles}/$cycleId/membres',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        debugPrint(
          '[API] Cycle membership lookup returned an invalid response: $body',
        );
        return null;
      }

      final data = body['data'];
      final rows =
          data is List
              ? data
              : data is Map && data['data'] is List
              ? data['data'] as List
              : null;
      if (rows == null) return null;

      return rows
          .whereType<Map>()
          .map(
            (row) => MembreGroupeCycle.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'MembreGroupeCycleController.getForCycle',
        error,
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>> addUserAsInvite({
    required String cycleId,
    required String utilisateurId,
  }) async {
    try {
      final now = DateTime.now();
      final dateAdhesion =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final endpoint = '${AppConstants.cycles}/$cycleId/membres';
      final payload = {
        'utilisateur_id': utilisateurId,
        'role': 'INVITE',
        'date_adhesion': dateAdhesion,
        'statut': 'ACTIF',
      };
      debugPrint(
        '[INVITATION][CYCLE] POST ${ApiService.dio.options.baseUrl}'
        '$endpoint payload=$payload',
      );
      final response = await ApiService.dio.post(endpoint, data: payload);
      final body = response.data;
      debugPrint('[INVITATION][CYCLE] Réponse HTTP: $body');
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Cycle invitation returned failure: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('invite_persist_error'),
        };
      }

      return {
        'success': true,
        'member': MembreGroupeCycle.fromJson(
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
      debugPrint('[API] Adding invitee to cycle failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('invite_persist_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> addCurrentUserAsAdmin({
    required String cycleId,
  }) async {
    try {
      final user = await StorageManager.getUser();
      if (user == null || user.id.isEmpty) {
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_admin_add_error'),
        };
      }

      final membersResponse = await ApiService.dio.get(
        '${AppConstants.cycles}/$cycleId/membres',
      );
      final membersBody = membersResponse.data;
      if (membersBody is! Map || membersBody['success'] != true) {
        debugPrint(
          '[API] Cycle members lookup returned an invalid response: '
          '$membersBody',
        );
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_admin_add_error'),
        };
      }

      final rawRows = membersBody['data'];
      final rows =
          rawRows is List
              ? rawRows
              : rawRows is Map && rawRows['data'] is List
              ? rawRows['data'] as List
              : const <dynamic>[];
      final existingRow =
          rows
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .where((row) => row['utilisateur_id']?.toString() == user.id)
              .firstOrNull;

      if (existingRow != null) {
        final member = MembreGroupeCycle.fromJson(existingRow);
        if (member.role.toUpperCase() == 'ADMIN') {
          return {'success': true, 'member': member};
        }
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_admin_add_error'),
        };
      }

      final now = DateTime.now();
      final dateAdhesion =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final response = await ApiService.dio.post(
        '${AppConstants.cycles}/$cycleId/membres',
        data: {
          'utilisateur_id': user.id,
          'role': 'ADMIN',
          'date_adhesion': dateAdhesion,
          'statut': 'ACTIF',
        },
      );
      final body = response.data;

      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Cycle admin enrollment returned failure: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_admin_add_error'),
        };
      }

      return {
        'success': true,
        'member': MembreGroupeCycle.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        ),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_admin_add_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Adding creator to cycle failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_admin_add_error'),
      };
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Models/MembreGroupe.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class MembreGroupeController {
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

      return {
        'success': true,
        'message': body['message']?.toString(),
        'membre': MembreGroupe.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        ),
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

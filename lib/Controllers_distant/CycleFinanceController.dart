import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';

class CycleFinanceController {
  static Future<Map<String, dynamic>> createEmergencyRequest({
    required String cycleId,
    required String motif,
    required num montantDemande,
  }) => _post(
    '${AppConstants.cycles}/$cycleId/secours/demandes',
    {'motif': motif, 'montant_demande': montantDemande},
    fallbackKey: 'SERVER_ERROR',
  );

  static Future<Map<String, dynamic>> decideEmergencyRequest({
    required String cycleId,
    required String demandeId,
    required String decision,
    num? montantAlloue,
  }) => _post(
    '${AppConstants.cycles}/$cycleId/secours/demandes/$demandeId/decision',
    {
      'decision': decision,
      if (montantAlloue != null) 'montant_alloue': montantAlloue,
    },
    fallbackKey: 'SERVER_ERROR',
  );

  static Future<Map<String, dynamic>> submitOperation({
    required String cycleId,
    required String type,
    required String utilisateurId,
    required num montant,
    required String description,
    String statut = 'EN_ATTENTE',
  }) => _post('${AppConstants.cycles}/$cycleId/operations', {
    'type': type,
    'utilisateur_id': utilisateurId,
    'montant': montant,
    'description': description,
    'statut': statut,
  }, fallbackKey: 'SERVER_ERROR');

  static Future<Map<String, dynamic>> decideOperation({
    required String cycleId,
    required String operationId,
    required String decision,
    String? commentaire,
  }) => _post(
    '${AppConstants.cycles}/$cycleId/operations/$operationId/decision',
    {'decision': decision, if (commentaire != null) 'commentaire': commentaire},
    fallbackKey: 'SERVER_ERROR',
  );

  static Future<Map<String, dynamic>> closeCycle(String cycleId) => _post(
    '${AppConstants.cycles}/$cycleId/cloture',
    null,
    fallbackKey: 'SERVER_ERROR',
  );

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic>? data, {
    required String fallbackKey,
  }) async {
    try {
      final response = await ApiService.dio.post(endpoint, data: data);
      final body = response.data;
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message': body['message']?.toString(),
          'data': body['data'],
        };
      }
      return {
        'success': false,
        'message':
            body is Map
                ? body['message']?.toString() ?? AppLocalizations.t(fallbackKey)
                : AppLocalizations.t(fallbackKey),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: fallbackKey,
        ),
      };
    } catch (error) {
      debugPrint('[API] POST $endpoint failed unexpectedly: $error');
      return {'success': false, 'message': AppLocalizations.t(fallbackKey)};
    }
  }
}

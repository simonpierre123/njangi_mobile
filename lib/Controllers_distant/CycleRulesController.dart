import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Models/Cycle.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CycleRulesController {
  static Future<Map<String, dynamic>> getRules(String cycleId) async {
    try {
      final response = await ApiService.dio.get('cycles/$cycleId/regles');
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_rules_load_error'),
        };
      }

      final cycleData = data['cycle'];
      if (cycleData is! Map) {
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_rules_load_error'),
        };
      }

      return {
        'success': true,
        'cycle': Cycle.fromJson(Map<String, dynamic>.from(cycleData)),
        'isAdmin': data['is_admin'] == true,
        'proposal':
            data['pending_proposal'] is Map
                ? Map<String, dynamic>.from(data['pending_proposal'] as Map)
                : null,
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_rules_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError('CycleRulesController.getRules', error);
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_rules_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> proposeChanges({
    required String cycleId,
    required Map<String, dynamic> changes,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/regles/propositions',
        data: {'changes': changes},
      );
      final body = response.data;
      if (body is Map && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_rules_proposal_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_rules_proposal_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Cycle rule proposal failed: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_rules_proposal_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> decideProposal({
    required String cycleId,
    required String proposalId,
    required String decision,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/regles/propositions/$proposalId/decision',
        data: {'decision': decision},
      );
      final body = response.data;
      if (body is Map && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_rules_decision_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_rules_decision_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Cycle rule decision failed: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_rules_decision_error'),
      };
    }
  }
}

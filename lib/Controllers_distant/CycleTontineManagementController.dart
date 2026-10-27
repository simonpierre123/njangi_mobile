import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CycleTontineManagementController {
  static String _base(String cycleId) => 'cycles/$cycleId/tontine/gestion';

  static Future<Map<String, dynamic>> load(String cycleId) async {
    try {
      final response = await ApiService.dio.get(_base(cycleId));
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Tontine management overview',
        statusCode: response.statusCode,
        body: body,
      );
      if (body is! Map ||
          !(body['success'] == true || body['status'] == 'success') ||
          body['data'] is! Map) {
        debugPrint('[API] Tontine management overview is invalid: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('tontine_management_load_error'),
        };
      }
      return {
        'success': true,
        'data': Map<String, dynamic>.from(body['data'] as Map),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'tontine_management_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineManagementController.load',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_management_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> review({
    required String cycleId,
    required String operationId,
    required String decision,
    String? reason,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/tontine/cotisations/$operationId/review',
        data: {
          'decision': decision,
          if (decision == 'REJETE' && reason != null) 'motif_rejet': reason,
        },
      );
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Tontine contribution review',
        statusCode: response.statusCode,
        body: body,
      );
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message': AppLocalizations.t(
            decision == 'VALIDE'
                ? 'tontine_contribution_validated'
                : 'tontine_contribution_rejected',
          ),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_contribution_review_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'tontine_contribution_review_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineManagementController.review',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_contribution_review_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> closePeriod({
    required String cycleId,
    required String tourId,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/tontine/tours/$tourId/cloturer',
      );
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Tontine contribution period closure',
        statusCode: response.statusCode,
        body: body,
      );
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message': AppLocalizations.t('tontine_period_closed'),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_period_close_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'tontine_period_close_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineManagementController.closePeriod',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_period_close_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> remind({
    required String cycleId,
    required String tourId,
    required String membershipId,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/tontine/tours/$tourId/rappels/$membershipId',
      );
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Personalized tontine contribution reminder',
        statusCode: response.statusCode,
        body: body,
      );
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message': AppLocalizations.t('tontine_reminder_sent'),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_reminder_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'tontine_reminder_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineManagementController.remind',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_reminder_error'),
      };
    }
  }
}

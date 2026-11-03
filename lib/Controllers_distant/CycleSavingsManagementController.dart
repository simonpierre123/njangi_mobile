import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CycleSavingsManagementController {
  static String _base(String cycleId) => 'cycles/$cycleId/epargne';

  static Future<Map<String, dynamic>> load(String cycleId) async {
    try {
      final response = await ApiService.dio.get('${_base(cycleId)}/gestion');
      return _parseResponse(
        response.data,
        statusCode: response.statusCode,
        operation: 'Savings management overview',
        fallbackKey: 'savings_management_load_error',
      );
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'savings_management_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError('CycleSavingsManagementController.load', error);
      return {
        'success': false,
        'message': AppLocalizations.t('savings_management_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> archives(String cycleId) async {
    try {
      final response = await ApiService.dio.get('${_base(cycleId)}/archives');
      ApiService.logServerResponse(
        operation: 'Savings archives',
        statusCode: response.statusCode,
        body: response.data,
      );
      final body = response.data;
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success') &&
          body['data'] is List) {
        return {
          'success': true,
          'data': (body['data'] as List)
              .whereType<Map>()
              .map(Map<String, dynamic>.from)
              .toList(),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('savings_archives_load_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'savings_archives_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleSavingsManagementController.archives',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('savings_archives_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> archive({
    required String cycleId,
    required String archiveId,
  }) async {
    try {
      final response = await ApiService.dio.get(
        '${_base(cycleId)}/archives/$archiveId',
      );
      return _parseResponse(
        response.data,
        statusCode: response.statusCode,
        operation: 'Savings archive details',
        fallbackKey: 'savings_archives_load_error',
      );
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'savings_archives_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleSavingsManagementController.archive',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('savings_archives_load_error'),
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
        '${_base(cycleId)}/cotisations/$operationId/review',
        data: {
          'decision': decision,
          if (decision == 'REJETE' && reason != null) 'motif_rejet': reason,
        },
      );
      ApiService.logServerResponse(
        operation: 'Savings contribution review',
        statusCode: response.statusCode,
        body: response.data,
      );
      final body = response.data;
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message': AppLocalizations.t(
            decision == 'VALIDE'
                ? 'savings_contribution_validated'
                : 'savings_contribution_rejected',
          ),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('savings_contribution_review_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'savings_contribution_review_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleSavingsManagementController.review',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('savings_contribution_review_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> closePeriod({
    required String cycleId,
    required String period,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '${_base(cycleId)}/periodes/cloturer',
        data: {'periode': period},
      );
      ApiService.logServerResponse(
        operation: 'Savings period closure',
        statusCode: response.statusCode,
        body: response.data,
      );
      final body = response.data;
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message': AppLocalizations.t('savings_period_closed'),
          'data': body['data'],
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('savings_period_close_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'savings_period_close_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleSavingsManagementController.closePeriod',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('savings_period_close_error'),
      };
    }
  }

  static Map<String, dynamic> _parseResponse(
    dynamic body, {
    required int? statusCode,
    required String operation,
    required String fallbackKey,
  }) {
    ApiService.logServerResponse(
      operation: operation,
      statusCode: statusCode,
      body: body,
    );
    if (body is Map &&
        (body['success'] == true || body['status'] == 'success') &&
        body['data'] is Map) {
      return {
        'success': true,
        'data': Map<String, dynamic>.from(body['data'] as Map),
      };
    }
    debugPrint('[API] $operation response is invalid: $body');
    return {
      'success': false,
      'message': AppLocalizations.t(fallbackKey),
    };
  }
}

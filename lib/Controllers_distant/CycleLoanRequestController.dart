import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CycleLoanRequestController {
  static Future<Map<String, dynamic>> submit({
    required String groupId,
    required String cycleId,
    required int amount,
    required DateTime repaymentDate,
    String? reason,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'groupes/$groupId/cycles/$cycleId/demande-prets',
        data: {
          'montant_demande': amount,
          'date_remboursement_souhaitee':
              '${repaymentDate.year.toString().padLeft(4, '0')}-'
              '${repaymentDate.month.toString().padLeft(2, '0')}-'
              '${repaymentDate.day.toString().padLeft(2, '0')}',
          'motif': reason?.trim().isEmpty == true ? null : reason?.trim(),
          'locale': AppLocalizations.locale.value,
        },
      );
      final body = response.data;
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        return {
          'success': true,
          'message':
              body['message']?.toString() ??
              AppLocalizations.t('loan_request_submit_success'),
        };
      }

      debugPrint('[API] Loan request returned an invalid response: $body');
      return {
        'success': false,
        'message': AppLocalizations.t('loan_request_submit_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'loan_request_submit_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError('CycleLoanRequestController.submit', error);
      return {
        'success': false,
        'message': AppLocalizations.t('loan_request_submit_error'),
      };
    }
  }
}

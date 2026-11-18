import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/ModeView/treasury_model.dart';

class CycleTontineContributionController {
  static String _endpoint(String cycleId) =>
      'cycles/$cycleId/tontine/cotisations';

  static Future<Map<String, dynamic>> getLatestValidated(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        '${_endpoint(cycleId)}/derniere-validee',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true) {
        debugPrint('[API] Latest validated contribution is invalid: $body');
        return {'success': false};
      }
      if (data == null) return {'success': true, 'receipt': null};
      if (data is! Map) {
        debugPrint('[API] Latest validated contribution data is invalid: $data');
        return {'success': false};
      }

      final operation = Map<String, dynamic>.from(data);
      final cycle = operation['cycle'];
      final cycleData =
          cycle is Map ? Map<String, dynamic>.from(cycle) : <String, dynamic>{};
      final validator = operation['validateur'];
      final validatorData =
          validator is Map
              ? Map<String, dynamic>.from(validator)
              : <String, dynamic>{};
      final date = DateTime.tryParse(
        operation['date_operation']?.toString() ?? '',
      );
      final locale = AppLocalizations.locale.value;
      final dateLabel =
          date == null ? '—' : DateFormat.yMMMd(locale).format(date);
      final monthLabel =
          date == null ? '—' : DateFormat('MMMM yyyy', locale).format(date);
      final amount = num.tryParse(operation['montant']?.toString() ?? '') ?? 0;
      final currency = cycleData['devise']?.toString() ?? 'XAF';
      final tour = operation['tour'];
      final tourData =
          tour is Map ? Map<String, dynamic>.from(tour) : <String, dynamic>{};
      final tourOrder = tourData['ordre']?.toString();

      return {
        'success': true,
        'receipt': ContributionReceipt(
          title: AppLocalizations.t('latest_contribution_title', args: [
            monthLabel,
          ]),
          dueLabel: AppLocalizations.t(
            'contribution_validated_on',
            args: [dateLabel],
          ),
          amount:
              '${NumberFormat.decimalPattern(locale).format(amount)} $currency',
          operationId: operation['id']?.toString(),
          cycleLabel: AppLocalizations.t(
            'cycle_history_item',
            args: [cycleData['numero']?.toString() ?? '—'],
          ),
          groupName: cycleData['groupe_nom']?.toString(),
          period:
              operation['periode']?.toString() ??
              (tourOrder == null ? null : 'TOUR-$tourOrder'),
          operationDate: operation['date_operation']?.toString(),
          validatedAt: operation['valide_le']?.toString(),
          paymentMode: operation['mode_paiement']?.toString(),
          operator: operation['operateur']?.toString(),
          paymentReference: operation['reference_paiement']?.toString(),
          validatorName: validatorData['nom_complet']?.toString(),
          isSimulation: operation['is_simulation'] == true,
        ),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {'success': false};
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineContributionController.getLatestValidated',
        error,
      );
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> getContext(String cycleId) async {
    try {
      final response = await ApiService.dio.get(_endpoint(cycleId));
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Tontine contribution context',
        statusCode: response.statusCode,
        body: body,
      );
      if (body is! Map ||
          !(body['success'] == true || body['status'] == 'success') ||
          body['data'] is! Map) {
        debugPrint('[API] Tontine contribution context is invalid: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('tontine_contribution_load_error'),
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
          fallbackKey: 'tontine_contribution_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineContributionController.getContext',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_contribution_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> submit({
    required String cycleId,
    required String period,
    required int amount,
    required String paymentMode,
    String? operator,
    String? paymentReference,
    File? receipt,
  }) async {
    try {
      final form = await buildSubmissionFormData(
        period: period,
        amount: amount,
        paymentMode: paymentMode,
        operator: operator,
        paymentReference: paymentReference,
        receipt: receipt,
      );
      final response = await ApiService.dio.post(
        _endpoint(cycleId),
        data: form,
      );
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Tontine contribution submission',
        statusCode: response.statusCode,
        body: body,
      );
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
        'message': AppLocalizations.t('tontine_contribution_submit_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'statusCode': error.response?.statusCode,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'tontine_contribution_submit_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineContributionController.submit',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_contribution_submit_error'),
      };
    }
  }

  @visibleForTesting
  static Future<FormData> buildSubmissionFormData({
    required String period,
    required int amount,
    required String paymentMode,
    String? operator,
    String? paymentReference,
    File? receipt,
  }) async {
    return FormData.fromMap({
      'periode': period,
      'montant': amount,
      'mode_paiement': paymentMode,
      if (operator != null && operator.isNotEmpty) 'operateur': operator,
      if (paymentReference != null && paymentReference.trim().isNotEmpty)
        'reference_paiement': paymentReference.trim(),
      if (receipt != null)
        'preuve_paiement': await MultipartFile.fromFile(receipt.path),
    });
  }
}

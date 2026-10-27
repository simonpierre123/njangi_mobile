import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CycleSavingsContributionController {
  static String _endpoint(String cycleId) =>
      'cycles/$cycleId/epargne/cotisations';

  static Future<Map<String, dynamic>> getContext(String cycleId) async {
    try {
      final response = await ApiService.dio.get(_endpoint(cycleId));
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Savings contribution context',
        statusCode: response.statusCode,
        body: body,
      );
      if (body is! Map ||
          !(body['success'] == true || body['status'] == 'success') ||
          body['data'] is! Map) {
        debugPrint('[API] Savings contribution context is invalid: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('savings_contribution_load_error'),
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
          fallbackKey: 'savings_contribution_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleSavingsContributionController.getContext',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('savings_contribution_load_error'),
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
      final response = await ApiService.dio.post(
        _endpoint(cycleId),
        data: await buildSubmissionFormData(
          period: period,
          amount: amount,
          paymentMode: paymentMode,
          operator: operator,
          paymentReference: paymentReference,
          receipt: receipt,
        ),
      );
      final body = response.data;
      ApiService.logServerResponse(
        operation: 'Savings contribution submission',
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
        'message': AppLocalizations.t('savings_contribution_submit_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'statusCode': error.response?.statusCode,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'savings_contribution_submit_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleSavingsContributionController.submit',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('savings_contribution_submit_error'),
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
      'type': 'EPARGNE',
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

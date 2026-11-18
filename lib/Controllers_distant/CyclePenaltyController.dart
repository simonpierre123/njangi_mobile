import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CyclePenaltyController {
  static Future<Map<String, dynamic>> getForCycle(String cycleId) async {
    try {
      final response = await ApiService.dio.get('cycles/$cycleId/penalites');
      final body = response.data;
      if (body is! Map ||
          body['success'] != true ||
          body['data'] is! Map) {
        debugPrint('[API] Cycle penalties response is invalid: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_penalties_load_error'),
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
          fallbackKey: 'cycle_penalties_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CyclePenaltyController.getForCycle',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_penalties_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> submitPayment({
    required String cycleId,
    required String penaltyId,
    required int amount,
    required String paymentMode,
    String? operator,
    String? paymentReference,
    File? receipt,
  }) async {
    try {
      final form = FormData.fromMap({
        'montant': amount,
        'mode_paiement': paymentMode,
        if (operator != null && operator.isNotEmpty) 'operateur': operator,
        if (paymentReference != null && paymentReference.trim().isNotEmpty)
          'reference_paiement': paymentReference.trim(),
        if (receipt != null)
          'preuve_paiement': await MultipartFile.fromFile(receipt.path),
      });
      final response = await ApiService.dio.post(
        'cycles/$cycleId/penalites/$penaltyId/paiements',
        data: form,
      );
      final body = response.data;
      if (body is Map && body['success'] == true) {
        return {
          'success': true,
          'message': AppLocalizations.t('cycle_penalty_payment_submitted'),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_penalty_payment_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_penalty_payment_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CyclePenaltyController.submitPayment',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_penalty_payment_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> reviewPayment({
    required String cycleId,
    required String paymentId,
    required String decision,
    String? reason,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/penalites/paiements/$paymentId/decision',
        data: {
          'decision': decision,
          if (decision == 'REJETE' && reason != null) 'motif_rejet': reason,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == true) {
        return {
          'success': true,
          'message': AppLocalizations.t('cycle_penalty_payment_reviewed'),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_penalty_payment_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_penalty_payment_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CyclePenaltyController.reviewPayment',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_penalty_payment_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> updateAttendance({
    required String cycleId,
    required String tourId,
    required String membershipId,
    required String status,
  }) async {
    try {
      final response = await ApiService.dio.put(
        'cycles/$cycleId/tontine/tours/$tourId/presences/$membershipId',
        data: {'statut': status},
      );
      final body = response.data;
      if (body is Map && body['success'] == true) {
        return {
          'success': true,
          'message': AppLocalizations.t('tontine_attendance_saved'),
        };
      }
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_attendance_save_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'tontine_attendance_save_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CyclePenaltyController.updateAttendance',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('tontine_attendance_save_error'),
      };
    }
  }
}

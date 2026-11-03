import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/cycle_cash_balance_model.dart';
import 'package:njangi/datasource/api_service.dart';

class CycleCashBalanceController {
  static Future<CycleCashBalance?> getForCycle(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/caisse/solde',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint('[API] Cycle cash balance returned an invalid response: $body');
        return null;
      }

      return CycleCashBalance.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleCashBalanceController.getForCycle',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleCashBalanceController.getForCycle',
        error,
      );
      return null;
    }
  }
}

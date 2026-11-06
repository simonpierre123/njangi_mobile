import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/community_admin_dashboard_model.dart';
import 'package:njangi/datasource/api_service.dart';

class CycleLoanDashboardController {
  static Future<LoanStats?> getForCycle(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/dashboard/loans',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint('[API] Loan dashboard returned an invalid response: $body');
        return null;
      }

      return LoanStats.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleLoanDashboardController.getForCycle',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleLoanDashboardController.getForCycle',
        error,
      );
      return null;
    }
  }
}

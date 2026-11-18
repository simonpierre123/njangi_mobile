import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/member_loan_dashboard_model.dart';
import 'package:njangi/datasource/api_service.dart';

class MemberLoanDashboardController {
  static Future<MemberLoanDashboard?> load(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/dashboard/member-loans',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint(
          '[API] Member loan dashboard returned an invalid response: $body',
        );
        return null;
      }

      return MemberLoanDashboard.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'MemberLoanDashboardController.load',
        error,
      );
      return null;
    }
  }
}

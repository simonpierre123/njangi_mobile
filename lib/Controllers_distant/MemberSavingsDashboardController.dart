import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/member_savings_dashboard_model.dart';
import 'package:njangi/datasource/api_service.dart';

class MemberSavingsDashboardController {
  static Future<MemberSavingsDashboard?> load(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/epargne/tableau-de-bord',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint(
          '[API] Member savings dashboard returned an invalid response: $body',
        );
        return null;
      }

      return MemberSavingsDashboard.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'MemberSavingsDashboardController.load',
        error,
      );
      return null;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/community_members_model.dart';
import 'package:njangi/datasource/api_service.dart';

class CycleMemberComplianceController {
  static Future<CycleMemberComplianceOverview?> getForCycle(
    String cycleId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/dashboard/members-compliance',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint(
          '[API] Cycle member compliance returned an invalid response: $body',
        );
        return null;
      }

      return CycleMemberComplianceOverview.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleMemberComplianceController.getForCycle',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleMemberComplianceController.getForCycle',
        error,
      );
      return null;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/datasource/api_service.dart';

class CycleHistorySummaryController {
  static Future<Map<String, dynamic>?> load(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/dashboard/cycle-summary',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint('[API] Cycle history summary returned an invalid response: $body');
        return null;
      }
      return Map<String, dynamic>.from(data);
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError('CycleHistorySummaryController.load', error);
      return null;
    }
  }
}

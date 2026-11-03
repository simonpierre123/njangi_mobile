import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/home_financial_summary_model.dart';
import 'package:njangi/datasource/api_service.dart';

class HomeFinancialSummaryController {
  static Future<HomeFinancialSummary?> fetch() async {
    try {
      final response = await ApiService.dio.get(
        'home/financial-obligations',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Home financial summary returned an invalid response: $body');
        return null;
      }

      return HomeFinancialSummary.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError('HomeFinancialSummaryController.fetch', error);
      return null;
    }
  }
}

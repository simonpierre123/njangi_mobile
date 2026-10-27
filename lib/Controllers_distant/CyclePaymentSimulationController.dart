import 'package:dio/dio.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';

class CyclePaymentSimulationController {
  static Future<Map<String, dynamic>> submit({
    required String cycleId,
    required String type,
    required String period,
    required int amount,
  }) async {
    try {
      final response = await ApiService.dio.post(
        'cycles/$cycleId/paiements/simuler',
        data: {'type': type, 'periode': period, 'montant': amount},
      );
      final body = response.data;
      ApiService.logServerResponse(
        operation: '$type test payment',
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
        'message': AppLocalizations.t('payment_simulation_error'),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'payment_simulation_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CyclePaymentSimulationController.submit',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('payment_simulation_error'),
      };
    }
  }
}

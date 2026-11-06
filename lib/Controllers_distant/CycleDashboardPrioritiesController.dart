import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/cycle_dashboard_priorities_model.dart';
import 'package:njangi/datasource/api_service.dart';

class CycleDashboardPrioritiesController {
  static Future<CycleGroupHealth?> getGroupHealth(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/dashboard/health',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint('[API] Group health returned an invalid response: $body');
        return null;
      }

      return CycleGroupHealth.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getGroupHealth',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getGroupHealth',
        error,
      );
      return null;
    }
  }

  static Future<CycleDashboardPriorities?> getForCycle(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/dashboard/priorities',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint(
          '[API] Dashboard priorities returned an invalid response: $body',
        );
        return null;
      }

      return CycleDashboardPriorities.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getForCycle',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getForCycle',
        error,
      );
      return null;
    }
  }

  static Future<List<PendingTontineContribution>?> getPendingContributions(
    String cycleId,
  ) async {
    final rows = await _getPaginatedRows(
      'cycles/$cycleId/tontine/cotisations/review',
      operation: 'CycleDashboardPrioritiesController.getPendingContributions',
    );
    if (rows == null) return null;
    try {
      return rows
          .map(PendingTontineContribution.fromJson)
          .where((contribution) => !contribution.isSimulation)
          .toList(growable: false);
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getPendingContributions',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getPendingContributions',
        error,
      );
      return null;
    }
  }

  static Future<List<PendingLoanRequest>?> getPendingLoanRequests(
    String cycleId,
  ) async {
    final rows = await _getPaginatedRows(
      'cycles/$cycleId/demande-prets',
      operation: 'CycleDashboardPrioritiesController.getPendingLoanRequests',
      queryParameters: const {'statut': 'EN_ATTENTE'},
    );
    if (rows == null) return null;
    try {
      return rows.map(PendingLoanRequest.fromJson).toList(growable: false);
    } on FormatException catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getPendingLoanRequests',
        error,
      );
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleDashboardPrioritiesController.getPendingLoanRequests',
        error,
      );
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> _getPaginatedRows(
    String endpoint, {
    required String operation,
    Map<String, dynamic> queryParameters = const {},
  }) async {
    try {
      final rows = <Map<String, dynamic>>[];
      var page = 1;
      var lastPage = 1;
      do {
        final response = await ApiService.dio.get(
          endpoint,
          queryParameters: {...queryParameters, 'page': page},
        );
        final body = response.data;
        final payload = body is Map ? body['data'] : null;
        final pageRows = payload is Map ? payload['data'] : null;
        final isSuccess =
            body is Map &&
            (body['success'] == true || body['status'] == 'success');
        if (!isSuccess || payload is! Map || pageRows is! List) {
          debugPrint('[API] $operation returned an invalid response: $body');
          return null;
        }

        rows.addAll(pageRows.whereType<Map>().map(Map<String, dynamic>.from));
        final parsedLastPage = int.tryParse('${payload['last_page']}');
        if (parsedLastPage == null || parsedLastPage < page) {
          debugPrint('[API] $operation returned invalid pagination metadata.');
          return null;
        }
        lastPage = parsedLastPage;
        page++;
      } while (page <= lastPage);

      return rows;
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(operation, error);
      return null;
    }
  }
}

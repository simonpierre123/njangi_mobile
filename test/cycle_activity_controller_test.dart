import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleActivityController.dart';
import 'package:njangi/datasource/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sends date range and selected turn as history filters', () async {
    final adapter = _CycleHistoryAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final result = await CycleActivityController.getHistory(
      cycleId: 'cycle-uuid',
      type: 'cotisations',
      tourId: 'tour-uuid',
      startDate: '2026-11-01',
      endDate: '2026-11-30',
    );

    expect(result, isNotNull);
    expect(adapter.request?.uri.path, '/api/cycles/cycle-uuid/historiques');
    expect(adapter.request?.queryParameters, {
      'type': 'cotisations',
      'tour_id': 'tour-uuid',
      'date_debut': '2026-11-01',
      'date_fin': '2026-11-30',
      'page': 1,
      'per_page': 25,
    });
  });
}

class _CycleHistoryAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {'items': [], 'filters': {}, 'pagination': {}},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

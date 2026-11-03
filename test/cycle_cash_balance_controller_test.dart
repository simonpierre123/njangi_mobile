import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleCashBalanceController.dart';
import 'package:njangi/datasource/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and parses the cycle cash balance from the API', () async {
    final adapter = _CashBalanceApiAdapter();
    final previousAdapter = ApiService.dio.httpClientAdapter;
    ApiService.dio.httpClientAdapter = adapter;

    try {
      final result = await CycleCashBalanceController.getForCycle('cycle-uuid');

      expect(result?.amount, 8500);
      expect(result?.currency, 'XAF');
      expect(
        adapter.requestPath,
        endsWith('/api/cycles/cycle-uuid/caisse/solde'),
      );
    } finally {
      ApiService.dio.httpClientAdapter = previousAdapter;
    }
  });
}

class _CashBalanceApiAdapter implements HttpClientAdapter {
  String? requestPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestPath = options.uri.path;
    return ResponseBody.fromString(
      '{"success":true,"data":{"cycle_id":"cycle-uuid","solde_caisse":8500,"devise":"XAF"}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

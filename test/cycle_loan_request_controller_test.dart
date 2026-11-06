import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/CycleLoanRequestController.dart';
import 'package:njangi/datasource/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('submits the loan amount, requested repayment date, and reason', () async {
    final adapter = _LoanRequestApiAdapter();
    final previousAdapter = ApiService.dio.httpClientAdapter;
    ApiService.dio.httpClientAdapter = adapter;
    addTearDown(() => ApiService.dio.httpClientAdapter = previousAdapter);

    final result = await CycleLoanRequestController.submit(
      groupId: 'group-uuid',
      cycleId: 'cycle-uuid',
      amount: 150000,
      repaymentDate: DateTime(2027, 2, 4),
      reason: 'Urgence familiale',
    );

    expect(result['success'], isTrue);
    expect(
      adapter.requestPath,
      '/api/groupes/group-uuid/cycles/cycle-uuid/demande-prets',
    );
    expect(adapter.requestBody, {
      'montant_demande': 150000,
      'date_remboursement_souhaitee': '2027-02-04',
      'motif': 'Urgence familiale',
      'locale': 'fr',
    });
  });
}

class _LoanRequestApiAdapter implements HttpClientAdapter {
  String? requestPath;
  Map<String, dynamic>? requestBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestPath = options.uri.path;
    final data = options.data;
    requestBody = Map<String, dynamic>.from(
      data is String ? jsonDecode(data) as Map : data as Map,
    );
    return ResponseBody.fromString(
      '{"status":"success","message":"Demande de prêt soumise avec succès","data":{"id":"request-uuid"}}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

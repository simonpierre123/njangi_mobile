import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/screens/community/tresorerie/loan_request_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the request form when loans are authorized', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final previousAdapter = ApiService.dio.httpClientAdapter;
    final adapter = _CycleDetailsAdapter();
    ApiService.dio.httpClientAdapter = adapter;
    addTearDown(() => ApiService.dio.httpClientAdapter = previousAdapter);

    await tester.pumpWidget(
      MaterialApp(
        home: LoanRequestPage(
          community: CommunityModel(
            id: 'group-1',
            name: 'Groupe',
            icon: Icons.groups,
            cycleCurrent: 1,
            cycleTotal: 1,
            memberCount: 4,
            contributionAmount: '25000',
            contributionFrequency: 'MENSUEL',
            progressPercent: 0,
            lastUpdateLabel: '',
            cycleId: 'cycle-enabled',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(adapter.requestPath, '/api/cycles/cycle-enabled');
    expect(find.text('loan_request_amount_label'), findsOneWidget);
    expect(find.text('loan_request_duration_not_configured'), findsOneWidget);
    expect(find.text('loan_request_unavailable'), findsNothing);
  });
}

class _CycleDetailsAdapter implements HttpClientAdapter {
  String? requestPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestPath = options.uri.path;
    expect(requestPath, '/api/cycles/cycle-enabled');
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {'id': 'cycle-enabled', 'module_pret_actif': '1'},
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

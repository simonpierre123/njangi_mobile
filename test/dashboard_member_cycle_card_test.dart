import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/routes/app_route_observer.dart';

import '../lib copy/dashboard_member.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cycle card uses home tontine progress and API tour data', (
    tester,
  ) async {
    final adapter = _DashboardApiAdapter();
    final previousAdapter = ApiService.dio.httpClientAdapter;
    ApiService.dio.httpClientAdapter = adapter;
    addTearDown(() => ApiService.dio.httpClientAdapter = previousAdapter);

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: const DashboardScreen(cycleId: 'cycle-uuid'),
      ),
    );
    for (var index = 0; index < 5; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1/2 tours'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('1 personne restante dans ce cycle'), findsOneWidget);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    expect(progress.value, 0.5);
    expect(
      adapter.paths,
      contains('/api/cycles/cycle-uuid/tontine/progression'),
    );
  });
}

class _DashboardApiAdapter implements HttpClientAdapter {
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    paths.add(path);
    if (path.endsWith('/caisse/solde')) {
      return _jsonResponse(
        '{"success":true,"data":{"cycle_id":"cycle-uuid","solde_caisse":0,"devise":"XAF"}}',
      );
    }
    if (path.endsWith('/tontine/progression')) {
      return _jsonResponse(
        '{"success":true,"data":{"tours_payes":1,"tours_total":2}}',
      );
    }
    if (path.endsWith('/tontine/tours')) {
      return _jsonResponse(
        '{"success":true,"data":['
        '{"ordre":1,"statut":"PAYE","beneficiaire":{"id":"member-1","utilisateur_nom":"Jean Doe"}},'
        '{"ordre":2,"statut":"A_VENIR","beneficiaire":{"id":"member-2","utilisateur_nom":"Jane Doe"}}'
        ']}',
      );
    }

    return ResponseBody.fromString(
      '{"success":false,"message":"Not found"}',
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  ResponseBody _jsonResponse(String body) => ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

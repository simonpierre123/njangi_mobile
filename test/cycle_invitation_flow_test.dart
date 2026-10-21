import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/NotificationController.dart';
import 'package:njangi/Models/Notification.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/home/invitation_detail_page.dart';

void main() {
  group('cycle invitation flow', () {
    test(
      ' extracts invitation id from notification payload before acceptance ',
      () {
        const notification = Notification(
          userId: 'user-1',
          scope: 'UTILISATEUR',
          groupId: 'group-1',
          cycleId: 'cycle-1',
          title: 'Invitation',
          description: 'Invitation reçue',
          eventType: 'INVITATION_GROUPE',
          payload: {
            'screen': 'INVITATION_DETAILS',
            'groupe_id': 'group-1',
            'cycle_id': 'cycle-1',
            'invitation_id': 'inv-123',
          },
        );

        expect(
          NotificationController.extractInvitationId(notification),
          'inv-123',
        );
      },
    );

    testWidgets('loads invited cycle by cycle id, not group cycle list', (
      tester,
    ) async {
      await AppLocalizations.load();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final adapter = _CycleDetailsApiAdapter();
      ApiService.dio.httpClientAdapter = adapter;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: InvitationDetailPage(
            notification: const Notification(
              id: 'notification-1',
              userId: 'user-1',
              scope: 'CYCLE',
              groupId: 'group-1',
              cycleId: 'cycle-1',
              title: 'Invitation',
              description: 'Invitation au cycle',
              eventType: 'INVITATION_PROCHAINS_CYCLES',
              payload: {'invitation_id': 'invitation-1'},
            ),
            onBack: () {},
            onCompleteProfile: () async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(adapter.request!.uri.path, '/api/cycles/cycle-1');
      expect(find.text('Groupe invité'), findsOneWidget);
    });
  });
}

class _CycleDetailsApiAdapter implements HttpClientAdapter {
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
        'data': {
          'id': 'cycle-1',
          'groupe_id': 'group-1',
          'groupe_nom': 'Groupe invité',
          'numero': 1,
          'statut': 'EN_ATTENTE',
          'montant_cotisation': 10000,
          'devise': 'XAF',
          'frequence_cycle': 'MENSUEL',
        },
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

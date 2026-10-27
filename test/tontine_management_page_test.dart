import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/tresorerie/tontine_history_page.dart';
import 'package:njangi/screens/community/tresorerie/tontine_management_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppLocalizations.load();
  });

  testWidgets('shows live contribution summary and sends a member reminder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _TontineManagementAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TontineManagementPage(
          community: _community(role: 'MEMBRE'),
          onBack: () {},
          onOpenHistory: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gestion des cotisations'), findsOneWidget);
    expect(find.text('Cotisations en attente de validation'), findsOneWidget);
    expect(find.text('Awa Njoya'), findsOneWidget);
    expect(find.text('Membres à relancer'), findsOneWidget);
    expect(find.text('Moussa Talla'), findsOneWidget);
    expect(find.text('0 XAF'), findsOneWidget);

    await tester.tap(find.text('Relancer'));
    await tester.pumpAndSettle();

    expect(
      adapter.lastPostPath,
      '/api/cycles/cycle-1/tontine/tours/tour-1/rappels/member-2',
    );
    expect(find.text('Le rappel personnalisé a été envoyé.'), findsOneWidget);
  });

  testWidgets('ordinary cycle members can validate a contribution', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _TontineManagementAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TontineManagementPage(
          community: _community(role: 'MEMBRE'),
          onBack: () {},
          onOpenHistory: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Awa Njoya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(
      adapter.lastPostPath,
      '/api/cycles/cycle-1/tontine/cotisations/operation-1/review',
    );
    expect(find.text('La cotisation a été validée.'), findsOneWidget);
  });

  testWidgets('test payments can be validated', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _TontineManagementAdapter(isTestPayment: true);
    ApiService.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TontineManagementPage(
          community: _community(role: 'MEMBRE'),
          onBack: () {},
          onOpenHistory: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Awa Njoya'));
    await tester.pumpAndSettle();
    expect(find.text('PAIEMENT DE TEST'), findsOneWidget);
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(
      adapter.lastPostPath,
      '/api/cycles/cycle-1/tontine/cotisations/operation-1/review',
    );
    expect(find.text('La cotisation a été validée.'), findsOneWidget);
  });

  testWidgets('lists archived periods as read-only history', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ApiService.dio.httpClientAdapter = _TontineManagementAdapter();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TontineHistoryPage(community: _community(), onBack: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Historique des cotisations'), findsOneWidget);
    expect(find.textContaining('TOUR-1'), findsOneWidget);
    expect(find.textContaining('XAF'), findsOneWidget);
    await tester.tap(find.textContaining('TOUR-1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Archive en lecture seule'), findsOneWidget);
    expect(find.text('Awa Njoya'), findsOneWidget);
  });
}

CommunityModel _community({String role = 'TRESORIER'}) => CommunityModel(
  id: 'group-1',
  name: 'Groupe secours',
  icon: Icons.groups,
  cycleCurrent: 1,
  cycleTotal: 1,
  memberCount: 2,
  contributionAmount: '50000',
  contributionFrequency: 'MENSUEL',
  progressPercent: 0,
  lastUpdateLabel: '',
  cycleId: 'cycle-1',
  role: role,
);

class _TontineManagementAdapter implements HttpClientAdapter {
  _TontineManagementAdapter({this.isTestPayment = false});

  final bool isTestPayment;
  String? lastPostPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'POST') {
      lastPostPath = options.uri.path;
      return _response({'success': true});
    }

    return _response({
      'success': true,
      'data': {
        'peut_gerer': true,
        'devise': 'XAF',
        'montant_cotisation': 50000,
        'tour_courant': {
          'id': 'tour-1',
          'ordre': 1,
          'periode': 'TOUR-1',
          'date_echeance': '2026-10-30',
        },
        'membres': [
          {
            'id': 'member-1',
            'prenom': 'Awa',
            'nom': 'Njoya',
            'operation': {
              'id': 'operation-1',
              'montant': 50000,
              'periode': 'TOUR-1',
              'statut': 'EN_ATTENTE',
              'mode_paiement': 'MOBILE_MONEY',
              if (isTestPayment) 'is_simulation': true,
            },
          },
          {
            'id': 'member-2',
            'prenom': 'Moussa',
            'nom': 'Talla',
            'operation': null,
          },
        ],
        'tours': [
          {
            'id': 'tour-1',
            'ordre': 1,
            'date_cloture': '2026-10-20T10:00:00Z',
            'statut': 'A_VENIR',
            'cotisations': [
              {
                'id': 'operation-2',
                'montant': 100000,
                'statut': 'VALIDE',
                'membre': {'prenom': 'Awa', 'nom': 'Njoya'},
              },
            ],
          },
        ],
      },
    });
  }

  ResponseBody _response(Map<String, dynamic> value) => ResponseBody.fromString(
    jsonEncode(value),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

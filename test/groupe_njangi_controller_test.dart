import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Controllers_distant/GroupeNjangiController.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads user groups with member counts and cycle details', () async {
    await AppLocalizations.load();
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 'user-uuid',
        'telephone': '+237600000000',
        'statut': 1,
        'active': '1',
        'delete': '0',
      }),
    });
    final adapter = _GroupsApiAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    final groups = await GroupeNjangiController.getCurrentUserCommunities();

    expect(groups, hasLength(1));
    final group = groups.single;
    expect(group.id, 'group-uuid');
    expect(group.name, 'BND Teams');
    expect(group.role, 'ADMIN');
    expect(group.memberCount, 2);
    expect(group.members, hasLength(2));
    expect(group.membersLoaded, isTrue);
    expect(group.members.first.displayName, 'Gaston Ndjanang');
    expect(group.cycleCurrent, 1);
    expect(group.contributionAmount, '50000 XAF');
    expect(group.contributionFrequency, 'mois');
    expect(group.meetingDay, 'Chaque 5 du mois');
    expect(
      group.logoUrl,
      'http://62.169.27.128:8001/storage/groupes/logos/logo.jpg',
    );
    expect(group.progressPercent, 0.6);
    expect(adapter.paths, contains('/api/utilisateurs/user-uuid/groupes'));
    expect(adapter.paths, contains('/api/groupes/group-uuid/membres'));
    expect(adapter.paths, contains('/api/groupes/group-uuid/cycles'));
  });

  test(
    'marks a group with an empty cycle response as not configured',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode({
          'id': 'user-uuid',
          'telephone': '+237600000000',
          'statut': 1,
          'active': '1',
          'delete': '0',
        }),
      });
      ApiService.dio.httpClientAdapter = _GroupsApiAdapter(emptyCycles: true);

      final groups = await GroupeNjangiController.getCurrentUserCommunities();

      expect(groups, hasLength(1));
      expect(groups.single.cyclesLoaded, isTrue);
      expect(groups.single.hasCycle, isFalse);
    },
  );

  test('hides a group while the user is only invited', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 'user-uuid',
        'telephone': '+237600000000',
        'statut': 1,
        'active': '1',
        'delete': '0',
      }),
    });
    ApiService.dio.httpClientAdapter = _GroupsApiAdapter(role: 'INVITE');

    final groups = await GroupeNjangiController.getCurrentUserCommunities();

    expect(groups, isEmpty);
  });
}

class _GroupsApiAdapter implements HttpClientAdapter {
  _GroupsApiAdapter({this.emptyCycles = false, this.role = 'ADMIN'});

  final bool emptyCycles;
  final String role;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.path);
    final Object response;
    if (options.uri.path.endsWith('/utilisateurs/user-uuid/groupes')) {
      response = {
        'success': true,
        'data': [
          {
            'role': role,
            'groupe_id': 'group-uuid',
            'groupe_nom': 'BND Teams',
            'groupe': {
              'id': 'group-uuid',
              'nom': 'BND Teams',
              'logo': 'groupes/logos/logo.jpg',
              'type': 'ENTREPRISE',
            },
          },
        ],
      };
    } else if (options.uri.path.endsWith('/groupes/group-uuid/membres')) {
      response = {
        'success': true,
        'data': [
          {
            'id': 'membership-1',
            'utilisateur_id': 'user-uuid',
            'groupe_id': 'group-uuid',
            'role': 'ADMIN',
            'statut': 'ACTIF',
            'active': '1',
            'utilisateur': {'prenom': 'Gaston', 'nom': 'Ndjanang'},
          },
          {
            'id': 'membership-2',
            'utilisateur_id': 'user-2',
            'groupe_id': 'group-uuid',
            'role': 'MEMBRE',
            'statut': 'ACTIF',
            'active': '1',
          },
        ],
      };
    } else {
      response = {
        'success': true,
        'data':
            emptyCycles
                ? []
                : [
                  {
                    'numero': 1,
                    'montant_cotisation': 50000,
                    'devise': 'XAF',
                    'frequence_cycle': 'MENSUEL',
                    'jour_echeance': 'Chaque 5 du mois',
                    'statut': 'EN_ATTENTE',
                  },
                ],
      };
    }

    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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
    expect(group.members.first.telephone, '+237690000001');
    expect(group.members.first.email, 'gaston@example.com');
    expect(group.members.first.photo, 'utilisateurs/gaston.jpg');
    expect(group.members.first.cniRecto, 'documents/cni-recto.jpg');
    expect(group.members.first.cniVerso, 'documents/cni-verso.jpg');
    expect(group.members.first.passport, 'documents/passport.jpg');
    expect(group.members.first.permis, 'documents/permis.jpg');
    expect(group.cycleCurrent, 1);
    expect(group.contributionAmount, '50000 XAF');
    expect(group.contributionFrequency, 'mois');
    expect(group.meetingDay, 'Chaque 5 du mois');
    expect(
      group.logoUrl,
      'http://62.169.27.128:8001/storage/groupes/logos/logo.jpg',
    );
    expect(group.progressPercent, 0.5);
    expect(adapter.paths, contains('/api/utilisateurs/user-uuid/groupes'));
    expect(adapter.paths, contains('/api/groupes/group-uuid/membres'));
    expect(adapter.paths, contains('/api/groupes/group-uuid/cycles'));
    expect(adapter.paths, contains('/api/cycles/cycle-uuid/membres'));
    expect(
      adapter.paths,
      contains('/api/cycles/cycle-uuid/tontine/progression'),
    );
  });

  test(
    'shows full tontine progress when every cycle member was paid',
    () async {
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
      ApiService.dio.httpClientAdapter = _GroupsApiAdapter(paidTours: 2);

      final groups = await GroupeNjangiController.getCurrentUserCommunities();

      expect(groups, hasLength(1));
      expect(groups.single.progressPercent, 1);
    },
  );

  test(
    'loads progress for the current cycle even if its tontine flag is false',
    () async {
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
      final adapter = _GroupsApiAdapter(tontineActive: false);
      ApiService.dio.httpClientAdapter = adapter;

      final groups = await GroupeNjangiController.getCurrentUserCommunities();

      expect(groups, hasLength(1));
      expect(groups.single.progressPercent, 0.5);
      expect(
        adapter.paths,
        contains('/api/cycles/cycle-uuid/tontine/progression'),
      );
    },
  );

  test(
    'loads progress for the selected cycle when API status is EN_ATTENTE',
    () async {
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
      final adapter = _GroupsApiAdapter(cycleStatus: 'EN_ATTENTE');
      ApiService.dio.httpClientAdapter = adapter;

      final groups = await GroupeNjangiController.getCurrentUserCommunities();

      expect(groups, hasLength(1));
      expect(groups.single.progressPercent, 0.5);
      expect(
        adapter.paths,
        contains('/api/cycles/cycle-uuid/tontine/progression'),
      );
    },
  );

  test(
    'falls back to paid tontine turns when the progress endpoint is unavailable',
    () async {
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
      final adapter = _GroupsApiAdapter(progressEndpointAvailable: false);
      ApiService.dio.httpClientAdapter = adapter;

      final groups = await GroupeNjangiController.getCurrentUserCommunities();

      expect(groups, hasLength(1));
      expect(groups.single.progressPercent, 0.5);
      expect(adapter.paths, contains('/api/cycles/cycle-uuid/tontine/tours'));
    },
  );

  test('accepts the earlier progress response member-count field', () async {
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
    ApiService.dio.httpClientAdapter = _GroupsApiAdapter(
      legacyProgressResponse: true,
    );

    final groups = await GroupeNjangiController.getCurrentUserCommunities();

    expect(groups, hasLength(1));
    expect(groups.single.progressPercent, 0.5);
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
  _GroupsApiAdapter({
    this.emptyCycles = false,
    this.role = 'ADMIN',
    this.paidTours = 1,
    this.progressEndpointAvailable = true,
    this.legacyProgressResponse = false,
    this.tontineActive = true,
    this.cycleStatus = 'EN_COURS',
  });

  final bool emptyCycles;
  final String role;
  final int paidTours;
  final bool progressEndpointAvailable;
  final bool legacyProgressResponse;
  final bool tontineActive;
  final String cycleStatus;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.path);
    if (!progressEndpointAvailable &&
        options.uri.path.endsWith('/cycles/cycle-uuid/tontine/progression')) {
      return ResponseBody.fromString(
        '{"message":"Not Found"}',
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

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
            'utilisateur': {
              'prenom': 'Gaston',
              'nom': 'Ndjanang',
              'telephone': '+237690000001',
              'email': 'gaston@example.com',
              'photo': 'utilisateurs/gaston.jpg',
              'sexe': 'M',
              'adresse': 'Rue du Centre',
              'ville': 'Douala',
              'pays': 'Cameroun',
              'cni_recto': 'documents/cni-recto.jpg',
              'cni_verso': 'documents/cni-verso.jpg',
              'passport': 'documents/passport.jpg',
              'permis_conduire': 'documents/permis.jpg',
              'created_at': '2025-01-10T10:00:00.000000Z',
            },
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
    } else if (options.uri.path.endsWith('/cycles/cycle-uuid/membres')) {
      response = {
        'success': true,
        'data': [
          {
            'id': 'cycle-membership-1',
            'utilisateur_id': 'user-uuid',
            'groupe_id': 'group-uuid',
            'cycle_id': 'cycle-uuid',
            'role': 'ADMIN',
            'active': '1',
            'statut': 'ACTIF',
          },
          {
            'id': 'cycle-membership-2',
            'utilisateur_id': 'user-2',
            'groupe_id': 'group-uuid',
            'cycle_id': 'cycle-uuid',
            'role': 'MEMBRE',
            'active': '1',
            'statut': 'ACTIF',
          },
        ],
      };
    } else if (options.uri.path.endsWith(
      '/cycles/cycle-uuid/tontine/progression',
    )) {
      response = {
        'success': true,
        'data': {
          'tours_payes': paidTours,
          if (legacyProgressResponse) 'membres_total': 2 else 'tours_total': 2,
        },
      };
    } else if (options.uri.path.endsWith('/cycles/cycle-uuid/tontine/tours')) {
      response = {
        'success': true,
        'data': [
          {
            'beneficiaire_membre_id': 'cycle-membership-1',
            'ordre': 1,
            'statut': paidTours > 0 ? 'PAYE' : 'A_VENIR',
            'beneficiaire': {'id': 'cycle-membership-1'},
          },
          {
            'beneficiaire_membre_id': 'cycle-membership-2',
            'ordre': 2,
            'statut': paidTours > 1 ? 'PAYE' : 'A_VENIR',
            'beneficiaire': {'id': 'cycle-membership-2'},
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
                    'id': 'cycle-uuid',
                    'numero': 1,
                    'montant_cotisation': 50000,
                    'devise': 'XAF',
                    'frequence_cycle': 'MENSUEL',
                    'jour_echeance': 'Chaque 5 du mois',
                    'statut': cycleStatus,
                    'nombre_membres': 2,
                    'tontine_active': tontineActive,
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

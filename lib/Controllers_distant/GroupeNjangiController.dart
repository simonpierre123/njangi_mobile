import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:njangi/Controllers_distant/CycleController.dart';
import 'package:njangi/Models/Cycle.dart';
import 'package:njangi/Models/GroupeNjangi.dart';
import 'package:njangi/Models/MembreGroupe.dart';
import 'package:njangi/Models/community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/datasource/community_mock_datasource.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class GroupeNjangiController {
  static Future<List<CommunityModel>> getCurrentUserCommunities() async {
    final user = await StorageManager.getUser();
    if (user == null || user.id.isEmpty) {
      debugPrint('[GROUPES] Chargement annulé: aucun utilisateur en session.');
      return [];
    }

    try {
      debugPrint(
        '[GROUPES] GET utilisateurs/.../groupes pour l’utilisateur finissant par ${user.id.length > 6 ? user.id.substring(user.id.length - 6) : user.id}.',
      );
      final response = await ApiService.dio.get(
        '${AppConstants.utilisateurs}/${user.id}/groupes',
      );
      final responseBody = response.data;
      final body =
          responseBody is String ? jsonDecode(responseBody) : responseBody;
      if (body is! Map || body['success'] != true || body['data'] is! List) {
        debugPrint(
          '[GROUPES] Réponse invalide: success=${body is Map ? body['success'] : 'absent'}, '
          'dataType=${body is Map ? body['data']?.runtimeType : body.runtimeType}, '
          'message=${body is Map ? body['message'] : 'corps non JSON objet'}.',
        );
        return [];
      }

      final memberships = (body['data'] as List).whereType<Map>().toList();
      debugPrint('[GROUPES] ${memberships.length} adhésion(s) reçue(s).');
      return await Future.wait(
        memberships.asMap().entries.map((entry) async {
          final membership = Map<String, dynamic>.from(entry.value);
          final groupValue = membership['groupe'];
          if (groupValue is! Map) return null;

          final group = Map<String, dynamic>.from(groupValue);
          final groupId =
              group['id']?.toString() ?? membership['groupe_id']?.toString();
          if (groupId == null || groupId.isEmpty) return null;

          final results = await Future.wait([
            _getList('${AppConstants.groupes}/$groupId/membres'),
            CycleController.getForGroup(groupId),
          ]);
          final memberRows = results[0] as List<Map<String, dynamic>>?;
          final cycles = results[1] as List<Cycle>?;
          final members =
              memberRows?.map(MembreGroupe.fromJson).toList(growable: false) ??
              const <MembreGroupe>[];
          final staticCommunity =
              CommunityMockDatasource.sample.isEmpty
                  ? null
                  : CommunityMockDatasource.sample[entry.key %
                      CommunityMockDatasource.sample.length];
          final cycle = _selectCycle(cycles ?? const []);
          final type = group['type']?.toString() ?? '';
          final rawLogo = group['logo']?.toString();
          final logoUrl =
              rawLogo == null || rawLogo.isEmpty
                  ? null
                  : rawLogo.startsWith('http')
                  ? rawLogo
                  : '${AppConstants.imageBaseUrl}${rawLogo.replaceFirst(RegExp(r'^/+'), '')}';
          final amount = cycle?.contributionAmount;
          final currency = cycle?.currency;

          return CommunityModel(
            id: groupId,
            name:
                group['nom']?.toString() ??
                membership['groupe_nom']?.toString() ??
                '',
            description: group['description']?.toString() ?? '',
            type: type,
            groupCode: group['code_groupe']?.toString(),
            icon: _iconForType(type),
            role: membership['role']?.toString(),
            cycleCurrent: cycle?.number ?? staticCommunity?.cycleCurrent ?? 0,
            cycleTotal: staticCommunity?.cycleTotal ?? 0,
            memberCount:
                memberRows == null
                    ? staticCommunity?.memberCount ?? 0
                    : members.where((member) => member.active != '0').length,
            members: members,
            membersLoaded: memberRows != null,
            cyclesLoaded: cycles != null,
            hasCycle: cycles?.isNotEmpty ?? false,
            contributionAmount:
                amount == null
                    ? staticCommunity?.contributionAmount ?? ''
                    : '$amount ${currency == null || currency.isEmpty ? 'XAF' : currency}',
            contributionFrequency:
                _formatFrequency(cycle?.frequency) ??
                staticCommunity?.contributionFrequency ??
                '',
            meetingDay:
                _localizeDueDay(cycle?.dueDay) ??
                staticCommunity?.lastUpdateLabel,
            logoUrl: logoUrl,
            progressPercent: staticCommunity?.progressPercent ?? 0,
            lastUpdateLabel: staticCommunity?.lastUpdateLabel ?? '',
            badgeLabel: staticCommunity?.badgeLabel,
            badgeType: staticCommunity?.badgeType ?? CommunityBadgeType.none,
            statusLabel: staticCommunity?.statusLabel,
            actionLabel: staticCommunity?.actionLabel,
          );
        }),
      ).then((communities) => communities.whereType<CommunityModel>().toList());
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return [];
    } catch (error) {
      ApiService.logUnexpectedError(
        'GroupeNjangiController.getCurrentUserCommunities',
        error,
      );
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>?> _getList(String endpoint) async {
    try {
      final response = await ApiService.dio.get(endpoint);
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! List) {
        return null;
      }
      return (body['data'] as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    }
  }

  static Cycle? _selectCycle(List<Cycle> cycles) {
    for (final cycle in cycles) {
      final status = cycle.status?.toUpperCase();
      if (status == 'EN_COURS' || status == 'ACTIF') return cycle;
    }
    return cycles.isEmpty ? null : cycles.first;
  }

  static int? _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

  static String? _localizeDueDay(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.trim().toLowerCase();
    final dayKeys = {
      'lundi': 'due_day_monday',
      'monday': 'due_day_monday',
      'mardi': 'due_day_tuesday',
      'tuesday': 'due_day_tuesday',
      'mercredi': 'due_day_wednesday',
      'wednesday': 'due_day_wednesday',
      'jeudi': 'due_day_thursday',
      'thursday': 'due_day_thursday',
      'vendredi': 'due_day_friday',
      'friday': 'due_day_friday',
      'samedi': 'due_day_saturday',
      'saturday': 'due_day_saturday',
      'dimanche': 'due_day_sunday',
      'sunday': 'due_day_sunday',
    };
    for (final entry in dayKeys.entries) {
      if (normalized.contains(entry.key)) {
        return AppLocalizations.t(entry.value);
      }
    }
    final monthlyMatch = RegExp(r'(\d{1,2})').firstMatch(value);
    if (normalized.contains('mois') || normalized.contains('month')) {
      final day = monthlyMatch?.group(1);
      if (day != null) {
        return AppLocalizations.t('cycle_due_day_monthly', args: [day]);
      }
    }
    return value;
  }

  static String? _formatFrequency(String? value) {
    if (value == null || value.isEmpty) return null;
    return switch (value.toUpperCase()) {
      'MENSUEL' || 'MENSUELLE' => AppLocalizations.t('cycle_frequency_month'),
      'HEBDO' || 'HEBDOMADAIRE' => AppLocalizations.t('cycle_frequency_week'),
      'BIHEBDO' ||
      'BIMENSUEL' ||
      'BIMENSUELLE' => AppLocalizations.t('cycle_frequency_two_weeks'),
      'AUTRE' => AppLocalizations.t('cycle_frequency_other'),
      _ => value,
    };
  }

  static IconData _iconForType(String type) => switch (type.toUpperCase()) {
    'FAMILLE' => Icons.home_outlined,
    'AMIS' => Icons.people_outline,
    'ENTREPRISE' => Icons.apartment_outlined,
    'ASSOCIATION' => Icons.groups_outlined,
    _ => Icons.more_horiz,
  };

  static Future<Map<String, dynamic>> create({
    required String nom,
    required String description,
    required String type,
    File? logo,
  }) async {
    try {
      final payload = <String, dynamic>{
        'nom': nom,
        'description': description,
        'type': type,
        'active': '1',
      };

      if (logo != null) {
        payload['logo'] = await MultipartFile.fromFile(
          logo.path,
          filename: logo.uri.pathSegments.last,
        );
      }

      final data = logo == null ? payload : FormData.fromMap(payload);
      final response = await ApiService.dio.post(
        AppConstants.groupes,
        data: data,
      );
      final body = response.data;

      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        return {
          'success': false,
          'message':
              body is Map
                  ? body['message']?.toString() ??
                      AppLocalizations.t('community_create_error')
                  : AppLocalizations.t('community_create_error'),
        };
      }

      return {
        'success': true,
        'message': body['message']?.toString(),
        'groupe': GroupeNjangi.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        ),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      final responseData = error.response?.data;
      return {
        'success': false,
        'message':
            responseData is Map
                ? responseData['message']?.toString() ??
                    ApiService.localizedErrorMessage(
                      error,
                      fallbackKey: 'community_create_error',
                    )
                : ApiService.localizedErrorMessage(
                  error,
                  fallbackKey: 'community_create_error',
                ),
      };
    } catch (error) {
      debugPrint('[API] Creating group failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('community_create_error'),
      };
    }
  }
}

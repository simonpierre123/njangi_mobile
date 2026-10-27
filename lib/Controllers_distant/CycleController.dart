import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Models/Cycle.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';

class CycleController {
  static Future<Cycle?> getById(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        '${AppConstants.cycles}/$cycleId',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Cycle details returned an invalid response: $body');
        return null;
      }
      return Cycle.fromJson(Map<String, dynamic>.from(body['data'] as Map));
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError('CycleController.getById', error);
      return null;
    }
  }

  static Future<List<Cycle>?> getForGroup(String groupId) async {
    try {
      final response = await ApiService.dio.get(
        '${AppConstants.groupes}/$groupId/cycles',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! List) {
        return null;
      }
      return (body['data'] as List)
          .whereType<Map>()
          .map((row) => Cycle.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError('CycleController.getForGroup', error);
      return null;
    }
  }

  static Future<Map<String, dynamic>> createForGroup({
    required String groupId,
    required CommunityDraft draft,
  }) async {
    final validationError = _validateDraft(draft);
    if (validationError != null) {
      return {'success': false, 'message': validationError};
    }

    final cycle = _cycleFromDraft(draft);

    try {
      final response = await ApiService.dio.post(
        '${AppConstants.groupes}/$groupId/cycles',
        data: cycle.toCreateJson(),
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Cycle creation returned an invalid response: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_create_error'),
        };
      }

      return {
        'success': true,
        'cycle': Cycle.fromJson(Map<String, dynamic>.from(body['data'] as Map)),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_create_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Cycle creation failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_create_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> updateForCycle({
    required String cycleId,
    required CommunityDraft draft,
  }) async {
    final validationError = _validateDraft(draft);
    if (validationError != null) {
      return {'success': false, 'message': validationError};
    }

    try {
      final response = await ApiService.dio.put(
        '${AppConstants.cycles}/$cycleId',
        data: _cycleFromDraft(draft).toCreateJson(),
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        debugPrint('[API] Cycle update returned an invalid response: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_update_error'),
        };
      }

      return {
        'success': true,
        'cycle': Cycle.fromJson(Map<String, dynamic>.from(body['data'] as Map)),
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_update_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Cycle update failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_update_error'),
      };
    }
  }

  static String? _validateDraft(CommunityDraft draft) {
    if (draft.tontineActive) {
      final contributionAmount = _parseAmount(draft.contributionAmount);
      if (contributionAmount == null || contributionAmount <= 0) {
        return AppLocalizations.t('cycle_amount_required');
      }
      if (draft.frequency == null) {
        return AppLocalizations.t('cycle_frequency_required');
      }
      if (draft.startDate == null) {
        return AppLocalizations.t('cycle_start_date_required');
      }
      if (draft.frequency == ContributionFrequency.personnalisee) {
        final memberCount = int.tryParse(draft.expectedMemberCount.trim());
        if (memberCount == null || memberCount < 1) {
          return AppLocalizations.t('cycle_custom_member_count_required');
        }
      }
      final usesWeekdaySchedule =
          draft.frequency == ContributionFrequency.hebdomadaire ||
          draft.frequency == ContributionFrequency.bimensuelle ||
          (draft.frequency == ContributionFrequency.mensuelle &&
              draft.tontineCalendarMode == 'NIEME_JOUR_SEMAINE');
      if (usesWeekdaySchedule) {
        final startDate = draft.startDate!;
        final matchesSchedule =
            startDate.weekday == draft.tontineWeekday &&
            (draft.frequency != ContributionFrequency.mensuelle ||
                ((startDate.day - 1) ~/ 7) + 1 == draft.tontineWeekOrdinal);
        if (!matchesSchedule) {
          return AppLocalizations.t('tontine_start_date_rule_mismatch');
        }
      }
    }
    if (draft.savingsActive && draft.savingsMode == 'FIXE') {
      final fixedAmount = _parseAmount(draft.savingsFixedAmount);
      if (fixedAmount == null || fixedAmount <= 0) {
        return AppLocalizations.t('cycle_amount_required');
      }
    }
    return null;
  }

  static Cycle _cycleFromDraft(CommunityDraft draft) {
    final startDate = draft.tontineActive ? draft.startDate : null;
    final frequency = draft.tontineActive ? draft.frequency : null;
    final usesWeekdaySchedule =
        frequency == ContributionFrequency.hebdomadaire ||
        frequency == ContributionFrequency.bimensuelle ||
        (frequency == ContributionFrequency.mensuelle &&
            draft.tontineCalendarMode == 'NIEME_JOUR_SEMAINE');
    return Cycle(
      number: 1,
      cycleName: 'Cycle 1',
      memberCount: int.tryParse(draft.expectedMemberCount.trim()),
      adminCount: draft.maxAdminCount,
      contributionAmount: _parseAmount(draft.contributionAmount),
      currency: 'XAF',
      maxLoanAmount:
          draft.allowLoans ? _parseAmount(draft.maxLoanAmount) : null,
      maxLoanDuration:
          draft.allowLoans
              ? int.tryParse(draft.maxLoanDurationMonths.trim())
              : null,
      maxSimultaneousLoans:
          draft.allowLoans
              ? int.tryParse(draft.maxSimultaneousLoans.trim())
              : null,
      frequency: frequency == null ? null : _apiFrequency(frequency),
      dueDay:
          usesWeekdaySchedule
              ? _localizedWeekdayLabel(draft.tontineWeekday)
              : null,
      tontineCalendarMode:
          draft.tontineActive ? draft.tontineCalendarMode : 'DATE_MOIS',
      tontineWeekOrdinal: draft.tontineActive ? draft.tontineWeekOrdinal : null,
      tontineWeekday: usesWeekdaySchedule ? draft.tontineWeekday : null,
      startDate: startDate,
      endDate:
          startDate == null
              ? null
              : DateTime(
                startDate.year + 1,
                startDate.month,
                startDate.day,
              ).subtract(const Duration(days: 1)),
      status: 'EN_ATTENTE',
      loanModuleActive: draft.allowLoans ? '1' : '0',
      collectiveLoanValidation: draft.collectiveValidation ? '1' : '0',
      penaltiesEnabled: draft.penaltiesEnabled ? '1' : '0',
      savingsActive: draft.savingsActive,
      savingsMode: draft.savingsMode,
      savingsFixedAmount:
          draft.savingsMode == 'FIXE'
              ? _parseAmount(draft.savingsFixedAmount)
              : null,
      savingsMinAmount:
          draft.savingsMode == 'LIBRE'
              ? _parseAmount(draft.savingsMinAmount)
              : null,
      savingsMaxAmount:
          draft.savingsMode == 'LIBRE'
              ? _parseAmount(draft.savingsMaxAmount)
              : null,
      savingsCalendarMode: draft.savingsCalendarMode,
      emergencyFundActive: draft.emergencyFundActive,
      emergencyIncludeBeneficiary: draft.emergencyIncludeBeneficiary,
      tontineActive: draft.tontineActive,
      tontineNextVisible: draft.tontineNextVisible,
    );
  }

  static int? _parseAmount(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));

  static String? _localizedWeekdayLabel(int weekday) {
    final key = switch (weekday) {
      1 => 'due_day_monday',
      2 => 'due_day_tuesday',
      3 => 'due_day_wednesday',
      4 => 'due_day_thursday',
      5 => 'due_day_friday',
      6 => 'due_day_saturday',
      7 => 'due_day_sunday',
      _ => null,
    };
    return key == null ? null : AppLocalizations.t(key);
  }

  static String _apiFrequency(ContributionFrequency frequency) =>
      switch (frequency) {
        ContributionFrequency.hebdomadaire => 'HEBDO',
        ContributionFrequency.bimensuelle => 'BIHEBDO',
        ContributionFrequency.mensuelle => 'MENSUEL',
        ContributionFrequency.personnalisee => 'AUTRE',
      };
}

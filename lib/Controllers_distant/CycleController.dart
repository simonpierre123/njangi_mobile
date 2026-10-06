import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/Models/Cycle.dart';
import 'package:njangi/Models/create_community_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';

class CycleController {
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
    final contributionAmount = _parseAmount(draft.contributionAmount);
    if (contributionAmount == null || contributionAmount <= 0) {
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_amount_required'),
      };
    }
    if (draft.frequency == null) {
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_frequency_required'),
      };
    }
    if (draft.startDate == null) {
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_start_date_required'),
      };
    }

    final startDate = draft.startDate!;
    final cycle = Cycle(
      memberCount: int.tryParse(draft.expectedMemberCount.trim()),
      adminCount: draft.maxAdminCount,
      contributionAmount: contributionAmount,
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
      frequency: _apiFrequency(draft.frequency!),
      dueDay: draft.dueDayLabel,
      startDate: startDate,
      endDate: DateTime(
        startDate.year + 1,
        startDate.month,
        startDate.day,
      ).subtract(const Duration(days: 1)),
      status: 'EN_ATTENTE',
      loanModuleActive: draft.allowLoans ? '1' : '0',
      collectiveLoanValidation: draft.collectiveValidation ? '1' : '0',
      penaltiesEnabled: draft.penaltiesEnabled ? '1' : '0',
    );

    try {
      final response = await ApiService.dio.post(
        '${AppConstants.groupes}/$groupId/cycles',
        data: cycle.toCreateJson(),
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
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

  static int? _parseAmount(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));

  static String _apiFrequency(ContributionFrequency frequency) =>
      switch (frequency) {
        ContributionFrequency.hebdomadaire => 'HEBDO',
        ContributionFrequency.bimensuelle => 'BIHEBDO',
        ContributionFrequency.mensuelle => 'MENSUEL',
        ContributionFrequency.personnalisee => 'AUTRE',
      };
}

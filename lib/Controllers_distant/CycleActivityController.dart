import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:njangi/ModeView/community_admin_dashboard_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_colors.dart';

class CycleActivityController {
  static Future<List<ActivityItem>?> getRecent(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/activites/recentes',
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! List) {
        debugPrint(
          '[API] Recent cycle activity returned an invalid response: $body',
        );
        return null;
      }

      return data
          .whereType<Map>()
          .map((item) => _activityItem(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError('CycleActivityController.getRecent', error);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getHistory({
    required String cycleId,
    required String type,
    String? tourId,
    String? startDate,
    String? endDate,
    String? period,
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/historiques',
        queryParameters: {
          'type': type,
          if (tourId != null) 'tour_id': tourId,
          if (startDate != null) 'date_debut': startDate,
          if (endDate != null) 'date_fin': endDate,
          if (period != null) 'periode': period,
          'page': page,
          'per_page': perPage,
        },
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        debugPrint('[API] Cycle history returned an invalid response: $body');
        return null;
      }

      return Map<String, dynamic>.from(data);
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return null;
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleActivityController.getHistory',
        error,
      );
      return null;
    }
  }

  static ActivityItem _activityItem(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? '';
    final name = item['membre_nom']?.toString().trim();
    final memberName =
        name == null || name.isEmpty
            ? AppLocalizations.t('member_label')
            : name;
    final amount = NumberFormat.decimalPattern(
      AppLocalizations.locale.value,
    ).format(num.tryParse(item['montant']?.toString() ?? '') ?? 0);
    final currency =
        item['devise']?.toString() == 'XAF'
            ? 'FCFA'
            : item['devise']?.toString() ?? 'XAF';
    final status = item['statut']?.toString() ?? '';
    final date =
        DateTime.tryParse(
          item['updated_at']?.toString() ??
              item['created_at']?.toString() ??
              '',
        )?.toLocal();

    final (titleKey, icon, iconBg, iconColor) = switch (type) {
      'TONTINE' => (
        'activity_tontine',
        Icons.person_outline,
        AppColors.iconBgMint,
        AppColors.primaryDark,
      ),
      'EPARGNE' || 'RETRAIT_EPARGNE' => (
        'activity_savings',
        Icons.savings_outlined,
        AppColors.iconBgMint,
        AppColors.primaryDark,
      ),
      'DEMANDE_PRET' => (
        status == 'APPROUVE'
            ? 'activity_loan_approved'
            : 'activity_loan_request',
        Icons.check_circle_outline,
        AppColors.purpleBg,
        AppColors.purple,
      ),
      'DECAISSEMENT_PRET' => (
        'activity_loan_disbursement',
        Icons.account_balance_wallet_outlined,
        AppColors.purpleBg,
        AppColors.purple,
      ),
      'REMBOURSEMENT_PRET' => (
        'activity_loan_repayment',
        Icons.account_balance_wallet_outlined,
        AppColors.purpleBg,
        AppColors.purple,
      ),
      _ => (
        'activity_financial_operation',
        Icons.receipt_long_outlined,
        AppColors.iconBgMint,
        AppColors.primaryDark,
      ),
    };

    final title = AppLocalizations.t(
      titleKey,
      args: [memberName, amount, currency],
    );
    final statusLabel = switch (status) {
      'EN_ATTENTE' => AppLocalizations.t('activity_pending'),
      'VALIDE' || 'APPROUVE' => AppLocalizations.t('activity_validated'),
      'REJETE' || 'REJETEE' => AppLocalizations.t('activity_rejected'),
      _ => '',
    };
    final dateLabel =
        date == null
            ? '—'
            : DateFormat(
              'dd/MM/yyyy HH:mm',
              AppLocalizations.locale.value,
            ).format(date);

    return ActivityItem(
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      title: title,
      subtitle: [
        statusLabel,
        dateLabel,
      ].where((part) => part.isNotEmpty).join(' · '),
    );
  }
}

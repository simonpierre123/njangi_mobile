import 'package:flutter/material.dart';
import '../../../ModeView/community_admin_dashboard_model.dart';
import '../../../common/basewidget/shimmer_loading.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Santé du groupe" — vue d'ensemble financière de la communauté
/// pour l'admin.
class GroupHealthCard extends StatelessWidget {
  const GroupHealthCard({super.key, required this.stats});

  final GroupHealthStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.mediumGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final healthSummary = _HealthSummary(stats: stats);
              final balanceSummary = _BalanceSummary(stats: stats);
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    healthSummary,
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: balanceSummary,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: healthSummary),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: balanceSummary,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: AppLocalizations.t('members_up_to_date'),
                  value: '${stats.membersUpToDate}/${stats.membersTotal}',
                  isLoading: stats.isHealthLoading,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: AppLocalizations.t('pending_label'),
                  value: '${stats.pendingCount}',
                  isLoading: stats.isHealthLoading,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: AppLocalizations.t('active_loans'),
                  value: '${stats.activeLoans}',
                  isLoading: stats.isHealthLoading,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Text(
            stats.lastUpdateLabel,
            style: TextStyle(color: AppColors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _HealthSummary extends StatelessWidget {
  const _HealthSummary({required this.stats});

  final GroupHealthStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.t('group_health_eyebrow').toUpperCase(),
          style: TextStyle(
            color: AppColors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            if (stats.isHealthLoading)
              const Shimmer(
                child: SkeletonBox(width: 78, height: 38, radius: 5),
              )
            else
              Text(
                stats.healthPercent == null ? '—' : '${stats.healthPercent}%',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.t(stats.healthLabel),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Tooltip(
              message: AppLocalizations.t('group_health_score_explanation'),
              child: Icon(
                Icons.info_outline,
                size: 15,
                color: AppColors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({required this.stats});

  final GroupHealthStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.t('current_balance'),
          textAlign: TextAlign.end,
          style: TextStyle(color: AppColors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        if (stats.isCashBalanceLoading)
          const Shimmer(child: SkeletonBox(width: 132, height: 22, radius: 4))
        else
          Text(
            stats.cashBalanceError
                ? AppLocalizations.t('cash_balance_unavailable')
                : stats.cashBalance,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.white,
              fontSize: stats.cashBalanceError ? 14 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        if (isLoading)
          const Shimmer(child: SkeletonBox(width: 38, height: 17, radius: 4))
        else
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.t('group_health_eyebrow').toUpperCase(),
                    style: TextStyle(color: AppColors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${stats.healthPercent}%',
                        style: const TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stats.healthLabel,
                          style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.t('current_balance'), style: TextStyle(color: AppColors.white70, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(
                    stats.cashBalance,
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: AppLocalizations.t('members_up_to_date'),
                value: '${stats.membersUpToDate}/${stats.membersTotal}',
              ),
              _StatItem(label: AppLocalizations.t('pending_label'), value: '${stats.pendingCount}'),
              _StatItem(label: AppLocalizations.t('active_loans'), value: '${stats.activeLoans}'),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Text(stats.lastUpdateLabel, style: TextStyle(color: AppColors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
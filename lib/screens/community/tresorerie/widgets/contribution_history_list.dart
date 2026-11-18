import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../common/basewidget/shimmer_loading.dart';
import '../../../../ModeView/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Liste des cycles précédents et du cycle en cours du groupe.
class ContributionHistoryList extends StatelessWidget {
  const ContributionHistoryList({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.isLoading,
    required this.error,
  });

  final List<CycleHistoryItem> items;
  final ValueChanged<CycleHistoryItem> onItemTap;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer(
        child: Column(
          children: [
            for (var index = 0; index < 3; index++) ...[
              _HistoryRowSkeleton(),
              SizedBox(height: 10),
            ],
          ],
        ),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(error!, style: const TextStyle(color: AppColors.error)),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          AppLocalizations.t('no_cycle_history'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _HistoryRow(item: items[i], onTap: () => onItemTap(items[i])),
          if (i != items.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
        ],
      ],
    );
  }
}

class _HistoryRowSkeleton extends StatelessWidget {
  const _HistoryRowSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      border: Border.all(color: AppColors.inputBorder),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceMd.w,
      vertical: AppDimensions.spaceSm.h,
    ),
    child: const Row(
      children: [
        SkeletonBox(width: 32, height: 32, isCircle: true),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 110, height: 13),
              SizedBox(height: 7),
              SkeletonBox(width: 85, height: 10),
            ],
          ),
        ),
        SizedBox(width: 12),
        SkeletonBox(width: 78, height: 15),
      ],
    ),
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.onTap});

  final CycleHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = item.endDate ?? item.startDate;
    final dateLabel =
        date == null
            ? '—'
            : DateFormat.yMMMd(AppLocalizations.locale.value).format(date);
    final amount =
        '${NumberFormat.decimalPattern(AppLocalizations.locale.value).format(item.amount)} ${item.currency}';
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.inputBorder),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.iconBgMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t(
                        'cycle_history_item',
                        args: [item.number],
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tagMintBg,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.t(
                        item.isCurrent
                            ? 'cycle_status_current'
                            : 'cycle_status_closed',
                      ),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

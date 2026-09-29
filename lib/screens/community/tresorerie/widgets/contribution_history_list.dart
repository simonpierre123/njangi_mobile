import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Liste de l'historique de cotisations personnelles.
class ContributionHistoryList extends StatelessWidget {
  const ContributionHistoryList({super.key, required this.items, required this.onItemTap});

  final List<ContributionHistoryItem> items;
  final ValueChanged<ContributionHistoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
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

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.onTap});

  final ContributionHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                decoration: const BoxDecoration(color: AppColors.iconBgMint, shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryDark),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.cycleLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(item.dateLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.tagMintBg,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      AppLocalizations.t('paid_label'),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
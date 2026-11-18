import 'package:flutter/material.dart';
import '../../../../common/basewidget/shimmer_loading.dart';
import '../../../../ModeView/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Cotisation du mois" avec accès au reçu.
class ContributionReceiptCard extends StatelessWidget {
  const ContributionReceiptCard({
    super.key,
    required this.receipt,
    required this.onSeeReceipt,
    required this.isLoading,
    required this.error,
  });

  final ContributionReceipt? receipt;
  final VoidCallback onSeeReceipt;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final contribution = receipt;
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child:
          contribution == null
              ? isLoading
                  ? const Shimmer(
                    child: Row(
                      children: [
                        SkeletonBox(width: 36, height: 36, isCircle: true),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: 150, height: 14),
                              SizedBox(height: 8),
                              SkeletonBox(width: 110, height: 11),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        SkeletonBox(width: 72, height: 18),
                      ],
                    ),
                  )
                  : Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppDimensions.spaceSm.w),
                      Expanded(
                        child: Text(
                          error ??
                              AppLocalizations.t('no_validated_contribution'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  )
              : Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contribution.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contribution.dueLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (contribution.isSimulation) ...[
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.t('simulated_contribution_notice'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        contribution.amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onSeeReceipt,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 12,
                              color: AppColors.secondaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.t('see_receipt'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryGreen,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}

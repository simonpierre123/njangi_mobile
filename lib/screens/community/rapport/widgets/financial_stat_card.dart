import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte statistique du Résumé financier — variante [dark] pour le
/// solde actuel (fond vert plein), sinon carte blanche avec montant
/// dans [amountColor].
class FinancialStatCard extends StatelessWidget {
  const FinancialStatCard({
    super.key,
    required this.label,
    required this.amount,
    this.dark = false,
    this.amountColor,
  });

  final String label;
  final String amount;
  final bool dark;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: dark ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: dark ? null : Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: dark ? AppColors.white.withValues(alpha: 0.75) : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceXs.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: dark ? 24 : 18,
              fontWeight: FontWeight.w700,
              color: dark ? AppColors.white : (amountColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
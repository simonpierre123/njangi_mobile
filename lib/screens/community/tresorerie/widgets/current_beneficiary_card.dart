import 'package:flutter/material.dart';
import '../../../../Models/beneficiary_model.dart';
import '../../../../common/basewidget/network_avatar.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte du bénéficiaire actuel — même famille visuelle que
/// FinancialPositionCard (fond vert foncé, texte blanc).
///
/// [onDisburse] n'est fourni que côté admin ; le bouton "Décaisser"
/// n'apparaît pas côté membre.
class CurrentBeneficiaryCard extends StatelessWidget {
  const CurrentBeneficiaryCard({
    super.key,
    required this.beneficiary,
    this.onDisburse,
  });

  final CurrentBeneficiary beneficiary;
  final VoidCallback? onDisburse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.financialPositionBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const NetworkAvatar(
                    radius: 32,
                    seed: 12,
                    fallbackBg: Colors.white24,
                    fallbackIconColor: AppColors.white,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, size: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppDimensions.spaceMd.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beneficiary.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                      ),
                      child: Text(
                        '${beneficiary.subtitle} · ${beneficiary.statusLabel}',
                        // Réutilise la même valeur que cycleBadgeBg
                        // (#B1F0D4), ici comme couleur de TEXTE, pas de fond.
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cycleBadgeBg),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      beneficiary.amount,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onDisburse != null) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            Center(
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                child: InkWell(
                  onTap: onDisburse,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.t('disburse_button'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
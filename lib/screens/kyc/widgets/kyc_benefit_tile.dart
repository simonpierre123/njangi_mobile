import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Avantage KYC demi-largeur — icône en cercle au-dessus, texte centré
/// en dessous. Utilisé par paire, côte à côte.
class KycBenefitTile extends StatelessWidget {
  const KycBenefitTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.tagMintBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
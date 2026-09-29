import 'package:flutter/material.dart';
import '../../../../Models/beneficiary_model.dart';
import '../../../../common/basewidget/network_avatar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Contenu de la carte d'une ligne d'ordre de passage — poignée de
/// glisser (si [draggable]), avatar (sauf pour l'entrée en cours), nom,
/// statut, date en texte simple à droite.
///
/// Le numéro/bouton lecture et la ligne verticale de la timeline ne
/// font PAS partie de cette carte — ils sont dessinés par le parent
/// ([_BeneficiairesTab]), à gauche de la carte.
class PassageOrderRow extends StatelessWidget {
  const PassageOrderRow({super.key, required this.entry, this.draggable = false});

  final PassageOrderEntry entry;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: entry.isCurrent ? AppColors.mintPale34 : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: entry.isCurrent ? AppColors.primaryDark : AppColors.inputBorder, width: entry.isCurrent ? 1.5 : 1),
      ),
      child: Row(
        children: [
          if (draggable) ...[
            const Icon(Icons.drag_indicator, size: 18, color: AppColors.textSecondary),
            SizedBox(width: AppDimensions.spaceXs.w),
          ],
          if (!entry.isCurrent) ...[
            NetworkAvatar(radius: 16, seed: entry.order),
            SizedBox(width: AppDimensions.spaceSm.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(entry.statusLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              entry.dateBadge,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
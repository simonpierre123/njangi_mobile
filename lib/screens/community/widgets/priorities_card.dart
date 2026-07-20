import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Liste des priorités de gestion (cotisations à enregistrer, demandes
/// de prêt, retards...). Chaque item est sa propre pilule colorée —
/// #F1F8F6 en temps normal, #FFDAD6 (20%) pour un item d'alerte.
class PrioritiesCard extends StatelessWidget {
  const PrioritiesCard({super.key, required this.items, this.onItemTap});

  final List<PriorityItem> items;
  final ValueChanged<PriorityItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _PriorityRow(item: items[i], onTap: () => onItemTap?.call(items[i])),
            if (i != items.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
          ],
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({required this.item, required this.onTap});

  final PriorityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = item.isAlert ? AppColors.alertRed : AppColors.primaryDark;

    return Material(
      color: item.isAlert ? AppColors.errorContainer20 : AppColors.mintSurfaceAlt,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Row(
            children: [
              Icon(item.icon, color: accent),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: item.isAlert ? accent : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
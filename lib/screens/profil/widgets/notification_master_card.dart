import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Carte maîtresse "Activer les notifications" — icône + libellé +
/// interrupteur. Quand désactivée, les sections en dessous sont
/// grisées/désactivées (géré par la page, pas ce widget).
class NotificationMasterCard extends StatelessWidget {
  const NotificationMasterCard({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.iconBgMint, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.primaryDark),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.secondaryGreen,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.toggleInactiveTrack,
          ),
        ],
      ),
    );
  }
}
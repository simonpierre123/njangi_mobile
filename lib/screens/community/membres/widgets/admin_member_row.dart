import 'package:flutter/material.dart';
import '../../../../Models/community_members_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Ligne de l'annuaire des membres — vue admin. 2ᵉ ligne contextuelle
/// (statut, prochain bénéficiaire, prêt en attente...) au lieu de
/// "présent depuis" ; menu "..." à droite, remplacé par une icône
/// enveloppe si [entry.hasUrgentAction] (ex: relancer un retardataire).
class AdminMemberRow extends StatelessWidget {
  const AdminMemberRow({
    super.key,
    required this.entry,
    this.onMenuTap,
    this.onUrgentAction,
  });

  final AdminMemberEntry entry;
  final VoidCallback? onMenuTap;
  final VoidCallback? onUrgentAction;

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
          const CircleAvatar(radius: 20, backgroundColor: AppColors.neutralGrayLight),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    if (entry.role != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        entry.role!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.roleText),
                      ),
                    ],
                    if (entry.isHighlighted) ...[
                      const SizedBox(width: 4),
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(entry.statusIcon, size: 12, color: entry.statusColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        entry.statusLine,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: entry.statusColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (entry.hasUrgentAction)
            InkWell(
              onTap: onUrgentAction,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.tagRedBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(Icons.mail_outline, size: 16, color: AppColors.alertRed),
              ),
            )
          else
            InkWell(
              onTap: onMenuTap,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
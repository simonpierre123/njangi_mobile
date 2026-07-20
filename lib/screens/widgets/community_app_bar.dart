import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// En-tête réutilisable pour tous les écrans d'une communauté (home,
/// trésorerie, membres...) : retour, icône, nom, rôle, cycle.
class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommunityAppBar({
    super.key,
    required this.name,
    required this.cycleLabel,
    required this.onBack,
    this.role,
  });

  final String name;
  final String cycleLabel;
  final String? role;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
            child: const Icon(Icons.hub_outlined, color: AppColors.white, size: 20),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    if (role != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.tagMintBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role!,
                          style: const TextStyle(color: AppColors.roleText, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(cycleLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
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
    this.logoUrl,
    this.memberCount,
    this.role,
    this.trailing,
  });

  final String name;
  final String cycleLabel;
  final String? logoUrl;
  final int? memberCount;
  final String? role;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      actions:
          trailing != null
              ? [trailing!, SizedBox(width: AppDimensions.spaceXs.w)]
              : null,
      title: Row(
        children: [
          ClipOval(
            child:
                logoUrl == null || logoUrl!.isEmpty
                    ? _fallbackLogo()
                    : Image.network(
                      logoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => _fallbackLogo(),
                    ),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    if (role != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tagMintBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role!,
                          style: const TextStyle(
                            color: AppColors.roleText,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        cycleLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (memberCount != null) ...[
                      SizedBox(width: AppDimensions.spaceXs.w),
                      Icon(
                        Icons.people_outline,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$memberCount ${AppLocalizations.t('members_label').toLowerCase()}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackLogo() => Container(
    width: 40,
    height: 40,
    color: AppColors.primaryDark,
    alignment: Alignment.center,
    child: const Icon(Icons.hub_outlined, color: AppColors.white, size: 20),
  );
}

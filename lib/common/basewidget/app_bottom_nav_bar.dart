import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

/// Un item de la barre de navigation basse. [activeIcon] est optionnel :
/// si fourni, il remplace [icon] quand l'onglet est sélectionné (ex:
/// home_outlined -> home_filled), reproduisant la maquette de référence.
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;
}

/// Barre de navigation basse réutilisable. Configurable via [items] pour
/// pouvoir servir aussi bien au tableau de bord principal qu'aux écrans
/// dédiés à chaque communauté (prochaine étape).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final isActive = i == currentIndex;
            final item = items[i];
            final icon = isActive ? (item.activeIcon ?? item.icon) : item.icon;

            return InkWell(
              onTap: () => onTap(i),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? AppColors.mintSurfaceLighter
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          icon,
                          color:
                              isActive
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                        ),
                        if ((item.badgeCount ?? 0) > 0)
                          Positioned(
                            right: -10,
                            top: -8,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 17,
                                minHeight: 17,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.badgeRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                item.badgeCount! > 99
                                    ? '99+'
                                    : item.badgeCount.toString(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isActive
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

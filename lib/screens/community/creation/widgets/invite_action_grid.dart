import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Une action d'invitation (Étape 4/5).
class InviteAction {
  const InviteAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

/// Grille 2x2 des actions d'invitation — icône en cercle + titre +
/// sous-titre, alignés à gauche (différent de QuickActionsGrid, qui
/// centre juste une icône + un libellé sans sous-titre).
class InviteActionGrid extends StatelessWidget {
  const InviteActionGrid({super.key, required this.actions});

  final List<InviteAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.spaceSm.w,
      mainAxisSpacing: AppDimensions.spaceSm.h,
      childAspectRatio: 1.15,
      children: [for (final action in actions) _InviteActionTile(action: action)],
    );
  }
}

class _InviteActionTile extends StatelessWidget {
  const _InviteActionTile({required this.action});

  final InviteAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryDark10,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceMd.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.mintPale, shape: BoxShape.circle),
                child: Icon(action.icon, size: 16, color: AppColors.primaryDeepest),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                action.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
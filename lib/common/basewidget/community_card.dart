import 'package:flutter/material.dart';
import '../../Models/community_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'member_avatars_stack.dart';

/// Card représentant une communauté sur le tableau de bord. Cliquable —
/// la navigation vers l'écran dédié à la communauté est déléguée via
/// [onTap] (pas encore construit, prochaine étape).
class CommunityCard extends StatelessWidget {
  const CommunityCard({
    super.key,
    required this.community,
    required this.onTap,
    this.onActionTap,
  });

  final CommunityModel community;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final isOverdue = community.actionLabel != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDimensions.spaceMd.w),
        margin: EdgeInsets.only(bottom: AppDimensions.spaceMd.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.iconBgMint,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Icon(community.icon, color: AppColors.primaryDark, size: 24),
                ),
                SizedBox(width: AppDimensions.spaceSm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          children: [
                            if (community.role != null)
                              TextSpan(
                                text: '${community.role}  •  ',
                                style: const TextStyle(
                                  color: AppColors.roleText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            TextSpan(
                              text: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (community.badgeLabel != null) _Badge(community: community),
              ],
            ),
            SizedBox(height: AppDimensions.spaceLg.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MEMBRES',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      MemberAvatarsStack(count: community.memberCount),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COTISATION',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${community.contributionAmount}/${community.contributionFrequency}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spaceLg.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PROGRESSION',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                Text(
                  '${(community.progressPercent * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: community.progressPercent,
                minHeight: 6,
                backgroundColor: AppColors.neutralGrayLighter,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            const Divider(height: 1, color: AppColors.divider),
            SizedBox(height: AppDimensions.spaceSm.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      community.lastUpdateLabel,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (isOverdue)
                  TextButton(
                    onPressed: onActionTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      community.actionLabel!,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else if (community.statusLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blueSurface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      community.statusLabel!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.community});

  final CommunityModel community;

  @override
  Widget build(BuildContext context) {
    final isWarning = community.badgeType == CommunityBadgeType.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.tagRedBg : AppColors.mintPale,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        community.badgeLabel!,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isWarning ? AppColors.alertRed : AppColors.primaryDark,
        ),
      ),
    );
  }
}
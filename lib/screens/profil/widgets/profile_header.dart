import 'package:flutter/material.dart';
import '../../../Models/profile_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'avatar_with_badge.dart';

/// En-tête du hub profil : avatar, nom, téléphone, badge de rôle global.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AvatarWithBadge(size: 80),
        SizedBox(height: AppDimensions.spaceSm.h),
        Text(
          user.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(user.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        SizedBox(height: AppDimensions.spaceSm.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                user.roleSummaryLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
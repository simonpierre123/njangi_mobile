import 'package:flutter/material.dart';
import '../../../Models/profile_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'avatar_with_badge.dart';
import 'verified_badge.dart';

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
        VerifiedBadge(label: user.roleSummaryLabel),
      ],
    );
  }
}
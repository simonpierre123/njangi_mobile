import 'package:flutter/material.dart';
import '../../../Models/profile_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Ligne "communauté" du hub profil — icône colorée, nom, rôle, chevron.
class ProfileCommunityRow extends StatelessWidget {
  const ProfileCommunityRow({super.key, required this.entry, required this.onTap});

  final ProfileCommunityEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: entry.iconBg, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                child: Icon(entry.icon, color: entry.iconColor, size: 20),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(entry.roleLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.roleText)),
                  ],
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
import 'package:flutter/material.dart';
import '../../Models/profile_model.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/logout_button.dart';
import 'widgets/profile_activity_card.dart';
import 'widgets/profile_community_row.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_row.dart';

/// Contenu de l'onglet "Profil" — identique que ce soit dans
/// [HomeShell] (3 onglets) ou [CommunityShell] (4 onglets).
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.user,
    required this.activity,
    required this.communities,
    required this.onCommunityTap,
    required this.onOpenMyProfile,
    required this.onOpenSecurity,
    required this.onOpenNotifications,
    required this.onOpenPreferences,
    required this.onOpenHelp,
    required this.onOpenAbout,
    required this.onLogout,
  });

  final UserProfile user;
  final ProfileActivity activity;
  final List<ProfileCommunityEntry> communities;
  final ValueChanged<ProfileCommunityEntry> onCommunityTap;
  final VoidCallback onOpenMyProfile;
  final VoidCallback onOpenSecurity;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenPreferences;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenAbout;
  final VoidCallback onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _previewCount = 3;

  bool _showAllCommunities = false;

  @override
  Widget build(BuildContext context) {
    final canToggle = widget.communities.length > _previewCount;
    final visibleCommunities = _showAllCommunities || !canToggle
        ? widget.communities
        : widget.communities.take(_previewCount).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH.w,
        vertical: AppDimensions.spaceMd.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centré explicitement : le Column parent est aligné à
          // gauche (pour les titres de section plus bas), donc sans ce
          // Center, ProfileHeader se retrouverait collé à gauche lui
          // aussi malgré son propre contenu centré en interne.
          Center(child: ProfileHeader(user: widget.user)),
          SizedBox(height: AppDimensions.spaceLg.h),
          Text(
            AppLocalizations.t('my_activity'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          ProfileActivityCard(activity: widget.activity),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('my_communities'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              if (canToggle)
                GestureDetector(
                  onTap: () => setState(() => _showAllCommunities = !_showAllCommunities),
                  child: Text(
                    _showAllCommunities ? AppLocalizations.t('see_less') : AppLocalizations.t('see_all_link'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryGreen,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          for (var i = 0; i < visibleCommunities.length; i++) ...[
            ProfileCommunityRow(
              entry: visibleCommunities[i],
              onTap: () => widget.onCommunityTap(visibleCommunities[i]),
            ),
            if (i != visibleCommunities.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceLg.h),
          Text(
            AppLocalizations.t('settings_section'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.settingsSectionBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceSm.w),
            child: Column(
              children: [
                SettingsRow(icon: Icons.person_outline, label: AppLocalizations.t('my_profile_label'), onTap: widget.onOpenMyProfile),
                SettingsRow(icon: Icons.shield_outlined, label: AppLocalizations.t('security_label'), onTap: widget.onOpenSecurity),
                SettingsRow(
                  icon: Icons.notifications_none_outlined,
                  label: AppLocalizations.t('nav_notifications'),
                  onTap: widget.onOpenNotifications,
                ),
                SettingsRow(icon: Icons.tune, label: AppLocalizations.t('preferences_label'), onTap: widget.onOpenPreferences),
                SettingsRow(icon: Icons.help_outline, label: AppLocalizations.t('help_label'), onTap: widget.onOpenHelp),
                SettingsRow(icon: Icons.info_outline, label: AppLocalizations.t('about_label'), onTap: widget.onOpenAbout),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          LogoutButton(onPressed: widget.onLogout),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}
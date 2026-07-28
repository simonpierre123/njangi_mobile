import 'package:flutter/material.dart';
import '../../Models/community_model.dart';
import '../../Models/notification_feed_model.dart';
import '../../Models/profile_model.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../common/basewidget/app_fab.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../profil/profile_page.dart';
import 'home_page.dart';
import 'notification_feed_page.dart';

/// Shell persistant de l'accueil : UN SEUL Scaffold, UNE SEULE bottom
/// nav (Accueil/Notifications/Profil) — le contenu change via
/// IndexedStack, jamais de reconstruction ni de navigation pour changer
/// d'onglet. Le FAB (+) n'apparaît que sur l'onglet Accueil.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.userName,
    required this.communities,
    required this.isProfileComplete,
    required this.onIdentify,
    required this.onCommunityTap,
    required this.onAddCommunity,
    required this.notifications,
    required this.user,
    required this.profileActivity,
    required this.profileCommunities,
    required this.onProfileCommunityTap,
    required this.onOpenMyProfile,
    required this.onOpenSecurity,
    required this.onOpenNotifications,
    required this.onOpenPreferences,
    required this.onOpenHelp,
    required this.onOpenAbout,
    required this.onLogout,
  });

  final String userName;
  final List<CommunityModel> communities;
  final bool isProfileComplete;
  final VoidCallback onIdentify;
  final ValueChanged<CommunityModel> onCommunityTap;
  final VoidCallback onAddCommunity;
  final List<NotificationItem> notifications;

  final UserProfile user;
  final ProfileActivity profileActivity;
  final List<ProfileCommunityEntry> profileCommunities;
  final ValueChanged<ProfileCommunityEntry> onProfileCommunityTap;
  final VoidCallback onOpenMyProfile;
  final VoidCallback onOpenSecurity;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenPreferences;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenAbout;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: _tabIndex == 0 ? AppFab(onPressed: widget.onAddCommunity) : null,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: [
          AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_filled, label: AppLocalizations.t('nav_home')),
          AppNavItem(icon: Icons.notifications_none_outlined, label: AppLocalizations.t('nav_notifications'), showDot: true),
          AppNavItem(icon: Icons.person_outline, label: AppLocalizations.t('nav_profile')),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: [
              HomePage(
                userName: widget.userName,
                communities: widget.communities,
                isProfileComplete: widget.isProfileComplete,
                onIdentify: widget.onIdentify,
                onCommunityTap: widget.onCommunityTap,
              ),
              // TODO (Njoya) : brancher un vrai badge "non lues" sur
              // l'onglet lui-même une fois l'API disponible.
              NotificationFeedPage(
                notifications: widget.notifications,
                onBackToHome: () => setState(() => _tabIndex = 0),
              ),
              ProfilePage(
                user: widget.user,
                activity: widget.profileActivity,
                communities: widget.profileCommunities,
                onCommunityTap: widget.onProfileCommunityTap,
                onOpenMyProfile: widget.onOpenMyProfile,
                onOpenSecurity: widget.onOpenSecurity,
                onOpenNotifications: widget.onOpenNotifications,
                onOpenPreferences: widget.onOpenPreferences,
                onOpenHelp: widget.onOpenHelp,
                onOpenAbout: widget.onOpenAbout,
                onLogout: widget.onLogout,
              ),
            ],
          ),
        ),
    );
  }
}
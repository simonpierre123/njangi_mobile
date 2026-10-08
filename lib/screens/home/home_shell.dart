import 'dart:async';

import 'package:flutter/material.dart';
import '../../api/firebase_api.dart';
import '../../Controllers_distant/GroupeNjangiController.dart';
import '../../Models/community_model.dart';
import '../../Models/notification_feed_model.dart';
import '../../Models/profile_model.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../common/basewidget/app_fab.dart';
import '../../localization/app_localizations.dart';
import '../../utils/management/storage_manager.dart';
import '../../utils/app_colors.dart';
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

  final List<CommunityModel> communities;
  final bool isProfileComplete;
  final VoidCallback onIdentify;
  final ValueChanged<CommunityModel> onCommunityTap;
  final Future<void> Function() onAddCommunity;
  final List<NotificationItem> notifications;

  final UserProfile user;
  final ProfileActivity profileActivity;
  final List<ProfileCommunityEntry> profileCommunities;
  final ValueChanged<ProfileCommunityEntry> onProfileCommunityTap;
  final Future<void> Function() onOpenMyProfile;
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
  String _userName = '';
  String? _greetingSubtitleKey;
  late UserProfile _profileUser;
  late List<CommunityModel> _communities = widget.communities;
  late List<ProfileCommunityEntry> _profileCommunities =
      widget.profileCommunities;
  late ProfileActivity _profileActivity = widget.profileActivity;
  bool _isLoadingCommunities = true;

  @override
  void initState() {
    super.initState();
    unawaited(FirebaseApi.syncTokenOnHomeEntry());
    _profileUser = widget.user;
    _loadGreeting();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    final communities =
        await GroupeNjangiController.getCurrentUserCommunities();
    if (!mounted) return;

    final profileCommunities = communities
        .map(
          (community) => ProfileCommunityEntry(
            community: community,
            roleLabel: _localizedRole(community.role),
            icon: community.icon,
            iconBg: AppColors.tagMintBg,
            iconColor: AppColors.primaryDark,
          ),
        )
        .toList(growable: false);
    setState(() {
      _communities = communities;
      _profileCommunities = profileCommunities;
      _profileActivity = ProfileActivity(
        communitiesCount: communities.length,
        adminCount:
            communities.where((community) => community.role == 'ADMIN').length,
        totalContributions: widget.profileActivity.totalContributions,
        activeLoans: widget.profileActivity.activeLoans,
      );
      _isLoadingCommunities = false;
    });
  }

  Future<void> _handleAddCommunity() async {
    await widget.onAddCommunity();
    if (!mounted) return;
    setState(() => _isLoadingCommunities = true);
    await _loadCommunities();
  }

  String _localizedRole(String? role) => switch (role?.toUpperCase()) {
    'ADMIN' => AppLocalizations.t('role_admin'),
    'CO_ADMIN' => AppLocalizations.t('role_co_admin'),
    'MEMBRE' => AppLocalizations.t('role_member'),
    _ => role ?? AppLocalizations.t('role_member'),
  };

  Future<void> _loadGreeting() async {
    final user = await StorageManager.getUser();
    final isFirstHomeVisit =
        user != null && user.id.trim().isNotEmpty
            ? await StorageManager.consumeFirstHomeWelcome(user.id)
            : false;

    if (!mounted) return;
    setState(() {
      _userName = user?.prenom?.trim() ?? '';
      if (user != null) _profileUser = UserProfile.fromUserModel(user);
      _greetingSubtitleKey =
          isFirstHomeVisit ? 'welcome_title' : 'greeting_subtitle';
    });
  }

  Future<void> _openMyProfile() async {
    await widget.onOpenMyProfile();
    final user = await StorageManager.getUser();
    if (!mounted || user == null) return;
    setState(() {
      _userName = user.prenom?.trim() ?? '';
      _profileUser = UserProfile.fromUserModel(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton:
          _tabIndex == 0 ? AppFab(onPressed: _handleAddCommunity) : null,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _tabIndex,
        onTap: (i) {
          setState(() => _tabIndex = i);
          if (i == 0) unawaited(FirebaseApi.syncTokenOnHomeEntry());
        },
        items: [
          AppNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_filled,
            label: AppLocalizations.t('nav_home'),
          ),
          AppNavItem(
            icon: Icons.notifications_none_outlined,
            label: AppLocalizations.t('nav_notifications'),
            showDot: true,
          ),
          AppNavItem(
            icon: Icons.person_outline,
            label: AppLocalizations.t('nav_profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: [
            HomePage(
              userName: _userName,
              userPhotoUrl: _profileUser.photoUrl,
              greetingSubtitleKey: _greetingSubtitleKey,
              communities: _communities,
              isLoadingCommunities: _isLoadingCommunities,
              isProfileComplete:
                  widget.isProfileComplete || _profileUser.isKycComplete,
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
              user: _profileUser,
              activity: _profileActivity,
              communities: _profileCommunities,
              onCommunityTap: widget.onProfileCommunityTap,
              onOpenMyProfile: _openMyProfile,
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

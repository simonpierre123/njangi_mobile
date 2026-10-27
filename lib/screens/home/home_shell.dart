import 'dart:async';

import 'package:flutter/material.dart';
import '../../api/firebase_api.dart';
import '../../Controllers_distant/GroupeNjangiController.dart';
import '../../Controllers_distant/NotificationController.dart';
import '../../Models/Notification.dart' as app_notification;
import '../../ModeView/community_model.dart';
import '../../ModeView/profile_model.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../common/basewidget/app_fab.dart';
import '../../localization/app_localizations.dart';
import '../../routes/app_route_observer.dart';
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
    required this.onOpenInvitation,
    required this.onLock,
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
  final Future<void> Function(app_notification.Notification) onOpenInvitation;
  final Future<void> Function() onLock;

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

class _HomeShellState extends State<HomeShell> with RouteAware {
  int _tabIndex = 0;
  String _userName = '';
  String? _greetingSubtitleKey;
  late UserProfile _profileUser;
  late List<CommunityModel> _communities = widget.communities;
  late List<ProfileCommunityEntry> _profileCommunities =
      widget.profileCommunities;
  late ProfileActivity _profileActivity = widget.profileActivity;
  bool _isLoadingCommunities = true;
  List<app_notification.Notification> _notifications = const [];
  bool _isLoadingNotifications = false;
  String? _notificationError;
  PageRoute<dynamic>? _homeRoute;

  int get _unreadNotificationCount =>
      _notifications.where((notification) => !notification.isRead).length;

  @override
  void initState() {
    super.initState();
    unawaited(FirebaseApi.syncTokenOnHomeEntry());
    _profileUser = widget.user;
    _loadGreeting();
    _loadCommunities();
    unawaited(_loadNotifications());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _homeRoute) {
      if (_homeRoute != null) appRouteObserver.unsubscribe(this);
      _homeRoute = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    unawaited(_refreshHome());
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _isLoadingNotifications = true;
        _notificationError = null;
      });
    }

    final user = await StorageManager.getUser();
    if (user == null || user.id.isEmpty) {
      if (!mounted) return;
      setState(() {
        _notifications = const [];
        _isLoadingNotifications = false;
        _notificationError = AppLocalizations.t('notification_load_error');
      });
      return;
    }

    final result = await NotificationController.getForUser(user.id);
    if (!mounted) return;
    setState(() {
      _notifications =
          result['success'] == true
              ? result['notifications'] as List<app_notification.Notification>
              : const [];
      _isLoadingNotifications = false;
      _notificationError =
          result['success'] == true
              ? null
              : result['message']?.toString() ??
                  AppLocalizations.t('notification_load_error');
    });
  }

  Future<void> _markNotificationAsRead(
    app_notification.Notification notification,
  ) async {
    final id = notification.id;
    if (id == null || notification.isRead) return;
    final result = await NotificationController.markAsRead(id);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _notifications = _notifications
            .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
            .toList(growable: false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                AppLocalizations.t('notification_mark_read_error'),
          ),
        ),
      );
    }
  }

  Future<void> _openInvitation(
    app_notification.Notification notification,
  ) async {
    await widget.onOpenInvitation(notification);
    await _loadNotifications();
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
            communities
                .where(
                  (community) =>
                      ['ADMIN', 'CO_ADMIN'].contains(
                        community.role?.toUpperCase(),
                      ),
                )
                .length,
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

  Future<void> _refreshHome() async {
    await Future.wait([_loadCommunities(), _loadNotifications()]);
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
          if (i == 0) {
            unawaited(FirebaseApi.syncTokenOnHomeEntry());
            unawaited(_refreshHome());
          }
          if (i == 1) unawaited(_loadNotifications());
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
            badgeCount: _unreadNotificationCount,
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
              onRefresh: _refreshHome,
              onLock: widget.onLock,
            ),
            NotificationFeedPage(
              notifications: _notifications,
              onBackToHome: () => setState(() => _tabIndex = 0),
              isLoading: _isLoadingNotifications,
              errorMessage: _notificationError,
              onRetry: () => unawaited(_loadNotifications()),
              onOpenInvitation: _openInvitation,
              onMarkAsRead:
                  (notification) =>
                      unawaited(_markNotificationAsRead(notification)),
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

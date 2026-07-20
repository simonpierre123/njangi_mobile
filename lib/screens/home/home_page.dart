import 'package:flutter/material.dart';
import '../../Models/community_model.dart';
import '../../common/basewidget/activity_summary_card.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../common/basewidget/app_fab.dart';
import '../../common/basewidget/app_search_field.dart';
import '../../common/basewidget/community_card.dart';
import '../../common/basewidget/stat_chip.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/greeting_header.dart';
import 'widgets/profile_incomplete_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.userName,
    required this.communities,
    required this.isProfileComplete,
    required this.onIdentify,
    required this.onCommunityTap,
    required this.onAddCommunity,
  });

  final String userName;
  final List<CommunityModel> communities;
  final bool isProfileComplete;
  final VoidCallback onIdentify;
  final ValueChanged<CommunityModel> onCommunityTap;
  final VoidCallback onAddCommunity;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _previewCount = 2;

  int _navIndex = 0;
  bool _bannerDismissed = false;
  bool _showAllCommunities = false;

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final hasCommunities = widget.communities.isNotEmpty;
    final showBanner = !widget.isProfileComplete && !_bannerDismissed;

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: AppFab(onPressed: widget.onAddCommunity),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
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
          AppNavItem(icon: Icons.person_outline, label: AppLocalizations.t('nav_profile')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceMd.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingHeader(userName: widget.userName),
              if (showBanner) ...[
                SizedBox(height: AppDimensions.spaceMd.h),
                ProfileIncompleteBanner(
                  onIdentify: widget.onIdentify,
                  onDismiss: () => setState(() => _bannerDismissed = true),
                ),
              ],
              SizedBox(height: AppDimensions.spaceMd.h),
              _buildSummary(hasCommunities),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppSearchField(hint: AppLocalizations.t('search_community_hint')),
              SizedBox(height: AppDimensions.spaceLg.h),
              if (!hasCommunities)
                _EmptyCommunities()
              else
                _CommunitiesList(
                  allCommunities: widget.communities,
                  visibleCommunities: _showAllCommunities || widget.communities.length <= _previewCount
                      ? widget.communities
                      : widget.communities.take(_previewCount).toList(),
                  isExpanded: _showAllCommunities,
                  onTap: widget.onCommunityTap,
                  onToggle: () => setState(() => _showAllCommunities = !_showAllCommunities),
                ),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(bool hasCommunities) {
    if (!hasCommunities) {
      return ActivitySummaryCard(
        eyebrow: AppLocalizations.t('activity_summary_eyebrow'),
        title: AppLocalizations.t('activity_empty_title'),
        chips: [
          StatChip(label: AppLocalizations.t('stat_communities'), count: 0),
          StatChip(label: AppLocalizations.t('stat_actions'), count: 0),
          StatChip(label: AppLocalizations.t('stat_no_meeting'), icon: Icons.event_busy_outlined),
        ],
        pendingAmountLabel: AppLocalizations.t('pending_contributions_label'),
        pendingAmount: '0 FCFA',
      );
    }

    final totalActions = widget.communities.where((c) => c.actionLabel != null).length;
    return ActivitySummaryCard(
      variant: ActivitySummaryVariant.filled,
      hasAlert: true,
      eyebrow: AppLocalizations.t('activity_summary_eyebrow'),
      title: AppLocalizations.t('activity_alert_title'),
      chips: [
        StatChip(
          label: AppLocalizations.t('stat_communities'),
          count: widget.communities.length,
          tone: StatChipTone.dark,
        ),
        StatChip(
          label: AppLocalizations.t('stat_actions'),
          count: totalActions,
          tone: StatChipTone.dark,
        ),
        StatChip(
          label: AppLocalizations.t('stat_meeting_tomorrow'),
          icon: Icons.calendar_today_outlined,
          tone: StatChipTone.dark,
        ),
      ],
      pendingAmountLabel: AppLocalizations.t('pending_contributions_label'),
      // TODO (Njoya) : calculer/formater ce montant depuis les vraies
      // données une fois l'API branchée.
      pendingAmount: '75 000 FCFA',
    );
  }
}

class _EmptyCommunities extends StatelessWidget {
  const _EmptyCommunities();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceXl.h),
      child: Center(
        child: Text(
          AppLocalizations.t('no_community_yet'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _CommunitiesList extends StatelessWidget {
  const _CommunitiesList({
    required this.allCommunities,
    required this.visibleCommunities,
    required this.isExpanded,
    required this.onTap,
    required this.onToggle,
  });

  final List<CommunityModel> allCommunities;
  final List<CommunityModel> visibleCommunities;
  final bool isExpanded;
  final ValueChanged<CommunityModel> onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final canToggle = allCommunities.length > visibleCommunities.length || isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.t('my_communities'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (canToggle)
              GestureDetector(
                onTap: onToggle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded
                          ? AppLocalizations.t('see_less')
                          : '${AppLocalizations.t('see_all_prefix')} ${allCommunities.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.arrow_upward : Icons.arrow_forward,
                      size: 14,
                      color: AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
          ],
        ),
        Text(
          AppLocalizations.t('communities_followup'),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        SizedBox(height: AppDimensions.spaceMd.h),
        for (final community in visibleCommunities)
          CommunityCard(
            community: community,
            onTap: () => onTap(community),
          ),
      ],
    );
  }
}
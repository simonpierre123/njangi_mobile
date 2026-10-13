import 'package:flutter/material.dart';
import '../../ModeView/community_model.dart';
import '../../common/basewidget/activity_summary_card.dart';
import '../../common/basewidget/app_search_field.dart';
import '../../common/basewidget/community_card.dart';
import '../../common/basewidget/community_card_skeleton.dart';
import '../../common/basewidget/stat_chip.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/greeting_header.dart';
import 'widgets/profile_incomplete_banner.dart';

/// Contenu de l'onglet "Accueil" — S'adapte automatiquement selon que
/// [communities] est vide ou non (les deux états visuels du Figma).
///
/// Ne possède plus de Scaffold/FAB/bottom nav propres : c'est
/// [HomeShell] qui les fournit désormais (pattern shell — un seul
/// Scaffold pour Accueil/Notifications/Profil).
///
/// TODO (Njoya) : remplacer [communities]/[userName]/[isProfileComplete]
/// par le vrai flux venant de l'API une fois branché — actuellement
/// alimenté par datasource/community_mock_datasource.dart.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.userName,
    required this.userPhotoUrl,
    required this.greetingSubtitleKey,
    required this.communities,
    this.isLoadingCommunities = false,
    required this.isProfileComplete,
    required this.onIdentify,
    required this.onCommunityTap,
    required this.onRefresh,
    required this.onLock,
  });

  final String userName;
  final String? userPhotoUrl;
  final String? greetingSubtitleKey;
  final List<CommunityModel> communities;
  final bool isLoadingCommunities;
  final bool isProfileComplete;
  final VoidCallback onIdentify;
  final ValueChanged<CommunityModel> onCommunityTap;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLock;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _previewCount = 2;

  bool _bannerDismissed = false;
  bool _showAllCommunities = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final hasCommunities = widget.communities.isNotEmpty;
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final matchingCommunities = widget.communities
        .where(
          (community) => community.name.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
    final showBanner = !widget.isProfileComplete && !_bannerDismissed;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH.w,
          vertical: AppDimensions.spaceMd.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeader(
              userName: widget.userName,
              photoUrl: widget.userPhotoUrl,
              subtitleKey: widget.greetingSubtitleKey,
              onLock: widget.onLock,
            ),
            if (showBanner) ...[
              SizedBox(height: AppDimensions.spaceMd.h),
              ProfileIncompleteBanner(
                onIdentify: widget.onIdentify,
                onDismiss: () => setState(() => _bannerDismissed = true),
              ),
            ],
            SizedBox(height: AppDimensions.spaceMd.h),
            _buildSummary(hasCommunities),
            SizedBox(
              height:
                  (hasCommunities
                          ? AppDimensions.spaceMd
                          : AppDimensions.spaceSm)
                      .h,
            ),
            AppSearchField(
              hint: AppLocalizations.t('search_community_hint'),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(
              height:
                  (hasCommunities
                          ? AppDimensions.spaceLg
                          : AppDimensions.spaceSm)
                      .h,
            ),
            if (widget.isLoadingCommunities) ...[
              const CommunityCardSkeleton(),
              const CommunityCardSkeleton(),
            ] else if (!hasCommunities)
              _EmptyCommunities()
            else if (matchingCommunities.isEmpty)
              _NoMatchingCommunities()
            else
              _CommunitiesList(
                allCommunities: matchingCommunities,
                visibleCommunities:
                    normalizedQuery.isNotEmpty ||
                            _showAllCommunities ||
                            matchingCommunities.length <= _previewCount
                        ? matchingCommunities
                        : matchingCommunities.take(_previewCount).toList(),
                isExpanded: normalizedQuery.isEmpty && _showAllCommunities,
                onTap: widget.onCommunityTap,
                onToggle:
                    () => setState(
                      () => _showAllCommunities = !_showAllCommunities,
                    ),
              ),
            SizedBox(height: AppDimensions.spaceXl.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(bool hasCommunities) {
    if (!hasCommunities) {
      return ActivitySummaryCard(
        variant: ActivitySummaryVariant.filled,
        eyebrow: AppLocalizations.t('activity_summary_eyebrow'),
        title: AppLocalizations.t('activity_empty_title'),
        chips: [
          StatChip(
            label: AppLocalizations.t('stat_communities'),
            count: 0,
            tone: StatChipTone.dark,
          ),
          StatChip(
            label: AppLocalizations.t('stat_actions'),
            count: 0,
            tone: StatChipTone.dark,
          ),
          StatChip(
            label: AppLocalizations.t('stat_no_meeting'),
            icon: Icons.event_busy_outlined,
            tone: StatChipTone.dark,
          ),
        ],
        pendingAmountLabel: AppLocalizations.t('pending_contributions_label'),
        pendingAmount: '0 ${AppLocalizations.t('currency_xaf')}',
      );
    }

    final totalActions =
        widget.communities.where((c) => c.actionLabel != null).length;
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

class _NoMatchingCommunities extends StatelessWidget {
  const _NoMatchingCommunities();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceLg.h),
      child: Center(
        child: Text(
          AppLocalizations.t('community_search_no_results'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.neutralGreenGray,
          ),
        ),
      ),
    );
  }
}

class _EmptyCommunities extends StatelessWidget {
  const _EmptyCommunities();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceXl.h),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 52.h),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd.w,
              vertical: AppDimensions.spaceSm.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.mintSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.borderMint),
            ),
            child: Text(
              AppLocalizations.t('advertising_space'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          SizedBox(
            width: double.infinity,
            height: 64.h,
            child: Center(
              child: Text(
                AppLocalizations.t('no_community_yet'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralGreenGray,
                ),
              ),
            ),
          ),
        ],
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
    final canToggle =
        allCommunities.length > visibleCommunities.length || isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.t('my_communities'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
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
          CommunityCard(community: community, onTap: () => onTap(community)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../Models/community_admin_dashboard_model.dart';
import '../../../Models/community_member_dashboard_model.dart';
import '../../../common/basewidget/app_bottom_nav_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../../widgets/community_app_bar.dart';
import '../widgets/group_health_card.dart';
import '../widgets/member_cycle_card.dart';
import '../widgets/members_overview_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/required_action_card.dart';

/// GroupHealthCard, RecentActivityCard, QuickActionsGrid et
/// AppBottomNavBar tels quels (identiques à la vue admin) ; le reste
/// (actions requises, cycle, membres) a une présentation différente et
/// vit dans ses propres composants.
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_member_mock_datasource.dart.
class MemberDashboardPage extends StatefulWidget {
  const MemberDashboardPage({
    super.key,
    required this.communityName,
    required this.cycleLabel,
    required this.health,
    required this.requiredActions,
    required this.cycle,
    required this.memberStatus,
    required this.activity,
    required this.onBack,
    required this.onQuickAction,
    required this.onActionPay,
    required this.onActionTap,
    required this.onSeeAllMembers,
    required this.onSeeAllActivity,
    required this.onOpenTreasury,
  });
 
  final String communityName;
  final String cycleLabel;
  final GroupHealthStats health;
  final List<RequiredActionItem> requiredActions;
  final MemberCycleInfo cycle;
  final MemberStatusStats memberStatus;
  final List<ActivityItem> activity;
  final VoidCallback onBack;
  final ValueChanged<String> onQuickAction;
  final ValueChanged<RequiredActionItem> onActionPay;
  final ValueChanged<RequiredActionItem> onActionTap;
  final VoidCallback onSeeAllMembers;
  final VoidCallback onSeeAllActivity;
  final VoidCallback onOpenTreasury;
 
  @override
  State<MemberDashboardPage> createState() => _MemberDashboardPageState();
}
 
class _MemberDashboardPageState extends State<MemberDashboardPage> {
  int _navIndex = 0;
 
  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
 
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommunityAppBar(
        name: widget.communityName,
        cycleLabel: widget.cycleLabel,
        onBack: widget.onBack,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 1) {
            widget.onOpenTreasury();
            return;
          }
          setState(() => _navIndex = i);
        },
        items: [
          AppNavItem(icon: Icons.grid_view_rounded, label: AppLocalizations.t('community_nav_dashboard')),
          AppNavItem(icon: Icons.history, label: AppLocalizations.t('community_nav_treasury')),
          AppNavItem(icon: Icons.people_outline, label: AppLocalizations.t('community_nav_members')),
          AppNavItem(icon: Icons.person_outline, label: AppLocalizations.t('nav_profile')),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GroupHealthCard(stats: widget.health),
              SizedBox(height: AppDimensions.spaceLg.h),
              _SectionTitle(AppLocalizations.t('required_actions')),
              SizedBox(height: AppDimensions.spaceSm.h),
              for (var i = 0; i < widget.requiredActions.length; i++) ...[
                RequiredActionCard(
                  item: widget.requiredActions[i],
                  onAction: () => widget.onActionPay(widget.requiredActions[i]),
                  onTap: () => widget.onActionTap(widget.requiredActions[i]),
                ),
                if (i != widget.requiredActions.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
              ],
              SizedBox(height: AppDimensions.spaceLg.h),
              _SectionTitle(AppLocalizations.t('quick_actions')),
              SizedBox(height: AppDimensions.spaceSm.h),
              QuickActionsGrid(
                actions: [
                  QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: AppLocalizations.t('my_contributions'),
                    onTap: () => widget.onQuickAction('contributions'),
                  ),
                  QuickAction(
                    icon: Icons.request_quote_outlined,
                    label: AppLocalizations.t('request_loan'),
                    onTap: () => widget.onQuickAction('request_loan'),
                  ),
                  QuickAction(
                    icon: Icons.people_outline,
                    label: AppLocalizations.t('members_label'),
                    onTap: () => widget.onQuickAction('members'),
                  ),
                  QuickAction(
                    icon: Icons.insert_chart_outlined,
                    label: AppLocalizations.t('reports_label'),
                    onTap: () => widget.onQuickAction('reports'),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              MemberCycleCard(info: widget.cycle),
              SizedBox(height: AppDimensions.spaceLg.h),
              MembersOverviewCard(stats: widget.memberStatus, onSeeAllMembers: widget.onSeeAllMembers),
              SizedBox(height: AppDimensions.spaceLg.h),
              _SectionTitle(AppLocalizations.t('recent_activity')),
              SizedBox(height: AppDimensions.spaceSm.h),
              RecentActivityCard(items: widget.activity, onSeeAll: widget.onSeeAllActivity),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
 
  final String title;
 
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    );
  }
}
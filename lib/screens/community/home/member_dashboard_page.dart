import 'package:flutter/material.dart';
import '../../../Models/community_admin_dashboard_model.dart';
import '../../../Models/community_member_dashboard_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../widgets/group_health_card.dart';
import '../widgets/member_cycle_card.dart';
import '../widgets/members_overview_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/required_action_card.dart';

/// Contenu de l'onglet "Tableau de Bord" — vue MEMBRE non-admin.
/// Réutilise GroupHealthCard, RecentActivityCard, QuickActionsGrid tels
/// quels (identiques à la vue admin) ; le reste (actions requises,
/// cycle, membres) a une présentation différente.
///
/// Ne possède plus de Scaffold/AppBar/bottom nav propres : c'est
/// [CommunityShell] qui les fournit désormais.
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_member_mock_datasource.dart.
class MemberDashboardPage extends StatelessWidget {
  const MemberDashboardPage({
    super.key,
    required this.health,
    required this.requiredActions,
    required this.cycle,
    required this.memberStatus,
    required this.activity,
    required this.onQuickAction,
    required this.onActionPay,
    required this.onActionTap,
    required this.onSeeAllMembers,
    required this.onSeeAllActivity,
  });

  final GroupHealthStats health;
  final List<RequiredActionItem> requiredActions;
  final MemberCycleInfo cycle;
  final MemberStatusStats memberStatus;
  final List<ActivityItem> activity;
  final ValueChanged<String> onQuickAction;
  final ValueChanged<RequiredActionItem> onActionPay;
  final ValueChanged<RequiredActionItem> onActionTap;
  final VoidCallback onSeeAllMembers;
  final VoidCallback onSeeAllActivity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH.w,
        vertical: AppDimensions.spaceSm.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupHealthCard(stats: health),
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('required_actions')),
          SizedBox(height: AppDimensions.spaceSm.h),
          for (var i = 0; i < requiredActions.length; i++) ...[
            RequiredActionCard(
              item: requiredActions[i],
              onAction: () => onActionPay(requiredActions[i]),
              onTap: () => onActionTap(requiredActions[i]),
            ),
            if (i != requiredActions.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('quick_actions')),
          SizedBox(height: AppDimensions.spaceSm.h),
          QuickActionsGrid(
            actions: [
              QuickAction(
                icon: Icons.receipt_long_outlined,
                label: AppLocalizations.t('my_contributions'),
                onTap: () => onQuickAction('contributions'),
              ),
              QuickAction(
                icon: Icons.request_quote_outlined,
                label: AppLocalizations.t('request_loan'),
                onTap: () => onQuickAction('request_loan'),
              ),
              QuickAction(
                icon: Icons.people_outline,
                label: AppLocalizations.t('members_label'),
                onTap: () => onQuickAction('members'),
              ),
              QuickAction(
                icon: Icons.insert_chart_outlined,
                label: AppLocalizations.t('reports_label'),
                onTap: () => onQuickAction('reports'),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          MemberCycleCard(info: cycle),
          SizedBox(height: AppDimensions.spaceLg.h),
          MembersOverviewCard(stats: memberStatus, onSeeAllMembers: onSeeAllMembers),
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('recent_activity')),
          SizedBox(height: AppDimensions.spaceSm.h),
          RecentActivityCard(items: activity, onSeeAll: onSeeAllActivity),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
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
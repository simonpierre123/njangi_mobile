import 'package:flutter/material.dart';
import '../../../Models/community_admin_dashboard_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../widgets/cycle_progress_card.dart';
import '../widgets/group_health_card.dart';
import '../widgets/loans_management_card.dart';
import '../widgets/members_status_card.dart';
import '../widgets/priorities_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_card.dart';

/// Contenu de l'onglet "Tableau de Bord" — vue ADMIN. Défile
/// verticalement, le contenu dépasse largement la hauteur d'écran.
///
/// Ne possède plus de Scaffold/AppBar/bottom nav propres : c'est
/// [CommunityShell] qui les fournit désormais (pattern shell — un seul
/// Scaffold pour les 4 onglets de la communauté).
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_admin_mock_datasource.dart.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    super.key,
    required this.health,
    required this.priorities,
    required this.cycle,
    required this.memberStatus,
    required this.loans,
    required this.activity,
    required this.onQuickAction,
    required this.onPriorityTap,
    required this.onManageMembers,
    required this.onSeeLoanFiles,
    required this.onSeeAllActivity,
  });

  final GroupHealthStats health;
  final List<PriorityItem> priorities;
  final CycleInfo cycle;
  final MemberStatusStats memberStatus;
  final LoanStats loans;
  final List<ActivityItem> activity;
  final ValueChanged<String> onQuickAction;
  final ValueChanged<PriorityItem> onPriorityTap;
  final VoidCallback onManageMembers;
  final VoidCallback onSeeLoanFiles;
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
          _SectionTitle(AppLocalizations.t('management_priorities')),
          SizedBox(height: AppDimensions.spaceSm.h),
          PrioritiesCard(items: priorities, onItemTap: onPriorityTap),
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('quick_actions')),
          SizedBox(height: AppDimensions.spaceSm.h),
          QuickActionsGrid(
            actions: [
              QuickAction(
                icon: Icons.add_circle_outline,
                label: AppLocalizations.t('record_contributions'),
                onTap: () => onQuickAction('contributions'),
              ),
              QuickAction(
                icon: Icons.account_balance_outlined,
                label: AppLocalizations.t('manage_loans'),
                onTap: () => onQuickAction('loans'),
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
          CycleProgressCard(cycle: cycle),
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('members_status')),
          SizedBox(height: AppDimensions.spaceSm.h),
          MembersStatusCard(stats: memberStatus, onManageMembers: onManageMembers),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(AppLocalizations.t('loans_management')),
              TextButton(
                onPressed: onSeeLoanFiles,
                child: Text(
                  AppLocalizations.t('files_label'),
                  style: const TextStyle(
                    color: AppColors.secondaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          LoansManagementCard(stats: loans),
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
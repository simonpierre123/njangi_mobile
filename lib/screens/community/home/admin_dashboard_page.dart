import 'package:flutter/material.dart';
import '../../../Models/community_admin_dashboard_model.dart';
import '../../../common/basewidget/app_bottom_nav_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../../widgets/community_app_bar.dart';
import '../widgets/cycle_progress_card.dart';
import '../widgets/group_health_card.dart';
import '../widgets/loans_management_card.dart';
import '../widgets/members_status_card.dart';
import '../widgets/priorities_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_activity_card.dart';


/// Tableau de bord admin d'une communauté — écran "home" de l'espace
/// communauté quand l'utilisateur y a le rôle ADMIN. Défile verticalement,
/// le contenu dépasse largement la hauteur d'écran.
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_admin_mock_datasource.dart.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({
    super.key,
    required this.communityName,
    required this.cycleLabel,
    required this.health,
    required this.priorities,
    required this.cycle,
    required this.memberStatus,
    required this.loans,
    required this.activity,
    required this.onBack,
    required this.onQuickAction,
    required this.onPriorityTap,
    required this.onManageMembers,
    required this.onSeeLoanFiles,
    required this.onSeeAllActivity,
    required this.onOpenTreasury,
  });
 
  final String communityName;
  final String cycleLabel;
  final GroupHealthStats health;
  final List<PriorityItem> priorities;
  final CycleInfo cycle;
  final MemberStatusStats memberStatus;
  final LoanStats loans;
  final List<ActivityItem> activity;
  final VoidCallback onBack;
  final ValueChanged<String> onQuickAction;
  final ValueChanged<PriorityItem> onPriorityTap;
  final VoidCallback onManageMembers;
  final VoidCallback onSeeLoanFiles;
  final VoidCallback onSeeAllActivity;
  final VoidCallback onOpenTreasury;
 
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}
 
class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _navIndex = 0;
 
  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
 
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommunityAppBar(
        name: widget.communityName,
        cycleLabel: widget.cycleLabel,
        role: 'ADMIN',
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
          AppNavItem(
            icon: Icons.grid_view_rounded,
            label: AppLocalizations.t('community_nav_dashboard'),
          ),
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
              _SectionTitle(AppLocalizations.t('management_priorities')),
              SizedBox(height: AppDimensions.spaceSm.h),
              PrioritiesCard(items: widget.priorities, onItemTap: widget.onPriorityTap),
              SizedBox(height: AppDimensions.spaceLg.h),
              _SectionTitle(AppLocalizations.t('quick_actions')),
              SizedBox(height: AppDimensions.spaceSm.h),
              QuickActionsGrid(
                actions: [
                  QuickAction(
                    icon: Icons.add_circle_outline,
                    label: AppLocalizations.t('record_contributions'),
                    onTap: () => widget.onQuickAction('contributions'),
                  ),
                  QuickAction(
                    icon: Icons.account_balance_outlined,
                    label: AppLocalizations.t('manage_loans'),
                    onTap: () => widget.onQuickAction('loans'),
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
              CycleProgressCard(cycle: widget.cycle),
              SizedBox(height: AppDimensions.spaceLg.h),
              _SectionTitle(AppLocalizations.t('members_status')),
              SizedBox(height: AppDimensions.spaceSm.h),
              MembersStatusCard(stats: widget.memberStatus, onManageMembers: widget.onManageMembers),
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle(AppLocalizations.t('loans_management')),
                  TextButton(
                    onPressed: widget.onSeeLoanFiles,
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
              LoansManagementCard(stats: widget.loans),
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
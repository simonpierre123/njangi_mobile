import 'package:flutter/material.dart';
import '../../../ModeView/community_admin_dashboard_model.dart';
import '../../../ModeView/community_member_dashboard_model.dart';
import '../../../common/basewidget/shimmer_loading.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../widgets/group_health_card.dart';
import '../widgets/loans_management_card.dart';
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
class MemberDashboardPage extends StatelessWidget {
  const MemberDashboardPage({
    super.key,
    required this.isTreasurer,
    required this.health,
    required this.loans,
    required this.requiredActions,
    required this.isLoadingRequiredActions,
    required this.requiredActionsError,
    required this.onRetryRequiredActions,
    required this.cycle,
    required this.memberStatus,
    required this.activity,
    required this.isLoadingActivity,
    required this.activityError,
    required this.onRetryActivity,
    required this.onQuickAction,
    required this.onActionPay,
    required this.onActionTap,
    required this.onSeeAllMembers,
    required this.onSeeAllActivity,
  });

  final bool isTreasurer;
  final GroupHealthStats health;
  final LoanStats loans;
  final List<RequiredActionItem> requiredActions;
  final bool isLoadingRequiredActions;
  final String? requiredActionsError;
  final VoidCallback onRetryRequiredActions;
  final MemberCycleInfo cycle;
  final MemberStatusStats memberStatus;
  final List<ActivityItem> activity;
  final bool isLoadingActivity;
  final String? activityError;
  final VoidCallback onRetryActivity;
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
          if (isLoadingRequiredActions)
            const _RequiredActionsShimmer()
          else if (requiredActionsError != null)
            _RequiredActionsError(
              message: requiredActionsError!,
              onRetry: onRetryRequiredActions,
            )
          else if (requiredActions.isEmpty)
            Text(
              AppLocalizations.t('required_actions_none'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            )
          else
            for (var i = 0; i < requiredActions.length; i++) ...[
              RequiredActionCard(
                item: requiredActions[i],
                onAction: () => onActionPay(requiredActions[i]),
                onTap: () => onActionTap(requiredActions[i]),
              ),
              if (i != requiredActions.length - 1)
                SizedBox(height: AppDimensions.spaceSm.h),
            ],
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('quick_actions')),
          SizedBox(height: AppDimensions.spaceSm.h),
          QuickActionsGrid(
            actions: [
              if (isTreasurer)
                QuickAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: AppLocalizations.t('manage_finances'),
                  onTap: () => _openFinanceManagementMenu(context),
                ),
              QuickAction(
                icon: Icons.receipt_long_outlined,
                label: AppLocalizations.t('my_contributions'),
                onTap: () => onQuickAction('my_contributions'),
              ),
              QuickAction(
                icon: Icons.request_quote_outlined,
                label: AppLocalizations.t('request_loan'),
                onTap: () => onQuickAction('request_loan'),
              ),
              if (!isTreasurer)
                QuickAction(
                  icon: Icons.people_outline,
                  label: AppLocalizations.t('cycle_rules_title'),
                  onTap: () => onQuickAction('rules'),
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
          if (isTreasurer) ...[
            SizedBox(height: AppDimensions.spaceLg.h),
            _SectionTitle(AppLocalizations.t('loans_management')),
            SizedBox(height: AppDimensions.spaceSm.h),
            LoansManagementCard(stats: loans),
          ],
          SizedBox(height: AppDimensions.spaceLg.h),
          MembersOverviewCard(
            stats: memberStatus,
            onSeeAllMembers: onSeeAllMembers,
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          _SectionTitle(AppLocalizations.t('recent_activity')),
          SizedBox(height: AppDimensions.spaceSm.h),
          RecentActivityCard(
            items: activity,
            onSeeAll: onSeeAllActivity,
            isLoading: isLoadingActivity,
            errorMessage: activityError,
            onRetry: onRetryActivity,
          ),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }

  Future<void> _openFinanceManagementMenu(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.t('finance_management_title'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _FinanceMenuItem(
                  icon: Icons.add_circle_outline,
                  label: AppLocalizations.t('record_contributions'),
                  onTap:
                      () => Navigator.pop(sheetContext, 'record_contributions'),
                ),
                _FinanceMenuItem(
                  icon: Icons.account_balance_outlined,
                  label: AppLocalizations.t('manage_loans'),
                  onTap: () => Navigator.pop(sheetContext, 'loans'),
                ),
                _FinanceMenuItem(
                  icon: Icons.savings_outlined,
                  label: AppLocalizations.t('manage_savings'),
                  onTap: () => Navigator.pop(sheetContext, 'manage_savings'),
                ),
                _FinanceMenuItem(
                  icon: Icons.health_and_safety_outlined,
                  label: AppLocalizations.t('manage_emergency_fund'),
                  onTap: () => Navigator.pop(sheetContext, 'emergency_fund'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
    if (action != null) onQuickAction(action);
  }
}

class _FinanceMenuItem extends StatelessWidget {
  const _FinanceMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primaryDark),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _RequiredActionsShimmer extends StatelessWidget {
  const _RequiredActionsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < 2; i++) ...[
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.neutralGrayLighter,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
            if (i == 0) SizedBox(height: AppDimensions.spaceSm.h),
          ],
        ],
      ),
    );
  }
}

class _RequiredActionsError extends StatelessWidget {
  const _RequiredActionsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.t('retry')),
        ),
      ],
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

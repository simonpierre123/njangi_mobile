import 'package:flutter/material.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../Models/treasury_model.dart';
import '../../../common/basewidget/app_bottom_nav_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../../widgets/community_app_bar.dart';
import 'widgets/collection_status_card.dart';
import 'widgets/contribution_history_list.dart';
import 'widgets/contribution_receipt_card.dart';
import 'widgets/financial_position_card.dart';
import 'widgets/loan_due_card.dart';
import 'widgets/loan_eligibility_card.dart';
import 'widgets/loan_how_it_works_card.dart';
import 'widgets/loan_notice_banner.dart';
import 'widgets/loan_summary_card.dart';
import 'widgets/member_contribution_row.dart';
import 'widgets/no_active_loan_card.dart';
import 'widgets/request_loan_button.dart';
import 'widgets/treasury_tab_selector.dart';

/// Écran "Trésorerie" d'une communauté — 3 onglets internes (Ma
/// Trésorerie / Contributions / Prêts). Chaque onglet défile
/// verticalement indépendamment.
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_treasury_mock_datasource.dart.
/// TODO (Njoya) : la bottom nav ne fait pour l'instant que mettre à jour
/// son état visuel local (sauf retour au Tableau de Bord) — le
/// branchement vers Membres / Profil viendra avec ces écrans.
class TreasuryPage extends StatefulWidget {
  const TreasuryPage({
    super.key,
    required this.communityName,
    required this.cycleLabel,
    required this.financialPosition,
    required this.receipt,
    required this.history,
    required this.collection,
    required this.memberContributions,
    required this.loan,
    required this.loanDue,
    required this.eligibility,
    required this.repaymentHistory,
    required this.onBack,
    required this.onSeeReceipt,
    required this.onHistoryItemTap,
    required this.onSeeAllHistory,
    required this.onSeeAllMembers,
    required this.onRequestLoan,
    required this.onOpenDashboard,
    required this.onOpenMembers,
  });

  final String communityName;
  final String cycleLabel;
  final FinancialPosition financialPosition;
  final ContributionReceipt receipt;
  final List<ContributionHistoryItem> history;
  final CollectionStatus collection;
  final List<MemberContribution> memberContributions;
  // null = aucun prêt en cours (affiche l'état d'éligibilité).
  final LoanInfo? loan;
  final LoanDueInfo? loanDue;
  final LoanEligibility eligibility;
  final List<MemberContribution> repaymentHistory;
  final VoidCallback onBack;
  final VoidCallback onSeeReceipt;
  final ValueChanged<ContributionHistoryItem> onHistoryItemTap;
  final VoidCallback onSeeAllHistory;
  final VoidCallback onSeeAllMembers;
  final VoidCallback onRequestLoan;
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenMembers;

  @override
  State<TreasuryPage> createState() => _TreasuryPageState();
}

class _TreasuryPageState extends State<TreasuryPage> {
  int _navIndex = 1; // Trésorerie
  int _tabIndex = 0;
  int _filterIndex = 0;

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
          if (i == 0) {
            widget.onOpenDashboard();
            return;
          }
          if (i == 2) {
            widget.onOpenMembers();
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TreasuryTabSelector(
                labels: [
                  AppLocalizations.t('treasury_tab_mine'),
                  AppLocalizations.t('treasury_tab_contributions'),
                  AppLocalizations.t('treasury_tab_loans'),
                ],
                currentIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabIndex) {
      case 0:
        return _MyTreasuryTab(
          position: widget.financialPosition,
          receipt: widget.receipt,
          history: widget.history,
          onSeeReceipt: widget.onSeeReceipt,
          onHistoryItemTap: widget.onHistoryItemTap,
          onSeeAllHistory: widget.onSeeAllHistory,
        );
      case 1:
        return _ContributionsTab(
          collection: widget.collection,
          members: widget.memberContributions,
          filterIndex: _filterIndex,
          onFilterChanged: (i) => setState(() => _filterIndex = i),
          onSeeAllMembers: widget.onSeeAllMembers,
        );
      default:
        return _LoansTab(
          loan: widget.loan,
          due: widget.loanDue,
          eligibility: widget.eligibility,
          history: widget.repaymentHistory,
          onRequestLoan: widget.onRequestLoan,
        );
    }
  }
}

class _MyTreasuryTab extends StatelessWidget {
  const _MyTreasuryTab({
    required this.position,
    required this.receipt,
    required this.history,
    required this.onSeeReceipt,
    required this.onHistoryItemTap,
    required this.onSeeAllHistory,
  });

  final FinancialPosition position;
  final ContributionReceipt receipt;
  final List<ContributionHistoryItem> history;
  final VoidCallback onSeeReceipt;
  final ValueChanged<ContributionHistoryItem> onHistoryItemTap;
  final VoidCallback onSeeAllHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialPositionCard(position: position),
          SizedBox(height: AppDimensions.spaceLg.h),
          ContributionReceiptCard(receipt: receipt, onSeeReceipt: onSeeReceipt),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('contribution_history'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              GestureDetector(
                onTap: onSeeAllHistory,
                child: Text(
                  AppLocalizations.t('see_all_link'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          ContributionHistoryList(items: history, onItemTap: onHistoryItemTap),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

class _ContributionsTab extends StatelessWidget {
  const _ContributionsTab({
    required this.collection,
    required this.members,
    required this.filterIndex,
    required this.onFilterChanged,
    required this.onSeeAllMembers,
  });

  final CollectionStatus collection;
  final List<MemberContribution> members;
  final int filterIndex;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onSeeAllMembers;

  @override
  Widget build(BuildContext context) {
    final filterLabels = [
      AppLocalizations.t('filter_all'),
      AppLocalizations.t('up_to_date'),
      AppLocalizations.t('pending_label'),
      AppLocalizations.t('overdue_label'),
    ];

    final filtered = switch (filterIndex) {
      1 => members.where((m) => m.status == ContributionStatus.upToDate).toList(),
      2 => members.where((m) => m.status == ContributionStatus.pending).toList(),
      3 => members.where((m) => m.status == ContributionStatus.late).toList(),
      _ => members,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollectionStatusCard(status: collection),
          SizedBox(height: AppDimensions.spaceLg.h),
          MemberFilterChips(labels: filterLabels, currentIndex: filterIndex, onChanged: onFilterChanged),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('members_activity'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              GestureDetector(
                onTap: onSeeAllMembers,
                child: Text(
                  AppLocalizations.t('see_all_link'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          for (final m in filtered) ...[
            MemberContributionRow(contribution: m),
            SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

class _LoansTab extends StatelessWidget {
  const _LoansTab({
    required this.loan,
    required this.due,
    required this.eligibility,
    required this.history,
    required this.onRequestLoan,
  });

  final LoanInfo? loan;
  final LoanDueInfo? due;
  final LoanEligibility eligibility;
  final List<MemberContribution> history;
  final VoidCallback onRequestLoan;

  @override
  Widget build(BuildContext context) {
    if (loan == null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NoActiveLoanCard(),
            SizedBox(height: AppDimensions.spaceLg.h),
            LoanEligibilityCard(eligibility: eligibility),
            SizedBox(height: AppDimensions.spaceLg.h),
            RequestLoanButton(onPressed: onRequestLoan),
            SizedBox(height: AppDimensions.spaceLg.h),
            const LoanHowItWorksCard(),
            SizedBox(height: AppDimensions.spaceXl.h),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoanSummaryCard(loan: loan!),
          SizedBox(height: AppDimensions.spaceLg.h),
          if (due != null) ...[
            LoanDueCard(due: due!),
            SizedBox(height: AppDimensions.spaceMd.h),
          ],
          const LoanNoticeBanner(),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('repayment_history'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                AppLocalizations.t('see_all_link'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryGreen,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          for (var i = 0; i < history.length; i++) ...[
            MemberContributionRow(contribution: history[i]),
            if (i != history.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}
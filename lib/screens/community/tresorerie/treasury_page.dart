import 'package:flutter/material.dart';
import '../../../Models/beneficiary_model.dart';
import '../../../Models/treasury_model.dart';
import '../../../common/basewidget/app_segmented_control.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/beneficiary_stats_grid.dart';
import 'widgets/collection_status_card.dart';
import 'widgets/contribution_history_list.dart';
import 'widgets/contribution_receipt_card.dart';
import 'widgets/current_beneficiary_card.dart';
import 'widgets/financial_position_card.dart';
import 'widgets/loan_due_card.dart';
import 'widgets/loan_eligibility_card.dart';
import 'widgets/loan_how_it_works_card.dart';
import 'widgets/loan_notice_banner.dart';
import 'widgets/loan_summary_card.dart';
import 'widgets/member_contribution_row.dart';
import 'widgets/no_active_loan_card.dart';
import 'widgets/passage_order_row.dart';
import 'widgets/payout_history_row.dart';
import 'widgets/request_loan_button.dart';

/// Contenu de l'onglet "Trésorerie" — 4 sous-onglets internes (Ma
/// Trésorerie / Contributions / Prêts / Bénéficiaires), gérés localement
/// puisqu'ils n'existent qu'à l'intérieur de cet onglet, pas au niveau
/// du shell.
///
/// Ne possède plus de Scaffold/AppBar/bottom nav propres : c'est
/// [CommunityShell] qui les fournit désormais.
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_treasury_mock_datasource.dart
/// et datasource/community_beneficiary_mock_datasource.dart.
class TreasuryPage extends StatefulWidget {
  const TreasuryPage({
    super.key,
    required this.isAdmin,
    required this.financialPosition,
    required this.receipt,
    required this.history,
    required this.collection,
    required this.memberContributions,
    required this.loan,
    required this.loanDue,
    required this.eligibility,
    required this.repaymentHistory,
    required this.currentBeneficiary,
    required this.beneficiaryStats,
    required this.passageOrder,
    required this.payoutHistory,
    required this.onSeeReceipt,
    required this.onHistoryItemTap,
    required this.onSeeAllHistory,
    required this.onSeeAllMembers,
    required this.onOpenDetailedReport,
    required this.onRequestLoan,
    required this.onDisburse,
    required this.onSeeAllPayoutHistory,
  });

  // Seul l'admin voit le bouton "Décaisser" et peut réorganiser l'ordre
  // de passage par glisser-déposer.
  final bool isAdmin;

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
  final CurrentBeneficiary currentBeneficiary;
  final BeneficiaryStats beneficiaryStats;
  final List<PassageOrderEntry> passageOrder;
  final List<PayoutHistoryEntry> payoutHistory;
  final VoidCallback onSeeReceipt;
  final ValueChanged<ContributionHistoryItem> onHistoryItemTap;
  final VoidCallback onSeeAllHistory;
  final VoidCallback onSeeAllMembers;
  final VoidCallback onOpenDetailedReport;
  final VoidCallback onRequestLoan;
  final VoidCallback onDisburse;
  final VoidCallback onSeeAllPayoutHistory;

  @override
  State<TreasuryPage> createState() => _TreasuryPageState();
}

class _TreasuryPageState extends State<TreasuryPage> {
  int _tabIndex = 0;
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH.w,
        vertical: AppDimensions.spaceSm.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSegmentedControl(
            labels: [
              AppLocalizations.t('treasury_tab_mine'),
              AppLocalizations.t('treasury_tab_contributions'),
              AppLocalizations.t('treasury_tab_loans'),
              AppLocalizations.t('treasury_tab_beneficiaries'),
            ],
            currentIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Expanded(child: _buildTabContent()),
        ],
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
          onOpenDetailedReport: widget.onOpenDetailedReport,
        );
      case 2:
        return _LoansTab(
          loan: widget.loan,
          due: widget.loanDue,
          eligibility: widget.eligibility,
          history: widget.repaymentHistory,
          onRequestLoan: widget.onRequestLoan,
        );
      default:
        return _BeneficiairesTab(
          isAdmin: widget.isAdmin,
          current: widget.currentBeneficiary,
          stats: widget.beneficiaryStats,
          passageOrder: widget.passageOrder,
          payoutHistory: widget.payoutHistory,
          onDisburse: widget.onDisburse,
          onSeeAllPayoutHistory: widget.onSeeAllPayoutHistory,
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
    required this.onOpenDetailedReport,
  });

  final CollectionStatus collection;
  final List<MemberContribution> members;
  final int filterIndex;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onSeeAllMembers;
  final VoidCallback onOpenDetailedReport;

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
          SizedBox(height: AppDimensions.spaceSm.h),
          GestureDetector(
            onTap: onOpenDetailedReport,
            child: Row(
              children: [
                const Icon(Icons.insert_chart_outlined, size: 14, color: AppColors.secondaryGreen),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.t('see_detailed_report_link'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
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

class _BeneficiairesTab extends StatefulWidget {
  const _BeneficiairesTab({
    required this.isAdmin,
    required this.current,
    required this.stats,
    required this.passageOrder,
    required this.payoutHistory,
    required this.onDisburse,
    required this.onSeeAllPayoutHistory,
  });

  final bool isAdmin;
  final CurrentBeneficiary current;
  final BeneficiaryStats stats;
  final List<PassageOrderEntry> passageOrder;
  final List<PayoutHistoryEntry> payoutHistory;
  final VoidCallback onDisburse;
  final VoidCallback onSeeAllPayoutHistory;

  @override
  State<_BeneficiairesTab> createState() => _BeneficiairesTabState();
}

class _BeneficiairesTabState extends State<_BeneficiairesTab> {
  // État local pour le glisser-déposer (pur front de démonstration —
  // aucune persistance réelle tant que l'API n'est pas branchée).
  late List<PassageOrderEntry> _order = List.of(widget.passageOrder);

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentBeneficiaryCard(
            beneficiary: widget.current,
            onDisburse: widget.isAdmin ? widget.onDisburse : null,
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          BeneficiaryStatsGrid(stats: widget.stats),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('passage_order_section'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.adminHintBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Text(
                  AppLocalizations.t(widget.isAdmin ? 'admin_view_reorder_hint' : 'member_view_hint'),
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          if (widget.isAdmin)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: _reorder,
              children: [
                for (var i = 0; i < _order.length; i++)
                  _TimelineStep(
                    key: ValueKey(_order[i].order),
                    entry: _order[i],
                    isLast: i == _order.length - 1,
                    child: ReorderableDragStartListener(
                      index: i,
                      child: PassageOrderRow(entry: _order[i], draggable: true),
                    ),
                  ),
              ],
            )
          else
            for (var i = 0; i < _order.length; i++)
              _TimelineStep(
                entry: _order[i],
                isLast: i == _order.length - 1,
                child: PassageOrderRow(entry: _order[i]),
              ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Text(
            AppLocalizations.t('payout_history_section'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.spaceMd.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                for (var i = 0; i < widget.payoutHistory.length; i++) ...[
                  PayoutHistoryRow(entry: widget.payoutHistory[i]),
                  SizedBox(height: AppDimensions.spaceSm.h),
                ],
                GestureDetector(
                  onTap: widget.onSeeAllPayoutHistory,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.mintPale34,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.t('see_full_history'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryContainer),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

/// Une étape de la timeline "Ordre de Passage" — marqueur (bouton
/// lecture pour l'entrée en cours, numéro sinon) + ligne verticale de
/// connexion à gauche, carte de contenu ([child], fourni par l'appelant)
/// à droite. Le marqueur et la ligne sont hors de la carte, à
/// l'extérieur — fidèle à la maquette.
class _TimelineStep extends StatelessWidget {
  const _TimelineStep({super.key, required this.entry, required this.isLast, required this.child});

  final PassageOrderEntry entry;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  entry.isCurrent
                      ? const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryDark,
                          child: Icon(Icons.play_arrow, size: 18, color: AppColors.white),
                        )
                      : CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.surface,
                          child: Text(
                            '${entry.order}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                        ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.inputBorder,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: AppDimensions.spaceSm.w),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
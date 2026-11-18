import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../ModeView/beneficiary_model.dart';
import '../../../ModeView/member_savings_dashboard_model.dart';
import '../../../ModeView/member_loan_dashboard_model.dart';
import '../../../ModeView/treasury_model.dart';
import '../../../common/basewidget/app_segmented_control.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../common/basewidget/shimmer_loading.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/beneficiary_stats_grid.dart';
import 'widgets/contribution_history_list.dart';
import 'widgets/contribution_receipt_card.dart';
import 'widgets/current_beneficiary_card.dart';
import 'widgets/financial_position_card.dart';
import 'widgets/loan_due_card.dart';
import 'widgets/loan_eligibility_card.dart';
import 'widgets/loan_how_it_works_card.dart';
import 'widgets/loan_notice_banner.dart';
import 'widgets/loan_summary_card.dart';
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
/// L'historique des cycles, le reçu personnel et le tableau d'épargne sont
/// chargés depuis l'API; les autres sections conservent leurs sources actuelles.
class TreasuryPage extends StatefulWidget {
  const TreasuryPage({
    super.key,
    required this.isAdmin,
    required this.isTreasurer,
    required this.financialPosition,
    required this.receipt,
    required this.history,
    required this.isLoadingOverview,
    required this.overviewError,
    required this.receiptError,
    required this.savingsDashboard,
    required this.isLoadingSavings,
    required this.savingsLoadError,
    required this.loanDashboard,
    required this.isLoadingLoanDashboard,
    required this.loanDashboardLoadError,
    required this.collection,
    required this.memberContributions,
    required this.currentBeneficiary,
    required this.beneficiaryStats,
    required this.passageOrder,
    required this.passageOrderLoading,
    required this.passageOrderError,
    required this.onReorderPassageOrder,
    required this.onRefresh,
    required this.showPassageOrderToMembers,
    required this.payoutHistory,
    required this.onSeeReceipt,
    required this.onHistoryItemTap,
    required this.onSeeAllMembers,
    required this.onOpenDetailedReport,
    required this.onRequestLoan,
    required this.onDisburse,
    required this.onSeeAllPayoutHistory,
  });

  // Seul l'admin voit le bouton "Décaisser" et peut réorganiser l'ordre
  // de passage par glisser-déposer. Le trésorier gère les opérations
  // financières comme les décaissements.
  final bool isAdmin;
  final bool isTreasurer;

  final FinancialPosition financialPosition;
  final ContributionReceipt? receipt;
  final List<CycleHistoryItem> history;
  final bool isLoadingOverview;
  final String? overviewError;
  final String? receiptError;
  final MemberSavingsDashboard? savingsDashboard;
  final bool isLoadingSavings;
  final bool savingsLoadError;
  final MemberLoanDashboard? loanDashboard;
  final bool isLoadingLoanDashboard;
  final bool loanDashboardLoadError;
  final CollectionStatus collection;
  final List<MemberContribution> memberContributions;
  final CurrentBeneficiary currentBeneficiary;
  final BeneficiaryStats beneficiaryStats;
  final List<PassageOrderEntry> passageOrder;
  final bool passageOrderLoading;
  final String? passageOrderError;
  final Future<List<PassageOrderEntry>?> Function(
    List<PassageOrderEntry> entries,
  )
  onReorderPassageOrder;
  final Future<void> Function() onRefresh;
  final bool showPassageOrderToMembers;
  final List<PayoutHistoryEntry> payoutHistory;
  final ValueChanged<ContributionReceipt> onSeeReceipt;
  final ValueChanged<CycleHistoryItem> onHistoryItemTap;
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
            onChanged: (i) {
              setState(() => _tabIndex = i);
              if (i == 3) {
                unawaited(widget.onRefresh());
              }
            },
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: _buildTabContent(),
            ),
          ),
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
          isLoadingOverview: widget.isLoadingOverview,
          overviewError: widget.overviewError,
          receiptError: widget.receiptError,
          onSeeReceipt: widget.onSeeReceipt,
          onHistoryItemTap: widget.onHistoryItemTap,
        );
      case 1:
        return _ContributionsTab(
          dashboard: widget.savingsDashboard,
          isLoading: widget.isLoadingSavings,
          hasError: widget.savingsLoadError,
          filterIndex: _filterIndex,
          onFilterChanged: (i) => setState(() => _filterIndex = i),
          onOpenDetailedReport: widget.onOpenDetailedReport,
        );
      case 2:
        return _LoansTab(
          dashboard: widget.loanDashboard,
          isLoading: widget.isLoadingLoanDashboard,
          hasError: widget.loanDashboardLoadError,
          onRetry: widget.onRefresh,
          onRequestLoan: widget.onRequestLoan,
        );
      default:
        return _BeneficiairesTab(
          isAdmin: widget.isAdmin,
          isTreasurer: widget.isTreasurer,
          current: widget.currentBeneficiary,
          stats: widget.beneficiaryStats,
          passageOrder: widget.passageOrder,
          passageOrderLoading: widget.passageOrderLoading,
          passageOrderError: widget.passageOrderError,
          onReorderPassageOrder: widget.onReorderPassageOrder,
          showPassageOrderToMembers: widget.showPassageOrderToMembers,
          payoutHistory: widget.payoutHistory,
          onDisburse: widget.onDisburse,
          onSeeAllPayoutHistory: widget.onSeeAllPayoutHistory,
        );
    }
  }
}

class _MyTreasuryTab extends StatefulWidget {
  const _MyTreasuryTab({
    required this.position,
    required this.receipt,
    required this.history,
    required this.isLoadingOverview,
    required this.overviewError,
    required this.receiptError,
    required this.onSeeReceipt,
    required this.onHistoryItemTap,
  });

  final FinancialPosition position;
  final ContributionReceipt? receipt;
  final List<CycleHistoryItem> history;
  final bool isLoadingOverview;
  final String? overviewError;
  final String? receiptError;
  final ValueChanged<ContributionReceipt> onSeeReceipt;
  final ValueChanged<CycleHistoryItem> onHistoryItemTap;

  @override
  State<_MyTreasuryTab> createState() => _MyTreasuryTabState();
}

class _MyTreasuryTabState extends State<_MyTreasuryTab> {
  bool _historyExpanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleHistory = visibleCycleHistory(
      widget.history,
      expanded: _historyExpanded,
    );
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialPositionCard(position: widget.position),
          SizedBox(height: AppDimensions.spaceLg.h),
          ContributionReceiptCard(
            receipt: widget.receipt,
            isLoading: widget.isLoadingOverview,
            error: widget.receiptError,
            onSeeReceipt: () {
              final receipt = widget.receipt;
              if (receipt != null) widget.onSeeReceipt(receipt);
            },
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('cycle_history_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.history.length > 3)
                GestureDetector(
                  onTap: () {
                    setState(() => _historyExpanded = !_historyExpanded);
                  },
                  child: Text(
                    AppLocalizations.t(
                      _historyExpanded ? 'see_less_link' : 'see_all_link',
                    ),
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
          ContributionHistoryList(
            items: visibleHistory,
            onItemTap: widget.onHistoryItemTap,
            isLoading: widget.isLoadingOverview,
            error: widget.overviewError,
          ),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

class _ContributionsTab extends StatelessWidget {
  const _ContributionsTab({
    required this.dashboard,
    required this.isLoading,
    required this.hasError,
    required this.filterIndex,
    required this.onFilterChanged,
    required this.onOpenDetailedReport,
  });

  final MemberSavingsDashboard? dashboard;
  final bool isLoading;
  final bool hasError;
  final int filterIndex;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onOpenDetailedReport;

  @override
  Widget build(BuildContext context) {
    final filterLabels = [
      AppLocalizations.t('filter_all'),
      AppLocalizations.t('savings_status_validated'),
      AppLocalizations.t('savings_status_pending'),
      AppLocalizations.t('savings_status_rejected'),
    ];
    final operations = dashboard?.operations ?? const [];
    final statusForFilter =
        const {1: 'VALIDE', 2: 'EN_ATTENTE', 3: 'REJETE'}[filterIndex];
    final filtered =
        statusForFilter == null
            ? operations
            : operations
                .where((operation) => operation.status == statusForFilter)
                .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hasError || dashboard == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  AppLocalizations.t('savings_dashboard_load_error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else ...[
            _MemberSavingsSummaryCard(dashboard: dashboard!),
            SizedBox(height: AppDimensions.spaceLg.h),
            GestureDetector(
              onTap: onOpenDetailedReport,
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_chart_outlined,
                    size: 14,
                    color: AppColors.secondaryGreen,
                  ),
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
          ],
          Text(
            AppLocalizations.t('savings_history_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          MemberFilterChips(
            labels: filterLabels,
            currentIndex: filterIndex,
            onChanged: onFilterChanged,
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          if (isLoading && dashboard == null)
            const Center(child: CircularProgressIndicator())
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  AppLocalizations.t('history_empty'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (final operation in filtered) ...[
              _MemberSavingsOperationRow(
                operation: operation,
                currency: dashboard?.currency ?? 'XAF',
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
            ],
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

class _MemberSavingsSummaryCard extends StatelessWidget {
  const _MemberSavingsSummaryCard({required this.dashboard});

  final MemberSavingsDashboard dashboard;

  String _amount(int amount) =>
      NumberFormat.decimalPattern(AppLocalizations.locale.value).format(amount);

  @override
  Widget build(BuildContext context) {
    final share = dashboard.balanceShare;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.financialPositionBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t('savings_dashboard_title').toUpperCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_amount(dashboard.memberBalance)} / ${_amount(dashboard.totalBalance)} ${dashboard.currency}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Text(
                '${(share * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 8,
              backgroundColor: AppColors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            children: [
              Expanded(
                child: _SavingsCounter(
                  label: AppLocalizations.t('savings_validated_transactions'),
                  value:
                      '${dashboard.validatedMemberCount}/${dashboard.totalValidatedCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SavingsCounter(
                  label: AppLocalizations.t('savings_pending_transactions'),
                  value: dashboard.pendingMemberCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsCounter extends StatelessWidget {
  const _SavingsCounter({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.white, fontSize: 11),
        ),
      ],
    );
  }
}

class _MemberSavingsOperationRow extends StatelessWidget {
  const _MemberSavingsOperationRow({
    required this.operation,
    required this.currency,
  });

  final MemberSavingsOperation operation;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isWithdrawal = operation.type == 'RETRAIT_EPARGNE';
    final statusTranslationKey = switch (operation.status) {
      'VALIDE' => 'savings_status_validated',
      'REJETE' => 'savings_status_rejected',
      _ => 'savings_status_pending',
    };
    final statusColor = switch (operation.status) {
      'VALIDE' => AppColors.secondaryGreenDeep,
      'REJETE' => AppColors.error,
      _ => AppColors.warningText,
    };
    final date = operation.date;
    final amount = NumberFormat.decimalPattern(
      AppLocalizations.locale.value,
    ).format(operation.amount);

    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.neutralGrayLighter),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.iconBgMint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWithdrawal ? Icons.south_west : Icons.savings_outlined,
              color: AppColors.secondaryGreenDeep,
              size: 20,
            ),
          ),
          SizedBox(width: AppDimensions.spaceMd.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t(
                    isWithdrawal ? 'savings_withdrawal' : 'savings_deposit',
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (date != null)
                  Text(
                    DateFormat.yMMMd(
                      AppLocalizations.locale.value,
                    ).format(date),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                if (operation.period?.isNotEmpty == true)
                  Text(
                    operation.period!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                Text(
                  AppLocalizations.t(statusTranslationKey),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              '${isWithdrawal ? '−' : '+'}$amount $currency',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoansTab extends StatefulWidget {
  const _LoansTab({
    required this.dashboard,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.onRequestLoan,
  });

  final MemberLoanDashboard? dashboard;
  final bool isLoading;
  final bool hasError;
  final Future<void> Function() onRetry;
  final VoidCallback onRequestLoan;

  @override
  State<_LoansTab> createState() => _LoansTabState();
}

class _LoansTabState extends State<_LoansTab> {
  int _filterIndex = 0;

  String _amount(int amount, String currency) =>
      '${NumberFormat.decimalPattern(AppLocalizations.locale.value).format(amount)} '
      '${currency == 'XAF' ? 'FCFA' : currency}';

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.dashboard;
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.hasError || dashboard == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.t('member_loan_dashboard_error'),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => unawaited(widget.onRetry()),
              child: Text(AppLocalizations.t('retry')),
            ),
          ],
        ),
      );
    }

    final activeLoan = dashboard.activeLoan;
    final seniority = AppLocalizations.t(
      'loan_seniority_with_required',
      args: [dashboard.seniorityMonths, dashboard.minimumSeniorityMonths],
    );
    final eligibility = LoanEligibility(
      availableLimit: _amount(dashboard.maximumLoanAmount, dashboard.currency),
      seniorityLabel: seniority,
      hasGoodHistory: dashboard.hasGoodHistory,
    );
    final loan =
        activeLoan == null
            ? null
            : LoanInfo(
              statusLabel: AppLocalizations.t('loan_status_active'),
              borrowedAmount: _amount(
                activeLoan.borrowedAmount,
                dashboard.currency,
              ),
              repaymentPercent: activeLoan.repaymentRatio,
              totalRepaid: _amount(activeLoan.repaidAmount, dashboard.currency),
              remainingBalance: _amount(
                activeLoan.remainingBalance,
                dashboard.currency,
              ),
            );
    final due =
        dashboard.nextDueDate == null
            ? null
            : LoanDueInfo(
              dueDate: DateFormat.yMMMd(
                AppLocalizations.locale.value,
              ).format(dashboard.nextDueDate!),
              amount: _amount(dashboard.nextDueAmount ?? 0, dashboard.currency),
            );
    final filterLabels = [
      AppLocalizations.t('filter_all'),
      AppLocalizations.t('loan_operation_type_loan'),
      AppLocalizations.t('loan_operation_type_repayment'),
    ];
    final operations = dashboard.operations
        .where((operation) {
          if (_filterIndex == 1) return operation.isLoan;
          if (_filterIndex == 2) return !operation.isLoan;
          return true;
        })
        .toList(growable: false);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoanMemberHeader(dashboard: dashboard),
          SizedBox(height: AppDimensions.spaceLg.h),
          if (loan == null) ...[
            const NoActiveLoanCard(),
            SizedBox(height: AppDimensions.spaceLg.h),
            LoanEligibilityCard(eligibility: eligibility),
            SizedBox(height: AppDimensions.spaceLg.h),
            RequestLoanButton(onPressed: widget.onRequestLoan),
            SizedBox(height: AppDimensions.spaceLg.h),
            const LoanHowItWorksCard(),
          ] else ...[
            LoanSummaryCard(loan: loan),
            SizedBox(height: AppDimensions.spaceLg.h),
            if (due != null) ...[
              LoanDueCard(due: due),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
            const LoanNoticeBanner(),
            SizedBox(height: AppDimensions.spaceLg.h),
            Text(
              AppLocalizations.t('loan_operations_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceSm.h),
            MemberFilterChips(
              labels: filterLabels,
              currentIndex: _filterIndex,
              onChanged: (index) => setState(() => _filterIndex = index),
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            if (operations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    AppLocalizations.t('history_empty'),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              for (final operation in operations) ...[
                _LoanOperationRow(
                  operation: operation,
                  dashboard: dashboard,
                  onTap:
                      () =>
                          _showOperationDetails(context, operation, dashboard),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
              ],
          ],
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }

  void _showOperationDetails(
    BuildContext context,
    LoanOperation operation,
    MemberLoanDashboard dashboard,
  ) {
    final date = operation.date;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spaceLg.w,
                0,
                AppDimensions.spaceLg.w,
                AppDimensions.spaceLg.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.t('loan_operation_details'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceMd.h),
                  Text(
                    AppLocalizations.t(
                      operation.isLoan
                          ? 'loan_operation_type_loan'
                          : 'loan_operation_type_repayment',
                    ),
                  ),
                  Text(
                    _amount(operation.amount, dashboard.currency),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _loanOperationStatus(operation.status),
                    style: TextStyle(
                      color: _loanOperationStatusColor(operation.status),
                    ),
                  ),
                  if (date != null)
                    Text(
                      DateFormat.yMMMd(
                        AppLocalizations.locale.value,
                      ).format(date),
                    ),
                  if (operation.reason != null)
                    _LoanDetailLine(
                      label: AppLocalizations.t('loan_detail_reason'),
                      value: operation.reason!,
                    ),
                  if (operation.rejectionReason != null)
                    _LoanDetailLine(
                      label: AppLocalizations.t(
                        'loan_operation_status_rejected',
                      ),
                      value: operation.rejectionReason!,
                    ),
                  if (operation.paymentMode != null)
                    _LoanDetailLine(
                      label: AppLocalizations.t('loan_detail_payment_mode'),
                      value: operation.paymentMode!,
                    ),
                  if (operation.paymentReference != null)
                    _LoanDetailLine(
                      label: AppLocalizations.t('loan_detail_reference'),
                      value: operation.paymentReference!,
                    ),
                ],
              ),
            ),
          ),
    );
  }
}

String _loanOperationStatus(String status) => switch (status) {
  'EN_ATTENTE' => AppLocalizations.t('loan_operation_status_pending'),
  'APPROUVE' => AppLocalizations.t('loan_operation_status_approved'),
  'REJETE' => AppLocalizations.t('loan_operation_status_rejected'),
  'VALIDE' => AppLocalizations.t('loan_operation_status_validated'),
  _ => status,
};

Color _loanOperationStatusColor(String status) => switch (status) {
  'APPROUVE' || 'VALIDE' => AppColors.secondaryGreenDeep,
  'REJETE' => AppColors.error,
  'EN_ATTENTE' => AppColors.warningText,
  _ => AppColors.textSecondary,
};

class _LoanMemberHeader extends StatelessWidget {
  const _LoanMemberHeader({required this.dashboard});

  final MemberLoanDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.neutralGrayLighter),
      ),
      child: Row(
        children: [
          ClipOval(
            child:
                dashboard.memberPhotoUrl == null
                    ? Container(
                      width: 46,
                      height: 46,
                      color: AppColors.iconBgMint,
                      child: const Icon(Icons.person_outline),
                    )
                    : Image.network(
                      dashboard.memberPhotoUrl!,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 46,
                            height: 46,
                            color: AppColors.iconBgMint,
                            child: const Icon(Icons.person_outline),
                          ),
                    ),
          ),
          SizedBox(width: AppDimensions.spaceMd.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dashboard.memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  dashboard.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  AppLocalizations.t(
                    'loan_cycle_label',
                    args: [dashboard.cycleNumber],
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanOperationRow extends StatelessWidget {
  const _LoanOperationRow({
    required this.operation,
    required this.dashboard,
    required this.onTap,
  });

  final LoanOperation operation;
  final MemberLoanDashboard dashboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeKey =
        operation.isLoan
            ? 'loan_operation_type_loan'
            : 'loan_operation_type_repayment';
    final date = operation.date;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceMd.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.neutralGrayLighter),
          ),
          child: Row(
            children: [
              ClipOval(
                child:
                    dashboard.memberPhotoUrl == null
                        ? Container(
                          width: 40,
                          height: 40,
                          color: AppColors.iconBgMint,
                          child: const Icon(Icons.person_outline, size: 20),
                        )
                        : Image.network(
                          dashboard.memberPhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 40,
                                height: 40,
                                color: AppColors.iconBgMint,
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 20,
                                ),
                              ),
                        ),
              ),
              SizedBox(width: AppDimensions.spaceMd.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t(typeKey),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (date != null)
                      Text(
                        DateFormat.yMMMd(
                          AppLocalizations.locale.value,
                        ).format(date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    Text(
                      _loanOperationStatus(operation.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _loanOperationStatusColor(operation.status),
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 104),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${NumberFormat.decimalPattern(AppLocalizations.locale.value).format(operation.amount)} ${dashboard.currency == 'XAF' ? 'FCFA' : dashboard.currency}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanDetailLine extends StatelessWidget {
  const _LoanDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: AppDimensions.spaceSm.h),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.textPrimary),
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

class _BeneficiairesTab extends StatefulWidget {
  const _BeneficiairesTab({
    required this.isAdmin,
    required this.isTreasurer,
    required this.current,
    required this.stats,
    required this.passageOrder,
    required this.passageOrderLoading,
    required this.passageOrderError,
    required this.onReorderPassageOrder,
    required this.showPassageOrderToMembers,
    required this.payoutHistory,
    required this.onDisburse,
    required this.onSeeAllPayoutHistory,
  });

  final bool isAdmin;
  final bool isTreasurer;
  final CurrentBeneficiary current;
  final BeneficiaryStats stats;
  final List<PassageOrderEntry> passageOrder;
  final bool passageOrderLoading;
  final String? passageOrderError;
  final Future<List<PassageOrderEntry>?> Function(
    List<PassageOrderEntry> entries,
  )
  onReorderPassageOrder;
  final bool showPassageOrderToMembers;
  final List<PayoutHistoryEntry> payoutHistory;
  final VoidCallback onDisburse;
  final VoidCallback onSeeAllPayoutHistory;

  @override
  State<_BeneficiairesTab> createState() => _BeneficiairesTabState();
}

class _BeneficiairesTabState extends State<_BeneficiairesTab> {
  late List<PassageOrderEntry> _order = List.of(widget.passageOrder);
  bool _isSavingOrder = false;

  @override
  void didUpdateWidget(covariant _BeneficiairesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passageOrder != widget.passageOrder) {
      _order = List.of(widget.passageOrder);
    }
  }

  void _reorder(int oldIndex, int newIndex) {
    if (_isSavingOrder || oldIndex == newIndex) return;
    setState(() {
      _order = reorderPassageOrder(_order, oldIndex, newIndex);
      _isSavingOrder = true;
    });
    unawaited(_persistOrder());
  }

  Future<void> _persistOrder() async {
    final previousOrder = List<PassageOrderEntry>.of(widget.passageOrder);
    try {
      final savedOrder = await widget.onReorderPassageOrder(_order);
      if (!mounted) return;
      setState(() {
        _order = savedOrder ?? previousOrder;
        _isSavingOrder = false;
      });
      if (savedOrder == null) _showOrderSaveError();
    } catch (error) {
      debugPrint('[TONTINE] Could not save reordered beneficiary list: $error');
      if (!mounted) return;
      setState(() {
        _order = previousOrder;
        _isSavingOrder = false;
      });
      _showOrderSaveError();
    }
  }

  void _showOrderSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.t('cycle_tontine_save_error'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEntries = _order.where((entry) => entry.isCurrent);
    final currentEntry = currentEntries.isEmpty ? null : currentEntries.first;
    final currentBeneficiary = CurrentBeneficiary(
      name: currentEntry?.name ?? '—',
      subtitle:
          currentEntry == null
              ? ''
              : '${AppLocalizations.t('cycle_word')} ${currentEntry.order}',
      statusLabel: currentEntry?.statusLabel ?? '',
      amount: widget.current.amount,
    );
    final currentStats = BeneficiaryStats(
      totalMembers: _order.length,
      potAmount: widget.stats.potAmount,
      servedCount: _order.where((entry) => entry.isPaid).length,
      remainingCount: _order.where((entry) => !entry.isPaid).length,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentBeneficiaryCard(
            beneficiary: currentBeneficiary,
            onDisburse: widget.isTreasurer ? widget.onDisburse : null,
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          BeneficiaryStatsGrid(stats: currentStats),
          SizedBox(height: AppDimensions.spaceLg.h),
          if (widget.isAdmin || widget.showPassageOrderToMembers) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.t('passage_order_section'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spaceXs.w),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adminHintBg,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.t(
                        widget.isAdmin
                            ? 'admin_view_reorder_hint'
                            : 'member_view_hint',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spaceSm.h),
            if (widget.passageOrderLoading)
              Shimmer(
                child: Column(
                  children: [
                    for (var index = 0; index < 3; index++)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SkeletonBox(width: 32, height: 32, isCircle: true),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonBox(width: 150, height: 14),
                                  SizedBox(height: 8),
                                  SkeletonBox(width: 100, height: 11),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            SkeletonBox(width: 20, height: 20),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            else if (_order.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceMd.h,
                ),
                child: Text(
                  widget.passageOrderError ??
                      AppLocalizations.t('cycle_tontine_no_members'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            else if (widget.isAdmin)
              IgnorePointer(
                ignoring: _isSavingOrder,
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorder:
                      (oldIndex, newIndex) => _reorder(oldIndex, newIndex),
                  children: [
                    for (var i = 0; i < _order.length; i++)
                      _TimelineStep(
                        key: ValueKey(_order[i].membershipId ?? 'position-$i'),
                        entry: _order[i],
                        isLast: i == _order.length - 1,
                        child: ReorderableDragStartListener(
                          index: i,
                          child: PassageOrderRow(
                            entry: _order[i],
                            draggable: true,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              for (var i = 0; i < _order.length; i++)
                _TimelineStep(
                  entry: _order[i],
                  isLast: i == _order.length - 1,
                  child: PassageOrderRow(entry: _order[i]),
                ),
          ],
          SizedBox(height: AppDimensions.spaceLg.h),
          Text(
            AppLocalizations.t('payout_history_section'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.t('see_full_history'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.primaryContainer,
                        ),
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
  const _TimelineStep({
    super.key,
    required this.entry,
    required this.isLast,
    required this.child,
  });

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
                        child: Icon(
                          Icons.play_arrow,
                          size: 18,
                          color: AppColors.white,
                        ),
                      )
                      : CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          '${entry.order}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
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

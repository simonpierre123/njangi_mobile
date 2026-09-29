import 'package:flutter/material.dart';
import '../../../Models/report_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../widgets/community_app_bar.dart';
import 'widgets/contribution_evolution_chart.dart';
import 'widgets/financial_stat_card.dart';
import 'widgets/loan_report_card.dart';
import 'widgets/participation_ring_card.dart';
import 'widgets/recent_report_activity_row.dart';

/// Écran "Résumé financier" — reçu au clic sur l'action rapide
/// "Rapports" du Tableau de Bord admin. Vue d'ensemble complète des
/// finances de la communauté.
///
/// Poussé par-dessus le shell (sous-page de consultation), avec son
/// propre CommunityAppBar (nom + rôle + cycle) puisqu'il n'est pas un
/// onglet du shell.
class FinancialSummaryPage extends StatelessWidget {
  const FinancialSummaryPage({
    super.key,
    required this.communityName,
    required this.cycleLabel,
    required this.role,
    required this.summary,
    required this.evolution,
    required this.participation,
    required this.loanDetails,
    required this.recentActivity,
    required this.onBack,
    required this.onExport,
    required this.onSeeFullHistory,
    required this.onOpenDetailedReport,
  });

  final String communityName;
  final String cycleLabel;
  final String? role;
  final FinancialSummary summary;
  final List<ChartPoint> evolution;
  final ParticipationBreakdown participation;
  final LoanReportDetails loanDetails;
  final List<RecentReportActivity> recentActivity;
  final VoidCallback onBack;
  final VoidCallback onExport;
  final VoidCallback onSeeFullHistory;
  final VoidCallback onOpenDetailedReport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommunityAppBar(
        name: communityName,
        cycleLabel: cycleLabel,
        role: role,
        onBack: onBack,
        trailing: IconButton(
          onPressed: onExport,
          icon: const Icon(Icons.ios_share, color: AppColors.textPrimary),
        ),
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
              Text(
                AppLocalizations.t('financial_summary_title'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              FinancialStatCard(
                label: AppLocalizations.t('current_balance_label'),
                amount: summary.currentBalance,
                dark: true,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              GestureDetector(
                onTap: onOpenDetailedReport,
                child: FinancialStatCard(
                  label: AppLocalizations.t('total_contributions_label'),
                  amount: summary.totalContributions,
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              FinancialStatCard(
                label: AppLocalizations.t('total_disbursements_label'),
                amount: summary.totalDisbursements,
                amountColor: AppColors.alertRed,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              FinancialStatCard(
                label: AppLocalizations.t('active_loans_label'),
                amount: summary.activeLoans,
                amountColor: AppColors.purple,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.t('contributions_evolution_title'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  // TODO (Njoya) : plage figée "Jan - Jul 2024" — à
                  // rendre dynamique une fois l'API branchée.
                  const Text('Jan - Jul 2024', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppDimensions.spaceSm.h),
                padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: ContributionEvolutionChart(points: evolution),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('participation_section'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              ParticipationRingCard(data: participation),
              SizedBox(height: AppDimensions.spaceLg.h),
              LoanReportCard(data: loanDetails),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('recent_activity_report_section'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
                    for (var i = 0; i < recentActivity.length; i++) ...[
                      RecentReportActivityRow(activity: recentActivity[i]),
                      SizedBox(height: AppDimensions.spaceSm.h),
                    ],
                    GestureDetector(
                      onTap: onSeeFullHistory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.mintPale34,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        ),
                        child: Text(
                          AppLocalizations.t('see_full_history'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppButton(
                label: AppLocalizations.t('export_report_button'),
                icon: Icons.download_outlined,
                iconLeading: true,
                onPressed: onExport,
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}
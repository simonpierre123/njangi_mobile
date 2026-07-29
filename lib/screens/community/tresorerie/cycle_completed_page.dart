import 'package:flutter/material.dart';
import '../../../Models/cycle_completion_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../widgets/community_app_bar.dart';
import 'widgets/beneficiary_history_row.dart';
import 'widgets/closure_report_card.dart';
import 'widgets/cycle_completion_header.dart';
import 'widgets/cycle_summary_stats_grid.dart';
import 'widgets/new_cycle_card.dart';

/// Écran "Cycle terminé" — affiché après confirmation d'un
/// décaissement qui clôture le cycle en cours (tous les bénéficiaires
/// servis).
class CycleCompletedPage extends StatelessWidget {
  const CycleCompletedPage({
    super.key,
    required this.communityName,
    required this.cycleLabel,
    required this.role,
    required this.closedDateLabel,
    required this.stats,
    required this.beneficiaryHistory,
    required this.onBack,
    required this.onSeeFullList,
    required this.onExportReport,
    required this.onStartNewCycle,
    required this.onSeeCyclesHistory,
  });

  final String communityName;
  final String cycleLabel;
  final String? role;
  final String closedDateLabel;
  final CycleSummaryStats stats;
  final List<BeneficiaryHistoryEntry> beneficiaryHistory;
  final VoidCallback onBack;
  final VoidCallback onSeeFullList;
  final VoidCallback onExportReport;
  final VoidCallback onStartNewCycle;
  final VoidCallback onSeeCyclesHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommunityAppBar(
        name: communityName,
        cycleLabel: cycleLabel,
        role: role,
        onBack: onBack,
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: CycleCompletionHeader(communityName: communityName, closedDateLabel: closedDateLabel),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('cycle_summary_section'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              CycleSummaryStatsGrid(stats: stats),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('beneficiary_history_section'),
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
                    for (var i = 0; i < beneficiaryHistory.length; i++) ...[
                      BeneficiaryHistoryRow(entry: beneficiaryHistory[i]),
                      SizedBox(height: AppDimensions.spaceSm.h),
                    ],
                    GestureDetector(
                      onTap: onSeeFullList,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.t('see_full_list_link'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryGreen),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.secondaryGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              ClosureReportCard(onExport: onExportReport),
              SizedBox(height: AppDimensions.spaceLg.h),
              NewCycleCard(onStartNewCycle: onStartNewCycle, onSeeCyclesHistory: onSeeCyclesHistory),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}
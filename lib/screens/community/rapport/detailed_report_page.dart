import 'package:flutter/material.dart';
import '../../../Models/report_model.dart';
import '../../../common/basewidget/member_avatars_stack.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/report_bar_chart.dart';
import 'widgets/report_transaction_row.dart';

/// Écran "Rapport détaillé" — vue transactionnelle détaillée des
/// contributions, reçue depuis l'onglet Contributions de la Trésorerie
/// (ou depuis "Contributions totales" du Résumé financier).
class DetailedReportPage extends StatefulWidget {
  const DetailedReportPage({
    super.key,
    required this.communityName,
    required this.role,
    required this.summary,
    required this.evolution,
    required this.transactions,
    required this.onBack,
    required this.onSeeAllTransactions,
    required this.onExport,
  });

  final String communityName;
  final String? role;
  final DetailedReportSummary summary;
  final List<ChartPoint> evolution;
  final List<ReportTransaction> transactions;
  final VoidCallback onBack;
  final VoidCallback onSeeAllTransactions;
  final VoidCallback onExport;

  @override
  State<DetailedReportPage> createState() => _DetailedReportPageState();
}

class _DetailedReportPageState extends State<DetailedReportPage> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('detailed_report_title'), onBack: widget.onBack),
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
              Row(
                children: [
                  Text(
                    AppLocalizations.t('contributions_breadcrumb'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(widget.communityName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (widget.role != null) ...[
                    const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      widget.role!,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.roleText),
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              MemberFilterChips(
                labels: [
                  AppLocalizations.t('filter_all'),
                  AppLocalizations.t('filter_today'),
                  AppLocalizations.t('filter_this_week'),
                  AppLocalizations.t('filter_this_month'),
                ],
                currentIndex: _filterIndex,
                onChanged: (i) => setState(() => _filterIndex = i),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t('total_collected_label').toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white.withValues(alpha: 0.75), letterSpacing: 0.5),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      widget.summary.totalCollected,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_upward, size: 10, color: AppColors.white),
                              const SizedBox(width: 2),
                              Text(
                                widget.summary.changeLabel,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppDimensions.spaceSm.w),
                        Text(
                          widget.summary.updatedAtLabel,
                          style: TextStyle(fontSize: 10, color: AppColors.white.withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t('transactions_word'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Row(
                      children: [
                        Text(
                          '${widget.summary.transactionsCount}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const Spacer(),
                        MemberAvatarsStack(count: widget.summary.transactionsCount),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.t('versements_evolution_title'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.t('objective_reached_label'),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
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
                child: ReportBarChart(points: widget.evolution),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.t('last_operations_section'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: widget.onSeeAllTransactions,
                    child: Text(
                      AppLocalizations.t('see_all_report_link'),
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
              for (var i = 0; i < widget.transactions.length; i++) ...[
                ReportTransactionRow(transaction: widget.transactions[i]),
                if (i != widget.transactions.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
              ],
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onExport,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text(AppLocalizations.t('export_pdf_button')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceSm.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: IconButton(
                      onPressed: widget.onExport,
                      icon: const Icon(Icons.ios_share, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}
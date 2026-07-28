import 'package:flutter/material.dart';
import '../../../Models/contribution_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/contribution_summary_header.dart';
import 'widgets/detail_row.dart';
import 'widgets/observation_box.dart';
import 'widgets/recorded_by_card.dart';

/// Page "Contribution" — détail complet d'une cotisation déjà
/// enregistrée. Poussée par-dessus le shell (sous-page de
/// consultation).
class ContributionDetailPage extends StatelessWidget {
  const ContributionDetailPage({
    super.key,
    required this.detail,
    required this.onBack,
    required this.onShareReceipt,
    required this.onModify,
    required this.onCancelRecording,
  });

  final ContributionDetail detail;
  final VoidCallback onBack;
  final VoidCallback onShareReceipt;
  final VoidCallback onModify;
  final VoidCallback onCancelRecording;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('contribution_detail_title'), onBack: onBack),
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
              ContributionSummaryHeader(
                memberName: detail.memberName,
                amount: detail.amount,
                periodLabel: detail.periodLabel,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('details_section').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    DetailRow(label: AppLocalizations.t('expected_amount_label'), value: detail.expectedAmount),
                    Divider(height: 1, color: AppColors.inputBorder),
                    DetailRow(label: AppLocalizations.t('paid_amount_label'), value: detail.paidAmount),
                    Divider(height: 1, color: AppColors.inputBorder),
                    DetailRow(
                      label: AppLocalizations.t('status_word'),
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.tagMintBg, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
                        child: Text(
                          detail.statusLabel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: AppColors.inputBorder),
                    DetailRow(label: AppLocalizations.t('date_word'), value: detail.dateLabel),
                    Divider(height: 1, color: AppColors.inputBorder),
                    DetailRow(label: AppLocalizations.t('time_word'), value: detail.timeLabel),
                    Divider(height: 1, color: AppColors.inputBorder),
                    DetailRow(
                      label: AppLocalizations.t('payment_method_label'),
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payments_outlined, size: 14, color: AppColors.textPrimary),
                          const SizedBox(width: 4),
                          Text(
                            detail.paymentMethodLabel,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColors.inputBorder),
                    DetailRow(label: AppLocalizations.t('reference_label'), value: detail.reference),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('history_section').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              RecordedByCard(
                name: detail.recordedByName,
                roleLabel: detail.recordedByRole,
                recordedAtLabel: detail.recordedAtLabel,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('observation_section').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              ObservationBox(text: detail.observation),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppButton(
                label: AppLocalizations.t('share_receipt_button'),
                icon: Icons.ios_share,
                iconLeading: true,
                onPressed: onShareReceipt,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              AppButton(
                label: AppLocalizations.t('modify_button'),
                icon: Icons.edit_outlined,
                iconLeading: true,
                variant: AppButtonVariant.secondary,
                onPressed: onModify,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Center(
                child: InkWell(
                  onTap: onCancelRecording,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline, size: 14, color: AppColors.alertRed),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.t('cancel_recording_button'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.alertRed),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}
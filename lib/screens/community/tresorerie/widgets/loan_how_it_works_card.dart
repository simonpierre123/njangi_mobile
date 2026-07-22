import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte explicative "Comment fonctionne un prêt ?" — 3 étapes numérotées.
class LoanHowItWorksCard extends StatelessWidget {
  const LoanHowItWorksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (AppLocalizations.t('step1_title'), AppLocalizations.t('step1_desc')),
      (AppLocalizations.t('step2_title'), AppLocalizations.t('step2_desc')),
      (AppLocalizations.t('step3_title'), AppLocalizations.t('step3_desc')),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.profileBannerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t('how_loan_works_title'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.stepGreen),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          for (var i = 0; i < steps.length; i++) ...[
            _StepRow(number: i + 1, title: steps[i].$1, description: steps[i].$2),
            if (i != steps.length - 1) SizedBox(height: AppDimensions.spaceMd.h),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.title, required this.description});

  final int number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.stepGreen)),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(fontSize: 12, color: AppColors.stepGreenText)),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Rapport de clôture" — icône document, titre, sous-titre,
/// bouton "Exporter le rapport".
class ClosureReportCard extends StatelessWidget {
  const ClosureReportCard({super.key, required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: AppColors.mintPale, shape: BoxShape.circle),
                child: const Icon(Icons.description_outlined, size: 15, color: AppColors.primaryDeepest),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t('closure_report_title'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.t('closure_report_subtitle'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Material(
            color: AppColors.mintPale34,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            child: InkWell(
              onTap: onExport,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_outlined, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.t('export_report_button'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
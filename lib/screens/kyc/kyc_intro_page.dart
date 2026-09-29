import 'package:flutter/material.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/kyc_benefit_row.dart';
import 'widgets/kyc_benefit_tile.dart';
import 'widgets/kyc_checklist_box.dart';

/// KYC — Étape 1/4 : introduction. Illustration = asset fourni par
/// Njoya (assets/images/kyc1.png).
class KycIntroPage extends StatelessWidget {
  const KycIntroPage({
    super.key,
    required this.onBack,
    required this.onStart,
    required this.onLater,
  });

  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('kyc_verification_title'), onBack: onBack),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                child: Image.asset(
                  'assets/images/kyc1.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: AppColors.tagMintBg,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, size: 32, color: AppColors.primaryDark),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc1_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc1_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              KycBenefitRow(icon: Icons.shield_outlined, label: AppLocalizations.t('kyc_benefit_secure_account')),
              SizedBox(height: AppDimensions.spaceSm.h),
              Row(
                children: [
                  Expanded(
                    child: KycBenefitTile(
                      icon: Icons.emoji_events_outlined,
                      label: AppLocalizations.t('kyc_benefit_loan_access'),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Expanded(
                    child: KycBenefitTile(
                      icon: Icons.handshake_outlined,
                      label: AppLocalizations.t('kyc_benefit_trusted_community'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.t('kyc_time_estimate'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              KycChecklistBox(
                title: AppLocalizations.t('kyc_prerequisites_section'),
                items: [
                  AppLocalizations.t('kyc_prereq_valid_id'),
                  AppLocalizations.t('kyc_prereq_lighting'),
                  AppLocalizations.t('kyc_prereq_internet'),
                ],
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppButton(label: AppLocalizations.t('kyc_start_button'), onPressed: onStart),
              SizedBox(height: AppDimensions.spaceSm.h),
              Center(
                child: GestureDetector(
                  onTap: onLater,
                  child: Text(
                    AppLocalizations.t('kyc_later_link'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}
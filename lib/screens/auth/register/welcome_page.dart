import 'package:flutter/material.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 4/4 de l'inscription : écran de bienvenue final.
class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onBack,
    required this.onStart,
    required this.onSetupProfile,
  });

  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onSetupProfile;

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepHeader(step: 4, totalSteps: 4, onBack: onBack),
              const Spacer(),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.white, size: 28),
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('welcome_title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('welcome_subtitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Spacer(),
              AppButton(
                label: AppLocalizations.t('onboarding_start'),
                icon: Icons.arrow_forward,
                onPressed: onStart,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              AppButton(
                label: AppLocalizations.t('setup_profile_button'),
                variant: AppButtonVariant.secondary,
                onPressed: onSetupProfile,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../common/basewidget/app_badge.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/app_logo.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/stat_pill.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({
    super.key,
    required this.onCreateAccount,
    required this.onLogin,
    required this.onLanguageToggle,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;
  final VoidCallback onLanguageToggle;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

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
              SizedBox(height: AppDimensions.spaceSm.h),
              _TopRow(onLanguageToggle: onLanguageToggle),
              SizedBox(height: AppDimensions.spaceLg.h),
              const Align(
                alignment: Alignment.centerRight,
                child: StatPill(value: '+12%'),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppBadge(
                label: AppLocalizations.t('auth_community_tag'),
                icon: Icons.people_outline,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: AppDimensions.spaceLg.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.mintSurfaceLighter, AppColors.white],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
              ),
              AppBadge(
                label: AppLocalizations.t('auth_welcome_ribbon'),
                variant: AppBadgeVariant.filled,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('auth_welcome_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('auth_welcome_desc'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppButton(
                label: AppLocalizations.t('auth_create_account'),
                icon: Icons.arrow_forward,
                onPressed: onCreateAccount,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              AppButton(
                label: AppLocalizations.t('auth_login'),
                variant: AppButtonVariant.secondary,
                onPressed: onLogin,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              _LegalText(onTermsTap: onTermsTap, onPrivacyTap: onPrivacyTap),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.onLanguageToggle});

  final VoidCallback onLanguageToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AppLogo(size: AppLogoSize.large),
        IconButton(
          onPressed: onLanguageToggle,
          icon: const Icon(Icons.language, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _LegalText extends StatelessWidget {
  const _LegalText({required this.onTermsTap, required this.onPrivacyTap});

  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = baseStyle?.copyWith(
      color: AppColors.primaryDark,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: '${AppLocalizations.t('auth_terms_prefix')} '),
          TextSpan(
            text: AppLocalizations.t('auth_terms_link'),
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          TextSpan(text: ' ${AppLocalizations.t('auth_terms_and')} '),
          TextSpan(
            text: AppLocalizations.t('auth_privacy_link'),
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
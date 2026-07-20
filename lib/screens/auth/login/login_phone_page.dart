import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 1/3 de la connexion : saisie du numéro de téléphone lié au compte.
class LoginPhonePage extends StatefulWidget {
  const LoginPhonePage({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.onRegister,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onContinue;
  final VoidCallback onRegister;

  @override
  State<LoginPhonePage> createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends State<LoginPhonePage> {
  String? _completeNumber;

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
              StepHeader(step: 1, totalSteps: 3, onBack: widget.onBack),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('login_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('login_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              IntlPhoneField(
                initialCountryCode: 'CM',
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (phone) => _completeNumber = phone.completeNumber,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('login_helper'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              AppButton(
                label: AppLocalizations.t('continue_button'),
                onPressed: () {
                  if (_completeNumber != null) widget.onContinue(_completeNumber!);
                },
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: '${AppLocalizations.t('no_account')} '),
                      TextSpan(
                        text: AppLocalizations.t('register_link'),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = widget.onRegister,
                      ),
                    ],
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
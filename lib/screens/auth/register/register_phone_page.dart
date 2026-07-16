import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 1/4 de l'inscription : saisie du numéro de téléphone.
/// Le sélecteur de pays + drapeau est fourni par le package
/// intl_phone_field (flutter pub add intl_phone_field).
class RegisterPhonePage extends StatefulWidget {
  const RegisterPhonePage({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.onLogin,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onContinue;
  final VoidCallback onLogin;

  @override
  State<RegisterPhonePage> createState() => _RegisterPhonePageState();
}

class _RegisterPhonePageState extends State<RegisterPhonePage> {
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
              StepHeader(step: 1, totalSteps: 4, onBack: widget.onBack),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('register_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('register_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              IntlPhoneField(
                // TODO (Njoya) : remplacer 'CM' par le pays détecté
                // automatiquement si tu veux préremplir selon la
                // localisation de l'utilisateur.
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
                AppLocalizations.t('register_helper'),
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
                      TextSpan(text: '${AppLocalizations.t('already_account')} '),
                      TextSpan(
                        text: AppLocalizations.t('login_link'),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = widget.onLogin,
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
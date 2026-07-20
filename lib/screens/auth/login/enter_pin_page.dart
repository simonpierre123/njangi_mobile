import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/numeric_keypard.dart';
import '../../../common/basewidget/pin_dots.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 3/3 de la connexion : saisie du code PIN existant (vérification,
/// pas de création — contrairement au parcours d'inscription).
class EnterPinPage extends StatefulWidget {
  const EnterPinPage({
    super.key,
    required this.onBack,
    required this.onSubmit,
    required this.onForgotPin,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSubmit;
  final VoidCallback onForgotPin;

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  String _pin = '';

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final isComplete = _pin.length == 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepHeader(step: 3, totalSteps: 3, onBack: widget.onBack),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('enter_pin_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('enter_pin_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              PinDots(length: _pin.length),
              const Spacer(),
              AppButton(
                label: AppLocalizations.t('access_account_button'),
                onPressed: isComplete ? () => widget.onSubmit(_pin) : () {},
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              NumericKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              SizedBox(height: AppDimensions.spaceMd.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: '${AppLocalizations.t('forgot_pin')} '),
                      TextSpan(
                        text: AppLocalizations.t('reset_pin_link'),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = widget.onForgotPin,
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
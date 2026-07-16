import 'package:flutter/material.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/info_banner.dart';
import '../../../common/basewidget/numeric_keypard.dart';


import '../../../common/basewidget/pin_dots.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 3/4 de l'inscription : création du code PIN (clavier custom,
/// pas de clavier système).
class CreatePinPage extends StatefulWidget {
  const CreatePinPage({
    super.key,
    required this.onBack,
    required this.onPinCreated,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onPinCreated;

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
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
              StepHeader(step: 3, totalSteps: 4, onBack: widget.onBack),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('pin_create_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('pin_create_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              PinDots(length: _pin.length),
              const Spacer(),
              InfoBanner(message: AppLocalizations.t('pin_tip')),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppButton(
                label: AppLocalizations.t('continue_button'),
                // TODO (Njoya) : AppButton n'a pas encore d'état "désactivé"
                // visuel — ici on bloque juste l'action tant que le PIN
                // n'est pas complet.
                onPressed: isComplete ? () => widget.onPinCreated(_pin) : () {},
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              NumericKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}
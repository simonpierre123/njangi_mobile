import 'package:flutter/material.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/info_banner.dart';
import '../../../common/basewidget/numeric_keypard.dart';


import '../../../common/basewidget/pin_dots.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 3/4 (suite) : confirmation du code PIN saisi précédemment.
class ConfirmPinPage extends StatefulWidget {
  const ConfirmPinPage({
    super.key,
    required this.originalPin,
    required this.onBack,
    required this.onConfirmed,
  });

  final String originalPin;
  final VoidCallback onBack;
  final ValueChanged<String> onConfirmed;

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
  String _pin = '';

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onConfirm() {
    if (_pin.length != 4) return;
    if (_pin == widget.originalPin) {
      widget.onConfirmed(_pin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.t('pin_mismatch'))),
      );
      setState(() => _pin = '');
    }
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
                AppLocalizations.t('pin_confirm_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              PinDots(length: _pin.length),
              const Spacer(),
              InfoBanner(message: AppLocalizations.t('pin_tip')),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppButton(
                label: AppLocalizations.t('pin_confirm_button'),
                onPressed: isComplete ? _onConfirm : () {},
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
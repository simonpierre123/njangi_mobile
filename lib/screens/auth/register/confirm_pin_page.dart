import 'package:flutter/material.dart';
import 'package:njangi/Controllers_distant/AuthController.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/info_banner.dart';
import '../../../common/basewidget/numeric_keypard.dart';
import '../../../common/basewidget/pin_dots.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

class ConfirmPinPage extends StatefulWidget {
  const ConfirmPinPage({
    super.key,
    required this.originalPin,
    required this.telephone,
    required this.onBack,
    required this.onConfirmed,
  });

  final String originalPin;
  final String telephone;
  final VoidCallback onBack;
  final ValueChanged<String> onConfirmed;

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
  final AuthController _authController = AuthController();
  String _pin = '';

  @override
  void initState() {
    super.initState();
    _authController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    if (_pin.length >= 4 || _authController.isLoading) return;
    setState(() => _pin += d);
  }

  void _onBackspace() {
    if (_pin.isEmpty || _authController.isLoading) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _onConfirm() async {
    if (_pin.length != 4 || _authController.isLoading) return;

    if (_pin != widget.originalPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.t('pin_mismatch')),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _pin = '');
      return;
    }

    // Appel au backend en passant le numéro de téléphone et le PIN
    final response = await _authController.setPin(
      telephone: widget.telephone,
      pin: _pin,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? AppLocalizations.t('PIN_SET_SUCCESS'),
          ),
          backgroundColor: Colors.green,
        ),
      );
      widget.onConfirmed(_pin);
    } else {
      final errorMessage =
          response['message'] ?? AppLocalizations.t('set_pin_error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH.w,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                      const SizedBox(height: 24),
                      InfoBanner(message: AppLocalizations.t('pin_tip')),
                      SizedBox(height: AppDimensions.spaceMd.h),
                      AppButton(
                        label: AppLocalizations.t('pin_confirm_button'),
                        isLoading: _authController.isLoading,
                        onPressed:
                            (isComplete && !_authController.isLoading)
                                ? _onConfirm
                                : () {},
                      ),
                      SizedBox(height: AppDimensions.spaceMd.h),
                      NumericKeypad(
                        onDigit: _onDigit,
                        onBackspace: _onBackspace,
                      ),
                      SizedBox(height: AppDimensions.spaceMd.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

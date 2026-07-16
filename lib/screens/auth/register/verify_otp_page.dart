import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/otp_input_boxes.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Étape 2/4 de l'inscription : vérification du code OTP.
class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onEditNumber,
    required this.onVerified,
    required this.onResend,
  });

  final String phoneNumber;
  final VoidCallback onBack;
  final VoidCallback onEditNumber;
  final ValueChanged<String> onVerified;
  final VoidCallback onResend;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  String _code = '';
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
              StepHeader(step: 2, totalSteps: 4, onBack: widget.onBack),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('otp_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text:
                          '${AppLocalizations.t('otp_subtitle_prefix')} ${widget.phoneNumber}. ',
                    ),
                    TextSpan(
                      text: AppLocalizations.t('otp_edit_number'),
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = widget.onEditNumber,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              OtpInputBoxes(
                length: 6,
                onChanged: (v) => _code = v,
                onCompleted: (v) => _code = v,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Row(
                children: [
                  Text(
                    '${AppLocalizations.t('otp_no_code')} ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: _secondsLeft == 0
                        ? () {
                            widget.onResend();
                            _startTimer();
                          }
                        : null,
                    child: Text(
                      _secondsLeft == 0
                          ? AppLocalizations.t('otp_resend_now')
                          : '${AppLocalizations.t('resend_prefix')} ${_secondsLeft}s',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppButton(
                label: AppLocalizations.t('verify_button'),
                onPressed: () {
                  if (_code.length == 6) widget.onVerified(_code);
                },
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}
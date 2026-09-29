import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/otp_input_boxes.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Écran de vérification du code OTP, réutilisé par l'inscription
/// (Étape 2/4) et la connexion (Étape 2/3) — step/totalSteps configurables.
class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onEditNumber,
    required this.onVerified,
    required this.onResend,
    this.step = 2,
    this.totalSteps = 4,
  });

  final String phoneNumber;
  final VoidCallback onBack;
  final VoidCallback onEditNumber;
  final FutureOr<void> Function(String) onVerified;
  final VoidCallback onResend;
  final int step;
  final int totalSteps;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  String _code = '';
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isLoading = false;

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

  /// Traitement de la validation de l'OTP
  Future<void> _handleVerify() async {
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.t('invalid_otp_length'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      // Transmet le code OTP saisi au callback parent pour gérer la suite du flux
      await widget.onVerified(_code);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepHeader(
                step: widget.step,
                totalSteps: widget.totalSteps,
                onBack: widget.onBack,
              ),
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
                      recognizer:
                          TapGestureRecognizer()..onTap = widget.onEditNumber,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              OtpInputBoxes(
                length: 6,
                onChanged: (v) => _code = v,
                onCompleted: (v) {
                  _code = v;
                  _handleVerify();
                },
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.t('otp_no_code')} ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap:
                        _secondsLeft == 0 && !_isLoading
                            ? () {
                              widget.onResend();
                              _startTimer();
                            }
                            : null,
                    child: Text(
                      _secondsLeft == 0
                          ? AppLocalizations.t('otp_resend_now')
                          : '${AppLocalizations.t('resend_prefix')} ${_secondsLeft}s',
                      style: TextStyle(
                        color:
                            _secondsLeft == 0
                                ? AppColors.primaryDark
                                : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppButton(
                label: AppLocalizations.t('verify_button'),
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleVerify,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}

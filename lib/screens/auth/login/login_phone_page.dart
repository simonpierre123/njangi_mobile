import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../Controllers_distant/AuthController.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

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
  final AuthController _authController = AuthController();
  String? _completeNumber;

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

  Future<void> _handleContinue() async {
    if (_completeNumber == null || _completeNumber!.isEmpty) return;

    final response = await _authController.sendOtp(_completeNumber!);

    if (!mounted) return;

    if (response['success'] == true) {
      widget.onContinue(_completeNumber!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['translated_message'] ??
                response['message'] ??
                AppLocalizations.t('UNKNOWN_ERROR'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                isLoading: _authController.isLoading,
                onPressed: _authController.isLoading ? null : _handleContinue,
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
                        recognizer:
                            TapGestureRecognizer()..onTap = widget.onRegister,
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

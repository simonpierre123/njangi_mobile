import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Écran de confirmation après création du code PIN. Avance
/// automatiquement vers l'écran de bienvenue après un court délai.
class PinCreatedPage extends StatefulWidget {
  const PinCreatedPage({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<PinCreatedPage> createState() => _PinCreatedPageState();
}

class _PinCreatedPageState extends State<PinCreatedPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 32),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('pin_created_title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('pin_created_subtitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
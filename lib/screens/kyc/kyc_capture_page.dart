import 'dart:io';
import 'package:flutter/material.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/media_picker.dart';
import 'widgets/kyc_tips_box.dart';

/// KYC — Étape 3/4 : capture photo du document. Illustration = asset
/// fourni par Njoya (assets/images/kyc3.png), remplacée par l'aperçu
/// réel une fois une photo choisie.
class KycCapturePage extends StatefulWidget {
  const KycCapturePage({
    super.key,
    required this.onBack,
    required this.onPhotoReady,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onPhotoReady;

  @override
  State<KycCapturePage> createState() => _KycCapturePageState();
}

class _KycCapturePageState extends State<KycCapturePage> {
  File? _photo;

  Future<void> _fromGallery() async {
    final file = await MediaPicker.pickFromGallery();
    if (file == null) return;
    setState(() => _photo = File(file.path));
    widget.onPhotoReady(file.path);
  }

  Future<void> _takePhoto() async {
    final file = await MediaPicker.pickFromCamera();
    if (file == null) return;
    setState(() => _photo = File(file.path));
    widget.onPhotoReady(file.path);
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: "${AppLocalizations.t('kyc_verification_title')} 3/4",
        onBack: widget.onBack,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc3_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc3_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                child: _photo != null
                    ? Image.file(_photo!, width: double.infinity, height: 240, fit: BoxFit.cover)
                    : Image.asset(
                        'assets/images/kyc3.png',
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 240,
                          color: AppColors.tagMintBg,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined, size: 32, color: AppColors.primaryDark),
                        ),
                      ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              KycTipsBox(
                tips: [
                  AppLocalizations.t('kyc_tip_lighting'),
                  AppLocalizations.t('kyc_tip_no_glare'),
                  AppLocalizations.t('kyc_tip_corners_visible'),
                ],
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppButton(
                label: AppLocalizations.t('kyc_choose_from_gallery'),
                icon: Icons.photo_library_outlined,
                iconLeading: true,
                variant: AppButtonVariant.secondary,
                onPressed: _fromGallery,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              AppButton(
                label: AppLocalizations.t('kyc_take_photo'),
                icon: Icons.camera_alt_outlined,
                iconLeading: true,
                onPressed: _takePhoto,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc_privacy_footer'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
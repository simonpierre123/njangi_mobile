import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../ModeView/kyc_model.dart';
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
    required this.documentType,
    required this.isBackSide,
    required this.onBack,
    required this.onPhotoReady,
  });

  final KycDocumentTypeId documentType;
  final bool isBackSide;
  final VoidCallback onBack;
  final Future<String?> Function(String path) onPhotoReady;

  @override
  State<KycCapturePage> createState() => _KycCapturePageState();
}

class _KycCapturePageState extends State<KycCapturePage> {
  File? _photo;
  bool _isProcessing = false;

  String get _illustrationPath {
    if (widget.documentType == KycDocumentTypeId.passport) {
      return 'assets/images/paskyc.png';
    }
    return widget.isBackSide
        ? 'assets/images/kyc4.png'
        : 'assets/images/kyc3.png';
  }

  String get _titleKey {
    if (widget.documentType == KycDocumentTypeId.passport) {
      return 'kyc_passport_capture_title';
    }
    return widget.isBackSide ? 'kyc_back_capture_title' : 'kyc3_title';
  }

  String get _descriptionKey {
    if (widget.documentType == KycDocumentTypeId.passport) {
      return 'kyc_passport_capture_desc';
    }
    return widget.isBackSide ? 'kyc_back_capture_desc' : 'kyc3_desc';
  }

  Future<void> _pickImage(Future<XFile?> Function() picker) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final file = await picker();
      if (file == null || !mounted) return;

      setState(() => _photo = File(file.path));
    } catch (error, stackTrace) {
      debugPrint('[KYC] Document capture failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.t('kyc_capture_error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _fromGallery() => _pickImage(MediaPicker.pickFromGallery);

  Future<void> _takePhoto() => _pickImage(MediaPicker.pickFromCamera);

  Future<void> _continueWithPhoto() async {
    final photo = _photo;
    if (photo == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final errorMessage = await widget.onPhotoReady(photo.path);
      if (errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (error, stackTrace) {
      debugPrint('[KYC] Document save failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.t('kyc_save_error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  int get _step => widget.isBackSide ? 4 : 3;

  String get _documentLabelKey {
    switch (widget.documentType) {
      case KycDocumentTypeId.nationalId:
        return 'kyc_doc_national_id';
      case KycDocumentTypeId.passport:
        return 'kyc_doc_passport';
      case KycDocumentTypeId.drivingLicense:
        return 'kyc_doc_license';
    }
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: "${AppLocalizations.t('kyc_verification_title')} $_step/4",
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
                  AppLocalizations.t(_titleKey),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  '${AppLocalizations.t(_documentLabelKey)} · ${AppLocalizations.t(_descriptionKey)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                child:
                    _photo != null
                        ? Image.file(
                          _photo!,
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          _illustrationPath,
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: 240,
                                color: AppColors.tagMintBg,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 32,
                                  color: AppColors.primaryDark,
                                ),
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
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _fromGallery,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              AppButton(
                label: AppLocalizations.t('kyc_take_photo'),
                icon: Icons.camera_alt_outlined,
                iconLeading: true,
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _takePhoto,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppButton(
                label: AppLocalizations.t('continue_button'),
                isLoading: _isProcessing,
                onPressed:
                    _photo == null || _isProcessing ? null : _continueWithPhoto,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc_privacy_footer'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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

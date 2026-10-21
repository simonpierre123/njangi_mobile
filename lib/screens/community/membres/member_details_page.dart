import 'package:flutter/material.dart';
import '../../../ModeView/community_members_model.dart';
import '../../../common/basewidget/network_avatar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_dimensions.dart';

class MemberDetailsPage extends StatelessWidget {
  const MemberDetailsPage({
    super.key,
    required this.name,
    required this.role,
    required this.details,
  });

  final String name;
  final String? role;
  final MemberPersonalDetails details;

  String? _mediaUrl(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http')) return value;
    return '${AppConstants.imageBaseUrl}${value.replaceFirst(RegExp(r'^/+'), '')}';
  }

  String _roleLabel(String? value) => switch (value?.toUpperCase()) {
    'ADMIN' => AppLocalizations.t('role_admin'),
    'CO_ADMIN' => AppLocalizations.t('role_co_admin'),
    'TRESORIER' => AppLocalizations.t('role_treasurer'),
    'SECRETARIAT' => AppLocalizations.t('role_secretary'),
    'MEMBRE' => AppLocalizations.t('role_member'),
    'INVITE' => AppLocalizations.t('role_invite'),
    _ => value ?? '',
  };

  @override
  Widget build(BuildContext context) {
    final documents =
        <({String label, String? path})>[
          (
            label: AppLocalizations.t('kyc_front_side_label'),
            path: details.cniFront,
          ),
          (
            label: AppLocalizations.t('kyc_back_side_label'),
            path: details.cniBack,
          ),
          (
            label: AppLocalizations.t('kyc_doc_passport'),
            path: details.passport,
          ),
          (
            label: AppLocalizations.t('kyc_doc_license'),
            path: details.drivingLicense,
          ),
        ].where((document) => _mediaUrl(document.path) != null).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.t('member_details_title')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceMd.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    NetworkAvatar(
                      radius: 42,
                      seed: name.hashCode.abs() % 70 + 1,
                      imageUrl: details.photoUrl,
                      fallbackBg: AppColors.neutralGrayLight,
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_roleLabel(role).isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spaceXs.h),
                      Text(
                        _roleLabel(role),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('personal_info_title'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              _info(AppLocalizations.t('full_name_label'), name),
              _info(AppLocalizations.t('phone_number_label'), details.phone),
              _info(AppLocalizations.t('email_address_label'), details.email),
              _info(AppLocalizations.t('gender_label'), details.gender),
              _info(AppLocalizations.t('address_label'), details.address),
              _info(AppLocalizations.t('city_label'), details.city),
              _info(AppLocalizations.t('country_label'), details.country),
              _info(
                AppLocalizations.t('member_since_label'),
                details.memberSince?.split('T').first,
              ),
              _info(AppLocalizations.t('member_status_label'), details.status),
              _info(AppLocalizations.t('member_id_label'), details.userId),
              if (documents.isNotEmpty) ...[
                SizedBox(height: AppDimensions.spaceLg.h),
                Text(
                  AppLocalizations.t('kyc_saved_documents_title'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                for (final document in documents)
                  _DocumentPreview(
                    label: document.label,
                    imageUrl: _mediaUrl(document.path)!,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String? rawValue) {
    final value = rawValue?.trim();
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          onTap: () => _showLargeImage(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spaceSm.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXs.h),
                SizedBox(
                  width: double.infinity,
                  height: 180.h,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Center(
                          child: Text(
                            AppLocalizations.t('kyc_document_image_error'),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppLocalizations.t('tap_to_enlarge'),
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLargeImage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 5,
                      child: Center(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Center(
                                child: Text(
                                  AppLocalizations.t(
                                    'kyc_document_image_error',
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      tooltip: AppLocalizations.t('close_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../Models/user_model.dart';
import '../../ModeView/profile_model.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/shimmer_loading.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_constants.dart';
import '../../utils/management/storage_manager.dart';
import 'widgets/avatar_with_badge.dart';
import 'widgets/profile_info_field.dart';
import 'widgets/profile_skeleton.dart';
import 'widgets/verified_badge.dart';

/// Écran "Mon Profil" — détail en lecture seule des informations
/// personnelles, avec accès à l'édition. Poussé par-dessus le shell
/// (Navigator.push) — pas de bottom nav ici, c'est une sous-page de
/// consultation, pas un onglet.
class MyProfilePage extends StatefulWidget {
  const MyProfilePage({
    super.key,
    required this.user,
    required this.onBack,
    required this.onEditInfo,
  });

  final UserProfile user;
  final VoidCallback onBack;
  final Future<void> Function() onEditInfo;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  UserModel? _storedUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageManager.getUser();
    if (!mounted) return;
    setState(() {
      _storedUser = user;
      _isLoading = false;
    });
  }

  String? _documentUrl(String? path) {
    final storedPath = path?.trim();
    if (storedPath == null || storedPath.isEmpty) return null;
    if (storedPath.startsWith('http')) return storedPath;
    return '${AppConstants.imageBaseUrl}${storedPath.replaceFirst(RegExp(r'^/+'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    final user =
        _storedUser == null
            ? widget.user
            : UserProfile.fromUserModel(_storedUser!);
    final passportUrl = _documentUrl(user.passport);
    final frontUrl = _documentUrl(user.cniRecto);
    final backUrl = _documentUrl(user.cniVerso);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('my_profile_title'),
        onBack: widget.onBack,
      ),
      body: SafeArea(
        top: false,
        child:
            _isLoading
                ? const ProfileSkeleton()
                : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingH.w,
                    vertical: AppDimensions.spaceSm.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            AvatarWithBadge(size: 90, imageUrl: user.photoUrl),
                            SizedBox(height: AppDimensions.spaceSm.h),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceXs.h),
                            if (user.isPhoneVerified)
                              VerifiedBadge(
                                label: AppLocalizations.t(
                                  'verified_number_badge',
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceLg.h),
                      Text(
                        AppLocalizations.t('personal_info_title'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      ProfileInfoField(
                        label: AppLocalizations.t('full_name_label'),
                        value: user.name,
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      ProfileInfoField(
                        label: AppLocalizations.t('phone_number_label'),
                        value: user.phone,
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      ProfileInfoField(
                        label: AppLocalizations.t('email_address_label'),
                        value: user.email,
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      ProfileInfoField(
                        label: AppLocalizations.t('gender_label'),
                        value: user.gender,
                      ),
                      if (passportUrl != null ||
                          frontUrl != null ||
                          backUrl != null) ...[
                        SizedBox(height: AppDimensions.spaceLg.h),
                        Text(
                          AppLocalizations.t('kyc_saved_documents_title'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceSm.h),
                        if (passportUrl != null)
                          _KycDocumentPreview(
                            label: AppLocalizations.t('kyc_doc_passport'),
                            imageUrl: passportUrl,
                          )
                        else if (frontUrl != null && backUrl != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _KycDocumentPreview(
                                  label: AppLocalizations.t(
                                    'kyc_front_side_label',
                                  ),
                                  imageUrl: frontUrl,
                                ),
                              ),
                              SizedBox(width: AppDimensions.spaceSm.w),
                              Expanded(
                                child: _KycDocumentPreview(
                                  label: AppLocalizations.t(
                                    'kyc_back_side_label',
                                  ),
                                  imageUrl: backUrl,
                                ),
                              ),
                            ],
                          )
                        else if (frontUrl != null || backUrl != null)
                          _KycDocumentPreview(
                            label: AppLocalizations.t(
                              frontUrl != null
                                  ? 'kyc_front_side_label'
                                  : 'kyc_back_side_label',
                            ),
                            imageUrl: frontUrl ?? backUrl!,
                          ),
                      ],
                      SizedBox(height: AppDimensions.spaceSm.h),
                      ProfileInfoField(
                        label: AppLocalizations.t('member_since_label'),
                        value: user.memberSinceLabel,
                        icon: Icons.calendar_today_outlined,
                      ),
                      SizedBox(height: AppDimensions.spaceLg.h),
                      AppButton(
                        label: AppLocalizations.t('edit_info_button'),
                        onPressed: () async {
                          await widget.onEditInfo();
                          await _loadUser();
                        },
                      ),
                      SizedBox(height: AppDimensions.spaceXl.h),
                    ],
                  ),
                ),
      ),
    );
  }
}

class _KycDocumentPreview extends StatelessWidget {
  const _KycDocumentPreview({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceSm.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceXs.h),
          AspectRatio(
            aspectRatio: 1.55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: ShimmerNetworkImage(
                url: imageUrl,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => ColoredBox(
                      color: AppColors.tagMintBg,
                      child: Center(
                        child: Text(
                          AppLocalizations.t('kyc_document_image_error'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

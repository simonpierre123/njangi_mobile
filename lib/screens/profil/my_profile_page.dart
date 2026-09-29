import 'package:flutter/material.dart';
import '../../Models/user_model.dart';
import '../../Models/profile_model.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/management/storage_manager.dart';
import 'widgets/avatar_with_badge.dart';
import 'widgets/profile_info_field.dart';
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

  @override
  Widget build(BuildContext context) {
    final user =
        _storedUser == null
            ? widget.user
            : UserProfile.fromUserModel(_storedUser!);

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
                ? const Center(child: CircularProgressIndicator())
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
                            const AvatarWithBadge(size: 90),
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

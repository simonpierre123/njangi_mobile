import 'dart:io';
import 'package:flutter/material.dart';
import '../../Controllers_distant/UserController.dart';
import '../../Models/user_model.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/app_text_field.dart';
import '../../common/basewidget/media_source_sheet.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/management/storage_manager.dart';
import 'widgets/avatar_with_badge.dart';
import 'widgets/phone_edit_row.dart';

/// Écran "Modifier mes informations" (écran 3) — formulaire d'édition
/// du profil. Le changement de photo est fonctionnel (caméra/galerie
/// réelles). Les données textuelles sont chargées depuis SharedPreferences
/// et enregistrées par l'API utilisateur, sans envoyer la photo.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.onChangeNumber,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onChangeNumber;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _gender;
  File? _photo;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageManager.getUser();
    if (!mounted) return;

    setState(() {
      _user = user;
      _firstNameController.text = user?.prenom ?? '';
      _lastNameController.text = user?.nom ?? '';
      _emailController.text = user?.email ?? '';
      final storedGender = user?.sexe?.trim().toUpperCase();
      _gender =
          storedGender == 'M' || storedGender == 'F' ? storedGender : null;
      _countryController.text = _localizedCountry(user?.pays);
      _cityController.text = user?.ville ?? '';
      _addressController.text = user?.adresse ?? '';
      _isLoading = false;
    });
  }

  String _localizedCountry(String? storedCountry) {
    final country = storedCountry?.trim() ?? '';
    final normalized = country.toLowerCase();
    if (country.isEmpty ||
        normalized == 'cm' ||
        normalized == 'cameroun' ||
        normalized == 'cameroon') {
      return AppLocalizations.t('country_cameroon');
    }
    return country;
  }

  Future<void> _changePhoto() async {
    final file = await showMediaSourceSheet(context);
    if (file == null) return;
    setState(() => _photo = File(file.path));
  }

  Future<void> _saveProfile() async {
    final user = _user;
    if (user == null || _isSaving) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      _showMessage(AppLocalizations.t('profile_name_required'));
      return;
    }
    if (_gender == null) {
      _showMessage(AppLocalizations.t('profile_gender_required'));
      return;
    }

    setState(() => _isSaving = true);
    final result = await UserController.updateProfile(
      userId: user.id,
      data: {
        'prenom': firstName,
        'nom': lastName,
        'email': _emailController.text.trim(),
        'sexe': _gender!,
        'pays': _countryController.text.trim(),
        'ville': _cityController.text.trim(),
        'adresse': _addressController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (result['success'] == true) {
      widget.onSave();
    } else {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('profile_update_error'),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return Scaffold(
        appBar: SimpleAppBar(
          title: AppLocalizations.t('edit_info_title'),
          onBack: widget.onCancel,
        ),
        body: Center(child: Text(AppLocalizations.t('profile_load_error'))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('edit_info_title'),
        onBack: widget.onCancel,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    AvatarWithBadge(
                      size: 90,
                      badgeIcon: Icons.camera_alt_outlined,
                      onBadgeTap: _changePhoto,
                      imageFile: _photo,
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    TextButton(
                      onPressed: _changePhoto,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.tagMintBg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXl,
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.t('change_photo_button'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppTextField(
                label: AppLocalizations.t('first_name_label'),
                hint: AppLocalizations.t('first_name_hint'),
                controller: _firstNameController,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppTextField(
                label: AppLocalizations.t('last_name_label'),
                hint: AppLocalizations.t('last_name_hint'),
                controller: _lastNameController,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppTextField(
                label: AppLocalizations.t('email_address_label'),
                hint: AppLocalizations.t('email_hint'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Text(
                AppLocalizations.t('gender_label'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXs.h),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'M',
                        groupValue: _gender,
                        title: const Text('M'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryDark,
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'F',
                        groupValue: _gender,
                        title: const Text('F'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryDark,
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppTextField(
                label: AppLocalizations.t('country_label'),
                hint: AppLocalizations.t('country_label'),
                controller: _countryController,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppTextField(
                label: AppLocalizations.t('city_label'),
                hint: AppLocalizations.t('city_label'),
                controller: _cityController,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppTextField(
                label: AppLocalizations.t('address_label'),
                hint: AppLocalizations.t('address_label'),
                controller: _addressController,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              PhoneEditRow(
                phone: _user!.telephone,
                onChangeTap: widget.onChangeNumber,
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppLocalizations.t('cancel_button'),
                      variant: AppButtonVariant.secondary,
                      onPressed: _isSaving ? null : widget.onCancel,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Expanded(
                    child: AppButton(
                      label: AppLocalizations.t('save_button'),
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _saveProfile,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}

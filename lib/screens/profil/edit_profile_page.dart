import 'dart:io';
import 'package:flutter/material.dart';
import '../../Models/profile_model.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/app_text_field.dart';
import '../../common/basewidget/labeled_date_field.dart';
import '../../common/basewidget/media_source_sheet.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/avatar_with_badge.dart';
import 'widgets/phone_edit_row.dart';

/// Écran "Modifier mes informations" (écran 3) — formulaire d'édition
/// du profil. Le changement de photo est fonctionnel (caméra/galerie
/// réelles) ; le reste du formulaire n'est pas encore persisté (pas
/// d'API branchée).
///
/// TODO (Njoya) : pas de validation de formulaire ni de sauvegarde
/// réelle pour l'instant — "Enregistrer" appelle [onSave] tel quel.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.user,
    required this.onCancel,
    required this.onSave,
    required this.onChangeNumber,
  });

  final UserProfile user;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onChangeNumber;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController = TextEditingController(text: widget.user.name);
  late final TextEditingController _emailController = TextEditingController(text: widget.user.email);
  DateTime? _birthdate;
  File? _photo;

  Future<void> _changePhoto() async {
    final file = await showMediaSourceSheet(context);
    if (file == null) return;
    setState(() => _photo = File(file.path));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('edit_info_title'), onBack: widget.onCancel),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
                      ),
                      child: Text(
                        AppLocalizations.t('change_photo_button'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              AppTextField(
                label: AppLocalizations.t('full_name_required_label'),
                hint: AppLocalizations.t('full_name_hint'),
                controller: _nameController,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              AppTextField(
                label: AppLocalizations.t('email_address_label'),
                hint: AppLocalizations.t('email_hint'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              LabeledDateField(
                label: AppLocalizations.t('birthdate_label'),
                value: _birthdate,
                onChanged: (d) => setState(() => _birthdate = d),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              PhoneEditRow(phone: widget.user.phone, onChangeTap: widget.onChangeNumber),
              SizedBox(height: AppDimensions.spaceLg.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppLocalizations.t('cancel_button'),
                      variant: AppButtonVariant.secondary,
                      onPressed: widget.onCancel,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Expanded(
                    child: AppButton(label: AppLocalizations.t('save_button'), onPressed: widget.onSave),
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
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../Controllers_distant/GroupeNjangiController.dart';
import '../../../Controllers_distant/MembreGroupeController.dart';
import '../../../Models/GroupeNjangi.dart';
import '../../../ModeView/create_community_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/community_photo_picker.dart';
import 'widgets/community_type_grid.dart';

/// Créer une communauté — Étape 1/5 : informations générales (photo,
/// nom, description, type).
class CreateCommunityStep1Page extends StatefulWidget {
  const CreateCommunityStep1Page({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onContinue,
  });

  final CommunityDraft draft;
  final VoidCallback onBack;
  final ValueChanged<CommunityDraft> onContinue;

  @override
  State<CreateCommunityStep1Page> createState() =>
      _CreateCommunityStep1PageState();
}

class _CreateCommunityStep1PageState extends State<CreateCommunityStep1Page> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.draft.name,
  );
  late final TextEditingController _descController = TextEditingController(
    text: widget.draft.description,
  );
  late CommunityType? _type = widget.draft.type;
  late String? _photoPath = widget.draft.photoPath;
  GroupeNjangi? _createdGroup;
  bool _creatorAdded = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_isLoading) return;

    final updatedDraft = widget.draft.copyWith(
      name: _nameController.text,
      description: _descController.text,
      type: _type,
      photoPath: _photoPath,
    );

    if (updatedDraft.name.trim().isEmpty) {
      _showError(AppLocalizations.t('community_name_required'));
      return;
    }
    if (updatedDraft.type == null) {
      _showError(AppLocalizations.t('community_type_required'));
      return;
    }

    if (_createdGroup == null) {
      setState(() => _isLoading = true);
      final result = await GroupeNjangiController.create(
        nom: updatedDraft.name.trim(),
        description: updatedDraft.description.trim(),
        type: updatedDraft.type!.apiValue,
        logo: _photoPath == null ? null : File(_photoPath!),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] != true) {
        _showError(
          result['message']?.toString() ??
              AppLocalizations.t('community_create_error'),
        );
        return;
      }

      _createdGroup = result['groupe'] as GroupeNjangi;
    }

    if (!_creatorAdded) {
      setState(() => _isLoading = true);
      final membership = await MembreGroupeController.addCurrentUser(
        groupeId: _createdGroup!.id,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (membership['success'] != true) {
        _showError(
          membership['message']?.toString() ??
              AppLocalizations.t('community_member_add_error'),
        );
        return;
      }

      _creatorAdded = true;
    }

    widget.onContinue(
      updatedDraft.copyWith(
        groupId: _createdGroup!.id,
        groupCode: _createdGroup!.codeGroupe,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH.w,
              ),
              child: StepHeader(step: 1, totalSteps: 5, onBack: widget.onBack),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(
                      AppLocalizations.t('create_community_title'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Text(
                      AppLocalizations.t('general_info_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('general_info_subtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    CommunityPhotoPicker(
                      onImagePicked:
                          (path) => setState(() => _photoPath = path),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    AppTextField(
                      label:
                          AppLocalizations.t(
                            'community_name_label',
                          ).toUpperCase(),
                      hint: AppLocalizations.t('community_name_hint'),
                      controller: _nameController,
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label:
                          AppLocalizations.t('description_label').toUpperCase(),
                      hint: AppLocalizations.t('description_hint'),
                      controller: _descController,
                      maxLines: 3,
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Text(
                      AppLocalizations.t('community_type_label').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    CommunityTypeGrid(
                      selected: _type,
                      onSelect: (t) => setState(() => _type = t),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH.w,
                AppDimensions.spaceSm.h,
                AppDimensions.screenPaddingH.w,
                AppDimensions.spaceMd.h,
              ),
              child: AppButton(
                label: AppLocalizations.t('continue_button'),
                icon: Icons.arrow_forward,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

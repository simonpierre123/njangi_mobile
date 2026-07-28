import 'package:flutter/material.dart';
import '../../../Models/create_community_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/number_stepper_field.dart';
import 'widgets/toggle_setting_row.dart';

/// Créer une communauté — Étape 3/5 : règles de fonctionnement (prêts,
/// pénalités, gouvernance).
class CreateCommunityStep3Page extends StatefulWidget {
  const CreateCommunityStep3Page({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onContinue,
  });

  final CommunityDraft draft;
  final VoidCallback onBack;
  final ValueChanged<CommunityDraft> onContinue;

  @override
  State<CreateCommunityStep3Page> createState() => _CreateCommunityStep3PageState();
}

class _CreateCommunityStep3PageState extends State<CreateCommunityStep3Page> {
  late final TextEditingController _maxAmountController =
      TextEditingController(text: widget.draft.maxLoanAmount);
  late final TextEditingController _maxDurationController =
      TextEditingController(text: widget.draft.maxLoanDurationMonths.isEmpty ? '6' : widget.draft.maxLoanDurationMonths);
  late final TextEditingController _maxSimultaneousController =
      TextEditingController(text: widget.draft.maxSimultaneousLoans.isEmpty ? '1' : widget.draft.maxSimultaneousLoans);

  late bool _allowLoans = widget.draft.allowLoans;
  late bool _adminValidation = widget.draft.adminValidationRequired;
  late bool _penalties = widget.draft.penaltiesEnabled;
  late int _maxAdmins = widget.draft.maxAdminCount;
  late bool _collectiveValidation = widget.draft.collectiveValidation;

  @override
  void dispose() {
    _maxAmountController.dispose();
    _maxDurationController.dispose();
    _maxSimultaneousController.dispose();
    super.dispose();
  }

  void _continue() {
    widget.onContinue(widget.draft.copyWith(
      allowLoans: _allowLoans,
      maxLoanAmount: _maxAmountController.text,
      maxLoanDurationMonths: _maxDurationController.text,
      maxSimultaneousLoans: _maxSimultaneousController.text,
      adminValidationRequired: _adminValidation,
      penaltiesEnabled: _penalties,
      maxAdminCount: _maxAdmins,
      collectiveValidation: _collectiveValidation,
    ));
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
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
              child: StepHeader(step: 3, totalSteps: 5, onBack: widget.onBack),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(AppLocalizations.t('rules_title'), style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('general_info_subtitle'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    ToggleSettingRow(
                      bordered: false,
                      leading: const CircledSettingIcon(icon: Icons.account_balance_outlined),
                      title: AppLocalizations.t('allow_loans_title'),
                      value: _allowLoans,
                      onChanged: (v) => setState(() => _allowLoans = v),
                    ),
                    if (_allowLoans) ...[
                      SizedBox(height: AppDimensions.spaceMd.h),
                      Container(
                        padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: AppLocalizations.t('max_loan_amount_label').toUpperCase(),
                              hint: '0',
                              controller: _maxAmountController,
                              keyboardType: TextInputType.number,
                              suffixText: 'FCFA',
                            ),
                            SizedBox(height: AppDimensions.spaceMd.h),
                            AppTextField(
                              label: AppLocalizations.t('max_loan_duration_label').toUpperCase(),
                              hint: '6',
                              controller: _maxDurationController,
                              keyboardType: TextInputType.number,
                              suffixText: AppLocalizations.t('duration_suffix_months'),
                            ),
                            SizedBox(height: AppDimensions.spaceMd.h),
                            AppTextField(
                              label: AppLocalizations.t('max_simultaneous_loans_label').toUpperCase(),
                              hint: '1',
                              controller: _maxSimultaneousController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: AppDimensions.spaceMd.h),
                            ToggleSettingRow(
                              bordered: false,
                              title: AppLocalizations.t('admin_validation_title'),
                              subtitle: AppLocalizations.t('admin_validation_subtitle'),
                              value: _adminValidation,
                              onChanged: (v) => setState(() => _adminValidation = v),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceMd.h),
                      ToggleSettingRow(
                        bordered: false,
                        leading: const Icon(Icons.gavel_outlined, size: 18, color: AppColors.textSecondary),
                        title: AppLocalizations.t('apply_penalties_title'),
                        subtitle: AppLocalizations.t('apply_penalties_subtitle'),
                        value: _penalties,
                        onChanged: (v) => setState(() => _penalties = v),
                      ),
                    ],
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Row(
                      children: [
                        const CircledSettingIcon(icon: Icons.admin_panel_settings_outlined, size: 24),
                        SizedBox(width: AppDimensions.spaceXs.w),
                        Text(
                          AppLocalizations.t('governance_section'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NumberStepperField(
                            label: AppLocalizations.t('max_admins_label').toUpperCase(),
                            value: _maxAdmins,
                            onChanged: (v) => setState(() => _maxAdmins = v),
                            min: 1,
                            max: 10,
                          ),
                          SizedBox(height: AppDimensions.spaceMd.h),
                          ToggleSettingRow(
                            bordered: false,
                            title: AppLocalizations.t('collective_validation_title'),
                            subtitle: AppLocalizations.t('collective_validation_subtitle'),
                            value: _collectiveValidation,
                            onChanged: (v) => setState(() => _collectiveValidation = v),
                          ),
                        ],
                      ),
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
              child: Column(
                children: [
                  AppButton(
                    label: AppLocalizations.t('continue_button'),
                    icon: Icons.arrow_forward,
                    onPressed: _continue,
                  ),
                  SizedBox(height: AppDimensions.spaceSm.h),
                  AppButton(
                    label: AppLocalizations.t('back_button'),
                    variant: AppButtonVariant.secondary,
                    onPressed: widget.onBack,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
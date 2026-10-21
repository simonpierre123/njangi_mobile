import 'package:flutter/material.dart';
import '../../../ModeView/create_community_model.dart';
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
  final Future<Map<String, dynamic>> Function(CommunityDraft) onContinue;

  @override
  State<CreateCommunityStep3Page> createState() =>
      _CreateCommunityStep3PageState();
}

class _CreateCommunityStep3PageState extends State<CreateCommunityStep3Page> {
  late final TextEditingController _maxAmountController = TextEditingController(
    text: widget.draft.maxLoanAmount,
  );
  late final TextEditingController _maxDurationController =
      TextEditingController(
        text:
            widget.draft.maxLoanDurationMonths.isEmpty
                ? '6'
                : widget.draft.maxLoanDurationMonths,
      );
  late final TextEditingController _maxSimultaneousController =
      TextEditingController(
        text:
            widget.draft.maxSimultaneousLoans.isEmpty
                ? '1'
                : widget.draft.maxSimultaneousLoans,
      );
  late final TextEditingController _savingsMinController =
      TextEditingController(text: widget.draft.savingsMinAmount);
  late final TextEditingController _savingsMaxController =
      TextEditingController(text: widget.draft.savingsMaxAmount);
  late final TextEditingController _savingsFixedController =
      TextEditingController(text: widget.draft.savingsFixedAmount);

  late bool _allowLoans = widget.draft.allowLoans;
  late bool _adminValidation = widget.draft.adminValidationRequired;
  late bool _penalties = widget.draft.penaltiesEnabled;
  late int _maxAdmins = widget.draft.maxAdminCount;
  late bool _collectiveValidation = widget.draft.collectiveValidation;
  late bool _savingsActive = widget.draft.savingsActive;
  late String _savingsMode = widget.draft.savingsMode ?? 'LIBRE';
  late String _savingsCalendarMode = widget.draft.savingsCalendarMode;
  late bool _emergencyFundActive = widget.draft.emergencyFundActive;
  late bool _emergencyIncludeBeneficiary =
      widget.draft.emergencyIncludeBeneficiary;
  late bool _tontineActive = widget.draft.tontineActive;
  late bool _tontineNextVisible = widget.draft.tontineNextVisible;
  late String? _cycleId = widget.draft.cycleId;
  bool _isSaving = false;

  @override
  void dispose() {
    _maxAmountController.dispose();
    _maxDurationController.dispose();
    _maxSimultaneousController.dispose();
    _savingsMinController.dispose();
    _savingsMaxController.dispose();
    _savingsFixedController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_isSaving) return;

    final updatedDraft = widget.draft.copyWith(
      allowLoans: _allowLoans,
      maxLoanAmount: _maxAmountController.text,
      maxLoanDurationMonths: _maxDurationController.text,
      maxSimultaneousLoans: _maxSimultaneousController.text,
      adminValidationRequired: _adminValidation,
      penaltiesEnabled: _penalties,
      maxAdminCount: _maxAdmins,
      collectiveValidation: _collectiveValidation,
      savingsActive: _savingsActive,
      savingsMode: _savingsMode,
      savingsFixedAmount: _savingsFixedController.text,
      savingsMinAmount: _savingsMinController.text,
      savingsMaxAmount: _savingsMaxController.text,
      savingsCalendarMode: _savingsCalendarMode,
      emergencyFundActive: _emergencyFundActive,
      emergencyIncludeBeneficiary: _emergencyIncludeBeneficiary,
      tontineActive: _tontineActive,
      tontineNextVisible: _tontineNextVisible,
      cycleId: _cycleId,
    );

    setState(() => _isSaving = true);
    Map<String, dynamic> result;
    try {
      result = await widget.onContinue(updatedDraft);
    } catch (error) {
      debugPrint('[COMMUNITY] Cycle creation callback failed: $error');
      result = {
        'success': false,
        'message': AppLocalizations.t('cycle_create_error'),
      };
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    final cycleId = result['cycleId']?.toString();
    if (cycleId != null && cycleId.isNotEmpty) {
      setState(() => _cycleId = cycleId);
    }

    if (result['success'] == true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              AppLocalizations.t('cycle_create_error'),
        ),
        backgroundColor: Colors.red,
      ),
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
              child: StepHeader(step: 3, totalSteps: 5, onBack: widget.onBack),
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
                      AppLocalizations.t('rules_title'),
                      style: Theme.of(context).textTheme.headlineMedium,
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
                    ToggleSettingRow(
                      bordered: false,
                      leading: const CircledSettingIcon(
                        icon: Icons.account_balance_outlined,
                      ),
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
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label:
                                  AppLocalizations.t(
                                    'max_loan_amount_label',
                                  ).toUpperCase(),
                              hint: '0',
                              controller: _maxAmountController,
                              keyboardType: TextInputType.number,
                              suffixText: 'FCFA',
                            ),
                            SizedBox(height: AppDimensions.spaceMd.h),
                            AppTextField(
                              label:
                                  AppLocalizations.t(
                                    'max_loan_duration_label',
                                  ).toUpperCase(),
                              hint: '6',
                              controller: _maxDurationController,
                              keyboardType: TextInputType.number,
                              suffixText: AppLocalizations.t(
                                'duration_suffix_months',
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceMd.h),
                            AppTextField(
                              label:
                                  AppLocalizations.t(
                                    'max_simultaneous_loans_label',
                                  ).toUpperCase(),
                              hint: '1',
                              controller: _maxSimultaneousController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: AppDimensions.spaceMd.h),
                            ToggleSettingRow(
                              bordered: false,
                              title: AppLocalizations.t(
                                'admin_validation_title',
                              ),
                              subtitle: AppLocalizations.t(
                                'admin_validation_subtitle',
                              ),
                              value: _adminValidation,
                              onChanged:
                                  (v) => setState(() => _adminValidation = v),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceMd.h),
                      ToggleSettingRow(
                        bordered: false,
                        leading: const Icon(
                          Icons.gavel_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        title: AppLocalizations.t('apply_penalties_title'),
                        subtitle: AppLocalizations.t(
                          'apply_penalties_subtitle',
                        ),
                        value: _penalties,
                        onChanged: (v) => setState(() => _penalties = v),
                      ),
                    ],
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Text(
                      AppLocalizations.t('cycle_modules_section'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ToggleSettingRow(
                            bordered: false,
                            leading: const CircledSettingIcon(
                              icon: Icons.savings_outlined,
                            ),
                            title: AppLocalizations.t('savings_active_title'),
                            value: _savingsActive,
                            onChanged:
                                (value) =>
                                    setState(() => _savingsActive = value),
                          ),
                          if (_savingsActive) ...[
                            SizedBox(height: AppDimensions.spaceSm.h),
                            SegmentedButton<String>(
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: 'LIBRE',
                                  label: Text(
                                    AppLocalizations.t('savings_mode_free'),
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'FIXE',
                                  label: Text(
                                    AppLocalizations.t('savings_mode_fixed'),
                                  ),
                                ),
                              ],
                              selected: {_savingsMode},
                              onSelectionChanged:
                                  (values) => setState(
                                    () => _savingsMode = values.first,
                                  ),
                            ),
                            SizedBox(height: AppDimensions.spaceSm.h),
                            if (_savingsMode == 'FIXE')
                              AppTextField(
                                label: AppLocalizations.t(
                                  'savings_fixed_amount_label',
                                ),
                                hint: '10000',
                                controller: _savingsFixedController,
                                keyboardType: TextInputType.number,
                              )
                            else ...[
                              AppTextField(
                                label: AppLocalizations.t(
                                  'savings_min_amount_label',
                                ),
                                hint: '1000',
                                controller: _savingsMinController,
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: AppDimensions.spaceSm.h),
                              AppTextField(
                                label: AppLocalizations.t(
                                  'savings_max_amount_label',
                                ),
                                hint: '50000',
                                controller: _savingsMaxController,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                            SizedBox(height: AppDimensions.spaceSm.h),
                            DropdownButtonFormField<String>(
                              value: _savingsCalendarMode,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.t(
                                  'savings_calendar_label',
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'MEME_QUE_TONTINE',
                                  child: Text(
                                    AppLocalizations.t('savings_calendar_same'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'INDEPENDANT',
                                  child: Text(
                                    AppLocalizations.t(
                                      'savings_calendar_independent',
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _savingsCalendarMode = value);
                                }
                              },
                            ),
                          ],
                          SizedBox(height: AppDimensions.spaceMd.h),
                          ToggleSettingRow(
                            bordered: false,
                            leading: const Icon(
                              Icons.health_and_safety_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            title: AppLocalizations.t(
                              'emergency_fund_active_title',
                            ),
                            value: _emergencyFundActive,
                            onChanged:
                                (value) => setState(
                                  () => _emergencyFundActive = value,
                                ),
                          ),
                          if (_emergencyFundActive) ...[
                            SizedBox(height: AppDimensions.spaceSm.h),
                            ToggleSettingRow(
                              bordered: false,
                              title: AppLocalizations.t(
                                'emergency_include_beneficiary_title',
                              ),
                              value: _emergencyIncludeBeneficiary,
                              onChanged:
                                  (value) => setState(
                                    () => _emergencyIncludeBeneficiary = value,
                                  ),
                            ),
                          ],
                          SizedBox(height: AppDimensions.spaceMd.h),
                          ToggleSettingRow(
                            bordered: false,
                            leading: const Icon(
                              Icons.autorenew,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            title: AppLocalizations.t('tontine_active_title'),
                            value: _tontineActive,
                            onChanged:
                                (value) =>
                                    setState(() => _tontineActive = value),
                          ),
                          if (_tontineActive) ...[
                            SizedBox(height: AppDimensions.spaceSm.h),
                            ToggleSettingRow(
                              bordered: false,
                              title: AppLocalizations.t(
                                'tontine_next_visible_title',
                              ),
                              value: _tontineNextVisible,
                              onChanged:
                                  (value) => setState(
                                    () => _tontineNextVisible = value,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Row(
                      children: [
                        const CircledSettingIcon(
                          icon: Icons.admin_panel_settings_outlined,
                          size: 24,
                        ),
                        SizedBox(width: AppDimensions.spaceXs.w),
                        Text(
                          AppLocalizations.t('governance_section'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NumberStepperField(
                            label:
                                AppLocalizations.t(
                                  'max_admins_label',
                                ).toUpperCase(),
                            value: _maxAdmins,
                            onChanged: (v) => setState(() => _maxAdmins = v),
                            min: 1,
                            max: 10,
                          ),
                          SizedBox(height: AppDimensions.spaceMd.h),
                          ToggleSettingRow(
                            bordered: false,
                            title: AppLocalizations.t(
                              'collective_validation_title',
                            ),
                            subtitle: AppLocalizations.t(
                              'collective_validation_subtitle',
                            ),
                            value: _collectiveValidation,
                            onChanged:
                                (v) =>
                                    setState(() => _collectiveValidation = v),
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
                    isLoading: _isSaving,
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

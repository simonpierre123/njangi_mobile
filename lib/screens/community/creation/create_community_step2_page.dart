import 'package:flutter/material.dart';
import '../../../Models/create_community_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/labeled_date_field.dart';
import '../../../common/basewidget/labeled_dropdown_field.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/frequency_option_grid.dart';
import 'widgets/trust_security_banner.dart';

/// Créer une communauté — Étape 2/5 : configuration financière
/// (cotisation, fréquence, cycle).
class CreateCommunityStep2Page extends StatefulWidget {
  const CreateCommunityStep2Page({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onContinue,
  });

  final CommunityDraft draft;
  final VoidCallback onBack;
  final ValueChanged<CommunityDraft> onContinue;

  @override
  State<CreateCommunityStep2Page> createState() => _CreateCommunityStep2PageState();
}

class _CreateCommunityStep2PageState extends State<CreateCommunityStep2Page> {
  late final TextEditingController _amountController =
      TextEditingController(text: widget.draft.contributionAmount);
  late final TextEditingController _membersController =
      TextEditingController(text: widget.draft.expectedMemberCount);
  late ContributionFrequency? _frequency = widget.draft.frequency;
  late DateTime? _startDate = widget.draft.startDate;
  late String _dueDay = widget.draft.dueDayLabel ?? AppLocalizations.t('due_day_monday');

  List<String> get _weekdayOptions => [
        AppLocalizations.t('due_day_monday'),
        AppLocalizations.t('due_day_tuesday'),
        AppLocalizations.t('due_day_wednesday'),
        AppLocalizations.t('due_day_thursday'),
        AppLocalizations.t('due_day_friday'),
        AppLocalizations.t('due_day_saturday'),
        AppLocalizations.t('due_day_sunday'),
      ];

  @override
  void dispose() {
    _amountController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  void _continue() {
    widget.onContinue(widget.draft.copyWith(
      contributionAmount: _amountController.text,
      frequency: _frequency,
      startDate: _startDate,
      dueDayLabel: _dueDay,
      expectedMemberCount: _membersController.text,
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
              child: StepHeader(step: 2, totalSteps: 5, onBack: widget.onBack),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(
                      AppLocalizations.t('financial_config_title'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('financial_config_subtitle'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(color: AppColors.mintPale, shape: BoxShape.circle),
                          child: const Icon(Icons.payments_outlined, size: 15, color: AppColors.primaryDeepest),
                        ),
                        SizedBox(width: AppDimensions.spaceXs.w),
                        Text(
                          AppLocalizations.t('contribution_section'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label: AppLocalizations.t('contribution_amount_label').toUpperCase(),
                      hint: '0',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      suffixText: 'FCFA',
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Text(
                      AppLocalizations.t('frequency_label').toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    FrequencyOptionGrid(selected: _frequency, onSelect: (f) => setState(() => _frequency = f)),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(color: AppColors.mintPale, shape: BoxShape.circle),
                          child: const Icon(Icons.event_repeat, size: 15, color: AppColors.primaryDeepest),
                        ),
                        SizedBox(width: AppDimensions.spaceXs.w),
                        Text(
                          AppLocalizations.t('cycle_section'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    LabeledDateField(
                      label: AppLocalizations.t('start_date_label').toUpperCase(),
                      value: _startDate,
                      onChanged: (d) => setState(() => _startDate = d),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    LabeledDropdownField(
                      label: AppLocalizations.t('due_day_label').toUpperCase(),
                      value: _dueDay,
                      options: _weekdayOptions,
                      onChanged: (v) => setState(() => _dueDay = v),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('due_day_helper'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label: AppLocalizations.t('expected_members_label').toUpperCase(),
                      hint: AppLocalizations.t('expected_members_hint'),
                      controller: _membersController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('expected_members_helper'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    const TrustSecurityBanner(),
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
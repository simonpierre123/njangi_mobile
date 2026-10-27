import 'package:flutter/material.dart';
import '../../../ModeView/create_community_model.dart';
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
  State<CreateCommunityStep2Page> createState() =>
      _CreateCommunityStep2PageState();
}

class _CreateCommunityStep2PageState extends State<CreateCommunityStep2Page> {
  late final TextEditingController _amountController = TextEditingController(
    text: widget.draft.contributionAmount,
  );
  late final TextEditingController _membersController = TextEditingController(
    text: widget.draft.expectedMemberCount,
  );
  late ContributionFrequency? _frequency = widget.draft.frequency;
  late DateTime? _startDate = widget.draft.startDate;
  late String _dueDay =
      _weekdayOptions.contains(widget.draft.dueDayLabel)
          ? widget.draft.dueDayLabel!
          : _weekdayOptions[widget.draft.tontineWeekday.clamp(1, 7).toInt() -
              1];
  late String _tontineCalendarMode = widget.draft.tontineCalendarMode;
  late int _tontineWeekOrdinal = widget.draft.tontineWeekOrdinal;
  late int _tontineWeekday = _weekdayOptions.indexOf(_dueDay) + 1;

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
    final validationMessage =
        _frequency == null
            ? AppLocalizations.t('cycle_frequency_required')
            : _startDate == null
            ? AppLocalizations.t('cycle_start_date_required')
            : _frequency == ContributionFrequency.personnalisee &&
                (int.tryParse(_membersController.text.trim()) ?? 0) < 1
            ? AppLocalizations.t('cycle_custom_member_count_required')
            : _frequency == ContributionFrequency.mensuelle &&
                _tontineCalendarMode == 'NIEME_JOUR_SEMAINE'
            ? (_startDateMatchesMonthlyRule()
                ? null
                : AppLocalizations.t('tontine_start_date_rule_mismatch'))
            : _usesWeekdaySchedule && !_startDateMatchesWeekday()
            ? AppLocalizations.t('tontine_start_date_rule_mismatch')
            : null;
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }
    widget.onContinue(
      widget.draft.copyWith(
        contributionAmount: _amountController.text,
        frequency: _frequency,
        startDate: _startDate,
        dueDayLabel: _usesWeekdaySchedule ? _dueDay : null,
        tontineCalendarMode: _tontineCalendarMode,
        tontineWeekOrdinal: _tontineWeekOrdinal,
        tontineWeekday: _tontineWeekday,
        expectedMemberCount: _membersController.text,
      ),
    );
  }

  bool _startDateMatchesMonthlyRule() {
    final date = _startDate;
    if (date == null || date.weekday != _tontineWeekday) return false;
    return ((date.day - 1) ~/ 7) + 1 == _tontineWeekOrdinal;
  }

  bool get _usesWeekdaySchedule =>
      _frequency == ContributionFrequency.hebdomadaire ||
      _frequency == ContributionFrequency.bimensuelle ||
      (_frequency == ContributionFrequency.mensuelle &&
          _tontineCalendarMode == 'NIEME_JOUR_SEMAINE');

  bool _startDateMatchesWeekday() => _startDate?.weekday == _tontineWeekday;

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
              child: StepHeader(step: 2, totalSteps: 5, onBack: widget.onBack),
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
                      AppLocalizations.t('financial_config_title'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('financial_config_subtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.mintPale,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            size: 15,
                            color: AppColors.primaryDeepest,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spaceXs.w),
                        Text(
                          AppLocalizations.t('contribution_section'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label:
                          AppLocalizations.t(
                            'contribution_amount_label',
                          ).toUpperCase(),
                      hint: '0',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      suffixText: 'FCFA',
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Text(
                      AppLocalizations.t('frequency_label').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    FrequencyOptionGrid(
                      selected: _frequency,
                      onSelect:
                          (f) => setState(() {
                            _frequency = f;
                            if (f != ContributionFrequency.mensuelle) {
                              _tontineCalendarMode = 'DATE_MOIS';
                            }
                          }),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.mintPale,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_repeat,
                            size: 15,
                            color: AppColors.primaryDeepest,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spaceXs.w),
                        Text(
                          AppLocalizations.t('cycle_section'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    LabeledDateField(
                      label:
                          AppLocalizations.t('start_date_label').toUpperCase(),
                      value: _startDate,
                      onChanged: (d) => setState(() => _startDate = d),
                    ),
                    if (_frequency == ContributionFrequency.hebdomadaire ||
                        _frequency == ContributionFrequency.bimensuelle) ...[
                      SizedBox(height: AppDimensions.spaceMd.h),
                      LabeledDropdownField(
                        label:
                            AppLocalizations.t('due_day_label').toUpperCase(),
                        value: _dueDay,
                        options: _weekdayOptions,
                        onChanged: (value) {
                          setState(() {
                            _dueDay = value;
                            _tontineWeekday =
                                _weekdayOptions.indexOf(value) + 1;
                          });
                        },
                      ),
                    ],
                    if (_frequency == ContributionFrequency.mensuelle) ...[
                      SizedBox(height: AppDimensions.spaceMd.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _tontineCalendarMode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.t(
                            'tontine_calendar_rule_label',
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'DATE_MOIS',
                            child: Text(
                              AppLocalizations.t('tontine_calendar_fixed_date'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'NIEME_JOUR_SEMAINE',
                            child: Text(
                              AppLocalizations.t(
                                'tontine_calendar_nth_weekday',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _tontineCalendarMode = value);
                          }
                        },
                      ),
                      if (_tontineCalendarMode == 'NIEME_JOUR_SEMAINE') ...[
                        SizedBox(height: AppDimensions.spaceSm.h),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: _tontineWeekOrdinal,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.t(
                              'tontine_week_ordinal_label',
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            for (var ordinal = 1; ordinal <= 4; ordinal++)
                              DropdownMenuItem(
                                value: ordinal,
                                child: Text(
                                  AppLocalizations.t(
                                    'tontine_week_ordinal_$ordinal',
                                  ),
                                ),
                              ),
                          ],
                          onChanged:
                              (value) => setState(
                                () => _tontineWeekOrdinal = value ?? 1,
                              ),
                        ),
                        SizedBox(height: AppDimensions.spaceSm.h),
                        LabeledDropdownField(
                          label:
                              AppLocalizations.t('due_day_label').toUpperCase(),
                          value: _dueDay,
                          options: _weekdayOptions,
                          onChanged: (value) {
                            setState(() {
                              _dueDay = value;
                              _tontineWeekday =
                                  _weekdayOptions.indexOf(value) + 1;
                            });
                          },
                        ),
                        SizedBox(height: AppDimensions.spaceXs.h),
                        Text(
                          AppLocalizations.t(
                            _startDateMatchesMonthlyRule()
                                ? 'tontine_contribution_window_helper'
                                : 'tontine_start_date_rule_mismatch',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                _startDateMatchesMonthlyRule()
                                    ? AppColors.textSecondary
                                    : AppColors.error,
                          ),
                        ),
                      ],
                    ],
                    SizedBox(height: AppDimensions.spaceXs.h),
                    if (_usesWeekdaySchedule)
                      Text(
                        AppLocalizations.t('due_day_helper'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label:
                          AppLocalizations.t(
                            _frequency == ContributionFrequency.personnalisee
                                ? 'expected_members_required_label'
                                : 'expected_members_label',
                          ).toUpperCase(),
                      hint: AppLocalizations.t('expected_members_hint'),
                      controller: _membersController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t(
                        _frequency == ContributionFrequency.personnalisee
                            ? 'expected_members_custom_helper'
                            : 'expected_members_helper',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
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

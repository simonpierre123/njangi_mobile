import 'package:flutter/material.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleRulesController.dart';
import '../../../Models/Cycle.dart';
import '../../../ModeView/create_community_model.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/labeled_date_field.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../creation/widgets/frequency_option_grid.dart';
import '../creation/widgets/number_stepper_field.dart';
import '../creation/widgets/trust_security_banner.dart';
import '../creation/widgets/toggle_setting_row.dart';

class CycleRulesRouteArgs {
  const CycleRulesRouteArgs({
    this.community,
    this.cycleId,
    this.proposalId,
    this.isAdmin,
  });

  final CommunityModel? community;
  final String? cycleId;
  final String? proposalId;
  final bool? isAdmin;
}

class CycleRulesPage extends StatefulWidget {
  const CycleRulesPage({super.key, required this.args});

  final CycleRulesRouteArgs args;

  @override
  State<CycleRulesPage> createState() => _CycleRulesPageState();
}

class _CycleRulesPageState extends State<CycleRulesPage> {
  static const _textFields = [
    'montant_cotisation',
    'devise',
    'montant_max_pret',
    'duree_max_pret',
    'nombre_max_pret_simultane',
    'epargne_montant_fixe',
    'epargne_montant_min',
    'epargne_montant_max',
  ];

  final Map<String, TextEditingController> _controllers = {
    for (final field in _textFields) field: TextEditingController(),
  };
  final TextEditingController _expectedMembersController =
      TextEditingController();
  final TextEditingController _savingsDueDayController =
      TextEditingController();
  final Map<String, bool> _toggles = {};

  Cycle? _cycle;
  Map<String, dynamic>? _proposal;
  String? _cycleId;
  String? _loadError;
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isBusy = false;
  ContributionFrequency? _frequency;
  String _savingsMode = 'LIBRE';
  String? _savingsCalendarMode;
  String? _savingsFrequency;
  String _tontineCalendarMode = 'DATE_MOIS';
  int _tontineWeekOrdinal = 2;
  int _tontineWeekday = 7;
  int _maxAdmins = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _savingsDueDay;

  @override
  void initState() {
    super.initState();
    _cycleId = widget.args.cycleId;
    _load();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _expectedMembersController.dispose();
    _savingsDueDayController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    var cycleId = _cycleId;
    if ((cycleId == null || cycleId.isEmpty) && widget.args.community != null) {
      final cycles = await CycleController.getForGroup(
        widget.args.community!.id,
      );
      if (cycles != null && cycles.isNotEmpty) {
        cycleId = _selectCycle(cycles)?.id;
      }
    }

    if (cycleId == null || cycleId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = AppLocalizations.t('cycle_rules_load_error');
      });
      return;
    }

    final result = await CycleRulesController.getRules(cycleId);
    if (!mounted) return;
    if (result['success'] != true || result['cycle'] is! Cycle) {
      setState(() {
        _isLoading = false;
        _loadError =
            result['message']?.toString() ??
            AppLocalizations.t('cycle_rules_load_error');
      });
      return;
    }

    final cycle = result['cycle'] as Cycle;
    _cycleId = cycleId;
    _cycle = cycle;
    _proposal = result['proposal'] as Map<String, dynamic>?;
    _isAdmin = widget.args.isAdmin ?? result['isAdmin'] == true;
    _populateForm(cycle);
    setState(() => _isLoading = false);
  }

  Cycle? _selectCycle(List<Cycle> cycles) {
    for (final cycle in cycles) {
      if (cycle.status == 'EN_COURS') return cycle;
    }
    for (final cycle in cycles) {
      if (cycle.status == 'EN_ATTENTE') return cycle;
    }
    return cycles.isEmpty ? null : cycles.first;
  }

  void _populateForm(Cycle cycle) {
    final values = {
      'montant_cotisation': cycle.contributionAmount,
      'devise': cycle.currency,
      'montant_max_pret': cycle.maxLoanAmount,
      'duree_max_pret': cycle.maxLoanDuration,
      'nombre_max_pret_simultane': cycle.maxSimultaneousLoans,
      'epargne_montant_fixe': cycle.savingsFixedAmount,
      'epargne_montant_min': cycle.savingsMinAmount,
      'epargne_montant_max': cycle.savingsMaxAmount,
    };
    for (final entry in values.entries) {
      _controllers[entry.key]!.text = entry.value?.toString() ?? '';
    }

    _toggles
      ..['module_pret_actif'] = cycle.loanModuleActive == '1'
      ..['validation_pret_colectif'] = cycle.collectiveLoanValidation == '1'
      ..['appliquer_penalites'] = cycle.penaltiesEnabled == '1'
      ..['epargne_active'] = cycle.savingsActive
      ..['caisse_secours_active'] = cycle.emergencyFundActive
      ..['secours_inclure_beneficiaire'] = cycle.emergencyIncludeBeneficiary
      ..['tontine_active'] = cycle.tontineActive
      ..['tontine_prochain_visible'] = cycle.tontineNextVisible;
    _expectedMembersController.text = cycle.memberCount?.toString() ?? '';
    _maxAdmins = (cycle.adminCount ?? 1).clamp(1, 10).toInt();
    _frequency = _frequencyFromApi(cycle.frequency);
    _savingsMode = cycle.savingsMode ?? 'LIBRE';
    _savingsCalendarMode = cycle.savingsCalendarMode;
    _savingsFrequency = cycle.savingsFrequency;
    _tontineCalendarMode = cycle.tontineCalendarMode;
    _tontineWeekOrdinal = cycle.tontineWeekOrdinal ?? 2;
    _tontineWeekday =
        cycle.tontineWeekday ?? _weekdayFromLabel(cycle.dueDay) ?? 7;
    _startDate = cycle.startDate;
    _endDate = cycle.endDate;
    _savingsDueDay = cycle.savingsDueDay;
    _savingsDueDayController.text = cycle.savingsDueDay ?? '';
  }

  ContributionFrequency? _frequencyFromApi(String? value) => switch (value) {
    'HEBDO' => ContributionFrequency.hebdomadaire,
    'BIHEBDO' => ContributionFrequency.bimensuelle,
    'MENSUEL' => ContributionFrequency.mensuelle,
    'AUTRE' => ContributionFrequency.personnalisee,
    _ => null,
  };

  String? _frequencyToApi(ContributionFrequency? value) => switch (value) {
    ContributionFrequency.hebdomadaire => 'HEBDO',
    ContributionFrequency.bimensuelle => 'BIHEBDO',
    ContributionFrequency.mensuelle => 'MENSUEL',
    ContributionFrequency.personnalisee => 'AUTRE',
    null => null,
  };

  List<String> get _weekdayOptions => [
    AppLocalizations.t('due_day_monday'),
    AppLocalizations.t('due_day_tuesday'),
    AppLocalizations.t('due_day_wednesday'),
    AppLocalizations.t('due_day_thursday'),
    AppLocalizations.t('due_day_friday'),
    AppLocalizations.t('due_day_saturday'),
    AppLocalizations.t('due_day_sunday'),
  ];

  int? _weekdayFromLabel(String? label) {
    if (label == null) return null;
    final index = _weekdayOptions.indexOf(label);
    return index < 0 ? null : index + 1;
  }

  bool get _usesWeekdaySchedule =>
      _frequency == ContributionFrequency.hebdomadaire ||
      _frequency == ContributionFrequency.bimensuelle ||
      (_frequency == ContributionFrequency.mensuelle &&
          _tontineCalendarMode == 'NIEME_JOUR_SEMAINE');

  bool _startDateMatchesSchedule() {
    final date = _startDate;
    if (date == null || date.weekday != _tontineWeekday) return false;
    return _frequency != ContributionFrequency.mensuelle ||
        _tontineCalendarMode != 'NIEME_JOUR_SEMAINE' ||
        ((date.day - 1) ~/ 7) + 1 == _tontineWeekOrdinal;
  }

  String? _editValidationMessage() {
    if (_toggles['tontine_active'] == true) {
      final amount = int.tryParse(_controllers['montant_cotisation']!.text);
      if (amount == null || amount <= 0) {
        return AppLocalizations.t('cycle_amount_required');
      }
      if (_frequency == null) {
        return AppLocalizations.t('cycle_frequency_required');
      }
      if (_startDate == null) {
        return AppLocalizations.t('cycle_start_date_required');
      }
      if (_frequency == ContributionFrequency.personnalisee &&
          (int.tryParse(_expectedMembersController.text.trim()) ?? 0) < 1) {
        return AppLocalizations.t('cycle_custom_member_count_required');
      }
      if (_usesWeekdaySchedule && !_startDateMatchesSchedule()) {
        return AppLocalizations.t('tontine_start_date_rule_mismatch');
      }
    }
    if (_toggles['epargne_active'] == true &&
        _savingsMode == 'FIXE' &&
        (int.tryParse(_controllers['epargne_montant_fixe']!.text) ?? 0) <= 0) {
      return AppLocalizations.t('cycle_amount_required');
    }
    return null;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  String _formatDate(DateTime? date) =>
      date == null
          ? AppLocalizations.t('not_configured')
          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _frequencyLabel(String? value) => switch (value) {
    'HEBDO' => AppLocalizations.t('freq_weekly_title'),
    'BIHEBDO' => AppLocalizations.t('freq_biweekly_title'),
    'MENSUEL' => AppLocalizations.t('freq_monthly_title'),
    'AUTRE' => AppLocalizations.t('freq_custom_title'),
    _ => AppLocalizations.t('not_configured'),
  };

  String _booleanLabel(bool value) =>
      AppLocalizations.t(value ? 'cycle_rule_enabled' : 'cycle_rule_disabled');

  List<MapEntry<String, String>> _ruleValues(Cycle cycle) => [
    MapEntry('nombre_membres', cycle.memberCount?.toString() ?? '—'),
    MapEntry('nombre_admin', cycle.adminCount?.toString() ?? '—'),
    MapEntry(
      'montant_cotisation',
      '${cycle.contributionAmount?.toString() ?? '—'} ${cycle.currency ?? ''}',
    ),
    MapEntry('frequence_cycle', _frequencyLabel(cycle.frequency)),
    MapEntry('jour_echeance', cycle.dueDay ?? '—'),
    MapEntry(
      'tontine_calendrier_mode',
      cycle.tontineCalendarMode == 'NIEME_JOUR_SEMAINE'
          ? '${AppLocalizations.t('tontine_week_ordinal_${cycle.tontineWeekOrdinal ?? 2}')} '
              '${AppLocalizations.t('weekday_name_${cycle.tontineWeekday ?? 7}')}'
          : AppLocalizations.t('tontine_calendar_fixed_date'),
    ),
    MapEntry('date_debut', _formatDate(cycle.startDate)),
    MapEntry('date_fin', _formatDate(cycle.endDate)),
    MapEntry('module_pret_actif', _booleanLabel(cycle.loanModuleActive == '1')),
    MapEntry(
      'validation_pret_colectif',
      _booleanLabel(cycle.collectiveLoanValidation == '1'),
    ),
    MapEntry('montant_max_pret', cycle.maxLoanAmount?.toString() ?? '—'),
    MapEntry('duree_max_pret', cycle.maxLoanDuration?.toString() ?? '—'),
    MapEntry(
      'nombre_max_pret_simultane',
      cycle.maxSimultaneousLoans?.toString() ?? '—',
    ),
    MapEntry(
      'appliquer_penalites',
      _booleanLabel(cycle.penaltiesEnabled == '1'),
    ),
    MapEntry('epargne_active', _booleanLabel(cycle.savingsActive)),
    MapEntry('epargne_mode', cycle.savingsMode ?? '—'),
    MapEntry(
      'epargne_montant_fixe',
      cycle.savingsFixedAmount?.toString() ?? '—',
    ),
    MapEntry('epargne_montant_min', cycle.savingsMinAmount?.toString() ?? '—'),
    MapEntry('epargne_montant_max', cycle.savingsMaxAmount?.toString() ?? '—'),
    MapEntry(
      'epargne_calendrier_mode',
      cycle.savingsCalendarMode == 'INDEPENDANT'
          ? AppLocalizations.t('cycle_rule_independent')
          : AppLocalizations.t('cycle_rule_same_schedule'),
    ),
    MapEntry('epargne_frequence', _frequencyLabel(cycle.savingsFrequency)),
    MapEntry('epargne_jour_echeance', cycle.savingsDueDay ?? '—'),
    MapEntry('caisse_secours_active', _booleanLabel(cycle.emergencyFundActive)),
    MapEntry(
      'secours_inclure_beneficiaire',
      _booleanLabel(cycle.emergencyIncludeBeneficiary),
    ),
    MapEntry('tontine_active', _booleanLabel(cycle.tontineActive)),
    MapEntry(
      'tontine_prochain_visible',
      _booleanLabel(cycle.tontineNextVisible),
    ),
  ];

  String _ruleLabel(String key) => AppLocalizations.t('cycle_rule_$key');

  String _dateForPayload(DateTime? date) =>
      date == null
          ? ''
          : '${date.year.toString().padLeft(4, '0')}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> _buildChanges() {
    final cycle = _cycle!;
    final loansActive = _toggles['module_pret_actif'] == true;
    final savingsActive = _toggles['epargne_active'] == true;
    final savingsIndependent =
        savingsActive && _savingsCalendarMode == 'INDEPENDANT';
    final weekdayLabel =
        _usesWeekdaySchedule ? _weekdayOptions[_tontineWeekday - 1] : null;
    final usesMonthlyWeekday =
        _frequency == ContributionFrequency.mensuelle &&
        _tontineCalendarMode == 'NIEME_JOUR_SEMAINE';
    final values = <String, dynamic>{
      'nombre_membres': int.tryParse(_expectedMembersController.text.trim()),
      'nombre_admin': _maxAdmins,
      'montant_cotisation': int.tryParse(
        _controllers['montant_cotisation']!.text,
      ),
      'devise': _controllers['devise']!.text.trim(),
      'montant_max_pret':
          loansActive
              ? int.tryParse(_controllers['montant_max_pret']!.text)
              : null,
      'duree_max_pret':
          loansActive
              ? int.tryParse(_controllers['duree_max_pret']!.text)
              : null,
      'nombre_max_pret_simultane':
          loansActive
              ? int.tryParse(_controllers['nombre_max_pret_simultane']!.text)
              : null,
      'frequence_cycle': _frequencyToApi(_frequency),
      'jour_echeance': weekdayLabel,
      'tontine_calendrier_mode':
          _frequency == ContributionFrequency.mensuelle
              ? _tontineCalendarMode
              : 'DATE_MOIS',
      'tontine_ordinal_semaine':
          usesMonthlyWeekday ? _tontineWeekOrdinal : null,
      'tontine_jour_semaine': _usesWeekdaySchedule ? _tontineWeekday : null,
      'date_debut': _startDate == null ? null : _dateForPayload(_startDate),
      'date_fin': _endDate == null ? null : _dateForPayload(_endDate),
      'module_pret_actif': _toggles['module_pret_actif']! ? '1' : '0',
      'validation_pret_colectif':
          _toggles['validation_pret_colectif']! ? '1' : '0',
      'appliquer_penalites': _toggles['appliquer_penalites']! ? '1' : '0',
      'epargne_active': savingsActive,
      'epargne_mode': savingsActive ? _savingsMode : null,
      'epargne_montant_fixe':
          savingsActive && _savingsMode == 'FIXE'
              ? int.tryParse(_controllers['epargne_montant_fixe']!.text)
              : null,
      'epargne_montant_min':
          savingsActive && _savingsMode == 'LIBRE'
              ? int.tryParse(_controllers['epargne_montant_min']!.text)
              : null,
      'epargne_montant_max':
          savingsActive && _savingsMode == 'LIBRE'
              ? int.tryParse(_controllers['epargne_montant_max']!.text)
              : null,
      'epargne_calendrier_mode': savingsActive ? _savingsCalendarMode : null,
      'epargne_frequence': savingsIndependent ? _savingsFrequency : null,
      'epargne_jour_echeance': savingsIndependent ? _savingsDueDay : null,
      'caisse_secours_active': _toggles['caisse_secours_active'],
      'secours_inclure_beneficiaire': _toggles['secours_inclure_beneficiaire'],
      'tontine_active': _toggles['tontine_active'],
      'tontine_prochain_visible': _toggles['tontine_prochain_visible'],
    };
    final original = <String, dynamic>{
      'nombre_membres': cycle.memberCount,
      'nombre_admin': cycle.adminCount,
      'montant_cotisation': cycle.contributionAmount,
      'devise': cycle.currency,
      'montant_max_pret': cycle.maxLoanAmount,
      'duree_max_pret': cycle.maxLoanDuration,
      'nombre_max_pret_simultane': cycle.maxSimultaneousLoans,
      'frequence_cycle': cycle.frequency,
      'jour_echeance': cycle.dueDay,
      'tontine_calendrier_mode': cycle.tontineCalendarMode,
      'tontine_ordinal_semaine': cycle.tontineWeekOrdinal,
      'tontine_jour_semaine': cycle.tontineWeekday,
      'date_debut':
          cycle.startDate == null ? null : _dateForPayload(cycle.startDate),
      'date_fin': cycle.endDate == null ? null : _dateForPayload(cycle.endDate),
      'module_pret_actif': cycle.loanModuleActive,
      'validation_pret_colectif': cycle.collectiveLoanValidation,
      'appliquer_penalites': cycle.penaltiesEnabled,
      'epargne_active': cycle.savingsActive,
      'epargne_mode': cycle.savingsMode,
      'epargne_montant_fixe': cycle.savingsFixedAmount,
      'epargne_montant_min': cycle.savingsMinAmount,
      'epargne_montant_max': cycle.savingsMaxAmount,
      'epargne_calendrier_mode': cycle.savingsCalendarMode,
      'epargne_frequence': cycle.savingsFrequency,
      'epargne_jour_echeance': cycle.savingsDueDay,
      'caisse_secours_active': cycle.emergencyFundActive,
      'secours_inclure_beneficiaire': cycle.emergencyIncludeBeneficiary,
      'tontine_active': cycle.tontineActive,
      'tontine_prochain_visible': cycle.tontineNextVisible,
    };

    return Map.fromEntries(
      values.entries
          .where((entry) {
            final value = entry.value;
            final normalized = value is String && value.isEmpty ? null : value;
            return normalized != original[entry.key];
          })
          .map((entry) {
            final value = entry.value;
            return MapEntry(
              entry.key,
              value is String && value.isEmpty ? null : value,
            );
          }),
    );
  }

  Future<void> _submitProposal() async {
    final validationMessage = _editValidationMessage();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }
    final changes = _buildChanges();
    if (changes.isEmpty) {
      _showMessage(AppLocalizations.t('cycle_rules_no_changes'));
      return;
    }
    setState(() => _isBusy = true);
    final result = await CycleRulesController.proposeChanges(
      cycleId: _cycleId!,
      changes: changes,
    );
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (result['success'] == true) {
      setState(() => _isEditing = false);
      await _load();
      _showMessage(AppLocalizations.t('cycle_rules_proposal_sent'));
    } else {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('cycle_rules_proposal_error'),
      );
    }
  }

  Future<void> _decide(String decision) async {
    final proposalId = _proposal?['id']?.toString();
    if (proposalId == null || proposalId.isEmpty) return;
    setState(() => _isBusy = true);
    final result = await CycleRulesController.decideProposal(
      cycleId: _cycleId!,
      proposalId: proposalId,
      decision: decision,
    );
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (result['success'] == true) {
      await _load();
    } else {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('cycle_rules_decision_error'),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final cycle = _cycle;
    final cycleName = cycle?.cycleName?.trim();
    final cycleNumber = cycle?.number?.toString();
    final cycleTitle =
        cycleName == null || cycleName.isEmpty
            ? [
              AppLocalizations.t('cycle_label'),
              if (cycleNumber != null) cycleNumber,
            ].join(' ')
            : cycleNumber == null ||
                cycleName.endsWith(' $cycleNumber') ||
                cycleName == cycleNumber
            ? cycleName
            : '$cycleName $cycleNumber';
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.t('cycle_rules_title')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null || cycle == null
                ? _buildLoadError()
                : ListView(
                  padding: EdgeInsets.all(AppDimensions.screenPaddingH.w),
                  children: [
                    Text(
                      cycleTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      _isAdmin
                          ? AppLocalizations.t('cycle_rules_admin_subtitle')
                          : AppLocalizations.t('cycle_rules_member_subtitle'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    _buildRuleSection(
                      AppLocalizations.t('cycle_rules_general'),
                      _ruleValues(cycle).take(7).toList(),
                    ),
                    _buildRuleSection(
                      AppLocalizations.t('cycle_rules_loans'),
                      _ruleValues(cycle).skip(7).take(6).toList(),
                    ),
                    _buildRuleSection(
                      AppLocalizations.t('cycle_rules_savings'),
                      _ruleValues(cycle).skip(13).take(8).toList(),
                    ),
                    _buildRuleSection(
                      AppLocalizations.t('cycle_rules_protection'),
                      _ruleValues(cycle).skip(21).toList(),
                    ),
                    if (_isAdmin && _proposal != null) ...[
                      SizedBox(height: AppDimensions.spaceLg.h),
                      _buildProposalCard(),
                    ],
                    if (_isAdmin &&
                        cycle.status == 'EN_ATTENTE' &&
                        _proposal == null &&
                        !_isEditing) ...[
                      SizedBox(height: AppDimensions.spaceLg.h),
                      FilledButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(AppLocalizations.t('cycle_rules_edit')),
                      ),
                    ],
                    if (_isAdmin && _isEditing) ...[
                      SizedBox(height: AppDimensions.spaceLg.h),
                      _buildEditForm(),
                    ],
                    SizedBox(height: AppDimensions.spaceXl.h),
                  ],
                ),
      ),
    );
  }

  Widget _buildLoadError() => Center(
    child: Padding(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _loadError ?? AppLocalizations.t('cycle_rules_load_error'),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.t('invite_retry')),
          ),
        ],
      ),
    ),
  );

  Widget _buildRuleSection(String title, List<MapEntry<String, String>> rules) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceMd.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spaceMd.w,
                AppDimensions.spaceMd.h,
                AppDimensions.spaceMd.w,
                AppDimensions.spaceXs.h,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            for (final rule in rules)
              ListTile(
                dense: true,
                title: Text(
                  _ruleLabel(rule.key),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Text(
                  rule.value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.t('cycle_rules_edit'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      SizedBox(height: AppDimensions.spaceMd.h),
      _editSection(
        AppLocalizations.t('contribution_section'),
        Icons.payments_outlined,
        [
          AppTextField(
            label:
                AppLocalizations.t('contribution_amount_label').toUpperCase(),
            hint: '0',
            controller: _controllers['montant_cotisation'],
            keyboardType: TextInputType.number,
            suffixText:
                _controllers['devise']!.text.isEmpty
                    ? 'FCFA'
                    : _controllers['devise']!.text,
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          AppTextField(
            label: _ruleLabel('devise').toUpperCase(),
            hint: 'XAF',
            controller: _controllers['devise'],
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
            onSelect: (frequency) {
              setState(() {
                _frequency = frequency;
                if (frequency != ContributionFrequency.mensuelle) {
                  _tontineCalendarMode = 'DATE_MOIS';
                }
              });
            },
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
            controller: _expectedMembersController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          LabeledDateField(
            label: AppLocalizations.t('start_date_label').toUpperCase(),
            value: _startDate,
            onChanged: (date) => setState(() => _startDate = date),
          ),
          if (_frequency == ContributionFrequency.hebdomadaire ||
              _frequency == ContributionFrequency.bimensuelle) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            _weekdayDropdown(
              label: AppLocalizations.t('due_day_label').toUpperCase(),
            ),
            SizedBox(height: AppDimensions.spaceXs.h),
            Text(
              AppLocalizations.t('due_day_helper'),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (_frequency == ContributionFrequency.mensuelle) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _tontineCalendarMode,
              decoration: InputDecoration(
                labelText: AppLocalizations.t('tontine_calendar_rule_label'),
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
                    AppLocalizations.t('tontine_calendar_nth_weekday'),
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
                  labelText: AppLocalizations.t('tontine_week_ordinal_label'),
                ),
                items: [
                  for (var ordinal = 1; ordinal <= 4; ordinal++)
                    DropdownMenuItem(
                      value: ordinal,
                      child: Text(
                        AppLocalizations.t('tontine_week_ordinal_$ordinal'),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tontineWeekOrdinal = value);
                  }
                },
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              _weekdayDropdown(
                label: AppLocalizations.t('due_day_label').toUpperCase(),
              ),
              SizedBox(height: AppDimensions.spaceXs.h),
              Text(
                AppLocalizations.t(
                  _startDateMatchesSchedule()
                      ? 'tontine_contribution_window_helper'
                      : 'tontine_start_date_rule_mismatch',
                ),
                style: TextStyle(
                  fontSize: 11,
                  color:
                      _startDateMatchesSchedule()
                          ? AppColors.textSecondary
                          : AppColors.error,
                ),
              ),
            ],
          ],
          SizedBox(height: AppDimensions.spaceMd.h),
          _datePickerTile('date_fin', _endDate, isStart: false),
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
        ],
      ),
      _editSection(
        AppLocalizations.t('allow_loans_title'),
        Icons.account_balance_outlined,
        [
          ToggleSettingRow(
            bordered: false,
            title: AppLocalizations.t('allow_loans_title'),
            value: _toggles['module_pret_actif'] ?? false,
            onChanged:
                (value) =>
                    setState(() => _toggles['module_pret_actif'] = value),
          ),
          if (_toggles['module_pret_actif'] == true) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            AppTextField(
              label: AppLocalizations.t('max_loan_amount_label').toUpperCase(),
              hint: '0',
              controller: _controllers['montant_max_pret'],
              keyboardType: TextInputType.number,
              suffixText: 'FCFA',
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            AppTextField(
              label:
                  AppLocalizations.t('max_loan_duration_label').toUpperCase(),
              hint: '6',
              controller: _controllers['duree_max_pret'],
              keyboardType: TextInputType.number,
              suffixText: AppLocalizations.t('duration_suffix_months'),
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            AppTextField(
              label:
                  AppLocalizations.t(
                    'max_simultaneous_loans_label',
                  ).toUpperCase(),
              hint: '1',
              controller: _controllers['nombre_max_pret_simultane'],
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            ToggleSettingRow(
              bordered: false,
              title: AppLocalizations.t('admin_validation_title'),
              subtitle: AppLocalizations.t('admin_validation_subtitle'),
              value: _toggles['validation_pret_colectif'] ?? false,
              onChanged:
                  (value) => setState(
                    () => _toggles['validation_pret_colectif'] = value,
                  ),
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            ToggleSettingRow(
              bordered: false,
              title: AppLocalizations.t('apply_penalties_title'),
              subtitle: AppLocalizations.t('apply_penalties_subtitle'),
              value: _toggles['appliquer_penalites'] ?? false,
              onChanged:
                  (value) =>
                      setState(() => _toggles['appliquer_penalites'] = value),
            ),
          ],
        ],
      ),
      _editSection(AppLocalizations.t('cycle_modules_section'), Icons.tune, [
        ToggleSettingRow(
          bordered: false,
          leading: const CircledSettingIcon(icon: Icons.savings_outlined),
          title: AppLocalizations.t('savings_active_title'),
          value: _toggles['epargne_active'] ?? false,
          onChanged:
              (value) => setState(() => _toggles['epargne_active'] = value),
        ),
        if (_toggles['epargne_active'] == true) ...[
          SizedBox(height: AppDimensions.spaceSm.h),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: 'LIBRE',
                label: Text(AppLocalizations.t('savings_mode_free')),
              ),
              ButtonSegment(
                value: 'FIXE',
                label: Text(AppLocalizations.t('savings_mode_fixed')),
              ),
            ],
            selected: {_savingsMode},
            onSelectionChanged:
                (values) => setState(() => _savingsMode = values.first),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          if (_savingsMode == 'FIXE')
            AppTextField(
              label: AppLocalizations.t('savings_fixed_amount_label'),
              hint: '10000',
              controller: _controllers['epargne_montant_fixe'],
              keyboardType: TextInputType.number,
            )
          else ...[
            AppTextField(
              label: AppLocalizations.t('savings_min_amount_label'),
              hint: '1000',
              controller: _controllers['epargne_montant_min'],
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppDimensions.spaceSm.h),
            AppTextField(
              label: AppLocalizations.t('savings_max_amount_label'),
              hint: '50000',
              controller: _controllers['epargne_montant_max'],
              keyboardType: TextInputType.number,
            ),
          ],
          SizedBox(height: AppDimensions.spaceSm.h),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _savingsCalendarMode ?? 'MEME_QUE_TONTINE',
            decoration: InputDecoration(
              labelText: AppLocalizations.t('savings_calendar_label'),
            ),
            items: [
              DropdownMenuItem(
                value: 'MEME_QUE_TONTINE',
                child: Text(AppLocalizations.t('savings_calendar_same')),
              ),
              DropdownMenuItem(
                value: 'INDEPENDANT',
                child: Text(AppLocalizations.t('savings_calendar_independent')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _savingsCalendarMode = value);
              }
            },
          ),
          if (_savingsCalendarMode == 'INDEPENDANT') ...[
            SizedBox(height: AppDimensions.spaceSm.h),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _savingsFrequency,
              decoration: InputDecoration(
                labelText: _ruleLabel('epargne_frequence'),
              ),
              items: [
                for (final frequency in [
                  'HEBDO',
                  'BIHEBDO',
                  'MENSUEL',
                  'AUTRE',
                ])
                  DropdownMenuItem(
                    value: frequency,
                    child: Text(_frequencyLabel(frequency)),
                  ),
              ],
              onChanged: (value) => setState(() => _savingsFrequency = value),
            ),
            SizedBox(height: AppDimensions.spaceSm.h),
            AppTextField(
              label: _ruleLabel('epargne_jour_echeance').toUpperCase(),
              hint: AppLocalizations.t('due_day_label'),
              controller: _savingsDueDayController,
              onChanged: (value) => _savingsDueDay = value,
            ),
          ],
        ],
        SizedBox(height: AppDimensions.spaceMd.h),
        ToggleSettingRow(
          bordered: false,
          leading: const Icon(
            Icons.health_and_safety_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          title: AppLocalizations.t('emergency_fund_active_title'),
          value: _toggles['caisse_secours_active'] ?? false,
          onChanged:
              (value) =>
                  setState(() => _toggles['caisse_secours_active'] = value),
        ),
        if (_toggles['caisse_secours_active'] == true) ...[
          SizedBox(height: AppDimensions.spaceSm.h),
          ToggleSettingRow(
            bordered: false,
            title: AppLocalizations.t('emergency_include_beneficiary_title'),
            value: _toggles['secours_inclure_beneficiaire'] ?? false,
            onChanged:
                (value) => setState(
                  () => _toggles['secours_inclure_beneficiaire'] = value,
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
          value: _toggles['tontine_active'] ?? false,
          onChanged:
              (value) => setState(() => _toggles['tontine_active'] = value),
        ),
        if (_toggles['tontine_active'] == true) ...[
          SizedBox(height: AppDimensions.spaceSm.h),
          ToggleSettingRow(
            bordered: false,
            title: AppLocalizations.t('tontine_next_visible_title'),
            value: _toggles['tontine_prochain_visible'] ?? false,
            onChanged:
                (value) => setState(
                  () => _toggles['tontine_prochain_visible'] = value,
                ),
          ),
        ],
      ]),
      _editSection(
        AppLocalizations.t('governance_section'),
        Icons.admin_panel_settings_outlined,
        [
          NumberStepperField(
            label: AppLocalizations.t('max_admins_label').toUpperCase(),
            value: _maxAdmins,
            min: 1,
            max: 10,
            onChanged: (value) => setState(() => _maxAdmins = value),
          ),
        ],
      ),
      SizedBox(height: AppDimensions.spaceMd.h),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _isBusy ? null : () => setState(() => _isEditing = false),
              child: Text(AppLocalizations.t('cancel')),
            ),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: FilledButton.icon(
              onPressed: _isBusy ? null : _submitProposal,
              icon:
                  _isBusy
                      ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.send_outlined),
              label: Text(AppLocalizations.t('cycle_rules_submit')),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _editSection(String title, IconData icon, List<Widget> children) =>
      Padding(
        padding: EdgeInsets.only(bottom: AppDimensions.spaceMd.h),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceMd.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircledSettingIcon(icon: icon, size: 28),
                  SizedBox(width: AppDimensions.spaceXs.w),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              ...children,
            ],
          ),
        ),
      );

  Widget _weekdayDropdown({required String label}) =>
      DropdownButtonFormField<int>(
        isExpanded: true,
        value: _tontineWeekday,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (var weekday = 1; weekday <= 7; weekday++)
            DropdownMenuItem(
              value: weekday,
              child: Text(_weekdayOptions[weekday - 1]),
            ),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _tontineWeekday = value);
        },
      );

  Widget _datePickerTile(
    String key,
    DateTime? value, {
    required bool isStart,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(_ruleLabel(key)),
    subtitle: Text(_formatDate(value)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: AppLocalizations.t('select_date'),
          onPressed: () => _pickDate(isStart: isStart),
          icon: const Icon(Icons.calendar_month_outlined),
        ),
        if (value != null)
          IconButton(
            tooltip: AppLocalizations.t('clear'),
            onPressed:
                () => setState(() {
                  if (isStart) {
                    _startDate = null;
                  } else {
                    _endDate = null;
                  }
                }),
            icon: const Icon(Icons.close),
          ),
      ],
    ),
  );

  Widget _buildProposalCard() {
    final proposal = _proposal!;
    final approvals = (proposal['approvals'] as List? ?? const [])
        .whereType<Map>()
        .toList(growable: false);
    final changes =
        proposal['changes'] is Map
            ? Map<String, dynamic>.from(proposal['changes'] as Map)
            : <String, dynamic>{};
    final canDecide = proposal['can_decide'] == true;

    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t('cycle_rules_pending_title'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          for (final change in changes.entries)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(_ruleLabel(change.key)),
              trailing: Text(change.value?.toString() ?? '—'),
            ),
          for (final approval in approvals)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                ((approval['admin'] as Map?)?['nom'] ??
                        (approval['admin'] as Map?)?['telephone'] ??
                        AppLocalizations.t('cycle_rules_admin'))
                    .toString(),
              ),
              trailing: Text(
                AppLocalizations.t(
                  'cycle_rules_vote_${approval['decision']?.toString().toLowerCase() ?? 'en_attente'}',
                ),
              ),
            ),
          if (canDecide) ...[
            SizedBox(height: AppDimensions.spaceSm.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isBusy ? null : () => _decide('REFUSEE'),
                    icon: const Icon(Icons.close),
                    label: Text(AppLocalizations.t('cycle_rules_reject')),
                  ),
                ),
                SizedBox(width: AppDimensions.spaceSm.w),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isBusy ? null : () => _decide('APPROUVEE'),
                    icon: const Icon(Icons.check),
                    label: Text(AppLocalizations.t('cycle_rules_approve')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

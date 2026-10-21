import 'package:flutter/material.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleRulesController.dart';
import '../../../Models/Cycle.dart';
import '../../../ModeView/community_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

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
    'nombre_membres',
    'nombre_admin',
    'montant_cotisation',
    'devise',
    'montant_max_pret',
    'duree_max_pret',
    'nombre_max_pret_simultane',
    'epargne_montant_fixe',
    'epargne_montant_min',
    'epargne_montant_max',
  ];

  static const _booleanFields = [
    'module_pret_actif',
    'validation_pret_colectif',
    'appliquer_penalites',
    'epargne_active',
    'caisse_secours_active',
    'secours_inclure_beneficiaire',
    'tontine_active',
    'tontine_prochain_visible',
  ];

  final Map<String, TextEditingController> _controllers = {
    for (final field in _textFields) field: TextEditingController(),
  };
  final TextEditingController _dueDayController = TextEditingController();
  final Map<String, bool> _toggles = {};

  Cycle? _cycle;
  Map<String, dynamic>? _proposal;
  String? _cycleId;
  String? _loadError;
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isBusy = false;
  String? _frequency;
  String? _savingsMode;
  String? _savingsCalendarMode;
  String? _savingsFrequency;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _dueDay;

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
    _dueDayController.dispose();
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
      'nombre_membres': cycle.memberCount,
      'nombre_admin': cycle.adminCount,
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
    _frequency = cycle.frequency;
    _savingsMode = cycle.savingsMode;
    _savingsCalendarMode = cycle.savingsCalendarMode;
    _savingsFrequency = cycle.savingsFrequency;
    _startDate = cycle.startDate;
    _endDate = cycle.endDate;
    _dueDay = cycle.dueDay;
    _dueDayController.text = cycle.dueDay ?? '';
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
    final values = <String, dynamic>{
      'nombre_membres': int.tryParse(_controllers['nombre_membres']!.text),
      'nombre_admin': int.tryParse(_controllers['nombre_admin']!.text),
      'montant_cotisation': int.tryParse(
        _controllers['montant_cotisation']!.text,
      ),
      'devise': _controllers['devise']!.text.trim(),
      'montant_max_pret': int.tryParse(_controllers['montant_max_pret']!.text),
      'duree_max_pret': int.tryParse(_controllers['duree_max_pret']!.text),
      'nombre_max_pret_simultane': int.tryParse(
        _controllers['nombre_max_pret_simultane']!.text,
      ),
      'frequence_cycle': _frequency,
      'jour_echeance': _dueDay,
      'date_debut': _startDate == null ? null : _dateForPayload(_startDate),
      'date_fin': _endDate == null ? null : _dateForPayload(_endDate),
      'module_pret_actif': _toggles['module_pret_actif']! ? '1' : '0',
      'validation_pret_colectif':
          _toggles['validation_pret_colectif']! ? '1' : '0',
      'appliquer_penalites': _toggles['appliquer_penalites']! ? '1' : '0',
      'epargne_active': _toggles['epargne_active'],
      'epargne_mode': _savingsMode,
      'epargne_montant_fixe': int.tryParse(
        _controllers['epargne_montant_fixe']!.text,
      ),
      'epargne_montant_min': int.tryParse(
        _controllers['epargne_montant_min']!.text,
      ),
      'epargne_montant_max': int.tryParse(
        _controllers['epargne_montant_max']!.text,
      ),
      'epargne_calendrier_mode': _savingsCalendarMode,
      'epargne_frequence': _savingsFrequency,
      'epargne_jour_echeance': _dueDay,
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

  Widget _buildEditForm() => Container(
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
          AppLocalizations.t('cycle_rules_edit'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppDimensions.spaceMd.h),
        for (final field in _textFields) ...[
          TextField(
            controller: _controllers[field],
            keyboardType:
                field == 'devise' ? TextInputType.text : TextInputType.number,
            decoration: InputDecoration(
              labelText: _ruleLabel(field),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
        ],
        DropdownButtonFormField<String>(
          value: _frequency,
          decoration: InputDecoration(
            labelText: _ruleLabel('frequence_cycle'),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final value in ['HEBDO', 'BIHEBDO', 'MENSUEL', 'AUTRE'])
              DropdownMenuItem(
                value: value,
                child: Text(_frequencyLabel(value)),
              ),
          ],
          onChanged: (value) => setState(() => _frequency = value),
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        TextField(
          controller: _dueDayController,
          decoration: InputDecoration(
            labelText: _ruleLabel('jour_echeance'),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) => _dueDay = value,
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        _datePickerTile('date_debut', _startDate, isStart: true),
        _datePickerTile('date_fin', _endDate, isStart: false),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: _savingsMode,
          decoration: InputDecoration(
            labelText: _ruleLabel('epargne_mode'),
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'FIXE', child: Text('FIXE')),
            DropdownMenuItem(value: 'LIBRE', child: Text('LIBRE')),
          ],
          onChanged: (value) => setState(() => _savingsMode = value),
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: _savingsCalendarMode,
          decoration: InputDecoration(
            labelText: _ruleLabel('epargne_calendrier_mode'),
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'MEME_QUE_TONTINE',
              child: Text(
                AppLocalizations.t('cycle_rule_same_schedule'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 'INDEPENDANT',
              child: Text(
                AppLocalizations.t('cycle_rule_independent'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: (value) => setState(() => _savingsCalendarMode = value),
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: _savingsFrequency,
          decoration: InputDecoration(
            labelText: _ruleLabel('epargne_frequence'),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final value in ['HEBDO', 'BIHEBDO', 'MENSUEL', 'AUTRE'])
              DropdownMenuItem(
                value: value,
                child: Text(
                  _frequencyLabel(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _savingsFrequency = value),
        ),
        SizedBox(height: AppDimensions.spaceMd.h),
        for (final field in _booleanFields)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(_ruleLabel(field)),
            value: _toggles[field] ?? false,
            onChanged: (value) => setState(() => _toggles[field] = value),
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
    ),
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

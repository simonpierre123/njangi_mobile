import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CyclePaymentSimulationController.dart';
import '../../../Controllers_distant/CycleSavingsContributionController.dart';
import '../../../Controllers_distant/CycleTontineContributionController.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/media_source_sheet.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

class CycleContributionPage extends StatefulWidget {
  const CycleContributionPage({
    super.key,
    required this.community,
    required this.onBack,
  });

  final CommunityModel community;
  final VoidCallback onBack;

  @override
  State<CycleContributionPage> createState() => _CycleContributionPageState();
}

class _CycleContributionPageState extends State<CycleContributionPage> {
  final _referenceController = TextEditingController();
  final _savingsAmountController = TextEditingController();
  String? _cycleId;
  String? _selectedContributionType;
  String? _selectedSavingsPeriod;
  String? _paymentMode;
  String _operator = 'MTN';
  File? _receipt;
  Map<String, dynamic>? _contextData;
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _referenceController.dispose();
    _savingsAmountController.dispose();
    super.dispose();
  }

  Future<void> _chooseTontine() async {
    setState(() {
      _selectedContributionType = 'TONTINE';
      _paymentMode = null;
      _receipt = null;
      _referenceController.clear();
      _contextData = null;
      _error = null;
      _loading = true;
    });
    final cycleId = await _resolveCycleId();
    if (!mounted) return;
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.t('tontine_contribution_load_error');
      });
      return;
    }
    _cycleId = cycleId;
    await _loadContext();
  }

  Future<void> _loadContext() async {
    final cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) return;
    final result = await CycleTontineContributionController.getContext(cycleId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['data'] is Map) {
        _contextData = Map<String, dynamic>.from(result['data'] as Map);
      } else {
        _error =
            result['message']?.toString() ??
            AppLocalizations.t('tontine_contribution_load_error');
      }
    });
  }

  Future<void> _chooseSavings() async {
    setState(() {
      _selectedContributionType = 'EPARGNE';
      _paymentMode = null;
      _receipt = null;
      _referenceController.clear();
      _savingsAmountController.clear();
      _selectedSavingsPeriod = null;
      _contextData = null;
      _error = null;
      _loading = true;
    });
    final cycleId = await _resolveCycleId();
    if (!mounted) return;
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.t('savings_contribution_load_error');
      });
      return;
    }
    _cycleId = cycleId;
    await _loadSavingsContext();
  }

  Future<void> _loadSavingsContext() async {
    final cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) return;
    final result = await CycleSavingsContributionController.getContext(cycleId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['data'] is Map) {
        _contextData = Map<String, dynamic>.from(result['data'] as Map);
        final periods = _periods(_contextData);
        _selectedSavingsPeriod =
            periods.isEmpty ? null : periods.first['value'];
      } else {
        _error =
            result['message']?.toString() ??
            AppLocalizations.t('savings_contribution_load_error');
      }
    });
  }

  Future<String?> _resolveCycleId() async {
    final existingId = widget.community.cycleId;
    if (existingId != null && existingId.isNotEmpty) return existingId;
    final cycles = await CycleController.getForGroup(widget.community.id);
    if (cycles == null || cycles.isEmpty) return null;
    final activeCycles =
        cycles.where((cycle) => cycle.status == 'EN_COURS').toList();
    return (activeCycles.isEmpty ? cycles.first : activeCycles.first).id;
  }

  Future<void> _pickReceipt() async {
    try {
      final picked = await showMediaSourceSheet(context);
      if (picked == null || !mounted) return;
      setState(() => _receipt = File(picked.path));
    } catch (error) {
      debugPrint('[TONTINE] Receipt selection failed: $error');
      if (mounted) {
        _showMessage(AppLocalizations.t('tontine_receipt_pick_error'));
      }
    }
  }

  Future<void> _submit() async {
    final cycleId = _cycleId;
    if (cycleId == null || _paymentMode == null || _submitting) return;
    final cycleStatus = _map(_contextData?['cycle'])?['statut'];
    final tontineWindowOpen = _contextData?['cotisation_ouverte'] == true;
    if (cycleStatus != 'EN_COURS' &&
        !((cycleStatus == 'EN_ATTENTE' || cycleStatus == null) &&
            tontineWindowOpen)) {
      _showMessage(AppLocalizations.t('contribution_auto_window_notice'));
      return;
    }
    final period = _contextData?['periode']?.toString();
    final amount = num.tryParse(
      _contextData?['montant_cotisation']?.toString() ?? '',
    );
    if (period == null || period.isEmpty || amount == null || amount <= 0) {
      _showMessage(AppLocalizations.t('tontine_no_upcoming_turn'));
      return;
    }
    if (_contextData?['cotisation_ouverte'] != true) {
      _showMessage(_contributionWindowMessage(_contextData));
      return;
    }
    if (_paymentMode == 'IN_APP_TEST') {
      await _submitTestPayment(
        type: 'TONTINE',
        period: period,
        amount: amount.toInt(),
      );
      return;
    }
    if (_paymentMode == 'MOBILE_MONEY' &&
        _referenceController.text.trim().isEmpty) {
      _showMessage(AppLocalizations.t('tontine_reference_required'));
      return;
    }
    if (_paymentMode == 'ESPECES' && _receipt == null) {
      _showMessage(AppLocalizations.t('tontine_receipt_required'));
      return;
    }
    setState(() => _submitting = true);
    final result = await CycleTontineContributionController.submit(
      cycleId: cycleId,
      period: period,
      amount: amount.toInt(),
      paymentMode: _paymentMode!,
      operator: _paymentMode == 'MOBILE_MONEY' ? _operator : null,
      paymentReference:
          _paymentMode == 'MOBILE_MONEY' ? _referenceController.text : null,
      receipt: _paymentMode == 'ESPECES' ? _receipt : null,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result['success'] == true) {
      _showMessage(AppLocalizations.t('tontine_contribution_submitted'));
      setState(() {
        _paymentMode = null;
        _receipt = null;
        _referenceController.clear();
      });
      await _refresh();
    } else {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('tontine_contribution_submit_error'),
      );
    }
  }

  Future<void> _submitSavings() async {
    final cycleId = _cycleId;
    final data = _contextData;
    final period = _selectedSavingsPeriod;
    if (cycleId == null ||
        data == null ||
        period == null ||
        _paymentMode == null ||
        _submitting) {
      return;
    }
    final cycleStatus = _map(data['cycle'])?['statut'];
    final tontineWindowOpen = data['cotisation_tontine_ouverte'] == true;
    if (cycleStatus != 'EN_COURS' &&
        !(cycleStatus == 'EN_ATTENTE' && tontineWindowOpen)) {
      _showMessage(AppLocalizations.t('contribution_auto_window_notice'));
      return;
    }

    final fixedAmount = num.tryParse(
      data['epargne_montant_fixe']?.toString() ?? '',
    );
    final amount =
        data['epargne_mode'] == 'FIXE'
            ? fixedAmount
            : num.tryParse(_savingsAmountController.text.trim());
    final minimum = num.tryParse(data['epargne_montant_min']?.toString() ?? '');
    final maximum = num.tryParse(data['epargne_montant_max']?.toString() ?? '');
    if (amount == null ||
        amount < 1 ||
        amount != amount.roundToDouble() ||
        (minimum != null && amount < minimum) ||
        (maximum != null && amount > maximum)) {
      _showMessage(AppLocalizations.t('savings_amount_invalid'));
      return;
    }
    if (_paymentMode == 'IN_APP_TEST') {
      await _submitTestPayment(
        type: 'EPARGNE',
        period: period,
        amount: amount.toInt(),
      );
      return;
    }
    if (_paymentMode == 'MOBILE_MONEY' &&
        _referenceController.text.trim().isEmpty) {
      _showMessage(AppLocalizations.t('tontine_reference_required'));
      return;
    }
    if (_paymentMode == 'ESPECES' && _receipt == null) {
      _showMessage(AppLocalizations.t('tontine_receipt_required'));
      return;
    }

    setState(() => _submitting = true);
    final result = await CycleSavingsContributionController.submit(
      cycleId: cycleId,
      period: period,
      amount: amount.toInt(),
      paymentMode: _paymentMode!,
      operator: _paymentMode == 'MOBILE_MONEY' ? _operator : null,
      paymentReference:
          _paymentMode == 'MOBILE_MONEY' ? _referenceController.text : null,
      receipt: _paymentMode == 'ESPECES' ? _receipt : null,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result['success'] == true) {
      _showMessage(AppLocalizations.t('savings_contribution_submitted'));
      setState(() {
        _paymentMode = null;
        _receipt = null;
        _referenceController.clear();
        _savingsAmountController.clear();
      });
      await _loadSavingsContext();
    } else {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('savings_contribution_submit_error'),
      );
    }
  }

  Future<void> _submitTestPayment({
    required String type,
    required String period,
    required int amount,
  }) async {
    final cycleId = _cycleId;
    if (cycleId == null || _submitting) return;
    setState(() => _submitting = true);
    final result = await CyclePaymentSimulationController.submit(
      cycleId: cycleId,
      type: type,
      period: period,
      amount: amount,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result['success'] == true) {
      _showMessage(AppLocalizations.t('payment_test_saved'));
      setState(() {
        _paymentMode = null;
        _receipt = null;
        _referenceController.clear();
        _savingsAmountController.clear();
      });
      await _refresh();
    } else {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('payment_test_error'),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _value(dynamic value, {String fallback = '—'}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatAmount(dynamic value) {
    final amount = num.tryParse(value?.toString() ?? '');
    return amount == null
        ? _value(value)
        : NumberFormat.decimalPattern(
          AppLocalizations.locale.value,
        ).format(amount);
  }

  String _beneficiaryName(Map<String, dynamic> beneficiary) {
    final name = [
      beneficiary['prenom']?.toString().trim() ?? '',
      beneficiary['nom']?.toString().trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    return name.isEmpty ? '—' : name;
  }

  String _contributionWindowMessage(Map<String, dynamic>? data) {
    final state = data?['etat_fenetre_cotisation']?.toString();
    if (state == 'AVANT_OUVERTURE') {
      return AppLocalizations.t(
        'tontine_contribution_not_open',
        args: [_formatDate(data?['date_ouverture_cotisation'])],
      );
    }
    if (state == 'FENETRE_FERMEE') {
      return AppLocalizations.t(
        'tontine_contribution_window_closed',
        args: [_formatDate(data?['date_fermeture_cotisation'])],
      );
    }
    return AppLocalizations.t('tontine_no_upcoming_turn');
  }

  List<Map<String, dynamic>> _periods(Map<String, dynamic>? data) =>
      (data?['periodes_disponibles'] as List?)
          ?.whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false) ??
      const <Map<String, dynamic>>[];

  Map<String, dynamic>? _savingsOperationForPeriod(
    Map<String, dynamic>? data,
    String? period,
  ) {
    if (period == null) return null;
    final operations =
        (data?['recent_epargne_operations'] as List?)?.whereType<Map>() ?? [];
    for (final item in operations) {
      final operation = Map<String, dynamic>.from(item);
      if (operation['periode']?.toString() == period) return operation;
    }
    return null;
  }

  Widget _buildPaymentSection({
    required String submitLabel,
    required VoidCallback onSubmit,
  }) {
    return _SectionCard(
      title: AppLocalizations.t('payment_method_label'),
      children: [
        _ChoiceTile(
          title: AppLocalizations.t('payment_mobile_money'),
          icon: Icons.phone_android,
          selected: _paymentMode == 'MOBILE_MONEY',
          onTap:
              () => setState(() {
                _paymentMode = 'MOBILE_MONEY';
                _receipt = null;
              }),
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        _ChoiceTile(
          title: AppLocalizations.t('payment_cash'),
          icon: Icons.payments_outlined,
          selected: _paymentMode == 'ESPECES',
          onTap:
              () => setState(() {
                _paymentMode = 'ESPECES';
                _referenceController.clear();
              }),
        ),
        if (_contextData?['paiement_simulation_active'] == true) ...[
          SizedBox(height: AppDimensions.spaceSm.h),
          _ChoiceTile(
            title: AppLocalizations.t('payment_in_app_test'),
            icon: Icons.phone_iphone_outlined,
            selected: _paymentMode == 'IN_APP_TEST',
            onTap:
                () => setState(() {
                  _paymentMode = 'IN_APP_TEST';
                  _receipt = null;
                  _referenceController.clear();
                }),
          ),
          if (_paymentMode == 'IN_APP_TEST') ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            _TestPaymentNotice(),
          ],
        ],
        if (_paymentMode == 'MOBILE_MONEY') ...[
          SizedBox(height: AppDimensions.spaceMd.h),
          DropdownButtonFormField<String>(
            value: _operator,
            decoration: InputDecoration(
              labelText: AppLocalizations.t('mobile_operator_label'),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'MTN',
                child: Text(AppLocalizations.t('operator_mtn')),
              ),
              DropdownMenuItem(
                value: 'ORANGE',
                child: Text(AppLocalizations.t('operator_orange')),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _operator = value);
            },
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          AppTextField(
            label: AppLocalizations.t('payment_reference_label'),
            hint: AppLocalizations.t('payment_reference_hint'),
            controller: _referenceController,
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(
            AppLocalizations.t('mobile_money_manual_verification'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (_paymentMode == 'ESPECES') ...[
          SizedBox(height: AppDimensions.spaceMd.h),
          Text(
            AppLocalizations.t('cash_receipt_instruction'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          OutlinedButton.icon(
            onPressed: _pickReceipt,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              AppLocalizations.t(
                _receipt == null
                    ? 'add_receipt_button'
                    : 'receipt_selected_label',
              ),
            ),
          ),
          if (_receipt != null) ...[
            SizedBox(height: AppDimensions.spaceSm.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Image.file(
                _receipt!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
        if (_paymentMode != null) ...[
          SizedBox(height: AppDimensions.spaceLg.h),
          AppButton(
            label:
                _paymentMode == 'IN_APP_TEST'
                    ? AppLocalizations.t('payment_test_button')
                    : submitLabel,
            icon: Icons.send_outlined,
            iconLeading: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : onSubmit,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildSavingsContent(Map<String, dynamic> data) {
    final cycle = _map(data['cycle']) ?? const <String, dynamic>{};
    final group = _map(cycle['groupe']) ?? const <String, dynamic>{};
    final cyclePending = cycle['statut'] == 'EN_ATTENTE';
    final tontineWindowOpen = data['cotisation_tontine_ouverte'] == true;
    final periods = _periods(data);
    final selectedPeriod = _selectedSavingsPeriod;
    final selectedPeriodData = periods.cast<Map<String, dynamic>?>().firstWhere(
      (period) => period?['value']?.toString() == selectedPeriod,
      orElse: () => null,
    );
    final operation = _savingsOperationForPeriod(data, selectedPeriod);
    final operationStatus =
        operation?['statut']?.toString().toUpperCase() ?? '';
    final canSubmit =
        (cycle['statut'] == 'EN_COURS' ||
            (cyclePending && tontineWindowOpen)) &&
        (data['epargne_mode'] == 'FIXE' || data['epargne_mode'] == 'LIBRE') &&
        selectedPeriodData != null &&
        (operation == null ||
            operationStatus == 'REJETE' ||
            operation['is_simulation'] == true);
    final currency = _value(data['devise'], fallback: 'XAF');
    final isFixed = data['epargne_mode'] == 'FIXE';
    final amountRule =
        isFixed
            ? '${_formatAmount(data['epargne_montant_fixe'])} $currency'
            : '${_formatAmount(data['epargne_montant_min'] ?? 0)} – '
                '${data['epargne_montant_max'] == null ? '∞' : _formatAmount(data['epargne_montant_max'])} '
                '$currency';
    final tontineWindowDates =
        data['date_ouverture_tontine'] == null
            ? null
            : '${_formatDate(data['date_ouverture_tontine'])} – '
                '${_formatDate(data['date_fermeture_tontine'])}';

    return [
      SizedBox(height: AppDimensions.spaceLg.h),
      _SectionCard(
        title: AppLocalizations.t('savings_details_title'),
        children: [
          _InfoRow(
            label: AppLocalizations.t('community_name_label'),
            value: _value(group['nom'], fallback: widget.community.name),
          ),
          _InfoRow(
            label: AppLocalizations.t('cycle_word'),
            value:
                '${AppLocalizations.t('cycle_word')} ${cycle['numero'] ?? ''} · '
                '${cycle['statut'] == 'EN_COURS' ? AppLocalizations.t('cycle_status_in_progress') : _value(cycle['statut'])}',
          ),
          _InfoRow(
            label: AppLocalizations.t('savings_mode_label'),
            value: AppLocalizations.t(
              isFixed ? 'savings_mode_fixed' : 'savings_mode_free',
            ),
          ),
          _InfoRow(
            label: AppLocalizations.t('savings_amount_rule_label'),
            value: amountRule,
          ),
          _InfoRow(
            label: AppLocalizations.t('savings_balance_label'),
            value: '${_formatAmount(data['solde_disponible'] ?? 0)} $currency',
          ),
          _InfoRow(
            label: AppLocalizations.t('treasurer_phone_label'),
            value: _value(data['telephone_tresorier']),
          ),
          if (tontineWindowDates != null)
            _InfoRow(
              label: AppLocalizations.t('tontine_contribution_window_label'),
              value: tontineWindowDates,
            ),
        ],
      ),
      SizedBox(height: AppDimensions.spaceLg.h),
      _SectionCard(
        title: AppLocalizations.t('savings_deposit_title'),
        children: [
          DropdownButtonFormField<String>(
            value:
                periods.any(
                      (period) => period['value']?.toString() == selectedPeriod,
                    )
                    ? selectedPeriod
                    : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.t('contribution_period_label'),
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final period in periods)
                DropdownMenuItem(
                  value: period['value']?.toString(),
                  child: Text(_formatDate(period['date_echeance'])),
                ),
            ],
            onChanged:
                periods.isEmpty
                    ? null
                    : (value) => setState(() {
                      _selectedSavingsPeriod = value;
                      _paymentMode = null;
                      _receipt = null;
                      _referenceController.clear();
                    }),
          ),
          if (periods.isEmpty) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            Text(
              AppLocalizations.t('savings_no_period_available'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppDimensions.spaceMd.h),
          if (isFixed)
            _InfoRow(
              label: AppLocalizations.t('savings_deposit_amount_label'),
              value:
                  '$amountRule · ${AppLocalizations.t('savings_fixed_amount_hint')}',
            )
          else
            AppTextField(
              label: AppLocalizations.t('savings_deposit_amount_label'),
              hint: AppLocalizations.t('savings_amount_hint'),
              controller: _savingsAmountController,
              suffixText: currency,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
            ),
          if (operation != null) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            _OperationStatus(operation: operation),
          ],
          if (cyclePending && !tontineWindowOpen) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            _OperationStatus(
              message: AppLocalizations.t('contribution_auto_window_notice'),
              icon: Icons.event_outlined,
            ),
          ],
          if (data['epargne_mode'] != 'FIXE' &&
              data['epargne_mode'] != 'LIBRE') ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            _OperationStatus(
              message: AppLocalizations.t('savings_mode_not_configured'),
              icon: Icons.warning_amber_outlined,
            ),
          ],
          if (canSubmit) ...[
            SizedBox(height: AppDimensions.spaceLg.h),
            _buildPaymentSection(
              submitLabel: AppLocalizations.t('submit_savings_deposit'),
              onSubmit: _submitSavings,
            ),
          ],
        ],
      ),
      if ((data['recent_epargne_operations'] as List?)?.isNotEmpty == true) ...[
        SizedBox(height: AppDimensions.spaceLg.h),
        _SectionCard(
          title: AppLocalizations.t('savings_history_title'),
          children: [
            for (final rawOperation
                in (data['recent_epargne_operations'] as List)
                    .whereType<Map>()) ...[
              _HistoryOperation(
                operation: Map<String, dynamic>.from(rawOperation),
              ),
              Divider(
                height: AppDimensions.spaceLg.h,
                color: AppColors.divider,
              ),
            ],
          ],
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final data = _contextData;
    final cycle = _map(data?['cycle']) ?? const <String, dynamic>{};
    final group = _map(cycle['groupe']) ?? const <String, dynamic>{};
    final beneficiary =
        _map(data?['prochain_beneficiaire']) ?? const <String, dynamic>{};
    final operation = _map(data?['current_period_operation']);
    final history =
        (data?['recent_tontine_operations'] as List?)
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
    final period = data?['periode']?.toString();
    final operationStatus =
        operation?['statut']?.toString().toUpperCase() ?? '';
    final canResubmit = operationStatus == 'REJETE';
    final contributionWindowOpen = data?['cotisation_ouverte'] == true;
    final cycleActive = cycle['statut'] == 'EN_COURS';
    final cyclePending = cycle['statut'] == 'EN_ATTENTE';
    final cycleStatusMissing = cycle['statut'] == null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('my_contributions'),
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppDimensions.screenPaddingH.w),
            children: [
              Text(
                AppLocalizations.t('contribution_type_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t('contribution_type_subtitle'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.loop,
                      title: AppLocalizations.t('tontine_label'),
                      subtitle: AppLocalizations.t('tontine_contribution_hint'),
                      enabled: true,
                      selected: _selectedContributionType == 'TONTINE',
                      onTap: _loading ? null : _chooseTontine,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.savings_outlined,
                      title: AppLocalizations.t('savings_label'),
                      subtitle: AppLocalizations.t('savings_contribution_hint'),
                      enabled: true,
                      selected: _selectedContributionType == 'EPARGNE',
                      onTap: _loading ? null : _chooseSavings,
                    ),
                  ),
                ],
              ),
              if (_loading) ...[
                SizedBox(height: AppDimensions.spaceXl.h),
                const Center(child: CircularProgressIndicator()),
              ] else if (_error != null) ...[
                SizedBox(height: AppDimensions.spaceLg.h),
                _ErrorMessage(
                  message: _error!,
                  onRetry:
                      _selectedContributionType == 'EPARGNE'
                          ? _chooseSavings
                          : _chooseTontine,
                ),
              ] else if (data != null &&
                  _selectedContributionType == 'EPARGNE') ...[
                ..._buildSavingsContent(data),
              ] else if (data != null) ...[
                SizedBox(height: AppDimensions.spaceLg.h),
                _SectionCard(
                  title: AppLocalizations.t('tontine_details_title'),
                  children: [
                    _InfoRow(
                      label: AppLocalizations.t('community_name_label'),
                      value: _value(
                        group['nom'],
                        fallback: widget.community.name,
                      ),
                    ),
                    _InfoRow(
                      label: AppLocalizations.t('cycle_word'),
                      value: _value(
                        cycle['nom'],
                        fallback:
                            '${AppLocalizations.t('cycle_word')} ${cycle['numero'] ?? ''}',
                      ),
                    ),
                    _InfoRow(
                      label: AppLocalizations.t('contribution_amount_label'),
                      value:
                          '${_formatAmount(data['montant_cotisation'] ?? data['montant'])} '
                          '${_value(data['devise'], fallback: 'XAF')}',
                    ),
                    _InfoRow(
                      label: AppLocalizations.t('contribution_period_label'),
                      value: _value(data['periode']),
                    ),
                    _InfoRow(
                      label: AppLocalizations.t('due_date_label'),
                      value: _formatDate(data['date_echeance']),
                    ),
                    _InfoRow(
                      label: AppLocalizations.t(
                        'tontine_contribution_window_label',
                      ),
                      value:
                          '${_formatDate(data['date_ouverture_cotisation'])} – '
                          '${_formatDate(data['date_fermeture_cotisation'])}',
                    ),
                    _InfoRow(
                      label: AppLocalizations.t('next_beneficiary'),
                      value: _beneficiaryName(beneficiary),
                    ),
                    _InfoRow(
                      label: AppLocalizations.t('treasurer_phone_label'),
                      value: _value(data['telephone_tresorier']),
                    ),
                  ],
                ),
                if (period == null || period.isEmpty) ...[
                  SizedBox(height: AppDimensions.spaceMd.h),
                  _OperationStatus(
                    message: AppLocalizations.t('tontine_no_upcoming_turn'),
                    icon: Icons.event_busy_outlined,
                  ),
                ],
                if (cyclePending && !contributionWindowOpen) ...[
                  SizedBox(height: AppDimensions.spaceMd.h),
                  _OperationStatus(
                    message: AppLocalizations.t(
                      'contribution_auto_window_notice',
                    ),
                    icon: Icons.event_outlined,
                  ),
                ],
                if (operation != null) ...[
                  SizedBox(height: AppDimensions.spaceMd.h),
                  _OperationStatus(operation: operation),
                ],
                if (!cyclePending &&
                    !contributionWindowOpen &&
                    (data['etat_fenetre_cotisation'] != 'AUCUN_TOUR')) ...[
                  SizedBox(height: AppDimensions.spaceMd.h),
                  _OperationStatus(
                    message: _contributionWindowMessage(data),
                    icon: Icons.event_busy_outlined,
                  ),
                ],
                if (history.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spaceLg.h),
                  _SectionCard(
                    title: AppLocalizations.t('tontine_history_title'),
                    children: [
                      for (var index = 0; index < history.length; index++) ...[
                        _HistoryOperation(operation: history[index]),
                        if (index != history.length - 1)
                          Divider(
                            height: AppDimensions.spaceLg.h,
                            color: AppColors.divider,
                          ),
                      ],
                    ],
                  ),
                ],
                if (period != null &&
                    period.isNotEmpty &&
                    (cycleActive ||
                        ((cyclePending || cycleStatusMissing) &&
                            contributionWindowOpen)) &&
                    contributionWindowOpen &&
                    (operation == null || canResubmit)) ...[
                  SizedBox(height: AppDimensions.spaceLg.h),
                  _buildPaymentSection(
                    submitLabel: AppLocalizations.t('submit_tontine_payment'),
                    onSubmit: _submit,
                  ),
                ],
              ],
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    if (_cycleId == null || _cycleId!.isEmpty) {
      if (_selectedContributionType == 'EPARGNE') {
        await _chooseSavings();
      } else {
        await _chooseTontine();
      }
    } else if (_selectedContributionType == 'EPARGNE') {
      await _loadSavingsContext();
    } else {
      await _loadContext();
    }
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primaryDark : AppColors.textSecondary;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 142),
          padding: EdgeInsets.all(AppDimensions.spaceMd.w),
          decoration: BoxDecoration(
            color: selected ? AppColors.tagMintBg : AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primaryDark : AppColors.inputBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
              SizedBox(height: AppDimensions.spaceXs.h),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spaceMd.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.tagMintBg : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.inputBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: AppDimensions.spaceSm.w),
            Expanded(child: Text(title, style: TextStyle(color: color))),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }
}

class _OperationStatus extends StatelessWidget {
  const _OperationStatus({
    this.operation,
    this.message,
    this.icon = Icons.info_outline,
  });

  final Map<String, dynamic>? operation;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final status = operation?['statut']?.toString().toUpperCase() ?? '';
    final labelKey = switch (status) {
      'VALIDE' => 'tontine_status_validated',
      'REJETE' => 'tontine_status_rejected',
      _ => 'tontine_status_pending',
    };
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.tagMintBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Text(
              message ?? AppLocalizations.t(labelKey),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestPaymentNotice extends StatelessWidget {
  const _TestPaymentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.tagMintBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primaryDark.withValues(alpha: .2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryDark,
            size: 20,
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Text(
              AppLocalizations.t('payment_test_notice'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryOperation extends StatelessWidget {
  const _HistoryOperation({required this.operation});

  final Map<String, dynamic> operation;

  @override
  Widget build(BuildContext context) {
    final status = operation['statut']?.toString().toUpperCase() ?? '';
    final label = switch (status) {
      'VALIDE' => AppLocalizations.t('tontine_status_validated'),
      'REJETE' => AppLocalizations.t('tontine_status_rejected'),
      _ => AppLocalizations.t('tontine_status_pending'),
    };
    final isTestPayment = operation['is_simulation'] == true;
    final amount = num.tryParse(operation['montant']?.toString() ?? '');
    final amountLabel =
        amount == null
            ? operation['montant']?.toString() ?? '—'
            : NumberFormat.decimalPattern(
              AppLocalizations.locale.value,
            ).format(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                operation['periode']?.toString() ?? '—',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$amountLabel XAF',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spaceXs.h),
        Text(
          isTestPayment ? '${AppLocalizations.t('payment_test_badge')} · $label' : label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        if ((operation['motif_rejet']?.toString().trim() ?? '').isNotEmpty) ...[
          SizedBox(height: AppDimensions.spaceXs.h),
          Text(
            operation['motif_rejet'].toString(),
            style: const TextStyle(fontSize: 12, color: AppColors.alertRed),
          ),
        ],
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, style: const TextStyle(color: AppColors.alertRed)),
        SizedBox(height: AppDimensions.spaceSm.h),
        TextButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.t('invite_retry')),
        ),
      ],
    );
  }
}

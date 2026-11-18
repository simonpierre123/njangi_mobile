import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Controllers_distant/CycleActivityController.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleFinanceController.dart';
import '../../../Controllers_distant/CycleHistorySummaryController.dart';
import '../../../Controllers_distant/CycleTontineTourController.dart';
import '../../../Models/Cycle.dart';
import '../../../ModeView/beneficiary_model.dart';
import '../../../ModeView/community_model.dart';
import '../../../ModeView/treasury_model.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';

class CycleDetailRouteArgs {
  const CycleDetailRouteArgs({required this.community, required this.cycle});

  final CommunityModel community;
  final CycleHistoryItem cycle;
}

class CycleDetailPage extends StatefulWidget {
  const CycleDetailPage({
    super.key,
    required this.community,
    required this.selectedCycle,
    required this.onBack,
    required this.onOpenTontineReport,
  });

  final CommunityModel community;
  final CycleHistoryItem selectedCycle;
  final VoidCallback onBack;
  final VoidCallback onOpenTontineReport;

  @override
  State<CycleDetailPage> createState() => _CycleDetailPageState();
}

class _CycleDetailPageState extends State<CycleDetailPage> {
  static const _pageSize = 25;
  static const _sectionKeys = [
    'cycle_detail_overview',
    'cycle_detail_tontine',
    'cycle_detail_savings',
    'cycle_detail_loans',
    'cycle_detail_emergency',
    'cycle_detail_closure',
  ];

  Cycle? _cycle;
  Map<String, dynamic>? _summary;
  List<PassageOrderEntry> _tours = const [];
  final Map<String, List<Map<String, dynamic>>> _history = {};
  final Map<String, int> _historyPages = {};
  final Map<String, bool> _historyHasMore = {};
  final Map<String, bool> _sectionLoading = {};
  final Map<String, String> _sectionErrors = {};
  String? _cycleError;
  String? _summaryError;
  String? _toursError;
  int _selectedSection = 0;
  bool _loading = true;
  int _requestGeneration = 0;

  String get _cycleId => widget.selectedCycle.id;
  String get _currency => _cycle?.currency ?? widget.selectedCycle.currency;

  @override
  void initState() {
    super.initState();
    _loadCycleDetails();
  }

  Future<void> _loadCycleDetails() async {
    final generation = ++_requestGeneration;
    setState(() {
      _loading = true;
      _cycleError = null;
      _summaryError = null;
    });

    final results = await Future.wait<Object?>([
      CycleController.getById(_cycleId),
      CycleHistorySummaryController.load(_cycleId),
    ]);
    if (!mounted || generation != _requestGeneration) return;

    final cycle = results[0] as Cycle?;
    final summary = results[1] as Map<String, dynamic>?;
    setState(() {
      _cycle = cycle;
      _summary = summary;
      _loading = false;
      if (cycle == null) {
        _cycleError = AppLocalizations.t('cycle_detail_load_error');
      }
      if (summary == null) {
        _summaryError = AppLocalizations.t('cycle_detail_summary_error');
      }
    });
    await _loadSection(_selectedSection);
  }

  Future<void> _loadSection(int index, {bool loadMore = false}) async {
    if (index == 0 || index == 5) return;
    final key = _sectionKeys[index];
    if (_sectionLoading[key] == true ||
        (!loadMore &&
            _history.containsKey(key) &&
            _sectionErrors[key] == null) ||
        (_tours.isNotEmpty && index == 1)) {
      return;
    }
    setState(() {
      _sectionLoading[key] = true;
      _sectionErrors.remove(key);
    });
    if (index == 1) {
      final result = await CycleTontineTourController.getForCycle(_cycleId);
      if (!mounted) return;
      final entries = result['entries'];
      setState(() {
        _toursError =
            result['success'] == true && entries is List
                ? null
                : result['message']?.toString() ??
                    AppLocalizations.t('cycle_detail_tours_error');
        _tours =
            entries is List
                ? entries.whereType<PassageOrderEntry>().toList(growable: false)
                : const [];
        _sectionLoading[key] = false;
      });
      return;
    }

    if (index == 4) {
      final page = loadMore ? (_historyPages[key] ?? 1) + 1 : 1;
      final requests = await CycleFinanceController.getEmergencyRequests(
        cycleId: _cycleId,
        page: page,
      );
      if (!mounted) return;
      setState(() {
        if (requests != null) {
          _history[key] = [if (loadMore) ...?_history[key], ...requests];
          _historyPages[key] = page;
          _historyHasMore[key] = requests.length >= _pageSize;
        } else {
          _sectionErrors[key] = AppLocalizations.t(
            'cycle_detail_emergency_error',
          );
        }
        _sectionLoading[key] = false;
      });
      return;
    }

    final type = switch (index) {
      2 => 'epargne',
      3 => 'prets',
      _ => 'cotisations',
    };
    final startDate = index == 1 ? _dateParameter(_cycle?.startDate) : null;
    final page = loadMore ? (_historyPages[key] ?? 1) + 1 : 1;
    final result = await CycleActivityController.getHistory(
      cycleId: _cycleId,
      type: type,
      startDate: startDate,
      page: page,
      perPage: _pageSize,
    );
    if (!mounted) return;
    final items =
        result?['items'] is List
            ? (result!['items'] as List)
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList()
            : null;
    final pagination = _asMap(result?['pagination']);
    setState(() {
      if (items != null) {
        _history[key] = [...?(_history[key]), ...items];
        _historyPages[key] = page;
        _historyHasMore[key] = pagination?['has_more'] == true;
      } else {
        if (!loadMore) _history[key] = [];
        _sectionErrors[key] = AppLocalizations.t('cycle_detail_history_error');
      }
      _sectionLoading[key] = false;
    });
  }

  String? _dateParameter(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  List<Map<String, dynamic>> _maps(dynamic value) =>
      value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : const [];

  int _operationTotal(String type, {String status = 'VALIDE'}) {
    final rows = _maps(_summary?['operations']);
    return rows
        .where((row) => row['type'] == type && row['statut'] == status)
        .fold<int>(
          0,
          (sum, row) =>
              sum + (int.tryParse(row['montant_total']?.toString() ?? '') ?? 0),
        );
  }

  int _operationCountForStatus(String status) => _maps(_summary?['operations'])
      .where((row) => row['statut'] == status)
      .fold<int>(
        0,
        (sum, row) =>
            sum + (int.tryParse(row['nombre']?.toString() ?? '') ?? 0),
      );

  String _amount(num value) =>
      '${NumberFormat.decimalPattern(AppLocalizations.locale.value).format(value)} $_currency';

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '—';
    return DateFormat.yMMMd(AppLocalizations.locale.value).format(date);
  }

  String _statusLabel(dynamic value) {
    final status = value?.toString().toUpperCase() ?? '';
    return switch (status) {
      'VALIDE' ||
      'PAYE' ||
      'APPROUVEE' => AppLocalizations.t('cycle_detail_status_valid'),
      'EN_ATTENTE' ||
      'A_VENIR' => AppLocalizations.t('cycle_detail_status_pending'),
      'REJETE' ||
      'REJETEE' => AppLocalizations.t('cycle_detail_status_rejected'),
      'TERMINEE' || 'CLOTURE' => AppLocalizations.t('cycle_status_closed'),
      _ => status.isEmpty ? '—' : status,
    };
  }

  Future<void> _selectSection(int index) async {
    setState(() => _selectedSection = index);
    await _loadSection(index);
  }

  Future<void> _openTour(PassageOrderEntry tour) async {
    final tourId = tour.tourId;
    if (tourId == null) return;
    final result = await CycleActivityController.getHistory(
      cycleId: _cycleId,
      type: 'cotisations',
      tourId: tourId,
      page: 1,
      perPage: 100,
    );
    if (!mounted) return;
    final operations = _maps(result?['items']);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (sheetContext) => SafeArea(
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.92,
              builder:
                  (context, scrollController) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      Text(
                        AppLocalizations.t(
                          'cycle_detail_tour_title',
                          args: [tour.order],
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: AppLocalizations.t('cycle_detail_beneficiary'),
                        value: tour.name,
                      ),
                      _InfoRow(
                        label: AppLocalizations.t('cycle_detail_due_date'),
                        value: _date(tour.dueDate?.toIso8601String()),
                      ),
                      _InfoRow(
                        label: AppLocalizations.t('cycle_detail_status'),
                        value: _statusLabel(tour.tourStatus),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.t('cycle_detail_contributions'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if (result == null)
                        Text(AppLocalizations.t('cycle_detail_history_error'))
                      else if (operations.isEmpty)
                        Text(AppLocalizations.t('cycle_detail_empty'))
                      else
                        for (final operation in operations)
                          _OperationTile(
                            title:
                                operation['membre_nom']?.toString() ??
                                AppLocalizations.t('member_label'),
                            subtitle:
                                '${_date(operation['date_operation'])} · ${operation['periode'] ?? 'TOUR-${tour.order}'}',
                            amount: _amount(
                              num.tryParse(
                                    operation['montant']?.toString() ?? '',
                                  ) ??
                                  0,
                            ),
                            status: _statusLabel(operation['statut']),
                          ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          widget.onOpenTontineReport();
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(
                          AppLocalizations.t('cycle_detail_open_tour_report'),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycle = _cycle;
    final cycleTitle = AppLocalizations.t(
      'cycle_history_item',
      args: [widget.selectedCycle.number],
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SimpleAppBar(title: cycleTitle, onBack: widget.onBack),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _cycleError != null
              ? _LoadState(message: _cycleError!, onRetry: _loadCycleDetails)
              : Column(
                children: [
                  _CycleHeader(
                    cycle: cycle!,
                    groupName: widget.community.name,
                    dateLabel:
                        '${_date(cycle.startDate?.toIso8601String())} – ${_date(cycle.endDate?.toIso8601String())}',
                    status: _statusLabel(cycle.status),
                  ),
                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: _sectionKeys.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final selected = _selectedSection == index;
                        return ChoiceChip(
                          label: Text(AppLocalizations.t(_sectionKeys[index])),
                          selected: selected,
                          onSelected: (_) => _selectSection(index),
                          selectedColor: AppColors.primaryDark,
                          labelStyle: TextStyle(
                            color:
                                selected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadCycleDetails,
                      child: _buildSection(),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSection() {
    if (_selectedSection == 0) return _buildOverview();
    if (_selectedSection == 1) return _buildTours();
    if (_selectedSection == 5) return _buildClosure();
    final key = _sectionKeys[_selectedSection];
    if (_sectionLoading[key] == true && (_history[key]?.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history[key] == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history[key]!.isEmpty && _sectionErrors[key] != null) {
      return _LoadState(
        message: _sectionErrors[key]!,
        onRetry: () => _loadSection(_selectedSection),
      );
    }
    final entries = _history[key]!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (_sectionErrors[key] != null)
          _InlineError(
            message: _sectionErrors[key]!,
            onRetry:
                () => _loadSection(
                  _selectedSection,
                  loadMore: entries.isNotEmpty,
                ),
          ),
        _SectionSummaryCard(
          title: AppLocalizations.t(key),
          subtitle: AppLocalizations.t(
            _selectedSection == 4
                ? 'cycle_detail_emergency_privacy_note'
                : 'cycle_detail_member_scope_note',
          ),
          value: '${entries.length}',
          valueLabel: AppLocalizations.t('cycle_detail_records'),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          _EmptyState(text: AppLocalizations.t('cycle_detail_empty'))
        else
          for (final operation in entries)
            _OperationTile(
              title: _operationTitle(operation),
              subtitle: _operationSubtitle(operation),
              amount: _amount(
                num.tryParse(operation['montant']?.toString() ?? '') ??
                    num.tryParse(
                      operation['montant_demande']?.toString() ?? '',
                    ) ??
                    0,
              ),
              status: _statusLabel(operation['statut'] ?? operation['status']),
            ),
        if (_historyHasMore[key] == true)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton(
              onPressed:
                  _sectionLoading[key] == true
                      ? null
                      : () => _loadSection(_selectedSection, loadMore: true),
              child: Text(AppLocalizations.t('cycle_detail_load_more')),
            ),
          ),
      ],
    );
  }

  String _operationTitle(Map<String, dynamic> operation) {
    final type = operation['type']?.toString();
    final member = operation['membre_nom']?.toString();
    final requestName = operation['membre_groupe_name']?.toString();
    final person = member ?? requestName;
    if (person != null && person.isNotEmpty) return person;
    return AppLocalizations.t(switch (type) {
      'EPARGNE' => 'cycle_detail_savings',
      'RETRAIT_EPARGNE' => 'cycle_detail_savings_withdrawal',
      'DEMANDE_PRET' => 'cycle_detail_loan_request',
      'DECAISSEMENT_PRET' => 'cycle_detail_loan_disbursement',
      'REMBOURSEMENT_PRET' => 'cycle_detail_loan_repayment',
      _ => 'cycle_detail_operation',
    });
  }

  String _operationSubtitle(Map<String, dynamic> operation) {
    final date = _date(operation['date_operation'] ?? operation['created_at']);
    final period = operation['periode']?.toString();
    return period == null || period.isEmpty ? date : '$date · $period';
  }

  Widget _buildOverview() {
    final totalContributions = _operationTotal('TONTINE');
    final totalSavings =
        _operationTotal('EPARGNE') - _operationTotal('RETRAIT_EPARGNE');
    final loanDisbursed = _operationTotal('DECAISSEMENT_PRET');
    final loanRepaid = _operationTotal('REMBOURSEMENT_PRET');
    final emergency = _operationTotal('SECOURS');
    final values = [
      (AppLocalizations.t('cycle_detail_tontine'), totalContributions),
      (AppLocalizations.t('cycle_detail_savings'), _operationTotal('EPARGNE')),
      (
        AppLocalizations.t('cycle_detail_savings_withdrawal'),
        _operationTotal('RETRAIT_EPARGNE'),
      ),
      (AppLocalizations.t('cycle_detail_loan_disbursement'), loanDisbursed),
      (AppLocalizations.t('cycle_detail_loan_repayment'), loanRepaid),
      (AppLocalizations.t('cycle_detail_emergency'), emergency),
    ];
    const chartColors = [
      AppColors.primaryDark,
      AppColors.secondaryGreen,
      AppColors.gold,
      AppColors.purple,
      AppColors.alertRed,
      AppColors.mediumGreen,
    ];
    final chartValues = [
      for (var index = 0; index < values.length; index++)
        (values[index].$1, values[index].$2, chartColors[index]),
    ].where((value) => value.$2 > 0).toList(growable: false);
    final chartTotal = chartValues.fold<int>(0, (sum, value) => sum + value.$2);
    final contributionsByTour = _maps(_summary?['collecte_par_tour']);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (_summaryError != null)
          _InlineError(message: _summaryError!, onRetry: _loadCycleDetails),
        _SectionSummaryCard(
          title: AppLocalizations.t('cycle_detail_financial_summary'),
          subtitle: AppLocalizations.t('cycle_detail_validated_only'),
          value: _amount(totalContributions + totalSavings),
          valueLabel: AppLocalizations.t('cycle_detail_tontine_savings_total'),
        ),
        const SizedBox(height: 12),
        _DonutBreakdownChart(
          title: AppLocalizations.t('cycle_detail_financial_distribution'),
          total: _amount(chartTotal),
          values: chartValues,
          amountFormatter: _amount,
          emptyLabel: AppLocalizations.t('cycle_detail_chart_empty'),
        ),
        const SizedBox(height: 12),
        _TourContributionChart(
          title: AppLocalizations.t('cycle_detail_tour_contributions_chart'),
          tours: contributionsByTour,
          amountFormatter: _amount,
          emptyLabel: AppLocalizations.t('cycle_detail_chart_empty'),
        ),
        const SizedBox(height: 16),
        _InfoRow(
          label: AppLocalizations.t('cycle_detail_validated_count'),
          value: '${_operationCountForStatus('VALIDE')}',
        ),
        _InfoRow(
          label: AppLocalizations.t('cycle_detail_pending_count'),
          value: '${_operationCountForStatus('EN_ATTENTE')}',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onOpenTontineReport,
          icon: const Icon(Icons.receipt_long_outlined),
          label: Text(AppLocalizations.t('cycle_detail_open_tour_reports')),
        ),
      ],
    );
  }

  Widget _buildTours() {
    final key = _sectionKeys[1];
    if (_sectionLoading[key] == true && _tours.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_toursError != null && _tours.isEmpty) {
      return _LoadState(message: _toursError!, onRetry: () => _loadSection(1));
    }
    if (_tours.isEmpty) {
      return _EmptyState(text: AppLocalizations.t('cycle_detail_empty_tours'));
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _SectionSummaryCard(
          title: AppLocalizations.t('cycle_detail_tours_title'),
          subtitle: AppLocalizations.t('cycle_detail_tour_tap_hint'),
          value: '${_tours.length}',
          valueLabel: AppLocalizations.t('cycle_detail_tours_total'),
        ),
        const SizedBox(height: 12),
        for (final tour in _tours)
          Card(
            color: AppColors.white,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.iconBgMint,
                child: Icon(Icons.repeat, color: AppColors.primaryDark),
              ),
              title: Text(
                AppLocalizations.t(
                  'cycle_detail_tour_title',
                  args: [tour.order],
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${tour.name} · ${_date(tour.dueDate?.toIso8601String())}',
              ),
              trailing: Text(_statusLabel(tour.tourStatus)),
              onTap: () => _openTour(tour),
            ),
          ),
      ],
    );
  }

  Widget _buildClosure() {
    final closure = _asMap(_summary?['cloture']);
    if (closure == null) {
      return _EmptyState(text: AppLocalizations.t('cycle_detail_not_closed'));
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _SectionSummaryCard(
          title: AppLocalizations.t('cycle_detail_closure_title'),
          subtitle: _date(closure['cloture_le']),
          value: '${closure['membres'] ?? 0}',
          valueLabel: AppLocalizations.t('cycle_detail_members_at_closure'),
        ),
        const SizedBox(height: 12),
        _InfoRow(
          label: AppLocalizations.t('cycle_detail_savings_at_closure'),
          value: _amount(
            num.tryParse(closure['solde_epargne']?.toString() ?? '') ?? 0,
          ),
        ),
        _InfoRow(
          label: AppLocalizations.t('cycle_detail_debt_at_closure'),
          value: _amount(
            num.tryParse(closure['dette_pret']?.toString() ?? '') ?? 0,
          ),
        ),
        _InfoRow(
          label: AppLocalizations.t('cycle_detail_payout_at_closure'),
          value: _amount(
            num.tryParse(closure['montant_a_verser']?.toString() ?? '') ?? 0,
          ),
        ),
        _InfoRow(
          label: AppLocalizations.t('cycle_detail_residual_debt'),
          value: _amount(
            num.tryParse(closure['dette_residuelle']?.toString() ?? '') ?? 0,
          ),
        ),
      ],
    );
  }
}

class _CycleHeader extends StatelessWidget {
  const _CycleHeader({
    required this.cycle,
    required this.groupName,
    required this.dateLabel,
    required this.status,
  });

  final Cycle cycle;
  final String groupName;
  final String dateLabel;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.t(
                    'cycle_history_item',
                    args: [cycle.number ?? '—'],
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(
                label: Text(status),
                backgroundColor: AppColors.tagMintBg,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(
            dateLabel,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionSummaryCard extends StatelessWidget {
  const _SectionSummaryCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueLabel,
  });

  final String title;
  final String subtitle;
  final String value;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            valueLabel,
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _DonutBreakdownChart extends StatelessWidget {
  const _DonutBreakdownChart({
    required this.title,
    required this.total,
    required this.values,
    required this.amountFormatter,
    required this.emptyLabel,
  });

  final String title;
  final String total;
  final List<(String, int, Color)> values;
  final String Function(num) amountFormatter;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (values.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    emptyLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: _DonutChartPainter(values: values),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              total,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (label, amount, color) in values)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    amountFormatter(amount),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.values});

  final List<(String, int, Color)> values;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (sum, value) => sum + value.$2);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    final strokeWidth = size.shortestSide * 0.17;
    final chartRect = rect.deflate(strokeWidth / 2);
    var startAngle = -math.pi / 2;
    for (final (_, amount, color) in values) {
      final sweepAngle = amount / total * math.pi * 2;
      canvas.drawArc(
        chartRect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) =>
      !listEquals(oldDelegate.values, values);
}

class _TourContributionChart extends StatelessWidget {
  const _TourContributionChart({
    required this.title,
    required this.tours,
    required this.amountFormatter,
    required this.emptyLabel,
  });

  final String title;
  final List<Map<String, dynamic>> tours;
  final String Function(num) amountFormatter;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final maxAmount = tours.fold<int>(
      0,
      (maximum, tour) => math.max(
        maximum,
        int.tryParse(tour['montant_total']?.toString() ?? '') ?? 0,
      ),
    );

    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (tours.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    emptyLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              SizedBox(
                height: 164,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(320, tours.length * 76).toDouble(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final tour in tours)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      amountFormatter(
                                        int.tryParse(
                                              tour['montant_total']
                                                      ?.toString() ??
                                                  '',
                                            ) ??
                                            0,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor:
                                            maxAmount == 0
                                                ? 0
                                                : ((int.tryParse(
                                                              tour['montant_total']
                                                                      ?.toString() ??
                                                                  '',
                                                            ) ??
                                                            0) /
                                                        maxAmount)
                                                    .clamp(0, 1)
                                                    .toDouble(),
                                        widthFactor: 0.58,
                                        child: DecoratedBox(
                                          decoration: const BoxDecoration(
                                            color: AppColors.secondaryGreen,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(7),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    'T${tour['ordre'] ?? '—'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$subtitle · $status'),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    ),
  );
}

class _LoadState extends StatelessWidget {
  const _LoadState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.t('retry_button')),
          ),
        ],
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.errorContainer,
    child: ListTile(
      title: Text(message),
      trailing: IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
    ),
  );
}

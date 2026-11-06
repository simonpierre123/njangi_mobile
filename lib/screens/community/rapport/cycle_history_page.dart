import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../Controllers_distant/CycleActivityController.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';

class CycleHistoryCategoryPage extends StatelessWidget {
  const CycleHistoryCategoryPage({
    super.key,
    required this.community,
    required this.onBack,
    required this.onSelect,
  });

  final CommunityModel community;
  final VoidCallback onBack;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('cotisations', Icons.groups_outlined, 'history_contributions'),
      ('epargne', Icons.savings_outlined, 'history_savings'),
      ('prets', Icons.account_balance_outlined, 'history_loans'),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('history_choose_type'),
        onBack: onBack,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (type, icon, labelKey) = categories[index];
          return Card(
            color: AppColors.white,
            child: ListTile(
              leading: Icon(icon, color: AppColors.primaryDark),
              title: Text(
                AppLocalizations.t(labelKey),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelect(type),
            ),
          );
        },
      ),
    );
  }
}

class CycleHistoryMenu extends StatelessWidget {
  const CycleHistoryMenu({super.key, required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('cotisations', Icons.groups_outlined, 'history_contributions'),
      ('epargne', Icons.savings_outlined, 'history_savings'),
      ('prets', Icons.account_balance_outlined, 'history_loans'),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.t('history_choose_type'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          for (final (type, icon, labelKey) in categories)
            ListTile(
              leading: Icon(icon, color: AppColors.primaryDark),
              title: Text(AppLocalizations.t(labelKey)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelect(type),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class CycleActivityHistoryPage extends StatefulWidget {
  const CycleActivityHistoryPage({
    super.key,
    required this.community,
    required this.type,
    required this.onBack,
  });

  final CommunityModel community;
  final String type;
  final VoidCallback onBack;

  @override
  State<CycleActivityHistoryPage> createState() =>
      _CycleActivityHistoryPageState();
}

class _CycleActivityHistoryPageState extends State<CycleActivityHistoryPage> {
  static const _perPage = 25;

  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> _tours = const [];
  String? _cycleId;
  String? _tourId;
  String? _period;
  DateTimeRange? _dateRange;
  String? _error;
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _exporting = false;

  String get _titleKey => switch (widget.type) {
    'cotisations' => 'history_contributions',
    'epargne' => 'history_savings',
    _ => 'history_loans',
  };

  @override
  void initState() {
    super.initState();
    _cycleId = widget.community.cycleId;
    _load();
  }

  Future<void> _load({bool reset = true}) async {
    var cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      final current = cycles?.where((cycle) => cycle.status == 'EN_COURS');
      cycleId =
          current?.isNotEmpty == true
              ? current!.first.id
              : cycles?.firstOrNull?.id;
      _cycleId = cycleId;
    }
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.t('history_load_error');
      });
      return;
    }

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final result = await CycleActivityController.getHistory(
      cycleId: cycleId,
      type: widget.type,
      tourId: _tourId,
      period: _period,
      startDate: _dateParameter(_dateRange?.start),
      endDate: _dateParameter(_dateRange?.end),
      page: reset ? 1 : _page + 1,
      perPage: _perPage,
    );
    if (!mounted) return;

    if (result == null) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = AppLocalizations.t('history_load_error');
      });
      return;
    }

    final items = _maps(result['items']);
    final filters = _map(result['filters']) ?? const <String, dynamic>{};
    final pagination = _map(result['pagination']) ?? const <String, dynamic>{};
    final tours = _maps(filters['tours']);

    setState(() {
      _loading = false;
      _loadingMore = false;
      _error = null;
      _items = reset ? items : [..._items, ...items];
      _tours = tours;
      _tourId = filters['selected_tour_id']?.toString();
      _period = filters['selected_periode']?.toString();
      final startDate = DateTime.tryParse(
        filters['selected_date_debut']?.toString() ?? '',
      );
      final endDate = DateTime.tryParse(
        filters['selected_date_fin']?.toString() ?? '',
      );
      _dateRange =
          startDate != null && endDate != null
              ? DateTimeRange(start: startDate, end: endDate)
              : null;
      _page = reset ? 1 : _page + 1;
      _hasMore = pagination['has_more'] == true;
    });
  }

  Future<List<Map<String, dynamic>>> _loadAllForExport() async {
    final cycleId = _cycleId;
    if (cycleId == null) throw StateError('Cycle introuvable.');
    final all = <Map<String, dynamic>>[];
    var page = 1;
    var hasMore = true;
    while (hasMore) {
      final result = await CycleActivityController.getHistory(
        cycleId: cycleId,
        type: widget.type,
        tourId: _tourId,
        period: _period,
        startDate: _dateParameter(_dateRange?.start),
        endDate: _dateParameter(_dateRange?.end),
        page: page,
        perPage: 100,
      );
      if (result == null) {
        throw StateError(AppLocalizations.t('history_load_error'));
      }
      all.addAll(_maps(result['items']));
      final pagination =
          _map(result['pagination']) ?? const <String, dynamic>{};
      hasMore = pagination['has_more'] == true;
      page++;
    }
    return all;
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final rows = await _loadAllForExport();
      final pdf = pw.Document();
      final currency =
          rows.isEmpty ? 'XAF' : (rows.first['devise']?.toString() ?? 'XAF');
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build:
              (context) => [
                pw.Text(
                  '${AppLocalizations.t(_titleKey)} · ${widget.community.name}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${AppLocalizations.t('history_period')}: ${_selectedFilterLabel()}',
                ),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  headers: [
                    AppLocalizations.t('member_label'),
                    AppLocalizations.t('history_operation'),
                    AppLocalizations.t('history_period'),
                    AppLocalizations.t('history_status'),
                    AppLocalizations.t('history_date'),
                    AppLocalizations.t('history_amount'),
                    AppLocalizations.t('history_details'),
                  ],
                  data:
                      rows
                          .map(
                            (row) => [
                              row['membre_nom']?.toString() ?? '—',
                              _operationLabel(row['type']?.toString() ?? ''),
                              row['periode']?.toString() ??
                                  row['date_remboursement_souhaitee']?.toString() ??
                                  '—',
                              _statusLabel(row['statut']?.toString() ?? ''),
                              _dateLabel(row['date_operation']?.toString()),
                              '${_amount(row['montant'])} $currency',
                              row['motif']?.toString() ??
                                  row['reference_paiement']?.toString() ??
                                  row['mode_paiement']?.toString() ??
                                  '—',
                            ],
                          )
                          .toList(),
                  headerStyle: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF176B58),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  cellPadding: const pw.EdgeInsets.all(6),
                ),
              ],
        ),
      );
      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.t('history_export_error')}: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _selectedFilterLabel() {
    final filters = <String>[];
    if (_tourId != null) {
      final tour = _tours.where((item) => item['id']?.toString() == _tourId);
      if (tour.isNotEmpty) filters.add('TOUR-${tour.first['ordre']}');
    }
    if (_dateRange != null) {
      final format = DateFormat('dd/MM/yyyy');
      filters.add(
        '${format.format(_dateRange!.start)} - ${format.format(_dateRange!.end)}',
      );
    }
    if (filters.isNotEmpty) return filters.join(' · ');
    return AppLocalizations.t('history_all_periods');
  }

  String? _dateParameter(DateTime? date) =>
      date == null ? null : DateFormat('yyyy-MM-dd').format(date);

  Future<void> _selectDateRange() async {
    final today = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 10),
      initialDateRange: _dateRange,
      helpText: AppLocalizations.t('history_filter_dates'),
      saveText: AppLocalizations.t('history_apply_dates'),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _dateRange = selected;
      _tourId = null;
    });
    await _load();
  }

  String _operationLabel(String type) => switch (type) {
    'TONTINE' => AppLocalizations.t('history_contributions'),
    'EPARGNE' => AppLocalizations.t('history_savings'),
    'RETRAIT_EPARGNE' => AppLocalizations.t('history_savings_withdrawal'),
    'DEMANDE_PRET' => AppLocalizations.t('history_loan_request'),
    'DECAISSEMENT_PRET' => AppLocalizations.t('history_loan_disbursement'),
    'REMBOURSEMENT_PRET' => AppLocalizations.t('history_loan_repayment'),
    _ => type,
  };

  String _statusLabel(String status) => switch (status) {
    'EN_ATTENTE' => AppLocalizations.t('activity_pending'),
    'VALIDE' || 'APPROUVE' => AppLocalizations.t('activity_validated'),
    'REJETE' || 'REJETEE' => AppLocalizations.t('activity_rejected'),
    _ => status,
  };

  String _dateLabel(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return '—';
    return DateFormat('dd/MM/yyyy', AppLocalizations.locale.value).format(date);
  }

  String _amount(dynamic value) => NumberFormat.decimalPattern(
    AppLocalizations.locale.value,
  ).format(num.tryParse(value?.toString() ?? '') ?? 0);

  List<Map<String, dynamic>> _maps(dynamic value) =>
      value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : const [];

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.t(_titleKey);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SimpleAppBar(title: title, onBack: widget.onBack),
      body: Column(
        children: [
          if (widget.type == 'cotisations' && _tours.isNotEmpty) _tourFilter(),
          _dateRangeFilter(),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _errorView()
                    : _items.isEmpty
                    ? Center(child: Text(AppLocalizations.t('history_empty')))
                    : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 120 &&
                            _hasMore &&
                            !_loadingMore) {
                          _load(reset: false);
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: _items.length + (_loadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= _items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _historyRow(_items[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exporting ? null : _exportPdf,
        icon:
            _exporting
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.picture_as_pdf_outlined),
        label: Text(AppLocalizations.t('history_export_pdf')),
      ),
    );
  }

  Widget _tourFilter() {
    final entries =
        _tours
            .map(
              (tour) => DropdownMenuItem<String>(
                value: tour['id']?.toString(),
                child: Text('TOUR-${tour['ordre'] ?? ''}'),
              ),
            )
            .toList();
    if (_tourId != null && entries.every((item) => item.value != _tourId)) {
      entries.insert(
        0,
        DropdownMenuItem(value: _tourId, child: Text(_selectedFilterLabel())),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: DropdownButtonFormField<String>(
        value: _tourId,
        decoration: InputDecoration(
          labelText: AppLocalizations.t('history_filter_tour'),
          border: const OutlineInputBorder(),
        ),
        items: entries,
        onChanged: (value) {
          setState(() => _tourId = value);
          _load();
        },
      ),
    );
  }

  Widget _dateRangeFilter() {
    final range = _dateRange;
    final label =
        range == null
            ? AppLocalizations.t('history_select_dates')
            : '${DateFormat('dd/MM/yyyy').format(range.start)} - '
                '${DateFormat('dd/MM/yyyy').format(range.end)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (range != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: AppLocalizations.t('clear'),
              onPressed: () {
                setState(() {
                  _dateRange = null;
                  _tourId = null;
                });
                _load();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _load,
            child: Text(AppLocalizations.t('retry')),
          ),
        ],
      ),
    ),
  );

  Widget _historyRow(Map<String, dynamic> item) {
    final amount = _amount(item['montant']);
    final currency = item['devise']?.toString() ?? 'XAF';
    return Card(
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['membre_nom']?.toString() ?? '—',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '$amount $currency',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(_operationLabel(item['type']?.toString() ?? '')),
              const SizedBox(height: 4),
              Text(
                '${_statusLabel(item['statut']?.toString() ?? '')} · '
                '${_dateLabel(item['date_operation']?.toString())}'
                '${item['periode'] == null ? '' : ' · ${item['periode']}'}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDetails(Map<String, dynamic> item) async {
    final proofPath = item['preuve_paiement']?.toString();
    final proofUrl = proofPath == null || proofPath.isEmpty
        ? null
        : _imageUrl(proofPath);
    final details = <(String, String)>[
      (AppLocalizations.t('history_operation'), _operationLabel(item['type']?.toString() ?? '')),
      (AppLocalizations.t('history_status'), _statusLabel(item['statut']?.toString() ?? '')),
      (AppLocalizations.t('history_date'), _dateLabel(item['date_operation']?.toString())),
      (AppLocalizations.t('history_amount'), '${_amount(item['montant'])} ${item['devise'] ?? 'XAF'}'),
      if (item['periode'] != null)
        (AppLocalizations.t('history_period'), item['periode'].toString()),
      if (item['mode_paiement'] != null)
        (AppLocalizations.t('history_payment_method'), item['mode_paiement'].toString()),
      if (item['reference_paiement'] != null)
        (AppLocalizations.t('history_reference'), item['reference_paiement'].toString()),
      if (item['motif'] != null)
        (AppLocalizations.t('history_reason'), item['motif'].toString()),
      if (item['motif_rejet'] != null)
        (AppLocalizations.t('history_rejection_reason'), item['motif_rejet'].toString()),
      if (item['date_remboursement_souhaitee'] != null)
        (AppLocalizations.t('history_repayment_date'), _dateLabel(item['date_remboursement_souhaitee'].toString())),
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['membre_nom']?.toString() ?? '—',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final (label, value) in details)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          label,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(child: Text(value)),
                    ],
                  ),
                ),
              if (proofUrl != null) ...[
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.t('history_payment_proof'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    proofUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      AppLocalizations.t('history_proof_unavailable'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _imageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }
}

class CycleHistoryRouteArgs {
  const CycleHistoryRouteArgs({required this.community, required this.type});

  final CommunityModel community;
  final String type;
}

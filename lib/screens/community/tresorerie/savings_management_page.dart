import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleSavingsManagementController.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import 'widgets/tontine_loading_skeleton.dart';

class SavingsManagementPage extends StatefulWidget {
  const SavingsManagementPage({
    super.key,
    required this.community,
    required this.onBack,
    required this.onOpenHistory,
  });

  final CommunityModel community;
  final VoidCallback onBack;
  final VoidCallback onOpenHistory;

  @override
  State<SavingsManagementPage> createState() => _SavingsManagementPageState();
}

class _SavingsManagementPageState extends State<SavingsManagementPage> {
  String? _cycleId;
  Map<String, dynamic>? _overview;
  String? _error;
  bool _loading = true;
  bool _closing = false;
  String? _reviewingOperationId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    var cycleId = _cycleId ?? widget.community.cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (cycles != null && cycles.isNotEmpty) {
        final active = cycles.where((cycle) => cycle.status == 'EN_COURS');
        cycleId = (active.isEmpty ? cycles.first : active.first).id;
      }
    }
    if (!mounted) return;
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.t('savings_management_load_error');
      });
      return;
    }
    _cycleId = cycleId;
    final result = await CycleSavingsManagementController.load(cycleId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['data'] is Map) {
        _overview = Map<String, dynamic>.from(result['data'] as Map);
        _error = null;
      } else {
        _error =
            result['message']?.toString() ??
            AppLocalizations.t('savings_management_load_error');
      }
    });
  }

  List<Map<String, dynamic>> _maps(dynamic value) =>
      value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : const [];

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _name(Map<String, dynamic>? member) {
    if (member == null) return AppLocalizations.t('member_label');
    final first =
        (member['prenom'] ?? member['first_name'])?.toString().trim() ?? '';
    final last =
        (member['nom'] ?? member['last_name'])?.toString().trim() ?? '';
    final fullName = [first, last].where((part) => part.isNotEmpty).join(' ');
    if (fullName.isNotEmpty) return fullName;
    return member['utilisateur_nom']?.toString() ??
        member['nom_complet']?.toString() ??
        member['name']?.toString() ??
        AppLocalizations.t('member_label');
  }

  String _amount(dynamic value, String currency) {
    final number = num.tryParse(value?.toString() ?? '');
    final formatted =
        number == null
            ? '0'
            : NumberFormat.decimalPattern(
              AppLocalizations.locale.value,
            ).format(number);
    return '$formatted $currency';
  }

  String _dateTime(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '—';
    return DateFormat(
      'dd/MM/yyyy HH:mm',
      AppLocalizations.locale.value,
    ).format(date.toLocal());
  }

  String _imageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }

  String _statusLabel(String? status) => switch (status) {
    'VALIDE' => AppLocalizations.t('savings_status_validated'),
    'REJETE' => AppLocalizations.t('savings_status_rejected'),
    _ => AppLocalizations.t('savings_status_pending'),
  };

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openContribution(Map<String, dynamic> operation) async {
    final member = _map(operation['membre']);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _name(member),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: AppLocalizations.t('savings_archive_amount'),
                      value: _amount(
                        operation['montant'],
                        _overview?['devise']?.toString() ?? 'XAF',
                      ),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('savings_contributed_at'),
                      value: _dateTime(
                        operation['created_at'] ?? operation['date_operation'],
                      ),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('savings_status_label'),
                      value: _statusLabel(operation['statut']?.toString()),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('payment_method_label'),
                      value: operation['mode_paiement']?.toString() ?? '—',
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('payment_reference_label'),
                      value: operation['reference_paiement']?.toString() ?? '—',
                    ),
                    if ((operation['preuve_paiement']?.toString() ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.t('tontine_receipt_label'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl(operation['preuve_paiement'].toString()),
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Text(
                                AppLocalizations.t(
                                  'tontine_receipt_load_error',
                                ),
                              ),
                        ),
                      ),
                    ],
                    if (operation['statut']?.toString() == 'EN_ATTENTE') ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _review(operation, 'VALIDE');
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            AppLocalizations.t('tontine_validate_button'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _review(operation, 'REJETE');
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: Text(
                            AppLocalizations.t('tontine_reject_button'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _review(Map<String, dynamic> operation, String decision) async {
    final cycleId = _cycleId;
    final operationId = operation['id']?.toString();
    if (cycleId == null || operationId == null) return;

    String? reason;
    if (decision == 'REJETE') {
      final reasonController = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(AppLocalizations.t('tontine_reject_title')),
              content: TextField(
                controller: reasonController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('tontine_reject_reason'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppLocalizations.t('cancel_button')),
                ),
                TextButton(
                  onPressed: () {
                    final text = reasonController.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(dialogContext, text);
                    }
                  },
                  child: Text(AppLocalizations.t('tontine_reject_button')),
                ),
              ],
            ),
      );
      reasonController.dispose();
      if (reason == null || reason.isEmpty) return;
    }

    setState(() => _reviewingOperationId = operationId);
    final result = await CycleSavingsManagementController.review(
      cycleId: cycleId,
      operationId: operationId,
      decision: decision,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _reviewingOperationId = null);
    _message(
      result['message']?.toString() ??
          AppLocalizations.t('savings_contribution_review_error'),
    );
    if (result['success'] == true) await _load();
  }

  Future<void> _closePeriod(String period) async {
    if (_closing) return;
    final cycleId = _cycleId;
    if (cycleId == null) {
      _message(AppLocalizations.t('savings_period_close_error'));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.t('savings_close_period_title')),
            content: Text(
              AppLocalizations.t('savings_close_period_confirmation'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(AppLocalizations.t('cancel_button')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(AppLocalizations.t('savings_close_period_button')),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    setState(() => _closing = true);
    final result = await CycleSavingsManagementController.closePeriod(
      cycleId: cycleId,
      period: period,
    );
    if (!mounted) return;
    setState(() => _closing = false);
    _message(
      result['message']?.toString() ??
          AppLocalizations.t('savings_period_close_error'),
    );
    if (result['success'] == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final currency = _overview?['devise']?.toString() ?? 'XAF';
    final period = _map(_overview?['periode_courante']);
    final dashboard = _map(_overview?['tableau_de_bord']) ?? const {};
    final pending = _maps(_overview?['cotisations_en_attente']);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('savings_management_title'),
        onBack: widget.onBack,
      ),
      body:
          _loading
              ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: TontineLoadingSkeleton(
                  variant: TontineLoadingVariant.management,
                ),
              )
              : _error != null
              ? _LoadError(message: _error!, onRetry: _load)
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onOpenHistory,
                      icon: const Icon(Icons.archive_outlined),
                      label: Text(AppLocalizations.t('savings_archives')),
                    ),
                    const SizedBox(height: 16),
                    if (period == null)
                      _EmptyPeriod()
                    else ...[
                      _PeriodCard(
                        period: period['value']?.toString() ?? '—',
                        dueDate: period['date_echeance']?.toString(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _MetricCard(
                      label: AppLocalizations.t('savings_validated_amount'),
                      value: _amount(dashboard['montant_valide'], currency),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: AppLocalizations.t(
                              'savings_validated_count',
                            ),
                            value: '${dashboard['nombre_validees'] ?? 0}',
                            icon: Icons.verified_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: AppLocalizations.t('savings_pending_count'),
                            value: '${dashboard['nombre_en_attente'] ?? 0}',
                            icon: Icons.hourglass_top_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionHeading(
                      title: AppLocalizations.t('savings_pending_title'),
                      count: pending.length,
                    ),
                    if (pending.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AppLocalizations.t('savings_no_pending'),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      for (final operation in pending)
                        _PendingTile(
                          operation: operation,
                          name: _name(_map(operation['membre'])),
                          amount: _amount(operation['montant'], currency),
                          date: _dateTime(
                            operation['created_at'] ??
                                operation['date_operation'],
                          ),
                          isBusy:
                              _reviewingOperationId ==
                              operation['id']?.toString(),
                          onTap: () => _openContribution(operation),
                        ),
                    if (period != null) ...[
                      const SizedBox(height: 12),
                      if (pending.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            AppLocalizations.t('savings_close_pending_blocked'),
                            style: const TextStyle(color: AppColors.alertRed),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              pending.isEmpty && !_closing
                                  ? () =>
                                      _closePeriod(period['value'].toString())
                                  : null,
                          icon:
                              _closing
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.archive_outlined),
                          label: Text(
                            AppLocalizations.t('savings_close_period_button'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}

class SavingsHistoryPage extends StatefulWidget {
  const SavingsHistoryPage({
    super.key,
    required this.community,
    required this.onBack,
  });

  final CommunityModel community;
  final VoidCallback onBack;

  @override
  State<SavingsHistoryPage> createState() => _SavingsHistoryPageState();
}

class _SavingsHistoryPageState extends State<SavingsHistoryPage> {
  String? _cycleId;
  List<Map<String, dynamic>> _archives = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    var cycleId = _cycleId ?? widget.community.cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (cycles != null && cycles.isNotEmpty) {
        final active = cycles.where((cycle) => cycle.status == 'EN_COURS');
        cycleId = (active.isEmpty ? cycles.first : active.first).id;
      }
    }
    if (!mounted) return;
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.t('savings_archives_load_error');
      });
      return;
    }
    _cycleId = cycleId;
    final result = await CycleSavingsManagementController.archives(cycleId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['data'] is List) {
        _archives =
            (result['data'] as List)
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList();
      } else {
        _error =
            result['message']?.toString() ??
            AppLocalizations.t('savings_archives_load_error');
      }
    });
  }

  String _amount(dynamic value, String currency) {
    final number = num.tryParse(value?.toString() ?? '');
    return '${number == null ? '0' : NumberFormat.decimalPattern(AppLocalizations.locale.value).format(number)} $currency';
  }

  String _dateTime(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '—';
    return DateFormat(
      'dd/MM/yyyy HH:mm',
      AppLocalizations.locale.value,
    ).format(date.toLocal());
  }

  Future<void> _openArchive(Map<String, dynamic> archive) async {
    final details = await _loadArchiveDetails(archive);
    if (!mounted || details == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder:
            (pageContext) => _ArchiveDetails(
              archive: details,
              communityName: widget.community.name,
              amount: _amount,
              dateTime: _dateTime,
              onPrint: () => _printArchiveReport(details),
              onOperationTap:
                  (operation) => _showArchivedContributionDetails(
                    pageContext,
                    operation,
                    details['devise']?.toString() ?? 'XAF',
                  ),
            ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _loadArchiveDetails(
    Map<String, dynamic> archive,
  ) async {
    final cycleId = _cycleId;
    final archiveId = archive['id']?.toString();
    if (cycleId == null || archiveId == null) return null;
    final result = await CycleSavingsManagementController.archive(
      cycleId: cycleId,
      archiveId: archiveId,
    );
    if (!mounted) return null;
    if (result['success'] != true || result['data'] is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                AppLocalizations.t('savings_archives_load_error'),
          ),
        ),
      );
      return null;
    }
    return Map<String, dynamic>.from(result['data'] as Map);
  }

  Future<void> _printArchiveFromList(Map<String, dynamic> archive) async {
    final details = await _loadArchiveDetails(archive);
    if (!mounted || details == null) return;
    await _printArchiveReport(details);
  }

  Future<void> _printArchiveReport(Map<String, dynamic> archive) async {
    final currency = archive['devise']?.toString() ?? 'XAF';
    final operations =
        archive['cotisations'] is List
            ? (archive['cotisations'] as List)
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList()
            : <Map<String, dynamic>>[];
    final closer = _map(archive['clotureur']);
    final closerName =
        closer?['nom_complet']?.toString() ??
        archive['cloture_par_nom']?.toString() ??
        '—';
    final document = pw.Document();
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Geist-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Geist-Bold.ttf'),
    );
    final headingStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromInt(0xFF123C35),
    );

    String personName(Map<String, dynamic>? person) {
      if (person == null) return '—';
      final parts =
          [
            person['prenom']?.toString().trim() ?? '',
            person['nom']?.toString().trim() ?? '',
          ].where((part) => part.isNotEmpty).toList();
      return parts.isEmpty
          ? person['nom_complet']?.toString() ??
              person['utilisateur_nom']?.toString() ??
              '—'
          : parts.join(' ');
    }

    String formattedAmount(dynamic value) {
      final number = num.tryParse(value?.toString() ?? '') ?? 0;
      return '${NumberFormat.decimalPattern(AppLocalizations.locale.value).format(number)} $currency';
    }

    String statusLabel(dynamic status) => switch (status?.toString()) {
      'VALIDE' => AppLocalizations.t('savings_status_validated'),
      'REJETE' => AppLocalizations.t('savings_status_rejected'),
      _ => AppLocalizations.t('savings_status_pending'),
    };

    final generatedAt = DateFormat(
      'dd/MM/yyyy HH:mm',
      AppLocalizations.locale.value,
    ).format(DateTime.now());
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        header:
            (_) => pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey400),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('NJANGI', style: headingStyle),
                  pw.Text(
                    AppLocalizations.t('savings_report_header'),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
              ),
              child: pw.Text(
                '${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ),
        build:
            (context) => [
              pw.SizedBox(height: 18),
              pw.Text(
                AppLocalizations.t('savings_report_title'),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF123C35),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '${AppLocalizations.t('savings_report_community')}: ${widget.community.name}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                '${AppLocalizations.t('savings_period_label')}: ${archive['periode'] ?? '—'}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF0F5F3),
                    ),
                    children: [
                      _pdfSummaryCell(
                        AppLocalizations.t('savings_archive_amount'),
                        formattedAmount(archive['montant_cotise']),
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('savings_archive_count'),
                        '${archive['nombre_epargnes'] ?? operations.length}',
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('savings_archive_validated_count'),
                        '${archive['nombre_validees'] ?? 0}',
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('savings_closed_by'),
                        closerName,
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('savings_closed_at'),
                        _dateTime(archive['cloture_le']),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                AppLocalizations.t('savings_archive_operations'),
                style: headingStyle,
              ),
              pw.SizedBox(height: 8),
              if (operations.isEmpty)
                pw.Text(
                  AppLocalizations.t('savings_archive_no_operations'),
                  style: const pw.TextStyle(fontSize: 10),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: [
                    AppLocalizations.t('member_label'),
                    AppLocalizations.t('savings_archive_amount'),
                    AppLocalizations.t('savings_status_label'),
                    AppLocalizations.t('savings_contributed_at'),
                    AppLocalizations.t('savings_validated_by'),
                    AppLocalizations.t('savings_validated_at'),
                  ],
                  data:
                      operations.map((operation) {
                        final member = _map(operation['membre']);
                        final validator = _map(operation['validateur']);
                        return [
                          personName(member),
                          formattedAmount(operation['montant']),
                          statusLabel(operation['statut']),
                          _dateTime(
                            operation['created_at'] ??
                                operation['date_operation'],
                          ),
                          personName(validator),
                          _dateTime(operation['valide_le']),
                        ];
                      }).toList(),
                  headerStyle: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF123C35),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  cellPadding: const pw.EdgeInsets.all(6),
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  oddRowDecoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAF9),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.25),
                    1: const pw.FlexColumnWidth(1.05),
                    2: const pw.FlexColumnWidth(0.8),
                    3: const pw.FlexColumnWidth(1.1),
                    4: const pw.FlexColumnWidth(1.15),
                    5: const pw.FlexColumnWidth(1.1),
                  },
                ),
              pw.SizedBox(height: 32),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          AppLocalizations.t('savings_treasurer_signature'),
                          style: headingStyle,
                        ),
                        pw.SizedBox(height: 48),
                        pw.Container(
                          width: 220,
                          height: 1,
                          color: PdfColors.grey700,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          AppLocalizations.t('savings_treasurer_name'),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${AppLocalizations.t('savings_report_generated_at')}: $generatedAt',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          AppLocalizations.t('savings_report_read_only'),
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
      ),
    );

    try {
      await Printing.layoutPdf(
        name: 'epargne-${archive['periode'] ?? 'archive'}.pdf',
        onLayout: (_) => document.save(),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      debugPrint('[SAVINGS] PDF printing failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.t('savings_report_print_error')),
        ),
      );
    }
  }

  pw.Widget _pdfSummaryCell(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );

  Future<void> _showArchivedContributionDetails(
    BuildContext pageContext,
    Map<String, dynamic> operation,
    String currency,
  ) async {
    final member = _map(operation['membre']);
    final validator = _map(operation['validateur']);
    await showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _personName(member),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: AppLocalizations.t('savings_archive_amount'),
                      value: _amount(operation['montant'], currency),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('savings_status_label'),
                      value: _statusLabel(operation['statut']?.toString()),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('savings_contributed_at'),
                      value: _dateTime(
                        operation['created_at'] ?? operation['date_operation'],
                      ),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('savings_validated_by'),
                      value: _personName(validator),
                    ),
                    _DetailRow(
                      label: AppLocalizations.t('savings_validated_at'),
                      value: _dateTime(operation['valide_le']),
                    ),
                    if ((operation['reference_paiement']?.toString() ?? '')
                        .isNotEmpty)
                      _DetailRow(
                        label: AppLocalizations.t('payment_reference_label'),
                        value: operation['reference_paiement'].toString(),
                      ),
                    if ((operation['preuve_paiement']?.toString() ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.t('tontine_receipt_label'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl(operation['preuve_paiement'].toString()),
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, error, stackTrace) => Text(
                                AppLocalizations.t(
                                  'tontine_receipt_load_error',
                                ),
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );
  }

  String _personName(Map<String, dynamic>? person) {
    if (person == null) return '—';
    final fullName = [
      person['prenom']?.toString().trim() ?? '',
      person['nom']?.toString().trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    return fullName.isNotEmpty
        ? fullName
        : person['nom_complet']?.toString() ??
            person['utilisateur_nom']?.toString() ??
            '—';
  }

  String _imageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }

  String _statusLabel(String? status) => switch (status) {
    'VALIDE' => AppLocalizations.t('savings_status_validated'),
    'REJETE' => AppLocalizations.t('savings_status_rejected'),
    _ => AppLocalizations.t('savings_status_pending'),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('savings_archives'),
        onBack: widget.onBack,
      ),
      body:
          _loading
              ? const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: TontineLoadingSkeleton(
                  variant: TontineLoadingVariant.history,
                ),
              )
              : _error != null
              ? _LoadError(message: _error!, onRetry: _load)
              : _archives.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.t('savings_archives_empty'),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _archives.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final archive = _archives[index];
                    final currency = archive['devise']?.toString() ?? 'XAF';
                    final closer = _map(archive['clotureur']);
                    final closerName =
                        closer?['nom_complet']?.toString() ??
                        archive['cloture_par_nom']?.toString() ??
                        '—';
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.savings_outlined),
                        ),
                        title: Text(
                          '${AppLocalizations.t('savings_period_label')} '
                          '${archive['periode'] ?? '—'}',
                        ),
                        subtitle: Text(
                          '${_amount(archive['montant_cotise'], currency)} · '
                          '${archive['nombre_epargnes'] ?? 0} '
                          '${AppLocalizations.t('savings_archive_count').toLowerCase()} · '
                          '${archive['nombre_validees'] ?? 0} '
                          '${AppLocalizations.t('savings_validated_count_short')}\n'
                          '${AppLocalizations.t('savings_closed_by')}: $closerName',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: AppLocalizations.t(
                                'savings_print_report',
                              ),
                              onPressed: () => _printArchiveFromList(archive),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => _openArchive(archive),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
}

class _ArchiveDetails extends StatelessWidget {
  const _ArchiveDetails({
    required this.archive,
    required this.communityName,
    required this.amount,
    required this.dateTime,
    required this.onPrint,
    required this.onOperationTap,
  });

  final Map<String, dynamic> archive;
  final String communityName;
  final String Function(dynamic, String) amount;
  final String Function(dynamic) dateTime;
  final VoidCallback onPrint;
  final ValueChanged<Map<String, dynamic>> onOperationTap;

  List<Map<String, dynamic>> _maps(dynamic value) =>
      value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : const [];

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _name(Map<String, dynamic>? user) {
    if (user == null) return '—';
    final fullName = [
      user['prenom']?.toString().trim() ?? '',
      user['nom']?.toString().trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    return fullName.isNotEmpty
        ? fullName
        : user['nom_complet']?.toString() ??
            user['utilisateur_nom']?.toString() ??
            '—';
  }

  @override
  Widget build(BuildContext context) {
    final closer = _map(archive['clotureur']);
    final operations = _maps(archive['cotisations']);
    final currency = archive['devise']?.toString() ?? 'XAF';
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          '${AppLocalizations.t('savings_period_label')} '
          '${archive['periode'] ?? '—'}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.t('savings_print_report'),
            onPressed: onPrint,
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            communityName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _MetricCard(
            label: AppLocalizations.t('savings_archive_amount'),
            value: amount(archive['montant_cotise'], currency),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: AppLocalizations.t('savings_archive_count'),
                  value: '${archive['nombre_epargnes'] ?? operations.length}',
                  icon: Icons.savings_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: AppLocalizations.t('savings_archive_validated_count'),
                  value: '${archive['nombre_validees'] ?? 0}',
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: AppLocalizations.t('savings_closed_by'),
            value:
                closer?['nom_complet']?.toString() ??
                archive['cloture_par_nom']?.toString() ??
                '—',
          ),
          _DetailRow(
            label: AppLocalizations.t('savings_closed_at'),
            value: dateTime(archive['cloture_le']),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print_outlined),
              label: Text(AppLocalizations.t('savings_print_report')),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeading(
            title: AppLocalizations.t('savings_archive_operations'),
            count: operations.length,
          ),
          const SizedBox(height: 8),
          if (operations.isEmpty)
            Text(AppLocalizations.t('savings_archive_no_operations'))
          else
            for (final operation in operations)
              _ArchiveOperationCard(
                operation: operation,
                memberName: _name(_map(operation['membre'])),
                validatorName: _name(_map(operation['validateur'])),
                amount: amount(operation['montant'], currency),
                dateTime: dateTime,
                onTap: () => onOperationTap(operation),
              ),
        ],
      ),
    );
  }
}

class _ArchiveOperationCard extends StatelessWidget {
  const _ArchiveOperationCard({
    required this.operation,
    required this.memberName,
    required this.validatorName,
    required this.amount,
    required this.dateTime,
    required this.onTap,
  });

  final Map<String, dynamic> operation;
  final String memberName;
  final String validatorName;
  final String amount;
  final String Function(dynamic) dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
      title: Text(
        memberName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '$amount · ${AppLocalizations.t('savings_status_label')}: '
        '${switch (operation['statut']?.toString()) {
          'VALIDE' => AppLocalizations.t('savings_status_validated'),
          'REJETE' => AppLocalizations.t('savings_status_rejected'),
          _ => AppLocalizations.t('savings_status_pending'),
        }}\n'
        '${AppLocalizations.t('savings_validated_by')}: $validatorName',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.period, required this.dueDate});

  final String period;
  final String? dueDate;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(dueDate ?? '');
    final formatted =
        date == null
            ? '—'
            : DateFormat.yMMMd(AppLocalizations.locale.value).format(date);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t('savings_open_period'),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            period,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.t('savings_period_due_date')}: $formatted',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.inputBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryDark, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({
    required this.operation,
    required this.name,
    required this.amount,
    required this.date,
    required this.isBusy,
    required this.onTap,
  });

  final Map<String, dynamic> operation;
  final String name;
  final String amount;
  final String date;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(name),
      subtitle: Text('$amount · $date'),
      trailing:
          isBusy
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.chevron_right),
      onTap: isBusy ? null : onTap,
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      CircleAvatar(
        radius: 13,
        backgroundColor: AppColors.tagMintBg,
        child: Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}

class _EmptyPeriod extends StatelessWidget {
  const _EmptyPeriod();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Text(
        AppLocalizations.t('savings_no_open_period'),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

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
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.t('invite_retry')),
          ),
        ],
      ),
    ),
  );
}

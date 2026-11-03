import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleTontineManagementController.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import 'widgets/tontine_loading_skeleton.dart';

class TontineHistoryPage extends StatefulWidget {
  const TontineHistoryPage({
    super.key,
    required this.community,
    required this.onBack,
  });

  final CommunityModel community;
  final VoidCallback onBack;

  @override
  State<TontineHistoryPage> createState() => _TontineHistoryPageState();
}

class _TontineHistoryPageState extends State<TontineHistoryPage> {
  Map<String, dynamic>? _overview;
  String? _cycleId;
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
        _error = AppLocalizations.t('tontine_management_load_error');
      });
      return;
    }
    _cycleId = cycleId;
    final result = await CycleTontineManagementController.load(cycleId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['data'] is Map) {
        _overview = Map<String, dynamic>.from(result['data'] as Map);
      } else {
        _error =
            result['message']?.toString() ??
            AppLocalizations.t('tontine_management_load_error');
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
    final user = _map(member['utilisateur']) ?? _map(member['user']);
    if (user != null) return _name(user);
    final first =
        (member['prenom'] ?? member['first_name'])?.toString().trim() ?? '';
    final last =
        (member['nom'] ?? member['last_name'])?.toString().trim() ?? '';
    final fullName = [first, last].where((part) => part.isNotEmpty).join(' ');
    return fullName.isEmpty
        ? member['nom_complet']?.toString() ??
            member['name']?.toString() ??
            member['utilisateur_nom']?.toString() ??
            AppLocalizations.t('member_label')
        : fullName;
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

  String _validatorName(Map<String, dynamic> operation) {
    final validator =
        _map(operation['validateur']) ??
        _map(operation['valideur']) ??
        _map(operation['valide_par']) ??
        _map(operation['utilisateur_validateur']) ??
        _map(operation['valide_par_utilisateur']);
    if (validator != null) return _name(validator);
    for (final key in [
      'validateur_nom',
      'valideur_nom',
      'nom_validateur',
      'valide_par_nom',
    ]) {
      final name = operation[key]?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    final validatorId =
        operation['valide_par']?.toString() ??
        operation['validateur_id']?.toString();
    if (validatorId != null && validatorId.isNotEmpty) {
      for (final member in _maps(_overview?['membres'])) {
        final user = _map(member['utilisateur']) ?? _map(member['user']);
        final memberIds = [
          member['utilisateur_id'],
          member['user_id'],
          member['id'],
          user?['id'],
        ].whereType<Object>().map((id) => id.toString());
        if (memberIds.contains(validatorId)) return _name(member);
      }
    }
    return '—';
  }

  String _imageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }

  Future<void> _showArchive(Map<String, dynamic> tour) async {
    final currency = _overview?['devise']?.toString() ?? 'XAF';
    final contributions = _maps(tour['cotisations']);
    final isArchived = tour['date_cloture'] != null || tour['statut'] == 'PAYE';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => SafeArea(
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.72,
              maxChildSize: 0.94,
              builder:
                  (context, scrollController) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '${AppLocalizations.t('tontine_history_period')} '
                        'TOUR-${tour['ordre'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.t('tontine_archive_read_only')} '
                        '· ${tour['date_cloture'] ?? tour['paye_le'] ?? '—'}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      if (isArchived) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _printTontineReport(tour),
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: Text(
                              AppLocalizations.t('tontine_print_report'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (contributions.isEmpty)
                        Text(
                          AppLocalizations.t(
                            'tontine_archive_no_contributions',
                          ),
                        )
                      else
                        for (final operation in contributions)
                          _ArchivedContribution(
                            name: _name(_map(operation['membre'])),
                            amount: _amount(operation['montant'], currency),
                            status: operation['statut']?.toString() ?? '',
                            contributionDate: _dateTime(
                              operation['created_at'] ??
                                  operation['date_cotisation'] ??
                                  operation['cotise_le'],
                            ),
                            validatorName: _validatorName(operation),
                            validationDate: _dateTime(
                              operation['valide_le'] ??
                                  operation['date_validation'],
                            ),
                            receipt: operation['preuve_paiement']?.toString(),
                            imageUrl: _imageUrl,
                          ),
                    ],
                  ),
            ),
          ),
    );
  }

  Future<void> _printTontineReport(Map<String, dynamic> tour) async {
    if (tour['date_cloture'] == null && tour['statut'] != 'PAYE') return;

    final currency = _overview?['devise']?.toString() ?? 'XAF';
    final contributions = _maps(tour['cotisations']);
    final validated =
        contributions
            .where((operation) => operation['statut'] == 'VALIDE')
            .toList();
    final total = validated.fold<num>(
      0,
      (sum, operation) =>
          sum + (num.tryParse(operation['montant']?.toString() ?? '') ?? 0),
    );
    final beneficiary = _map(tour['beneficiaire']);
    final document = pw.Document();
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Geist-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Geist-Bold.ttf'),
    );
    final brandColor = PdfColor.fromInt(0xFF123C35);
    final headingStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: brandColor,
    );

    String formattedAmount(dynamic value) {
      final amount = num.tryParse(value?.toString() ?? '') ?? 0;
      return '${NumberFormat.decimalPattern(AppLocalizations.locale.value).format(amount)} $currency';
    }

    String statusLabel(dynamic status) => switch (status?.toString()) {
      'VALIDE' => AppLocalizations.t('tontine_status_validated'),
      'REJETE' => AppLocalizations.t('tontine_status_rejected'),
      _ => AppLocalizations.t('tontine_status_pending'),
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
                  pw.Text(
                    'NJANGI',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                  pw.Text(
                    AppLocalizations.t('tontine_report_header'),
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
            (_) => [
              pw.SizedBox(height: 18),
              pw.Text(
                AppLocalizations.t('tontine_report_title'),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${AppLocalizations.t('savings_report_community')}: ${widget.community.name}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                '${AppLocalizations.t('tontine_history_period')}: TOUR-${tour['ordre'] ?? ''}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                '${AppLocalizations.t('tontine_report_beneficiary')}: ${_name(beneficiary)}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF0F5F3),
                    ),
                    children: [
                      _pdfSummaryCell(
                        AppLocalizations.t('tontine_report_total'),
                        formattedAmount(total),
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('tontine_report_contributions'),
                        '${validated.length}',
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('tontine_report_paid_at'),
                        _dateTime(tour['paye_le']),
                      ),
                      _pdfSummaryCell(
                        AppLocalizations.t('tontine_archive_closed_at'),
                        _dateTime(tour['date_cloture']),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                AppLocalizations.t('tontine_report_contribution_details'),
                style: headingStyle,
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.t('member_label'),
                  AppLocalizations.t('tontine_report_amount'),
                  AppLocalizations.t('tontine_report_status'),
                  AppLocalizations.t('tontine_contributed_at'),
                  AppLocalizations.t('tontine_validated_by'),
                  AppLocalizations.t('tontine_validated_at'),
                ],
                data:
                    contributions.map((operation) {
                      final member = _map(operation['membre']);
                      return [
                        _name(member),
                        formattedAmount(operation['montant']),
                        statusLabel(operation['statut']),
                        _dateTime(
                          operation['created_at'] ??
                              operation['date_operation'],
                        ),
                        _name(_map(operation['validateur'])),
                        _dateTime(operation['valide_le']),
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: brandColor),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellPadding: const pw.EdgeInsets.all(6),
                border: pw.TableBorder.all(color: PdfColors.grey300),
                oddRowDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF8FAF9),
                ),
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
                          AppLocalizations.t('tontine_report_paid_note'),
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
      final groupName = widget.community.name
          .trim()
          .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-')
          .replaceAll(RegExp(r'\s+'), '-');
      await Printing.layoutPdf(
        name: 'tontine-$groupName-tour-${tour['ordre'] ?? 'archive'}.pdf',
        onLayout: (_) => document.save(),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      debugPrint('[TONTINE] PDF printing failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.t('tontine_report_print_error')),
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

  @override
  Widget build(BuildContext context) {
    final tours =
        _maps(_overview?['tours'])
            .where(
              (tour) =>
                  tour['date_cloture'] != null || tour['statut'] == 'PAYE',
            )
            .toList()
          ..sort(
            (a, b) => (int.tryParse(b['ordre']?.toString() ?? '') ?? 0)
                .compareTo(int.tryParse(a['ordre']?.toString() ?? '') ?? 0),
          );
    final currency = _overview?['devise']?.toString() ?? 'XAF';

    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.t('tontine_archive_title'),
        onBack: widget.onBack,
      ),
      body:
          _loading
              ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: const TontineLoadingSkeleton(
                  variant: TontineLoadingVariant.history,
                ),
              )
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _load,
                        child: Text(AppLocalizations.t('invite_retry')),
                      ),
                    ],
                  ),
                ),
              )
              : tours.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.t('tontine_history_empty'),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tours.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    final contributions = _maps(tour['cotisations']);
                    final validated = contributions.where(
                      (operation) => operation['statut'] == 'VALIDE',
                    );
                    final total = validated.fold<num>(
                      0,
                      (sum, operation) =>
                          sum +
                          (num.tryParse(
                                operation['montant']?.toString() ?? '',
                              ) ??
                              0),
                    );
                    final closedAt =
                        tour['date_cloture']?.toString() ??
                        tour['paye_le']?.toString() ??
                        '—';
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.archive_outlined),
                            ),
                            title: Text(
                              '${AppLocalizations.t('tontine_history_period')} '
                              'TOUR-${tour['ordre'] ?? ''}',
                            ),
                            subtitle: Text(
                              '${AppLocalizations.t('tontine_archive_closed_at')}: '
                              '$closedAt\n'
                              '${validated.length} · ${_amount(total, currency)}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showArchive(tour),
                          ),
                          if (tour['date_cloture'] != null ||
                              tour['statut'] == 'PAYE')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: OutlinedButton.icon(
                                onPressed: () => _printTontineReport(tour),
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: Text(
                                  AppLocalizations.t('tontine_print_report'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class _ArchivedContribution extends StatelessWidget {
  const _ArchivedContribution({
    required this.name,
    required this.amount,
    required this.status,
    required this.contributionDate,
    required this.validatorName,
    required this.validationDate,
    required this.receipt,
    required this.imageUrl,
  });

  final String name;
  final String amount;
  final String status;
  final String contributionDate;
  final String validatorName;
  final String validationDate;
  final String? receipt;
  final String Function(String) imageUrl;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status == 'VALIDE'
                ? AppLocalizations.t('tontine_status_validated')
                : status == 'REJETE'
                ? AppLocalizations.t('tontine_status_rejected')
                : AppLocalizations.t('tontine_status_pending'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          _ArchiveDetailRow(
            label: AppLocalizations.t('tontine_contributed_at'),
            value: contributionDate,
          ),
          _ArchiveDetailRow(
            label: AppLocalizations.t('tontine_validated_by'),
            value: validatorName,
          ),
          _ArchiveDetailRow(
            label: AppLocalizations.t('tontine_validated_at'),
            value: validationDate,
          ),
          if ((receipt ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl(receipt!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Text(AppLocalizations.t('tontine_receipt_load_error')),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _ArchiveDetailRow extends StatelessWidget {
  const _ArchiveDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../ModeView/treasury_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

class ContributionReceiptPage extends StatelessWidget {
  const ContributionReceiptPage({super.key, required this.receipt});

  final ContributionReceipt receipt;

  String _dateLabel(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return value ?? '—';
    return DateFormat.yMMMd(AppLocalizations.locale.value).format(date);
  }

  String _dateTimeLabel(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return value ?? '—';
    return DateFormat.yMMMd(
      AppLocalizations.locale.value,
    ).add_jm().format(date);
  }

  String _paymentModeLabel(String? value) => switch (value) {
    'MOBILE_MONEY' => AppLocalizations.t('mobile_money'),
    'ESPECES' => AppLocalizations.t('cash_payment'),
    null || '' => '—',
    _ => value,
  };

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final document = pw.Document();
      final rows = <(String, String)>[
        (
          AppLocalizations.t('receipt_number_label'),
          receipt.operationId ?? '—',
        ),
        if (receipt.isSimulation)
          (
            AppLocalizations.t('payment_record_type_label'),
            AppLocalizations.t('simulated_contribution_notice'),
          ),
        (AppLocalizations.t('group_label'), receipt.groupName ?? '—'),
        (AppLocalizations.t('cycle_label'), receipt.cycleLabel ?? '—'),
        (AppLocalizations.t('period_label'), receipt.period ?? '—'),
        (AppLocalizations.t('date_word'), _dateLabel(receipt.operationDate)),
        (
          AppLocalizations.t('payment_method_label'),
          _paymentModeLabel(receipt.paymentMode),
        ),
        (AppLocalizations.t('payment_operator_label'), receipt.operator ?? '—'),
        (
          AppLocalizations.t('reference_label'),
          receipt.paymentReference ?? '—',
        ),
        (
          AppLocalizations.t('validated_at_label'),
          _dateTimeLabel(receipt.validatedAt),
        ),
        (
          AppLocalizations.t('validated_by_label'),
          receipt.validatorName ?? '—',
        ),
      ];

      final regularFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Geist-Regular.ttf'),
      );
      final boldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Geist-Bold.ttf'),
      );
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'NJANGI',
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFF1E5E4E),
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    AppLocalizations.t('contribution_receipt_title'),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(receipt.title),
                  pw.SizedBox(height: 18),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF2F9F7),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(AppLocalizations.t('amount_label')),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          receipt.amount,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  for (final (label, value) in rows)
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 9),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.grey300),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(label),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                            child: pw.Text(
                              value,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  pw.SizedBox(height: 18),
                  pw.Text(
                    AppLocalizations.t('receipt_generated_note'),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
        ),
      );
      await Printing.layoutPdf(onLayout: (_) async => document.save());
    } catch (error) {
      debugPrint('[Receipt] PDF export failed: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.t('receipt_export_error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      (AppLocalizations.t('receipt_number_label'), receipt.operationId ?? '—'),
      if (receipt.isSimulation)
        (
          AppLocalizations.t('payment_record_type_label'),
          AppLocalizations.t('simulated_contribution_notice'),
        ),
      (AppLocalizations.t('group_label'), receipt.groupName ?? '—'),
      (AppLocalizations.t('cycle_label'), receipt.cycleLabel ?? '—'),
      (AppLocalizations.t('period_label'), receipt.period ?? '—'),
      (AppLocalizations.t('date_word'), _dateLabel(receipt.operationDate)),
      (
        AppLocalizations.t('payment_method_label'),
        _paymentModeLabel(receipt.paymentMode),
      ),
      (AppLocalizations.t('payment_operator_label'), receipt.operator ?? '—'),
      (AppLocalizations.t('reference_label'), receipt.paymentReference ?? '—'),
      (
        AppLocalizations.t('validated_at_label'),
        _dateTimeLabel(receipt.validatedAt),
      ),
      (AppLocalizations.t('validated_by_label'), receipt.validatorName ?? '—'),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        title: Text(AppLocalizations.t('contribution_receipt_title')),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH.w),
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceLg.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        color: AppColors.primaryDark,
                        size: 38,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.t('contribution_validated'),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (receipt.isSimulation) ...[
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.t('simulated_contribution_notice'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        receipt.amount,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        receipt.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final (label, value) in rows)
                  _ReceiptDetailRow(label: label, value: value),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          AppButton(
            label: AppLocalizations.t('export_receipt_pdf'),
            icon: Icons.picture_as_pdf_outlined,
            iconLeading: true,
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDetailRow extends StatelessWidget {
  const _ReceiptDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
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

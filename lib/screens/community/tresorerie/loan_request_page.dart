import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:njangi/Controllers_distant/CycleController.dart';
import 'package:njangi/Controllers_distant/CycleLoanRequestController.dart';
import 'package:njangi/Models/Cycle.dart';
import 'package:njangi/ModeView/community_model.dart';
import 'package:njangi/common/basewidget/app_button.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_colors.dart';
import 'package:njangi/utils/app_dimensions.dart';

class LoanRequestPage extends StatefulWidget {
  const LoanRequestPage({super.key, required this.community});

  final CommunityModel community;

  @override
  State<LoanRequestPage> createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends State<LoanRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  Cycle? _cycle;
  DateTime? _repaymentDate;
  bool _isLoadingCycle = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCycle();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadCycle() async {
    if (mounted) {
      setState(() {
        _isLoadingCycle = true;
        _loadError = null;
      });
    }
    final communityCycleId = widget.community.cycleId;
    Cycle? cycle;
    if (communityCycleId != null && communityCycleId.isNotEmpty) {
      cycle = await CycleController.getById(communityCycleId);
    } else {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (cycles != null) {
        for (final candidate in cycles) {
          if (candidate.status?.trim().toUpperCase() == 'EN_COURS' &&
              candidate.id != null &&
              candidate.id!.isNotEmpty) {
            cycle = await CycleController.getById(candidate.id!);
            break;
          }
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _cycle = cycle;
      _isLoadingCycle = false;
      _loadError =
          cycle == null
              ? AppLocalizations.t('loan_request_cycle_load_error')
              : null;
    });
  }

  DateTime? get _maximumRepaymentDate {
    final duration = _cycle?.maxLoanDuration;
    if (duration == null || duration < 1) return null;
    final today = DateUtils.dateOnly(DateTime.now());
    final targetMonth = today.month - 1 + duration;
    final year = today.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;
    final finalDay = DateUtils.getDaysInMonth(year, month);
    return DateTime(year, month, today.day > finalDay ? finalDay : today.day);
  }

  bool get _loanModuleAvailable => _cycle?.loanModuleActive == '1';

  Future<void> _chooseRepaymentDate() async {
    final maxDate = _maximumRepaymentDate;
    if (maxDate == null) return;
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _repaymentDate ?? maxDate,
      firstDate: today,
      lastDate: maxDate,
      helpText: AppLocalizations.t('loan_request_repayment_date_label'),
    );
    if (selected != null && mounted) {
      setState(() => _repaymentDate = DateUtils.dateOnly(selected));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cycle = _cycle;
    final cycleId = cycle?.id;
    final amount = int.tryParse(_amountController.text.trim());
    final date = _repaymentDate;
    final maxDate = _maximumRepaymentDate;
    if (cycle == null ||
        cycleId == null ||
        amount == null ||
        date == null ||
        maxDate == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await CycleLoanRequestController.submit(
      groupId: widget.community.id,
      cycleId: cycleId,
      amount: amount,
      repaymentDate: date,
      reason: _reasonController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    final message =
        result['message']?.toString() ??
        AppLocalizations.t('loan_request_submit_error');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (result['success'] == true) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.t('request_loan')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child:
            _isLoadingCycle
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? _ErrorState(message: _loadError!, onRetry: _loadCycle)
                : !_loanModuleAvailable
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.spaceLg.w),
                    child: Text(
                      AppLocalizations.t('loan_request_unavailable'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    final cycle = _cycle!;
    final maxDate = _maximumRepaymentDate;
    final maxAmount = cycle.maxLoanAmount;
    final currency = cycle.currency == 'XAF' ? 'FCFA' : cycle.currency ?? '';
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (maxAmount != null &&
                maxAmount > 0 &&
                cycle.maxLoanDuration != null &&
                cycle.maxLoanDuration! > 0)
              Text(
                AppLocalizations.t(
                  'loan_request_rules_description',
                  args: [
                    NumberFormat.decimalPattern(
                      AppLocalizations.locale.value,
                    ).format(maxAmount),
                    currency,
                    cycle.maxLoanDuration!,
                  ],
                ),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            SizedBox(height: AppDimensions.spaceLg.h),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.t('loan_request_amount_label'),
                suffixText: currency,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = int.tryParse(value?.trim() ?? '');
                if (amount == null || amount < 1) {
                  return AppLocalizations.t('loan_request_amount_invalid');
                }
                if (maxAmount != null && amount > maxAmount) {
                  return AppLocalizations.t(
                    'loan_request_amount_exceeds_limit',
                    args: [
                      NumberFormat.decimalPattern(
                        AppLocalizations.locale.value,
                      ).format(maxAmount),
                      currency,
                    ],
                  );
                }
                return null;
              },
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            InkWell(
              onTap: maxDate == null ? null : _chooseRepaymentDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.t(
                    'loan_request_repayment_date_label',
                  ),
                  errorText:
                      maxDate == null
                          ? AppLocalizations.t(
                            'loan_request_duration_not_configured',
                          )
                          : _repaymentDate == null
                          ? AppLocalizations.t(
                            'loan_request_repayment_date_required',
                          )
                          : null,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _repaymentDate == null
                      ? AppLocalizations.t('select_date')
                      : DateFormat.yMMMd(
                        AppLocalizations.locale.value,
                      ).format(_repaymentDate!),
                ),
              ),
            ),
            if (maxDate != null) ...[
              SizedBox(height: AppDimensions.spaceSm.h),
              Text(
                AppLocalizations.t(
                  'loan_request_latest_repayment_date',
                  args: [
                    DateFormat.yMMMd(
                      AppLocalizations.locale.value,
                    ).format(maxDate),
                  ],
                ),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            SizedBox(height: AppDimensions.spaceMd.h),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppLocalizations.t('loan_request_reason_label'),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: AppDimensions.spaceLg.h),
            AppButton(
              label: AppLocalizations.t('loan_request_submit'),
              onPressed:
                  _isSubmitting || maxDate == null || _repaymentDate == null
                      ? null
                      : _submit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            child: Text(AppLocalizations.t('retry')),
          ),
        ],
      ),
    ),
  );
}

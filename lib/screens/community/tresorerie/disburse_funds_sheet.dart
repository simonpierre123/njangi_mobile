import 'package:flutter/material.dart';
import '../../../Models/beneficiary_model.dart';
import '../../../Models/contribution_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/labeled_date_field.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/beneficiary_due_card.dart';
import 'widgets/payment_method_grid.dart';
import 'widgets/receipt_source_grid.dart';

/// Modal "Enregistrer un décaissement" — présenté en bottom sheet
/// (showModalBottomSheet), même traitement que RecordContributionSheet
/// (flou plein écran + hauteur plafonnée gérés par le router).
///
/// TODO (Njoya) : pur front de démonstration — "Confirmer le
/// décaissement" ne persiste rien réellement.
class DisburseFundsSheet extends StatefulWidget {
  const DisburseFundsSheet({
    super.key,
    required this.communityName,
    required this.beneficiary,
    required this.onConfirm,
    required this.onCancel,
  });

  final String communityName;
  final CurrentBeneficiary beneficiary;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<DisburseFundsSheet> createState() => _DisburseFundsSheetState();
}

class _DisburseFundsSheetState extends State<DisburseFundsSheet> {
  late final TextEditingController _amountController = TextEditingController(text: '600 000');
  late final TextEditingController _notesController = TextEditingController();

  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _date = DateTime(2026, 7, 24);
  bool _confirmed = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusCard)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH.w,
              AppDimensions.spaceMd.h,
              AppDimensions.screenPaddingH.w,
              AppDimensions.spaceMd.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.t('record_disbursement_title'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    InkWell(
                      onTap: widget.onCancel,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                Text(widget.communityName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: AppDimensions.spaceLg.h),
                BeneficiaryDueCard(beneficiary: widget.beneficiary),
                SizedBox(height: AppDimensions.spaceLg.h),
                AppTextField(
                  label: AppLocalizations.t('amount_paid_out_label').toUpperCase(),
                  hint: '0',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  suffixText: 'FCFA',
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                Text(
                  AppLocalizations.t('payment_method_label').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                PaymentMethodGrid(selected: _method, onSelect: (m) => setState(() => _method = m)),
                SizedBox(height: AppDimensions.spaceMd.h),
                LabeledDateField(
                  label: AppLocalizations.t('disbursement_date_label').toUpperCase(),
                  value: _date,
                  onChanged: (d) => setState(() => _date = d),
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                Text(
                  AppLocalizations.t('receipt_optional_label').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                ReceiptSourceGrid(onFilePicked: (path) {}),
                SizedBox(height: AppDimensions.spaceMd.h),
                Text(
                  AppLocalizations.t('observation_section').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.t('observation_hint'),
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                InkWell(
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _confirmed,
                        onChanged: (v) => setState(() => _confirmed = v ?? false),
                        activeColor: AppColors.primaryDark,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            AppLocalizations.t('confirm_disbursement_checkbox'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.spaceLg.h),
                AppButton(
                  label: AppLocalizations.t('confirm_disbursement_button'),
                  onPressed: _confirmed
                      ? widget.onConfirm
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.t('confirm_required_message'))),
                          ),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                AppButton(
                  label: AppLocalizations.t('cancel_button'),
                  variant: AppButtonVariant.secondary,
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
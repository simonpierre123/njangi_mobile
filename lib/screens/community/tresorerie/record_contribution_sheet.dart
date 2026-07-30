import 'package:flutter/material.dart';
import '../../../Models/contribution_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/app_segmented_control.dart';
import '../../../common/basewidget/app_text_field.dart';
import '../../../common/basewidget/labeled_date_field.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/attach_receipt_button.dart';
import 'widgets/member_due_card.dart';
import 'widgets/payment_method_grid.dart';

/// Modal "Enregistrer une cotisation" — présenté en bottom sheet
/// (showModalBottomSheet) depuis l'action rapide "Enregistrer
/// Cotisations" du Tableau de Bord admin.
///
/// TODO (Njoya) : pur front de démonstration — "Enregistrer" ne
/// persiste rien réellement, il ferme le modal et affiche la page de
/// détail avec les données mock (Jean Tchoumba), pas les valeurs
/// saisies ici, en attendant l'API.
class RecordContributionSheet extends StatefulWidget {
  const RecordContributionSheet({
    super.key,
    required this.communityName,
    required this.member,
    required this.onSave,
    required this.onCancel,
  });

  final String communityName;
  final ContributionMemberSummary member;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  State<RecordContributionSheet> createState() => _RecordContributionSheetState();
}

class _RecordContributionSheetState extends State<RecordContributionSheet> {
  late final TextEditingController _amountController = TextEditingController(text: '50 000');
  late final TextEditingController _notesController = TextEditingController();

  ContributionStatusInput _status = ContributionStatusInput.paid;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _date = DateTime(2023, 10, 12);

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
                      AppLocalizations.t('record_contribution_title'),
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
                MemberDueCard(member: widget.member),
                SizedBox(height: AppDimensions.spaceLg.h),
                Text(
                  AppLocalizations.t('status_contribution_label').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                AppSegmentedControl(
                  labels: [
                    AppLocalizations.t('status_paid'),
                    AppLocalizations.t('status_partial'),
                    AppLocalizations.t('status_unpaid'),
                  ],
                  currentIndex: _status.index,
                  onChanged: (i) => setState(() => _status = ContributionStatusInput.values[i]),
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                AppTextField(
                  label: AppLocalizations.t('amount_received_label').toUpperCase(),
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
                  label: AppLocalizations.t('payment_date_label').toUpperCase(),
                  value: _date,
                  onChanged: (d) => setState(() => _date = d),
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                Text(
                  AppLocalizations.t('receipt_optional_label').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                SizedBox(height: AppDimensions.spaceSm.h),
                // TODO (Njoya) : aucun vrai sélecteur de fichier branché.
                AttachReceiptButton(onFilePicked: (path) {}),
                SizedBox(height: AppDimensions.spaceMd.h),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.t('notes_hint'),
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
                SizedBox(height: AppDimensions.spaceLg.h),
                AppButton(label: AppLocalizations.t('save_button'), onPressed: widget.onSave),
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
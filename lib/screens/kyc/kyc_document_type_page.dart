import 'package:flutter/material.dart';
import '../../Models/kyc_model.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/kyc_checklist_box.dart';
import 'widgets/kyc_document_option_card.dart';

/// KYC — Étape 2/4 : choix du type de document.
///
/// Un seul SingleChildScrollView (contenu + boutons ensemble) plutôt
/// qu'un Column/Expanded séparant contenu scrollable et boutons fixes
/// — ce dernier laissait un grand vide entre la dernière carte et le
/// bouton quand le contenu était plus court que l'écran.
class KycDocumentTypePage extends StatefulWidget {
  const KycDocumentTypePage({
    super.key,
    required this.options,
    required this.onBack,
    required this.onContinue,
  });

  final List<KycDocumentOption> options;
  final VoidCallback onBack;
  final ValueChanged<KycDocumentTypeId> onContinue;

  @override
  State<KycDocumentTypePage> createState() => _KycDocumentTypePageState();
}

class _KycDocumentTypePageState extends State<KycDocumentTypePage> {
  late KycDocumentTypeId _selected = widget.options.first.id;

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: "${AppLocalizations.t('kyc_verification_title')} 2/4",
        onBack: widget.onBack,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc2_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppLocalizations.t('kyc2_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
              for (var i = 0; i < widget.options.length; i++) ...[
                KycDocumentOptionCard(
                  icon: widget.options[i].icon,
                  title: AppLocalizations.t(widget.options[i].titleKey),
                  subtitle: AppLocalizations.t(widget.options[i].subtitleKey),
                  isSelected: _selected == widget.options[i].id,
                  onTap: () => setState(() => _selected = widget.options[i].id),
                ),
                if (i != widget.options.length - 1) SizedBox(height: AppDimensions.spaceMd.h),
              ],
              SizedBox(height: AppDimensions.spaceXl.h),
              KycChecklistBox(
                title: AppLocalizations.t('kyc_doc_requirements_title'),
                leadingIcon: Icons.info_outline,
                items: [
                  AppLocalizations.t('kyc_doc_req_valid'),
                  AppLocalizations.t('kyc_doc_req_readable'),
                  AppLocalizations.t('kyc_doc_req_not_expired'),
                ],
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
              AppButton(
                label: AppLocalizations.t('continue_button'),
                onPressed: () => widget.onContinue(_selected),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              Center(
                child: GestureDetector(
                  onTap: widget.onBack,
                  child: Text(
                    AppLocalizations.t('back_button'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}
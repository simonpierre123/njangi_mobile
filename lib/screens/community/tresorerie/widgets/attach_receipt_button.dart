import 'package:flutter/material.dart';
import '../../../../common/basewidget/media_source_sheet.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Bouton pilule "Ajouter un reçu" — fonctionnel : ouvre un choix
/// caméra/galerie réel, affiche le nom du fichier une fois choisi.
class AttachReceiptButton extends StatefulWidget {
  const AttachReceiptButton({super.key, this.onFilePicked});

  final ValueChanged<String>? onFilePicked;

  @override
  State<AttachReceiptButton> createState() => _AttachReceiptButtonState();
}

class _AttachReceiptButtonState extends State<AttachReceiptButton> {
  String? _fileName;

  Future<void> _pick() async {
    final file = await showMediaSourceSheet(context);
    if (file == null) return;
    setState(() => _fileName = file.name);
    widget.onFilePicked?.call(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _fileName != null;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: _pick,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceSm.h, horizontal: AppDimensions.spaceSm.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: hasFile ? AppColors.secondaryGreen : AppColors.inputBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                size: 16,
                color: hasFile ? AppColors.secondaryGreen : AppColors.primaryDark,
              ),
              SizedBox(width: AppDimensions.spaceXs.w),
              Flexible(
                child: Text(
                  hasFile ? _fileName! : AppLocalizations.t('add_receipt_button'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasFile ? AppColors.secondaryGreen : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
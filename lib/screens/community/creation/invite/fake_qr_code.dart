import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../utils/app_colors.dart';

class InvitationQrCode extends StatelessWidget {
  const InvitationQrCode({super.key, required this.data, required this.size});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        backgroundColor: AppColors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      ),
    );
  }
}

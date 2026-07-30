import 'package:flutter/material.dart';
import '../Models/kyc_model.dart';

/// Données mock du flux KYC, en attendant l'API.
class KycMockDatasource {
  KycMockDatasource._();

  static const documentOptions = [
    KycDocumentOption(
      id: KycDocumentTypeId.nationalId,
      icon: Icons.badge_outlined,
      titleKey: 'kyc_doc_national_id',
      subtitleKey: 'kyc_doc_national_id_sub',
    ),
    KycDocumentOption(
      id: KycDocumentTypeId.passport,
      icon: Icons.menu_book_outlined,
      titleKey: 'kyc_doc_passport',
      subtitleKey: 'kyc_doc_passport_sub',
    ),
    KycDocumentOption(
      id: KycDocumentTypeId.drivingLicense,
      icon: Icons.directions_car_outlined,
      titleKey: 'kyc_doc_license',
      subtitleKey: 'kyc_doc_license_sub',
    ),
  ];
}
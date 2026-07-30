import 'package:flutter/material.dart';

/// Modèles pour le flux "Vérification d'identité" (KYC), 4 étapes
/// prévues (3 construites pour l'instant, la 4e viendra ensuite).
///
/// TODO (Njoya) : à remplacer par les vraies données de l'API — alimentés
/// pour l'instant par datasource/kyc_mock_datasource.dart.

enum KycDocumentTypeId { nationalId, passport, drivingLicense }

class KycDocumentOption {
  const KycDocumentOption({
    required this.id,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });

  final KycDocumentTypeId id;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
}
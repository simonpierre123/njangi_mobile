import 'package:flutter/widgets.dart';

/// Dimensions de référence issues du Figma. Aucune valeur en dur ne doit
/// apparaître directement dans un écran ou un widget : toujours passer
/// par AppDimensions (valeurs fixes) ou l'extension .w / .h (valeurs
/// adaptées à l'écran réel de l'utilisateur).
class AppDimensions {
  AppDimensions._();

  // Cadre de référence (Figma)
  static const double refWidth = 390;
  static const double refHeight = 884;

  // Composants communs (référence Figma)
  static const double buttonWidth = 350;
  static const double buttonHeight = 52;
  static const double cardWidth = 350;

  // Padding uniforme contenu <-> bords d'écran
  static const double screenPaddingH = 20;
  static const double screenPaddingV = 16;

  // Rayons
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusCard = 20; // cards communauté
  static const double radiusXl = 24; // carte synthèse d'activité

  // Espacements
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
}

/// Scaling responsive basé sur la largeur/hauteur de référence Figma.
/// À initialiser une fois par écran (ou au niveau racine) avant toute
/// utilisation des extensions .w / .h ci-dessous.
class AppScale {
  AppScale._();

  static double _widthScale = 1;
  static double _heightScale = 1;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Le clamp évite un rendu disproportionné sur tablette tout en
    // gardant une échelle fidèle sur téléphone.
    _widthScale = (size.width / AppDimensions.refWidth).clamp(0.85, 1.35);
    _heightScale = (size.height / AppDimensions.refHeight).clamp(0.85, 1.35);
  }

  static double w(double value) => value * _widthScale;
  static double h(double value) => value * _heightScale;
}

/// Usage : 24.w (largeur adaptée) ou 24.h (hauteur adaptée), après
/// AppScale.init(context) exécuté au moins une fois dans l'écran.
extension ResponsiveNum on num {
  double get w => AppScale.w(toDouble());
  double get h => AppScale.h(toDouble());
}
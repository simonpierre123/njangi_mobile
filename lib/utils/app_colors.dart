import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  // ===== Vert principal (marque) =====
  static const Color primary = Color(0xFF41D092);
  static const Color primaryDark = Color(0xFF18624A);
  static const Color primaryDarkAlt = Color(0xFF17624A);
  static const Color primaryDeep = Color(0xFF003022);
  static const Color primaryDeepest = Color(0xFF002116);
  static const Color primaryContainer = Color(0xFF004935);
  static const Color onPrimaryDark = Color(0xFF0E1D26);

  static const Color secondaryGreen = Color(0xFF3AC387);
  static const Color secondaryGreenAlt = Color(0xFF3BB58B);
  static const Color secondaryGreenDeep = Color(0xFF003527);
  static const Color mediumGreen = Color(0xFF3B846C);

  // ===== Verts clairs / surfaces =====
  static const Color mintLight = Color(0xFF95DBBD);
  static const Color mintPale = Color(0xFFAAF1D2);
  static const Color mintSurface = Color(0xFFC9E6D7);
  static const Color mintSurfaceLighter = Color(0xFFE2FAF0);
  static const Color mintSurfaceLightest = Color(0xFFF2F9F7);
  static const Color mintSurfaceAlt = Color(0xFFF1F8F6);

  // ===== Neutres / gris =====
  static const Color neutralDark = Color(0xFF181C1A);
  static const Color neutralGreenGray = Color(0xFF6F7973);
  static const Color neutralGreenGrayLight = Color(0xFF4A6458);
  static const Color neutralGray = Color(0xFF3F4944);
  static const Color neutralGrayLight = Color(0xFFBFC9C2);
  static const Color neutralGrayLighter = Color(0xFFE0E3E0);
  static const Color slate = Color(0xFFCBD5E1);
  static const Color slateLight = Color(0xFFE2E8F0);

  // ===== Accents =====
  static const Color gold = Color(0xFFC9A45A);
  static const Color purple = Color(0xFF764A89);
  static const Color purpleLight = Color(0xFFB960E5);

  // ===== Fonds neutres =====
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFAF5E0);
  static const Color blueSurface = Color(0xFFE0F0FC);

  // ===== Erreurs =====
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFF93000A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ===================================================================
  // RÔLES SÉMANTIQUES — à utiliser dans les écrans/widgets
  // ===================================================================
  static const Color background = white;
  static const Color surface = mintSurfaceLightest;
  static const Color surfaceAlt = mintSurfaceAlt;
  static const Color cardBackground = mintSurface;

  static const Color textPrimary = neutralDark;
  static const Color textSecondary = neutralGray;
  static const Color textOnPrimary = white;
  static const Color textOnPrimaryContainer = primaryDark;

  static const Color success = primary;
  static const Color warning = gold;
  static const Color accent = purple;

  static const Color border = neutralGrayLight;
  static const Color divider = neutralGrayLighter;

  // ===================================================================
  // Variantes avec opacité (fonds superposés / états), calculées à
  // partir des couleurs ci-dessus pour éviter les Color(0x..) en dur.
  // ===================================================================
  static Color mintPale34 = mintPale.withValues(alpha: 0.34);
  static Color mintLight50 = mintLight.withValues(alpha: 0.50);
  static Color mintLight60 = mintLight.withValues(alpha: 0.60);
  static Color mintLight70 = mintLight.withValues(alpha: 0.70);
  static Color primaryContainer10 = primaryContainer.withValues(alpha: 0.10);
  static Color primaryDark10 = primaryDark.withValues(alpha: 0.10);
  static Color primaryDark20 = primaryDark.withValues(alpha: 0.20);
  static Color neutralGrayLight5 = neutralGrayLight.withValues(alpha: 0.05);
  static Color neutralGrayLight10 = neutralGrayLight.withValues(alpha: 0.10);
  static Color neutralGrayLight30 = neutralGrayLight.withValues(alpha: 0.30);
  static Color neutralGrayLighter50 = neutralGrayLighter.withValues(alpha: 0.50);
  static Color neutralGray40 = neutralGray.withValues(alpha: 0.40);
  static Color neutralGray70 = neutralGray.withValues(alpha: 0.70);
  static Color white10 = white.withValues(alpha: 0.10);
  static Color errorContainer20 = errorContainer.withValues(alpha: 0.20);
  static Color purpleLight10 = purpleLight.withValues(alpha: 0.10);
}
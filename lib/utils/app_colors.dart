import 'package:flutter/material.dart';

/// Palette extraite des variables Figma. Les couleurs sont groupées par
/// teinte, puis exposées sous forme de rôles sémantiques (section du bas)
/// à utiliser dans les écrans/widgets. Ne jamais écrire un Color(0x...)
/// en dur ailleurs que dans ce fichier.
///
/// NB: le panneau Figma ne donnait pas les noms de tokens (juste les hex),
/// donc le mapping ci-dessous est une première passe. On ajustera les
/// alias sémantiques dès que je verrai chaque couleur appliquée sur un
/// écran réel.
class AppColors {
  AppColors._();

  // ===== Vert principal (marque) =====
  static const Color primary = Color(0xFF41D092);
  // Corrigé : valeur exacte confirmée sur l'écran home de référence
  // (impacte aussi les boutons/textes qui l'utilisaient déjà).
  static const Color primaryDark = Color(0xFF1E5E4E);
  static const Color primaryDarkAlt = Color(0xFF17624A);
  static const Color primaryDeep = Color(0xFF003022);
  static const Color primaryDeepest = Color(0xFF002116);
  static const Color primaryContainer = Color(0xFF004935);
  static const Color onPrimaryDark = Color(0xFF0E1D26);

  static const Color secondaryGreen = Color(0xFF3AC387);
  static const Color secondaryGreenAlt = Color(0xFF3BB58B);
  static const Color secondaryGreenDeep = Color(0xFF003527);
  // Corrigé : couleur distincte de primaryDark — c'est ELLE qui remplit
  // la carte "Synthèse d'activité", pas primaryDark.
  static const Color mediumGreen = Color(0xFF3B846F);
  // Nouveau : couleur du texte de rôle (ADMIN) sur les cards communauté.
  static const Color roleText = Color(0xFF3BB58B);

  // ===== Verts clairs / surfaces =====
  static const Color mintLight = Color(0xFF95DBBD);
  static const Color mintPale = Color(0xFFAAF1D2);
  static const Color mintSurface = Color(0xFFC9E6D7);
  // Corrigé : valeur exacte (fond de la pastille "profil incomplet" /
  // du nav actif).
  static const Color mintSurfaceLighter = Color(0xFFE8F3EF);
  static const Color mintSurfaceLightest = Color(0xFFF2F9F7);
  static const Color mintSurfaceAlt = Color(0xFFF1F8F6);
  // Nouveau : fond du bandeau "Complétez votre profil".
  static const Color profileBannerBg = Color(0xFFDDEDD7);
  // Nouveau : fond du conteneur d'icône sur les cards communauté.
  static const Color iconBgMint = Color(0xFFEBFDF5);
  // Nouveau : fond des tags "Réunion demain" / "À jour".
  static const Color tagMintBg = Color(0xFFE6F5EE);
  // Nouveau : fond du bandeau "Complétez votre profil".
 
  // ===== Neutres / gris =====
  // Corrigé : valeur exacte (texte principal, teinte verdâtre).
  static const Color neutralDark = Color(0xFF1C2D27);
  static const Color neutralGreenGray = Color(0xFF6F7973);
  static const Color neutralGreenGrayLight = Color(0xFF4A6458);
  static const Color neutralGray = Color(0xFF3F4944);
  static const Color neutralGrayLight = Color(0xFFBFC9C2);
  static const Color neutralGrayLighter = Color(0xFFE0E3E0);
  static const Color slate = Color(0xFFCBD5E1);
  static const Color slateLight = Color(0xFFE2E8F0);
  // Nouveau : gris neutre pour avatars placeholder / pill "À jour".
  static const Color neutralPill = Color(0xFFECEFF1);

  // ===== Accents =====
  static const Color gold = Color(0xFFC9A45A);
  static const Color purple = Color(0xFF764A89);
  static const Color purpleLight = Color(0xFFB960E5);

  // ===== Fonds neutres =====
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFAF5E0);
  static const Color blueSurface = Color(0xFFE0F0FC);

  // ===== Erreurs / alertes =====
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFF93000A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  // Nouveau : rouge doux utilisé pour le texte du tag "En retard".
  static const Color alertRed = Color(0xFFE55C5C);
  // Nouveau : fond du tag "En retard".
  static const Color tagRedBg = Color(0xFFFEECEB);
  // Nouveau : rouge vif du point d'alerte (carte synthèse, nav badge).
  static const Color badgeRed = Color(0xFFFF5B5B);

  // ===== Dashboard admin communauté =====
  static const Color borderMint = Color(0xFFD1F5EA); // contour actions rapides
  static const Color surfaceMuted = Color(0xFFF4F8F6); // encarts bénéficiaire/restants
  static const Color warningBg = Color(0xFFFFF9E6); // fond "en attente"
  static const Color warningText = Color(0xFFB28900); // texte "en attente"
  static const Color purpleBg = Color(0xFFF3E8FF); // fond icône "prêt approuvé"
  static const Color brightGreen = Color(0xFF2CE497); // icône cotisation
  static const Color amber = Color(0xFFFFB300); // icône nouveau membre

  // ===== Trésorerie =====
  static const Color treasuryTabBg = Color(0xFFC4E5D8); // fond du sélecteur d'onglets
  static const Color financialPositionBg = Color(0xFF3B846C); // carte "Ma position financière"
  static const Color filterChipActiveBg = Color(0xFFB7E3D5); // chip de filtre sélectionné
  static const Color filterChipInactiveBg = Color(0x2918624A); // chip de filtre non sélectionné
  static const Color loanNoticeText = Color(0xFF3B6938); // icône + texte du rappel de remboursement

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
  // Corrigé : valeur exacte du séparateur (footer des cards communauté).
  static const Color divider = Color(0xFFECECEC);

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
  static Color white15 = white.withValues(alpha: 0.15);
  static Color white70 = white.withValues(alpha: 0.70);
  static Color white60 = white.withValues(alpha: 0.60);
  static Color errorContainer20 = errorContainer.withValues(alpha: 0.20);
  static Color purpleLight10 = purpleLight.withValues(alpha: 0.10);
  // Ombre très légère sous les cards blanches (community_card, etc.).
  static Color cardShadow = const Color(0xFF000000).withValues(alpha: 0.02);
  // Bordure discrète des champs de saisie (search field).
  static Color inputBorder = const Color(0xFF000000).withValues(alpha: 0.08);
}
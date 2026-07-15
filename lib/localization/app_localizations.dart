import 'package:flutter/foundation.dart';

/// Système de localisation custom (pas d'ARB / gen-l10n).
/// La détection automatique de la langue du téléphone et le déclenchement
/// du changement de langue sont gérés ailleurs (Njoya) — cette classe se
/// contente de stocker les traductions et d'exposer la langue active.
class AppLocalizations {
  AppLocalizations._();

  /// Langue active ('fr' ou 'en'). Écouter ce notifier au niveau racine
  /// (ex: ValueListenableBuilder autour du MaterialApp) pour rebuild
  /// l'app entière quand la langue change.
  static final ValueNotifier<String> locale = ValueNotifier<String>('fr');

  static void setLocale(String code) {
    if (code == 'fr' || code == 'en') {
      locale.value = code;
    }
  }

  /// Récupère la traduction pour une clé donnée, dans la langue active.
  /// Retourne la clé elle-même si aucune traduction n'est trouvée
  /// (utile pour repérer rapidement les clés manquantes en dev).
  static String t(String key) {
    final lang = _translations[locale.value] ?? _translations['fr']!;
    return lang[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'app_name': 'Njangi',

      // Onboarding
      'onboarding_skip': 'Passer',
      'onboarding_next': 'Suivant',
      'onboarding_start': 'Commencer',
      'onboarding_1_title': "Toutes vos communautés, au même endroit.",
      'onboarding_1_desc':
          "Gérez tous vos groupes Njangi depuis un compte unique. Passez facilement d'une communauté à l'autre tout en gardant vos informations organisées et séparées.",
      'onboarding_2_title':
          "Toutes les cotisations. Tous les prêts. Chaque étape.",
      'onboarding_2_desc':
          "Suivez les cotisations, les prêts, les remboursements et les activités du groupe avec une transparence totale, pour que chaque membre reste informé et confiant.",
      'onboarding_3_title': "Conçu pour votre communauté.",
      'onboarding_3_desc':
          "Une expérience simple, sécurisée et pensée pour accompagner les Njangis au quotidien. Commencez dès aujourd'hui avec votre communauté.",

      // Écran d'accueil / auth
      'auth_community_tag': 'Communauté',
      'auth_welcome_ribbon': 'BIENVENUE SUR ITECH NJANGI',
      'auth_welcome_title': "Gérez vos communautés en toute confiance.",
      'auth_welcome_desc':
          "Créez un compte pour commencer ou connectez-vous pour retrouver vos groupes d'épargne.",
      'auth_create_account': 'Créer un compte',
      'auth_login': 'Se connecter',
      'auth_terms_prefix': 'En continuant, vous acceptez nos',
      'auth_terms_link': "Conditions d'utilisation",
      'auth_terms_and': 'et notre',
      'auth_privacy_link': 'Politique de confidentialité',
    },
    'en': {
      'app_name': 'Njangi',

      // Onboarding
      'onboarding_skip': 'Skip',
      'onboarding_next': 'Next',
      'onboarding_start': 'Start',
      'onboarding_1_title': 'All your communities, in one place.',
      'onboarding_1_desc':
          "Manage all your Njangi groups from a single account. Switch easily from one community to another while keeping your information organized and separate.",
      'onboarding_2_title': 'All contributions. All loans. Every step.',
      'onboarding_2_desc':
          "Track contributions, loans, repayments and group activity with full transparency, so every member stays informed and confident.",
      'onboarding_3_title': 'Built for your community.',
      'onboarding_3_desc':
          "A simple, secure experience designed to support your Njangis every day. Get started today with your community.",

      // Home / auth screen
      'auth_community_tag': 'Community',
      'auth_welcome_ribbon': 'WELCOME TO ITECH NJANGI',
      'auth_welcome_title': 'Manage your communities with confidence.',
      'auth_welcome_desc':
          "Create an account to get started or log in to find your savings groups.",
      'auth_create_account': 'Create an account',
      'auth_login': 'Log in',
      'auth_terms_prefix': 'By continuing, you agree to our',
      'auth_terms_link': 'Terms of Use',
      'auth_terms_and': 'and our',
      'auth_privacy_link': 'Privacy Policy',
    },
  };
}
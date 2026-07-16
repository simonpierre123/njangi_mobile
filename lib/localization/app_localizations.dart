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

      // Étapes multi-écrans
      'step_word': 'Étape',
      'of_word': 'sur',
      'continue_button': 'Continuer',

      // Inscription - téléphone
      'register_title': 'Créez votre compte',
      'register_subtitle':
          'Entrez votre numéro de téléphone mobile pour commencer',
      'register_helper':
          'Nous vous enverrons un code de vérification pour confirmer votre numéro',
      'already_account': 'Vous avez déjà un compte ?',
      'login_link': 'Connectez-vous',

      // Inscription - OTP
      'otp_title': 'Vérifiez votre numéro de téléphone',
      'otp_subtitle_prefix': 'Entrez le code à 6 chiffres envoyé au numéro',
      'otp_edit_number': 'Modifier le numéro',
      'otp_no_code': "Vous n'avez pas reçu le code ?",
      'resend_prefix': 'Renvoyer dans',
      'otp_resend_now': 'Renvoyer le code',
      'verify_button': 'Vérifier mon numéro',

      // Inscription - succès
      'success_title': 'Numéro de téléphone vérifié',
      'success_subtitle': 'Votre identité a été vérifiée avec succès',

      // Inscription - PIN
      'pin_create_title': 'Créez votre code PIN',
      'pin_create_subtitle':
          'Choisissez un code à 4 chiffres pour accéder à votre compte en toute sécurité.',
      'pin_confirm_subtitle':
          'Retapez le même code PIN à 4 chiffres pour confirmer',
      'pin_tip':
          'Utilisez un code facile à retenir pour vous, mais difficile à deviner pour les autres.',
      'pin_confirm_button': 'Confirmer le code PIN',
      'pin_mismatch': 'Les codes PIN ne correspondent pas',
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

      // Multi-step screens
      'step_word': 'Step',
      'of_word': 'of',
      'continue_button': 'Continue',

      // Registration - phone
      'register_title': 'Create your account',
      'register_subtitle': 'Enter your mobile phone number to get started',
      'register_helper':
          'We will send you a verification code to confirm your number',
      'already_account': 'Already have an account?',
      'login_link': 'Log in',

      // Registration - OTP
      'otp_title': 'Verify your phone number',
      'otp_subtitle_prefix': 'Enter the 6-digit code sent to the number',
      'otp_edit_number': 'Edit number',
      'otp_no_code': "Didn't receive the code?",
      'resend_prefix': 'Resend in',
      'otp_resend_now': 'Resend code',
      'verify_button': 'Verify my number',

      // Registration - success
      'success_title': 'Phone number verified',
      'success_subtitle': 'Your identity has been successfully verified',

      // Registration - PIN
      'pin_create_title': 'Create your PIN code',
      'pin_create_subtitle':
          'Choose a 4-digit code to access your account securely.',
      'pin_confirm_subtitle': 'Re-enter the same 4-digit PIN code to confirm',
      'pin_tip':
          'Use a code that is easy for you to remember, but hard for others to guess.',
      'pin_confirm_button': 'Confirm PIN code',
      'pin_mismatch': 'The PIN codes do not match',
    },
  };
}
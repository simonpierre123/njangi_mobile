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

      // Connexion
      'login_title': 'Connectez-vous',
      'login_subtitle': 'Entrez le numéro de téléphone lié à votre compte Njangi',
      'login_helper':
          'Nous vous enverrons un code de vérification pour confirmer votre identité',
      'no_account': 'Pas encore de compte ?',
      'register_link': 'Inscrivez-vous',
      'enter_pin_title': 'Entrez votre code PIN',
      'enter_pin_subtitle':
          'Entrez votre code PIN à 4 chiffres pour accéder à votre compte',
      'access_account_button': 'Accéder à mon compte',
      'forgot_pin': 'Code PIN oublié ?',
      'reset_pin_link': 'Réinitialiser mon code',
      'incorrect_pin': 'Code PIN incorrect',

      // Fin d'inscription
      'pin_created_title': 'Code PIN créé avec succès',
      'pin_created_subtitle': 'Votre compte est désormais protégé',
      'welcome_title': 'Bienvenue sur Njangi',
      'welcome_subtitle':
          "Votre compte est prêt. Vous pouvez désormais créer ou rejoindre des communautés d'épargne et les gérer en toute confiance.",
      'setup_profile_button': 'Configurer mon profil',

      // Tableau de bord
      'greeting_hello': 'Bonjour',
      'greeting_subtitle': 'Heureux de vous revoir',
      'profile_incomplete_banner':
          'Complétez les informations de votre profil pour créer ou faire partie des communautés.',
      'identify_button': "M'identifier",
      'activity_summary_eyebrow': "Synthèse d'activité",
      'activity_empty_title': 'Aucune activité pour le moment',
      'activity_alert_title': 'Vérifications requises',
      'stat_communities': 'Communautés',
      'stat_actions': 'Actions à traiter',
      'stat_no_meeting': 'Aucune réunion programmée',
      'stat_meeting_tomorrow': 'Réunion demain',
      'pending_contributions_label': 'Cotisations en attente',
      'search_community_hint': 'Rechercher une communauté...',
      'no_community_yet': 'Aucune communauté pour le moment',
      'my_communities': 'Mes Communautés',
      'communities_followup': 'Suivi de vos groupes et cycles',
      'see_all_prefix': 'Voir les',
      'see_less': 'Voir moins',
      'nav_home': 'Accueil',
      'nav_notifications': 'Notifications',
      'nav_profile': 'Profil',

      // Dashboard admin communauté
      'group_health_eyebrow': 'Santé du groupe',
      'current_balance': 'Caisse actuelle',
      'members_up_to_date': 'Membres à jour',
      'pending_label': 'En attente',
      'active_loans': 'Prêts actifs',
      'management_priorities': 'Priorités de gestion',
      'quick_actions': 'Actions rapides',
      'record_contributions': 'Enregistrer Cotisations',
      'manage_loans': 'Gérer les Prêts',
      'members_label': 'Membres',
      'reports_label': 'Rapports',
      'current_cycle': 'Cycle en cours',
      'cycle_word': 'Cycle',
      'progress_word': 'Progression',
      'next_beneficiary': 'Prochain bénéficiaire',
      'remaining_label': 'Restants',
      'cycles_word': 'cycles',
      'members_status': 'Statut des Membres',
      'total_label': 'Total',
      'up_to_date': 'À jour',
      'overdue_label': 'En retard',
      'manage_members': 'Gérer les membres',
      'loans_management': 'Gestion des Prêts',
      'files_label': 'Dossiers',
      'pending_requests': 'Demandes en attente',
      'borrowing_capacity': "Capacité d'emprunt",
      'recent_activity': 'Activité récente',
      'see_full_history': "Voir tout l'historique",
      'community_nav_dashboard': 'Tableau de Bord',
      'community_nav_treasury': 'Trésorerie',
      'community_nav_members': 'Membres',

      // Dashboard membre (non-admin)
      'required_actions': 'Actions requises',
      'pay_button': 'Payer',
      'my_contributions': 'Mes Cotisations',
      'request_loan': 'Demander un prêt',
      'members_title': 'Membres',
      'see_all_members': 'Voir tous les membres',
      'next_beneficiary_colon': 'Prochain bénéficiaire :',
      'cycles_remaining_period': 'cycles restants dans cette période',

      // Trésorerie
      'treasury_tab_mine': 'Ma Trésorerie',
      'treasury_tab_contributions': 'Contributions',
      'treasury_tab_loans': 'Prêts',
      'my_financial_position': 'Ma position financière',
      'participation_suffix': 'Particip.',
      'total_contributed': 'Total cotisé',
      'none_label': 'Aucun',
      'next_due_date': 'Prochaine échéance',
      'see_receipt': 'Voir le reçu',
      'contribution_history': 'Historique de mes cotisations',
      'see_all_link': 'Tout voir',
      'paid_label': 'Payé',
      'collection_status': 'État de la collecte',
      'members_activity': 'Membres et activités',
      'filter_all': 'Tous',
      'loans_tab_placeholder': 'Section Prêts à venir',

      // Onglet Prêts
      'loan_title': 'Mon prêt',
      'loan_status_active': 'En cours',
      'borrowed_amount': 'Montant emprunté',
      'repayment_label': 'Remboursement',
      'total_repaid': 'Total remboursé',
      'remaining_balance': 'Solde restant',
      'loan_notice':
          "Vous devez rembourser votre prêt actuel avant d'en demander un nouveau.",
      'repayment_history': 'Historique des remboursements',

      // Aucun prêt en cours
      'no_active_loan_title': 'Aucun prêt en cours',
      'no_active_loan_subtitle':
          "Vous n'avez actuellement aucun prêt en cours auprès de votre communauté.",
      'eligible_badge': 'Éligible à une demande',
      'loan_request_note':
          'Vous pouvez effectuer une nouvelle demande de prêt selon les règles de votre communauté.',
      'your_eligibility': 'Votre éligibilité',
      'available_limit': 'Plafond disponible',
      'seniority_label': 'Ancienneté',
      'good_repayment_history': 'Historique de remboursement exemplaire',
      'request_loan_button': 'Demander un prêt',
      'how_loan_works_title': 'Comment fonctionne un prêt ?',
      'step1_title': 'Envoyer une demande',
      'step1_desc': 'Remplissez le formulaire avec le montant et la durée souhaités.',
      'step2_title': 'Validation',
      'step2_desc': 'Votre demande est examinée par les administrateurs du cycle.',
      'step3_title': 'Versement',
      'step3_desc': 'Une fois approuvé, les fonds sont versés sur votre compte.',

      // Onglet Membres
      'the_community': 'La communauté',
      'active_label': 'actifs',
      'late_label': 'en retard',
      'current_cycle_label': 'Cycle actuel',
      'search_member_hint': 'Rechercher un membre...',
      'filter_admin': 'Administrateur',
      'filter_member': 'Membre',
      'trust_score_title': 'Score de Confiance du Groupe',
      'growth_title': 'Croissance mensuelle',
      'invite_member_button': 'Inviter un membre',
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

      // Login
      'login_title': 'Log in',
      'login_subtitle': 'Enter the phone number linked to your Njangi account',
      'login_helper':
          'We will send you a verification code to confirm your identity',
      'no_account': "Don't have an account yet?",
      'register_link': 'Sign up',
      'enter_pin_title': 'Enter your PIN code',
      'enter_pin_subtitle': 'Enter your 4-digit PIN code to access your account',
      'access_account_button': 'Access my account',
      'forgot_pin': 'Forgot your PIN code?',
      'reset_pin_link': 'Reset my code',
      'incorrect_pin': 'Incorrect PIN code',

      // End of registration
      'pin_created_title': 'PIN code created successfully',
      'pin_created_subtitle': 'Your account is now protected',
      'welcome_title': 'Welcome to Njangi',
      'welcome_subtitle':
          'Your account is ready. You can now create or join savings communities and manage them with confidence.',
      'setup_profile_button': 'Set up my profile',

      // Dashboard
      'greeting_hello': 'Hello',
      'greeting_subtitle': 'Happy to see you again',
      'profile_incomplete_banner':
          'Complete your profile information to create or join communities.',
      'identify_button': 'Verify me',
      'activity_summary_eyebrow': 'Activity summary',
      'activity_empty_title': 'No activity yet',
      'activity_alert_title': 'Verifications required',
      'stat_communities': 'Communities',
      'stat_actions': 'Actions to handle',
      'stat_no_meeting': 'No meeting scheduled',
      'stat_meeting_tomorrow': 'Meeting tomorrow',
      'pending_contributions_label': 'Pending contributions',
      'search_community_hint': 'Search for a community...',
      'no_community_yet': 'No community yet',
      'my_communities': 'My Communities',
      'communities_followup': 'Track your groups and cycles',
      'see_all_prefix': 'See all',
      'see_less': 'See less',
      'nav_home': 'Home',
      'nav_notifications': 'Notifications',
      'nav_profile': 'Profile',

      // Community admin dashboard
      'group_health_eyebrow': 'Group health',
      'current_balance': 'Current balance',
      'members_up_to_date': 'Members up to date',
      'pending_label': 'Pending',
      'active_loans': 'Active loans',
      'management_priorities': 'Management priorities',
      'quick_actions': 'Quick actions',
      'record_contributions': 'Record Contributions',
      'manage_loans': 'Manage Loans',
      'members_label': 'Members',
      'reports_label': 'Reports',
      'current_cycle': 'Current cycle',
      'cycle_word': 'Cycle',
      'progress_word': 'Progress',
      'next_beneficiary': 'Next beneficiary',
      'remaining_label': 'Remaining',
      'cycles_word': 'cycles',
      'members_status': 'Members Status',
      'total_label': 'Total',
      'up_to_date': 'Up to date',
      'overdue_label': 'Overdue',
      'manage_members': 'Manage members',
      'loans_management': 'Loans Management',
      'files_label': 'Files',
      'pending_requests': 'Pending requests',
      'borrowing_capacity': 'Borrowing capacity',
      'recent_activity': 'Recent activity',
      'see_full_history': 'See full history',
      'community_nav_dashboard': 'Dashboard',
      'community_nav_treasury': 'Treasury',
      'community_nav_members': 'Members',

      // Member (non-admin) dashboard
      'required_actions': 'Required actions',
      'pay_button': 'Pay',
      'my_contributions': 'My Contributions',
      'request_loan': 'Request a loan',
      'members_title': 'Members',
      'see_all_members': 'See all members',
      'next_beneficiary_colon': 'Next beneficiary:',
      'cycles_remaining_period': 'cycles remaining this period',

      // Treasury
      'treasury_tab_mine': 'My Treasury',
      'treasury_tab_contributions': 'Contributions',
      'treasury_tab_loans': 'Loans',
      'my_financial_position': 'My financial position',
      'participation_suffix': 'Particip.',
      'total_contributed': 'Total contributed',
      'none_label': 'None',
      'next_due_date': 'Next due date',
      'see_receipt': 'See receipt',
      'contribution_history': 'My contribution history',
      'see_all_link': 'See all',
      'paid_label': 'Paid',
      'collection_status': 'Collection status',
      'members_activity': 'Members and activity',
      'filter_all': 'All',
      'loans_tab_placeholder': 'Loans section coming soon',

      // Loans tab
      'loan_title': 'My loan',
      'loan_status_active': 'Active',
      'borrowed_amount': 'Borrowed amount',
      'repayment_label': 'Repayment',
      'total_repaid': 'Total repaid',
      'remaining_balance': 'Remaining balance',
      'loan_notice':
          'You must repay your current loan before requesting a new one.',
      'repayment_history': 'Repayment history',

      // No active loan
      'no_active_loan_title': 'No active loan',
      'no_active_loan_subtitle':
          "You don't currently have any active loan with your community.",
      'eligible_badge': 'Eligible to apply',
      'loan_request_note':
          'You can submit a new loan request according to your community rules.',
      'your_eligibility': 'Your eligibility',
      'available_limit': 'Available limit',
      'seniority_label': 'Seniority',
      'good_repayment_history': 'Exemplary repayment history',
      'request_loan_button': 'Request a loan',
      'how_loan_works_title': 'How does a loan work?',
      'step1_title': 'Send a request',
      'step1_desc': 'Fill in the form with the desired amount and duration.',
      'step2_title': 'Validation',
      'step2_desc': 'Your request is reviewed by the cycle administrators.',
      'step3_title': 'Disbursement',
      'step3_desc': 'Once approved, the funds are transferred to your account.',

      // Members tab
      'the_community': 'The community',
      'active_label': 'active',
      'late_label': 'late',
      'current_cycle_label': 'Current cycle',
      'search_member_hint': 'Search for a member...',
      'filter_admin': 'Administrator',
      'filter_member': 'Member',
      'trust_score_title': 'Group Trust Score',
      'growth_title': 'Monthly growth',
      'invite_member_button': 'Invite a member',
    },
  };
}
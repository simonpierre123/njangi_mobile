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

      // Profil — hub
      'my_activity': 'Mon activité',
      'contributions_label': 'Cotisations',
      'settings_section': 'Paramètres',
      'my_profile_label': 'Mon profil',
      'security_label': 'Sécurité',
      'preferences_label': 'Préférences',
      'help_label': 'Aide',
      'about_label': 'À propos',
      'logout_button': 'Se déconnecter',

      // Profil — Mon Profil
      'my_profile_title': 'Mon Profil',
      'verified_number_badge': 'Numéro vérifié',
      'personal_info_title': 'Informations personnelles',
      'full_name_label': 'Nom complet',
      'phone_number_label': 'Numéro de téléphone',
      'email_address_label': 'Adresse e-mail',
      'gender_label': 'Genre',
      'member_since_label': "Date d'adhésion",
      'edit_info_button': 'Modifier mes informations',

      // Profil — Modifier mes informations
      'edit_info_title': 'Modifier mes informations',
      'change_photo_button': 'Modifier la photo',
      'full_name_required_label': 'Nom complet *',
      'full_name_hint': 'Ex: Jean Dupont',
      'email_hint': 'jean.dupont@email.com',
      'birthdate_label': 'Date de naissance (optionnel)',
      'birthdate_hint': 'mm/dd/yyyy',
      'change_number_link': 'Modifier',
      'change_number_notice':
          'Le changement de numéro nécessite une nouvelle vérification par SMS.',
      'cancel_button': 'Annuler',
      'save_button': 'Enregistrer',

      // Profil — Sécurité
      'security_title': 'Sécurité',
      'account_security_eyebrow': 'Sécurité du compte',
      'authentication_section': 'Authentification',
      'change_pin_title': 'Modifier le code PIN',
      'change_pin_subtitle': 'Changez votre code PIN à tout moment',
      'biometric_auth_title': 'Authentification biométrique',
      'access_section': 'Accès',
      'connected_devices_title': 'Appareils connectés',
      'connected_devices_subtitle':
          'Consultez les appareils autorisés à accéder à votre compte',
      'logout_all_devices': 'Déconnecter tous les appareils',

      // Notifications
      'push_notifications_title': 'Notifications Push',
      'push_notifications_desc': 'Recevez des notifications directement sur votre téléphone.',
      'enable_notifications': 'Activer les notifications',
      'notif_section_treasury': 'Trésorerie',
      'notif_section_loans': 'Prêts',
      'notif_section_communities': 'Communautés',
      'notif_section_general': 'Général',
      'notif_new_contribution': 'Nouvelle cotisation enregistrée',
      'notif_due_reminder': 'Rappel avant échéance',
      'notif_late_contribution': 'Cotisation en retard',
      'notif_receipt_available': 'Reçu disponible',
      'notif_new_loan_request': 'Nouvelle demande de prêt',
      'notif_loan_approved': 'Prêt approuvé',
      'notif_loan_rejected': 'Prêt refusé',
      'notif_repayment_due': 'Échéance de remboursement',
      'notif_repayment_recorded': 'Remboursement enregistré',
      'notif_community_invitation': 'Invitation à rejoindre une communauté',
      'notif_new_member': 'Nouveau membre',
      'notif_role_change': 'Changement de rôle',
      'notif_rules_modification': 'Modification des règles',
      'notif_meeting_scheduled': 'Réunion programmée',
      'notif_app_updates': "Mises à jour de l'application",
      'notif_tips_news': 'Conseils et nouveautés',
      'notif_planned_maintenance': 'Maintenance planifiée',

      // Préférences
      'preferences_title': 'Préférences',
      'language_title': 'Langue',
      'language_subtitle': 'Personnalisez votre interface',
      'language_fr_label': 'Français',
      'language_en_label': 'English',
      'appearance_title': 'Apparence',
      'appearance_subtitle': 'Thème clair ou sombre',
      'appearance_value': 'Automatique',
      'currency_title': 'Devise',
      'currency_subtitle': 'Unité monétaire par défaut',
      'currency_value': 'FCFA (XAF)',
      'regional_format_title': 'Format régional',
      'regional_format_subtitle':
          'Personnalisez le format des dates, des nombres et de la semaine',

      // Créer une communauté — Étape 1/5
      'create_community_title': 'Créer une communauté',
      'general_info_title': 'Informations générales',
      'general_info_subtitle': 'Commençons par les informations de base de votre communauté.',
      'add_photo_label': 'Ajouter',
      'community_name_label': 'Nom de la communauté *',
      'community_name_hint': 'Ex: Famille Bamiléké',
      'description_label': 'Description',
      'description_hint': 'Décrivez brièvement votre communauté.',
      'community_type_label': 'Type de communauté',
      'community_type_family': 'Famille',
      'community_type_friends': 'Amis',
      'community_type_business': 'Entreprise',
      'community_type_association': 'Association',
      'community_type_other': 'Autre',

      // Créer une communauté — Étape 2/5
      'financial_config_title': 'Configuration financière',
      'financial_config_subtitle': 'Commençons par les informations de base de votre communauté.',
      'contribution_section': 'Cotisation',
      'contribution_amount_label': 'Montant de la cotisation',
      'frequency_label': 'Fréquence',
      'freq_weekly_title': 'Hebdomadaire',
      'freq_weekly_subtitle': '7 jours',
      'freq_biweekly_title': 'Bimensuelle',
      'freq_biweekly_subtitle': '15 jours',
      'freq_monthly_title': 'Mensuelle',
      'freq_monthly_subtitle': '30 jours',
      'freq_custom_title': 'Personnalisée',
      'freq_custom_subtitle': 'Sur mesure',
      'cycle_section': 'Cycle',
      'start_date_label': 'Date de début',
      'due_day_label': "Jour d'échéance",
      'due_day_helper': 'Tous les membres devront effectuer leur cotisation avant cette date.',
      'expected_members_label': 'Nombre de membres prévu (optionnel)',
      'expected_members_hint': 'Ex: 12',
      'expected_members_helper': 'Vous pourrez inviter les membres ultérieurement.',
      'trust_security_title': 'Confiance et Sécurité',
      'trust_security_desc':
          'Ces paramètres garantissent la transparence au sein de votre tontine. Les fonds sont sécurisés via le grand livre numérique.',
      'back_button': 'Retour',
      'due_day_monday': 'Chaque lundi',
      'due_day_tuesday': 'Chaque mardi',
      'due_day_wednesday': 'Chaque mercredi',
      'due_day_thursday': 'Chaque jeudi',
      'due_day_friday': 'Chaque vendredi',
      'due_day_saturday': 'Chaque samedi',
      'due_day_sunday': 'Chaque dimanche',

      // Créer une communauté — Étape 3/5
      'rules_title': 'Règles de fonctionnement',
      'allow_loans_title': 'Autoriser les prêts',
      'max_loan_amount_label': "Montant maximum d'un prêt",
      'max_loan_duration_label': 'Durée maximale',
      'duration_suffix_months': 'mois',
      'max_simultaneous_loans_label': 'Nombre max simultanés',
      'admin_validation_title': 'Validation par les admins',
      'admin_validation_subtitle': 'Un administrateur doit approuver chaque prêt.',
      'apply_penalties_title': 'Appliquer des pénalités',
      'apply_penalties_subtitle': 'Amendes pour retards de paiement.',
      'governance_section': 'Gouvernance',
      'max_admins_label': "Nombre maximum d'administrateurs",
      'collective_validation_title': 'Validation collective',
      'collective_validation_subtitle':
          'Lorsque cette option est activée, plusieurs administrateurs devront approuver une demande de prêt.',

      // Créer une communauté — Étape 4/5
      'invite_members_title': 'Inviter des membres',
      'invite_members_subtitle':
          'Invitez les premiers membres de votre communauté. Vous pourrez toujours en ajouter plus tard.',
      'invite_link_title': "Lien d'invitation",
      'invite_link_subtitle': 'Générez un lien à partager.',
      'qr_code_title': 'QR Code',
      'qr_code_subtitle': 'Permettez de rejoindre rapidement.',
      'invite_by_number_title': 'Inviter par numéro',
      'invite_by_number_subtitle': 'Saisissez un numéro de téléphone.',
      'choose_contacts_title': 'Choisir contacts',
      'choose_contacts_subtitle': 'Sélectionnez depuis votre téléphone.',
      'invitations_sent_section': 'Invitations envoyées',
      'invited_status': 'Invité',
      'invite_later_button': 'Inviter plus tard',

      // Créer une communauté — Étape 5/5
      'almost_done_title': 'Presque fini !',
      'review_subtitle': 'Vérifiez les informations de votre communauté avant de la créer.',
      'edit_link': 'Modifier',
      'type_label_prefix': 'Type :',
      'cotisation_label': 'Cotisation',
      'rules_short_title': 'Règles',
      'rules_loans_enabled': 'Prêts autorisés',
      'rules_loans_disabled': 'Prêts désactivés',
      'rules_penalties_enabled': 'Pénalités activées',
      'rules_penalties_disabled': 'Pénalités désactivées',
      'rules_admin_validation_enabled': 'Validation par les administrateurs',
      'rules_admin_validation_disabled': 'Validation désactivée',
      'invited_members_card_title': 'Membres invités',
      'invitations_sent_label': 'invitations envoyées',
      'confirm_checkbox_label': 'Je confirme que les informations ci-dessus sont correctes.',
      'create_community_button': 'Créer la communauté',
      'confirm_required_message': 'Merci de confirmer les informations avant de continuer.',

      // Fil de notifications (onglet Accueil)
      'filter_all_feminine': 'Toutes',
      'filter_unread': 'Non lues',
      'loans_label': 'Prêts',
      'today_label': "Aujourd'hui",
      'yesterday_label': 'Hier',
      'no_notifications_yet': 'Aucune notification pour le moment',

      // Enregistrer une cotisation (modal)
      'record_contribution_title': 'Enregistrer une cotisation',
      'contribution_expected_label': 'Cotisation attendue :',
      'status_contribution_label': 'Statut de la contribution',
      'status_paid': 'Payée',
      'status_partial': 'Partielle',
      'status_unpaid': 'Non payée',
      'amount_received_label': 'Montant reçu',
      'payment_method_label': 'Mode de paiement',
      'payment_cash': 'Espèces',
      'payment_mobile_money': 'Mobile Money',
      'payment_transfer': 'Virement',
      'payment_date_label': 'Date de paiement',
      'receipt_optional_label': 'Justificatif (optionnel)',
      'add_receipt_button': 'Ajouter un reçu',
      'notes_hint': 'Notes ou détails supplémentaires...',

      // Contribution (page de détail)
      'contribution_detail_title': 'Contribution',
      'details_section': 'Détails',
      'expected_amount_label': 'Montant attendu',
      'paid_amount_label': 'Montant versé',
      'status_word': 'Statut',
      'date_word': 'Date',
      'time_word': 'Heure',
      'reference_label': 'Référence',
      'reference_none': 'Aucune',
      'history_section': 'Historique',
      'recorded_by_label': 'Enregistré par',
      'observation_section': 'Observation',
      'share_receipt_button': 'Partager le reçu',
      'modify_button': 'Modifier',
      'cancel_recording_button': "Annuler l'enregistrement",

      // Résumé financier ("Rapport")
      'financial_summary_title': 'Résumé financier',
      'current_balance_label': 'Solde actuel',
      'total_contributions_label': 'Contributions totales',
      'total_disbursements_label': 'Décaissements',
      'active_loans_label': 'Prêts actifs',
      'contributions_evolution_title': 'Évolution des contributions',
      'participation_section': 'Participation',
      'members_word': 'Membres',
      'loan_details_section': 'Détails des Prêts',
      'active_loans_word': 'Prêts actifs',
      'repayment_word': 'Remboursement',
      'total_loan_amount_label': 'Montant total prêté',
      'recent_activity_report_section': 'Activité récente',
      'contribution_of_prefix': 'Cotisation de',
      'disbursement_of_prefix': 'Décaissement de',
      'repayment_of_prefix': 'Remboursement de',
      'export_report_button': 'Exporter le rapport',
      'export_pdf_button': 'Exporter PDF',

      // Rapport détaillé
      'detailed_report_title': 'Rapport détaillé',
      'contributions_breadcrumb': 'Contributions',
      'filter_today': "Aujourd'hui",
      'filter_this_week': 'Cette semaine',
      'filter_this_month': 'Ce mois',
      'total_collected_label': 'Total encaissé',
      'transactions_word': 'Transactions',
      'versements_evolution_title': 'Évolution des versements',
      'objective_reached_label': 'Objectif atteint',
      'last_operations_section': 'Dernières opérations',
      'see_all_report_link': 'Tout voir',
      'see_detailed_report_link': 'Voir le rapport détaillé',

      // Trésorerie — onglet Bénéficiaires
      'treasury_tab_beneficiaries': 'Bénéficiaires',
      'disburse_button': 'Décaisser',
      'pot_label': 'Cagnotte',
      'served_label': 'Servis',
      'passage_order_section': 'Ordre de Passage',
      'admin_view_reorder_hint': 'Vue Admin · Glissez pour réorganiser',
      'member_view_hint': 'Vue Membre',
      'today_badge': "Aujourd'hui",
      'payout_history_section': 'Historique des versements',
      'completed_status': 'Effectué',

      // Trésorerie — modal "Enregistrer un décaissement"
      'record_disbursement_title': 'Enregistrer un décaissement',
      'amount_due_label': 'À recevoir',
      'amount_paid_out_label': 'Montant versé',
      'disbursement_date_label': 'Date du décaissement',
      'take_photo_button': 'Prendre une photo',
      'from_gallery_button': 'Depuis galerie',
      'observation_hint': 'Notes complémentaires...',
      'confirm_disbursement_checkbox': 'Je confirme que les fonds ont été remis au bénéficiaire.',
      'confirm_disbursement_button': 'Confirmer le décaissement',

      // Cycle terminé
      'cycle_completed_title': 'Cycle terminé',
      'cycle_completed_subtitle': 'Tous les bénéficiaires ont reçu leur cagnotte.',
      'cycle_summary_section': 'Résumé du Cycle',
      'loans_word': 'Prêts',
      'beneficiary_history_section': 'Historique des bénéficiaires',
      'paid_out_status': 'Versé',
      'see_full_list_link': 'Voir la liste complète',
      'closure_report_title': 'Rapport de clôture',
      'closure_report_subtitle': 'Archive complète au format PDF',
      'ready_new_cycle_title': 'Prêt pour un nouveau cycle',
      'ready_new_cycle_desc':
          'Configurez les paramètres de la prochaine session pour les membres de votre groupe.',
      'start_new_cycle_button': 'Démarrer un nouveau cycle',
      'see_cycles_history_link': "Consulter l'historique des cycles",
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

      // Profile — hub
      'my_activity': 'My activity',
      'contributions_label': 'Contributions',
      'settings_section': 'Settings',
      'my_profile_label': 'My profile',
      'security_label': 'Security',
      'preferences_label': 'Preferences',
      'help_label': 'Help',
      'about_label': 'About',
      'logout_button': 'Log out',

      // Profile — My Profile
      'my_profile_title': 'My Profile',
      'verified_number_badge': 'Verified number',
      'personal_info_title': 'Personal information',
      'full_name_label': 'Full name',
      'phone_number_label': 'Phone number',
      'email_address_label': 'Email address',
      'gender_label': 'Gender',
      'member_since_label': 'Member since',
      'edit_info_button': 'Edit my information',

      // Profile — Edit info
      'edit_info_title': 'Edit my information',
      'change_photo_button': 'Change photo',
      'full_name_required_label': 'Full name *',
      'full_name_hint': 'E.g. John Doe',
      'email_hint': 'john.doe@email.com',
      'birthdate_label': 'Date of birth (optional)',
      'birthdate_hint': 'mm/dd/yyyy',
      'change_number_link': 'Change',
      'change_number_notice':
          'Changing your number requires a new SMS verification.',
      'cancel_button': 'Cancel',
      'save_button': 'Save',

      // Profile — Security
      'security_title': 'Security',
      'account_security_eyebrow': 'Account security',
      'authentication_section': 'Authentication',
      'change_pin_title': 'Change PIN code',
      'change_pin_subtitle': 'Change your PIN code anytime',
      'biometric_auth_title': 'Biometric authentication',
      'access_section': 'Access',
      'connected_devices_title': 'Connected devices',
      'connected_devices_subtitle':
          'View devices authorized to access your account',
      'logout_all_devices': 'Log out of all devices',

      // Notifications
      'push_notifications_title': 'Push Notifications',
      'push_notifications_desc': 'Receive notifications directly on your phone.',
      'enable_notifications': 'Enable notifications',
      'notif_section_treasury': 'Treasury',
      'notif_section_loans': 'Loans',
      'notif_section_communities': 'Communities',
      'notif_section_general': 'General',
      'notif_new_contribution': 'New contribution recorded',
      'notif_due_reminder': 'Reminder before due date',
      'notif_late_contribution': 'Late contribution',
      'notif_receipt_available': 'Receipt available',
      'notif_new_loan_request': 'New loan request',
      'notif_loan_approved': 'Loan approved',
      'notif_loan_rejected': 'Loan rejected',
      'notif_repayment_due': 'Repayment due date',
      'notif_repayment_recorded': 'Repayment recorded',
      'notif_community_invitation': 'Invitation to join a community',
      'notif_new_member': 'New member',
      'notif_role_change': 'Role change',
      'notif_rules_modification': 'Rules modification',
      'notif_meeting_scheduled': 'Meeting scheduled',
      'notif_app_updates': 'App updates',
      'notif_tips_news': 'Tips and news',
      'notif_planned_maintenance': 'Planned maintenance',

      // Preferences
      'preferences_title': 'Preferences',
      'language_title': 'Language',
      'language_subtitle': 'Customize your interface',
      'language_fr_label': 'Français',
      'language_en_label': 'English',
      'appearance_title': 'Appearance',
      'appearance_subtitle': 'Light or dark theme',
      'appearance_value': 'Automatic',
      'currency_title': 'Currency',
      'currency_subtitle': 'Default monetary unit',
      'currency_value': 'FCFA (XAF)',
      'regional_format_title': 'Regional format',
      'regional_format_subtitle': 'Customize date, number and week format',

      // Create community — Step 1/5
      'create_community_title': 'Create a community',
      'general_info_title': 'General information',
      'general_info_subtitle': "Let's start with the basic information about your community.",
      'add_photo_label': 'Add',
      'community_name_label': 'Community name *',
      'community_name_hint': 'E.g. Bamiléké Family',
      'description_label': 'Description',
      'description_hint': 'Briefly describe your community.',
      'community_type_label': 'Community type',
      'community_type_family': 'Family',
      'community_type_friends': 'Friends',
      'community_type_business': 'Business',
      'community_type_association': 'Association',
      'community_type_other': 'Other',

      // Create community — Step 2/5
      'financial_config_title': 'Financial setup',
      'financial_config_subtitle': "Let's start with the basic information about your community.",
      'contribution_section': 'Contribution',
      'contribution_amount_label': 'Contribution amount',
      'frequency_label': 'Frequency',
      'freq_weekly_title': 'Weekly',
      'freq_weekly_subtitle': '7 days',
      'freq_biweekly_title': 'Biweekly',
      'freq_biweekly_subtitle': '15 days',
      'freq_monthly_title': 'Monthly',
      'freq_monthly_subtitle': '30 days',
      'freq_custom_title': 'Custom',
      'freq_custom_subtitle': 'Custom',
      'cycle_section': 'Cycle',
      'start_date_label': 'Start date',
      'due_day_label': 'Due day',
      'due_day_helper': 'All members must make their contribution before this date.',
      'expected_members_label': 'Expected number of members (optional)',
      'expected_members_hint': 'E.g. 12',
      'expected_members_helper': 'You can invite members later.',
      'trust_security_title': 'Trust and Security',
      'trust_security_desc':
          'These settings guarantee transparency within your tontine. Funds are secured via the digital ledger.',
      'back_button': 'Back',
      'due_day_monday': 'Every Monday',
      'due_day_tuesday': 'Every Tuesday',
      'due_day_wednesday': 'Every Wednesday',
      'due_day_thursday': 'Every Thursday',
      'due_day_friday': 'Every Friday',
      'due_day_saturday': 'Every Saturday',
      'due_day_sunday': 'Every Sunday',

      // Create community — Step 3/5
      'rules_title': 'Operating rules',
      'allow_loans_title': 'Allow loans',
      'max_loan_amount_label': 'Maximum loan amount',
      'max_loan_duration_label': 'Maximum duration',
      'duration_suffix_months': 'months',
      'max_simultaneous_loans_label': 'Max simultaneous loans',
      'admin_validation_title': 'Admin validation',
      'admin_validation_subtitle': 'An administrator must approve each loan.',
      'apply_penalties_title': 'Apply penalties',
      'apply_penalties_subtitle': 'Fines for late payments.',
      'governance_section': 'Governance',
      'max_admins_label': 'Maximum number of administrators',
      'collective_validation_title': 'Collective validation',
      'collective_validation_subtitle':
          'When enabled, several administrators must approve a loan request.',

      // Create community — Step 4/5
      'invite_members_title': 'Invite members',
      'invite_members_subtitle':
          "Invite the first members of your community. You'll always be able to add more later.",
      'invite_link_title': 'Invitation link',
      'invite_link_subtitle': 'Generate a link to share.',
      'qr_code_title': 'QR Code',
      'qr_code_subtitle': 'Let people join quickly.',
      'invite_by_number_title': 'Invite by number',
      'invite_by_number_subtitle': 'Enter a phone number.',
      'choose_contacts_title': 'Choose contacts',
      'choose_contacts_subtitle': 'Select from your phone.',
      'invitations_sent_section': 'Invitations sent',
      'invited_status': 'Invited',
      'invite_later_button': 'Invite later',

      // Create community — Step 5/5
      'almost_done_title': 'Almost done!',
      'review_subtitle': 'Review your community information before creating it.',
      'edit_link': 'Edit',
      'type_label_prefix': 'Type:',
      'cotisation_label': 'Contribution',
      'rules_short_title': 'Rules',
      'rules_loans_enabled': 'Loans allowed',
      'rules_loans_disabled': 'Loans disabled',
      'rules_penalties_enabled': 'Penalties enabled',
      'rules_penalties_disabled': 'Penalties disabled',
      'rules_admin_validation_enabled': 'Admin validation',
      'rules_admin_validation_disabled': 'Validation disabled',
      'invited_members_card_title': 'Invited members',
      'invitations_sent_label': 'invitations sent',
      'confirm_checkbox_label': 'I confirm that the information above is correct.',
      'create_community_button': 'Create community',
      'confirm_required_message': 'Please confirm the information before continuing.',

      // Notification feed (Home tab)
      'filter_all_feminine': 'All',
      'filter_unread': 'Unread',
      'loans_label': 'Loans',
      'today_label': 'Today',
      'yesterday_label': 'Yesterday',
      'no_notifications_yet': 'No notifications yet',

      // Record contribution (modal)
      'record_contribution_title': 'Record a contribution',
      'contribution_expected_label': 'Expected contribution:',
      'status_contribution_label': 'Contribution status',
      'status_paid': 'Paid',
      'status_partial': 'Partial',
      'status_unpaid': 'Unpaid',
      'amount_received_label': 'Amount received',
      'payment_method_label': 'Payment method',
      'payment_cash': 'Cash',
      'payment_mobile_money': 'Mobile Money',
      'payment_transfer': 'Transfer',
      'payment_date_label': 'Payment date',
      'receipt_optional_label': 'Receipt (optional)',
      'add_receipt_button': 'Add a receipt',
      'notes_hint': 'Notes or additional details...',

      // Contribution (detail page)
      'contribution_detail_title': 'Contribution',
      'details_section': 'Details',
      'expected_amount_label': 'Expected amount',
      'paid_amount_label': 'Amount paid',
      'status_word': 'Status',
      'date_word': 'Date',
      'time_word': 'Time',
      'reference_label': 'Reference',
      'reference_none': 'None',
      'history_section': 'History',
      'recorded_by_label': 'Recorded by',
      'observation_section': 'Observation',
      'share_receipt_button': 'Share receipt',
      'modify_button': 'Edit',
      'cancel_recording_button': 'Cancel recording',

      // Financial summary ("Report")
      'financial_summary_title': 'Financial summary',
      'current_balance_label': 'Current balance',
      'total_contributions_label': 'Total contributions',
      'total_disbursements_label': 'Disbursements',
      'active_loans_label': 'Active loans',
      'contributions_evolution_title': 'Contributions over time',
      'participation_section': 'Participation',
      'members_word': 'Members',
      'loan_details_section': 'Loan details',
      'active_loans_word': 'Active loans',
      'repayment_word': 'Repayment',
      'total_loan_amount_label': 'Total amount lent',
      'recent_activity_report_section': 'Recent activity',
      'contribution_of_prefix': 'Contribution from',
      'disbursement_of_prefix': 'Disbursement to',
      'repayment_of_prefix': 'Repayment from',
      'export_report_button': 'Export report',
      'export_pdf_button': 'Export PDF',

      // Detailed report
      'detailed_report_title': 'Detailed report',
      'contributions_breadcrumb': 'Contributions',
      'filter_today': 'Today',
      'filter_this_week': 'This week',
      'filter_this_month': 'This month',
      'total_collected_label': 'Total collected',
      'transactions_word': 'Transactions',
      'versements_evolution_title': 'Payments over time',
      'objective_reached_label': 'Goal reached',
      'last_operations_section': 'Latest operations',
      'see_all_report_link': 'See all',
      'see_detailed_report_link': 'View detailed report',

      // Treasury — Beneficiaries tab
      'treasury_tab_beneficiaries': 'Beneficiaries',
      'disburse_button': 'Disburse',
      'pot_label': 'Pot',
      'served_label': 'Served',
      'passage_order_section': 'Payout Order',
      'admin_view_reorder_hint': 'Admin View · Drag to reorder',
      'member_view_hint': 'Member View',
      'today_badge': 'Today',
      'payout_history_section': 'Payout History',
      'completed_status': 'Completed',

      // Treasury — "Record a disbursement" modal
      'record_disbursement_title': 'Record a disbursement',
      'amount_due_label': 'Amount due',
      'amount_paid_out_label': 'Amount paid out',
      'disbursement_date_label': 'Disbursement date',
      'take_photo_button': 'Take a photo',
      'from_gallery_button': 'From gallery',
      'observation_hint': 'Additional notes...',
      'confirm_disbursement_checkbox': 'I confirm the funds have been given to the beneficiary.',
      'confirm_disbursement_button': 'Confirm disbursement',

      // Cycle completed
      'cycle_completed_title': 'Cycle completed',
      'cycle_completed_subtitle': 'All beneficiaries have received their pot.',
      'cycle_summary_section': 'Cycle Summary',
      'loans_word': 'Loans',
      'beneficiary_history_section': 'Beneficiary History',
      'paid_out_status': 'Paid',
      'see_full_list_link': 'See full list',
      'closure_report_title': 'Closure report',
      'closure_report_subtitle': 'Complete archive in PDF format',
      'ready_new_cycle_title': 'Ready for a new cycle',
      'ready_new_cycle_desc': "Set up the parameters for your group's next session.",
      'start_new_cycle_button': 'Start a new cycle',
      'see_cycles_history_link': 'View cycle history',
    },
  };
}
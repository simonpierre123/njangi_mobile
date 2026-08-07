# Njangi — Documentation frontend (pour intégration API)

Ce document récapitule l'architecture front construite jusqu'ici : structure des dossiers, rôle de chaque fichier, et (dans les parties suivantes) la table de routage complète et les points d'attention pour l'intégration API. Objectif : permettre à un développeur qui prend en main l'intégration API de savoir immédiatement où brancher les données réelles, sans avoir à relire tout l'historique de conception.

**Toutes les données actuellement affichées viennent de fichiers `datasource/*_mock_datasource.dart`** — ce sont les seuls fichiers à remplacer pour brancher l'API. Aucun écran ni widget ne devrait avoir besoin d'être modifié en profondeur pour ça, sauf ajout de gestion d'état de chargement/erreur (non géré pour l'instant, tout est synchrone en mémoire).

## 1. Stack et conventions

- Flutter / Dart, pas de package de state management (`setState` natif partout)
- Navigation : routes nommées + table centralisée (`lib/routes/app_router.dart`), pas de `go_router`
- Internationalisation : classe custom `AppLocalizations` (FR/EN), pas d'ARB/gen-l10n
- Design tokens centralisés : `AppColors`, `AppDimensions`, `AppTheme` — aucune couleur/dimension ne doit être écrite en dur ailleurs
- Responsive : `AppScale.init(context)` en haut de chaque écran plein-page + extensions `.w`/`.h` sur les nombres
- Police : Geist (déclarée dans `pubspec.yaml`, fichiers dans `assets/fonts/`)
- Packages tiers : `intl_phone_field` (téléphone), `image_picker` (caméra/galerie)
- **Pattern "shell"** : deux écrans (`HomeShell`, `CommunityShell`) possèdent un seul `Scaffold` + bottom nav persistante ; le contenu bascule via `IndexedStack` (pas de navigation). Voir détail section 2.
- **Aucune persistance** : tout l'état vit en mémoire, réinitialisé au redémarrage.

## 2. Arborescence complète

```
njangi/
├── pubspec.yaml
├── assets/
│   ├── fonts/                              18 fichiers .ttf Geist
│   └── images/
│       ├── icone_name.png                  logo (grand, écran accueil)
│       ├── icone_njangui_no_white.png      logo (petit, footer onboarding)
│       ├── subtle_pattern.png              motif déco (carte synthèse verte)
│       ├── onboarding1.png                 illustration onboarding slide 1
│       ├── onboarding2.png                 illustration onboarding slide 2
│       ├── onboarding3.png                 illustration onboarding slide 3
│       ├── onboarding4.png                 illustration écran Auth (Créer un compte/Se connecter)
│       ├── cycle_finish.png                illustration "Cycle terminé" (icône verte incluse dans l'image)
│       ├── kyc1.png                        illustration KYC étape 1 (intro)
│       └── kyc3.png                        illustration KYC étape 3 (capture photo)
│
└── lib/
    ├── main.dart                           point d'entrée, détection langue auto, ValueListenableBuilder locale
    │
    ├── routes/
    │   ├── app_routes.dart                 noms de routes (constantes uniquement)
    │   └── app_router.dart                 ⚠️ FICHIER CENTRAL — table de routage, câblage de tous les écrans
    │
    ├── utils/
    │   ├── app_colors.dart                 palette complète de l'app (toute couleur utilisée y est nommée)
    │   ├── app_dimensions.dart             tailles de référence, espacements, rayons, AppScale (responsive)
    │   ├── app_theme.dart                  ThemeData global (police, boutons, textes)
    │   └── media_picker.dart               utilitaire partagé caméra/galerie (image_picker)
    │
    ├── localization/
    │   └── app_localizations.dart          traductions FR/EN (classe custom) — ~475 clés
    │
    ├── Models/                             modèles de données (structures, pas de logique métier)
    │   ├── community_model.dart                    une communauté (card du dashboard accueil)
    │   ├── community_admin_dashboard_model.dart     santé groupe, priorités, cycle, prêts (dashboard admin)
    │   ├── community_member_dashboard_model.dart    actions requises, cycle (dashboard membre)
    │   ├── community_members_model.dart             annuaire membres, score de confiance, croissance
    │   ├── treasury_model.dart                      position financière, collecte, prêts (Ma Trésorerie)
    │   ├── profile_model.dart                       UserProfile, activité, communautés liées, sécurité
    │   ├── create_community_model.dart              CommunityDraft + enums Type/Fréquence (création communauté)
    │   ├── notification_settings_model.dart         items de préférences de notifications (toggles)
    │   ├── preferences_model.dart                   items de préférences générales (langue/apparence/devise)
    │   ├── notification_feed_model.dart             notifications du fil d'accueil (clés i18n, pas de texte brut)
    │   ├── contribution_model.dart                  enregistrement + détail d'une cotisation
    │   ├── beneficiary_model.dart                   bénéficiaire actuel, stats, ordre de passage, historique
    │   ├── cycle_completion_model.dart               résumé de cycle terminé, historique bénéficiaires
    │   ├── report_model.dart                        résumé financier + rapport détaillé (contributions)
    │   └── kyc_model.dart                           options de type de document (vérification d'identité)
    │
    ├── datasource/                         ⚠️ DONNÉES MOCK — SEULS FICHIERS À REMPLACER PAR L'API
    │   ├── community_mock_datasource.dart              liste des communautés (dashboard accueil)
    │   ├── community_admin_mock_datasource.dart        stats dashboard admin
    │   ├── community_member_mock_datasource.dart       stats dashboard membre
    │   ├── community_treasury_mock_datasource.dart     cotisations, collecte, prêts (Ma Trésorerie)
    │   ├── community_members_mock_datasource.dart      annuaire, score confiance, croissance
    │   ├── community_beneficiary_mock_datasource.dart  bénéficiaire actuel, ordre de passage, versements
    │   ├── profile_mock_datasource.dart                utilisateur courant, activité, sécurité
    │   ├── create_community_mock_datasource.dart       invitations pré-remplies (démo Étape 4/5)
    │   ├── notification_settings_mock_datasource.dart  préférences de notifications (toggles)
    │   ├── preferences_mock_datasource.dart            apparence/devise/format régional
    │   ├── notification_feed_mock_datasource.dart      fil de notifications (clés i18n)
    │   ├── contribution_mock_datasource.dart           cotisation à enregistrer + détail exemple
    │   ├── report_mock_datasource.dart                 résumé financier + rapport détaillé
    │   ├── cycle_completion_mock_datasource.dart       résumé cycle terminé
    │   └── kyc_mock_datasource.dart                    types de documents disponibles
    │
    ├── common/basewidget/                  composants réutilisés dans PLUSIEURS écrans/domaines
    │   ├── app_button.dart                 bouton primaire/secondaire, icône avant/après texte (iconLeading)
    │   ├── app_logo.dart                   logo Njangi (icône + wordmark)
    │   ├── app_dots_indicator.dart         indicateur de progression (onboarding)
    │   ├── app_badge.dart                  chip/badge générique (couleurs personnalisables)
    │   ├── coming_soon_page.dart           écran placeholder générique (fonctionnalités non branchées)
    │   ├── step_header.dart                en-tête "Étape X sur Y" (inscription/connexion/création communauté)
    │   ├── pin_dots.dart                   4 cases de saisie PIN
    │   ├── numeric_keypad.dart             clavier numérique custom
    │   ├── info_banner.dart                bandeau conseil (simple, une ligne)
    │   ├── otp_input_boxes.dart            6 cases de saisie OTP (clavier système)
    │   ├── stat_chip.dart                  pastille stat (ex: "3 Communautés")
    │   ├── activity_summary_card.dart      carte "Synthèse d'activité" (dashboard accueil)
    │   ├── app_search_field.dart           barre de recherche
    │   ├── app_bottom_nav_bar.dart         nav bar basse générique (items configurables) — utilisée par les 2 shells
    │   ├── app_fab.dart                    bouton flottant rond
    │   ├── community_card.dart             card communauté (liste dashboard accueil)
    │   ├── member_avatars_stack.dart       avatars membres empilés + compteur "+N"
    │   ├── member_filter_chips.dart        pilules de filtre à largeur de contenu (promu depuis Trésorerie)
    │   ├── percent_ring.dart               anneau de pourcentage (Participation, Rapport)
    │   ├── simple_app_bar.dart             en-tête simple (flèche retour + titre) — sous-pages
    │   ├── app_text_field.dart             champ de saisie labellisé générique (promu depuis Profil)
    │   ├── labeled_date_field.dart         champ date labellisé (ouvre showDatePicker)
    │   ├── labeled_dropdown_field.dart     champ liste déroulante labellisé
    │   ├── app_segmented_control.dart      sélecteur en pilule à largeur égale, FittedBox anti-débordement
    │   ├── media_source_sheet.dart         bottom sheet "Prendre une photo/Depuis galerie" réutilisable
    │   └── network_avatar.dart             avatar avec vraie photo démo (pravatar.cc), repli auto hors-ligne
    │
    └── screens/
        │
        ├── onboarding/
        │   ├── onboarding_page.dart        carrousel 3 slides (PageView), Passer/Suivant/Commencer
        │   └── widgets/onboarding_slide.dart   illustration réelle (asset) + titre + description
        │
        ├── auth/
        │   ├── auth_landing_page.dart      écran d'accueil (Créer un compte / Se connecter), illustration réelle
        │   ├── widgets/stat_pill.dart       pastille "+12%"
        │   ├── register/                   PARCOURS D'INSCRIPTION (4 étapes)
        │   │   ├── register_phone_page.dart    Étape 1/4 — téléphone + indicatif pays
        │   │   ├── verify_otp_page.dart        Étape 2/4 — OTP (réutilisé aussi en connexion)
        │   │   ├── phone_verified_page.dart    succès vérification (réutilisé, transition auto)
        │   │   ├── create_pin_page.dart         Étape 3/4 — création PIN
        │   │   ├── confirm_pin_page.dart        Étape 3/4 (suite) — confirmation PIN
        │   │   ├── pin_created_page.dart        succès création PIN (transition auto)
        │   │   └── welcome_page.dart            Étape 4/4 — écran de bienvenue final
        │   └── login/                      PARCOURS DE CONNEXION (3 étapes)
        │       ├── login_phone_page.dart       Étape 1/3 — téléphone
        │       └── enter_pin_page.dart          Étape 3/3 — saisie PIN existant
        │
        ├── home/                           SHELL PRINCIPAL (post-connexion) — 3 onglets
        │   ├── home_shell.dart              ⚠️ Scaffold unique + bottom nav Accueil/Notifications/Profil (IndexedStack)
        │   ├── home_page.dart               contenu onglet Accueil : synthèse, recherche, mes communautés
        │   ├── notification_feed_page.dart  contenu onglet Notifications : filtres + fil groupé par jour
        │   └── widgets/
        │       ├── greeting_header.dart          "Bonjour, {nom} 👋" + avatar (NetworkAvatar)
        │       ├── profile_incomplete_banner.dart bandeau profil à compléter (avec croix de fermeture)
        │       └── notification_feed_card.dart    carte notification (variante lue/non lue)
        │
        ├── profil/                         Contenu de l'onglet "Profil" (partagé HomeShell ET CommunityShell)
        │   ├── profile_page.dart            hub profil (contenu d'onglet, pas de Scaffold propre)
        │   ├── my_profile_page.dart         sous-page "Mon Profil" (poussée, lecture seule)
        │   ├── edit_profile_page.dart       sous-page "Modifier mes informations" (photo fonctionnelle)
        │   ├── security_page.dart           sous-page "Sécurité"
        │   ├── notifications_page.dart      sous-page "Notifications" (préférences/toggles — PAS le fil d'accueil)
        │   ├── preferences_page.dart        sous-page "Préférences" (langue fonctionnelle, apparence/devise/format)
        │   └── widgets/
        │       ├── avatar_with_badge.dart        avatar + badge overlay (photo réelle ou démo réseau)
        │       ├── profile_header.dart            en-tête hub (avatar, nom, tél, badge rôle = VerifiedBadge)
        │       ├── profile_activity_card.dart      grille 2×2 activité
        │       ├── profile_community_row.dart      ligne communauté liée (hub profil)
        │       ├── settings_row.dart               ligne de paramètre (icône + label + chevron)
        │       ├── logout_button.dart              bouton déconnexion
        │       ├── verified_badge.dart             pilule mint (réutilisée pour "Numéro vérifié" ET rôle admin)
        │       ├── profile_info_field.dart          champ lecture seule (Mon Profil)
        │       ├── phone_edit_row.dart              ligne téléphone (lecture seule + lien Modifier)
        │       ├── security_status_card.dart        carte état sécurité (Sécurité)
        │       ├── security_action_row.dart         ligne action sécurité (icône/toggle)
        │       ├── notification_master_card.dart    interrupteur maître (Notifications/préférences)
        │       ├── notification_toggle_row.dart     ligne de préférence de notification
        │       └── preference_row.dart              ligne de préférence générale (langue/apparence/...)
        │
        └── community/                      SHELL COMMUNAUTÉ (après clic sur une card) — 4 onglets
            ├── community_shell.dart         ⚠️ Scaffold unique + bottom nav (IndexedStack), bascule admin/membre
            ├── widgets/
            │   └── community_app_bar.dart   en-tête partagé (nom, cycle, rôle, trailing optionnel)
            │
            ├── home/                        contenu onglet "Tableau de Bord"
            │   ├── admin_dashboard_page.dart    vue ADMIN (community.role == 'ADMIN')
            │   ├── member_dashboard_page.dart   vue MEMBRE (tout autre rôle)
            │   └── widgets/
            │       ├── group_health_card.dart       carte verte "Santé du groupe" (partagée admin/membre)
            │       ├── priorities_card.dart          "Priorités de gestion" (admin)
            │       ├── quick_actions_grid.dart       grille actions rapides (générique — voir router pour le câblage spécial "contributions"/"reports")
            │       ├── cycle_progress_card.dart      "Cycle en cours" — vue admin (badge + barre)
            │       ├── members_status_card.dart      "Statut des membres" — grille 2×2 (admin)
            │       ├── loans_management_card.dart    "Gestion des prêts" (admin)
            │       ├── recent_activity_card.dart     "Activité récente" (partagée admin/membre)
            │       ├── required_action_card.dart     "Actions requises" (membre)
            │       ├── member_cycle_card.dart         "Cycle en cours" — vue membre (gros %)
            │       └── members_overview_card.dart    "Membres" — lignes colorées (membre)
            │
            ├── tresorerie/                  contenu onglet "Trésorerie" (4 sous-onglets internes)
            │   ├── treasury_page.dart           écran conteneur (Ma Trésorerie/Contributions/Prêts/Bénéficiaires)
            │   ├── record_contribution_sheet.dart  MODAL "Enregistrer une cotisation" (bottom sheet, flou)
            │   ├── disburse_funds_sheet.dart        MODAL "Enregistrer un décaissement" (bottom sheet, flou)
            │   ├── contribution_detail_page.dart    page détail d'une cotisation enregistrée
            │   ├── cycle_completed_page.dart        page "Cycle terminé" (après décaissement final)
            │   └── widgets/
            │       ├── financial_position_card.dart    "Ma position financière" (Ma Trésorerie)
            │       ├── contribution_receipt_card.dart  carte reçu de cotisation
            │       ├── contribution_history_list.dart  historique de mes cotisations
            │       ├── collection_status_card.dart     "État de la collecte" (Contributions)
            │       ├── member_contribution_row.dart    ligne contribution membre (réutilisée aussi pour prêts)
            │       ├── loan_summary_card.dart           "Mon prêt" — état prêt actif
            │       ├── loan_due_card.dart                prochaine échéance — état prêt actif
            │       ├── loan_notice_banner.dart           rappel remboursement — état prêt actif
            │       ├── no_active_loan_card.dart          état "aucun prêt en cours"
            │       ├── loan_eligibility_card.dart        "Votre éligibilité" — état sans prêt
            │       ├── request_loan_button.dart          CTA "Demander un prêt" — état sans prêt
            │       ├── loan_how_it_works_card.dart       explication 3 étapes — état sans prêt
            │       ├── member_due_card.dart              carte membre concerné (modal cotisation)
            │       ├── payment_method_grid.dart          grille Espèces/Mobile Money/Virement (cotisation + décaissement)
            │       ├── attach_receipt_button.dart        bouton "Ajouter un reçu" (fonctionnel — caméra/galerie)
            │       ├── beneficiary_due_card.dart         carte bénéficiaire "À recevoir" (modal décaissement)
            │       ├── receipt_source_grid.dart          2 boutons caméra/galerie séparés (décaissement, fonctionnel)
            │       ├── contribution_summary_header.dart  en-tête page détail cotisation (avatar, montant, badge)
            │       ├── detail_row.dart                   ligne label/valeur (page détail cotisation)
            │       ├── recorded_by_card.dart              carte "Enregistré par" (page détail cotisation)
            │       ├── observation_box.dart               citation sur fond teinté (page détail cotisation)
            │       ├── current_beneficiary_card.dart      carte bénéficiaire actuel (onglet Bénéficiaires, bouton Décaisser)
            │       ├── beneficiary_stats_grid.dart        grille 2×2 stats bénéficiaires
            │       ├── passage_order_row.dart             contenu carte ordre de passage (timeline externe, voir treasury_page.dart)
            │       ├── payout_history_row.dart            ligne historique versement (pas de carte propre — regroupée)
            │       ├── cycle_completion_header.dart       en-tête "Cycle terminé" (illustration réelle)
            │       ├── cycle_summary_stats_grid.dart      grille 2×2 résumé de cycle (Membres/Cagnotte/Servis/Prêts)
            │       ├── beneficiary_history_row.dart       ligne bénéficiaire déjà servi (Cycle terminé)
            │       ├── closure_report_card.dart           carte "Rapport de clôture" (Cycle terminé)
            │       └── new_cycle_card.dart                carte "Prêt pour un nouveau cycle" (Cycle terminé)
            │
            ├── membres/                     contenu onglet "Membres"
            │   ├── admin_members_page.dart      vue admin (gestion, croissance, invitation)
            │   ├── members_page.dart            vue non-admin (annuaire + score de confiance)
            │   └── widgets/
            │       ├── community_summary_card.dart      résumé communauté (avatars empilés, partagé admin/non-admin)
            │       ├── admin_member_row.dart              ligne membre (vue admin — action contextuelle, NetworkAvatar)
            │       ├── member_directory_row.dart          ligne membre (vue non-admin, NetworkAvatar)
            │       ├── trust_score_card.dart               "Score de confiance" (non-admin)
            │       ├── growth_stats_card.dart               stats de croissance (admin)
            │       └── invite_member_button.dart            CTA "Inviter un membre" (admin)
            │
            ├── creation/                    FLUX "Créer une communauté" — 5 étapes (déclenché par le FAB Accueil)
            │   ├── create_community_step1_page.dart    Étape 1/5 — infos générales (photo fonctionnelle, type)
            │   ├── create_community_step2_page.dart    Étape 2/5 — configuration financière
            │   ├── create_community_step3_page.dart    Étape 3/5 — règles de fonctionnement
            │   ├── create_community_step4_page.dart    Étape 4/5 — inviter des membres
            │   ├── create_community_step5_page.dart    Étape 5/5 — révision et confirmation
            │   └── widgets/
            │       ├── community_photo_picker.dart       sélecteur photo (fonctionnel — caméra/galerie)
            │       ├── community_type_grid.dart           grille Famille/Amis/Entreprise/Association/Autre
            │       ├── frequency_option_grid.dart          grille fréquence de cotisation
            │       ├── trust_security_banner.dart          bandeau "Confiance et Sécurité"
            │       ├── toggle_setting_row.dart              ligne à bascule (icône optionnelle en cercle)
            │       ├── number_stepper_field.dart            stepper numérique (− valeur +)
            │       ├── invite_action_grid.dart               grille 2×2 actions d'invitation
            │       ├── invited_member_row.dart               ligne membre déjà invité (avatar, badge, retrait)
            │       ├── review_section_card.dart              carte de résumé avec lien "Modifier" (Étape 5)
            │       └── rules_checklist_item.dart             item checklist des règles (Étape 5)
            │
            └── rapport/                     Rapports financiers (déclenchés depuis Tableau de Bord/Trésorerie)
                ├── financial_summary_page.dart      "Résumé financier" (action rapide "Rapports")
                ├── detailed_report_page.dart        "Rapport détaillé" (depuis Trésorerie > Contributions)
                └── widgets/
                    ├── financial_stat_card.dart          carte stat (variante foncée solde / claire le reste)
                    ├── contribution_evolution_chart.dart  graphique courbe + zone remplie (CustomPainter)
                    ├── report_bar_chart.dart              graphique en barres (CustomPainter)
                    ├── participation_ring_card.dart       carte Participation (réutilise PercentRing)
                    ├── loan_report_card.dart              carte "Détails des Prêts"
                    ├── recent_report_activity_row.dart    ligne activité récente (couleur explicite par type)
                    └── report_transaction_row.dart        ligne transaction (Dernières opérations)
        │
        └── kyc/                            FLUX "Vérification d'identité" — 3/4 étapes construites
            ├── kyc_intro_page.dart          Étape 1/4 — introduction (illustration réelle, avantages, prérequis)
            ├── kyc_document_type_page.dart  Étape 2/4 — choix du type de document
            ├── kyc_capture_page.dart        Étape 3/4 — capture photo (fonctionnel — caméra/galerie réelles)
            └── widgets/
                ├── kyc_benefit_row.dart          avantage pleine largeur
                ├── kyc_benefit_tile.dart         avantage demi-largeur (paire)
                ├── kyc_checklist_box.dart        bloc checklist (Prérequis + exigences document)
                ├── kyc_document_option_card.dart carte de sélection d'un type de document
                └── kyc_tips_box.dart             bloc "Conseils pour réussir" (capture photo)
```

## 3. Table de routage complète

Toutes les routes sont définies dans `lib/routes/app_routes.dart` (noms) et câblées dans `lib/routes/app_router.dart` (`onGenerateRoute`). Le paramètre `arguments` est typé `Object?` (cast explicite dans chaque `case`).

| Route (constante) | Chemin | Écran | Arguments | Écran suivant |
|---|---|---|---|---|
| `onboarding` | `/` | `OnboardingPage` | — | `authLanding` |
| `authLanding` | `/auth` | `AuthLandingPage` | — | `registerPhone` / `loginPhone` |
| `registerPhone` | `/register/phone` | `RegisterPhonePage` | — | `registerOtp` |
| `registerOtp` | `/register/otp` | `VerifyOtpPage` (step 2/4) | `String` téléphone | `phoneVerified` (arg: `createPin`) |
| `createPin` | `/register/pin/create` | `CreatePinPage` | — | `confirmPin` |
| `confirmPin` | `/register/pin/confirm` | `ConfirmPinPage` | `String` PIN original | `pinCreated` |
| `pinCreated` | `/register/pin/created` | `PinCreatedPage` | — (auto, 1.6s) | `welcome` |
| `welcome` | `/register/welcome` | `WelcomePage` (step 4/4) | — | `home` / `editProfile` ("Configurer mon profil") |
| `loginPhone` | `/login/phone` | `LoginPhonePage` | — | `loginOtp` |
| `loginOtp` | `/login/otp` | `VerifyOtpPage` (step 2/3) | `String` téléphone | `phoneVerified` (arg: `enterPin`) |
| `enterPin` | `/login/pin/enter` | `EnterPinPage` | — | `home` |
| `phoneVerified` | `/verified` | `PhoneVerifiedPage` | `String` nom de la route suivante | variable (voir argument) |
| `home` | `/home` | `HomeShell` ⚠️ shell | — | `communityShell` (tap communauté), `createCommunityStep1` (FAB) |
| `communityShell` | `/community` | `CommunityShell` ⚠️ shell | `CommunityModel` | interne (Trésorerie/Membres/Profil via `IndexedStack`, aucune route) |
| `myProfile` | `/profile/me` | `MyProfilePage` | — | `editProfile` |
| `editProfile` | `/profile/edit` | `EditProfilePage` | — | pop |
| `security` | `/profile/security` | `SecurityPage` | — | — |
| `notifications` | `/profile/notifications` | `NotificationsPage` (préférences, pas le fil) | — | — |
| `preferences` | `/profile/preferences` | `PreferencesPage` | — | — |
| `createCommunityStep1` | `/community/create/1` | `CreateCommunityStep1Page` | `CommunityDraft?` | `createCommunityStep2` |
| `createCommunityStep2` | `/community/create/2` | `CreateCommunityStep2Page` | `CommunityDraft` | `createCommunityStep3` |
| `createCommunityStep3` | `/community/create/3` | `CreateCommunityStep3Page` | `CommunityDraft` | `createCommunityStep4` |
| `createCommunityStep4` | `/community/create/4` | `CreateCommunityStep4Page` | `CommunityDraft` | `createCommunityStep5` |
| `createCommunityStep5` | `/community/create/5` | `CreateCommunityStep5Page` | `CommunityDraft` | `comingSoon` ("Communauté créée !") |
| `contributionDetail` | `/community/contribution/detail` | `ContributionDetailPage` | — | — |
| `financialSummary` | `/community/report/summary` | `FinancialSummaryPage` | `CommunityModel` | `detailedReport` (tap "Contributions totales") |
| `detailedReport` | `/community/report/detailed` | `DetailedReportPage` | `CommunityModel` | — |
| `cycleCompleted` | `/community/cycle-completed` | `CycleCompletedPage` | `CommunityModel` | — |
| `kycIntro` | `/kyc/intro` | `KycIntroPage` | — | `kycDocumentType` |
| `kycDocumentType` | `/kyc/document-type` | `KycDocumentTypePage` | — | `kycCapture` (arg: `KycDocumentTypeId`) |
| `kycCapture` | `/kyc/capture` | `KycCapturePage` | — | `comingSoon` ("Étape 4 sur 4") |
| `comingSoon` | `/coming-soon` | `ComingSoonPage` | `String` libellé affiché | — |

**Modales (pas des routes classiques)** — affichées via `showModalBottomSheet` depuis des méthodes statiques privées de `AppRouter` :

| Déclencheur | Modal | Action de sortie |
|---|---|---|
| Tableau de Bord admin → action rapide "Enregistrer Cotisations" | `RecordContributionSheet` (`_showRecordContributionSheet`) | "Enregistrer" → ferme le modal + pousse `contributionDetail` |
| Onglet Bénéficiaires → bouton "Décaisser" | `DisburseFundsSheet` (`_showDisburseFundsSheet(community)`) | "Confirmer" → ferme le modal + pousse `cycleCompleted` |

Les deux modales partagent le même traitement visuel : flou plein écran (`BackdropFilter`) derrière une carte alignée en bas, hauteur plafonnée à 90 % de l'écran (`ConstrainedBox`).

### Notes de navigation

- `_push` = `pushNamed` (empile, retour possible) ; `_replace` = `pushReplacementNamed` ; `_replaceAll` = `pushNamedAndRemoveUntil` (vide toute la pile — utilisé pour la déconnexion) ; `_pop` = retour simple.
- **Les 5 anciennes routes communauté ont été fusionnées** : `communityAdmin` / `communityMember` / `communityTreasury` / `communityMembersAdmin` / `communityMembers` n'existent plus — tout passe désormais par la seule route `communityShell`, qui bascule en interne entre variante admin/membre selon `community.role == 'ADMIN'`.
- La route `profile` a été supprimée : le Profil n'est plus une page poussée, c'est un onglet embarqué (`ProfilePage` en contenu direct) dans `HomeShell` **et** `CommunityShell` — même widget, deux shells.
- Aucune des sous-pages de Profil (`myProfile`, `editProfile`, `security`, `notifications`, `preferences`) n'a de bottom nav propre — ce sont des sous-pages de consultation poussées par-dessus le shell, pas des onglets.
- **Garde-fou web** : `communityShell`, `financialSummary`, `detailedReport`, `cycleCompleted` castent `settings.arguments as CommunityModel?` (nullable) — si `null` (perte d'état possible après un hot restart sur Flutter Web), redirection propre vers `home` via `_MissingCommunityRedirect` au lieu de planter.
- `AdminDashboardPage.onQuickAction` est un callback générique (`ValueChanged<String>`) — le router spécial-case les valeurs `'contributions'` (ouvre le modal cotisation) et `'reports'` (pousse `financialSummary`) ; toute autre valeur pousse un `comingSoon`.

## 4. Ce qui reste à faire / points d'attention pour l'intégration API

### Données et état
- Remplacer les **15 fichiers `datasource/*_mock_datasource.dart`** par de vrais appels API (repository pattern recommandé). Les `Models/*.dart` correspondants peuvent servir de DTO ou être adaptés.
- Aucune gestion de chargement/erreur n'existe actuellement (tout est synchrone, en mémoire) — à ajouter lors du branchement API (états `loading`/`error`/`data`).
- Aucune persistance : tout état (langue choisie, session, brouillon de création de communauté, etc.) est perdu au redémarrage.

### Points figés / à individualiser
- `community_admin_mock_datasource.dart` et `community_member_mock_datasource.dart` renvoient les **mêmes données quelle que soit la communauté cliquée** (un seul jeu de données mock) — à individualiser par communauté une fois l'API branchée.
- `RecordContributionSheet` : le nom de communauté affiché dans le modal est **figé** (`'Famille Bamiléké'`) — `onQuickAction` ne transporte que la clé de l'action, pas le `CommunityModel` actif. TODO explicite laissé dans `app_router.dart` (`_showRecordContributionSheet`). **`DisburseFundsSheet` a déjà été corrigé** (utilise `community.name` réel) — même correctif à répliquer côté cotisation si besoin.
- `main.dart` détecte la langue du téléphone au démarrage (`PlatformDispatcher`) mais ne persiste pas un choix manuel — TODO `shared_preferences` laissé dans le code. Le changement de langue (Préférences) est néanmoins **fonctionnel en mémoire** pour la session en cours.
- `AppButton` n'a pas d'état "désactivé" visuel — certains écrans bloquent l'action via un `onPressed` gardé plutôt qu'un vrai style grisé.

### Flux incomplets
- **KYC** : seules les étapes 1 à 3/4 sont construites. L'étape 4/4 (revue/soumission finale) pousse un `comingSoon` placeholder.
- **Création de communauté** : "Créer la communauté" (Étape 5/5) ne crée rien réellement — pousse un `comingSoon` placeholder au lieu de faire un vrai appel API + navigation vers la communauté créée.
- **Export PDF / rapports** : tous les boutons "Exporter" (Rapports, Cycle terminé) sont présents mais ne génèrent aucun fichier réel.
- **Glisser-déposer** (Ordre de Passage, onglet Bénéficiaires) : réordonnancement fonctionnel mais **état local uniquement**, jamais persisté.

### Médias (caméra / galerie)
- `image_picker` est branché sur **5 endroits** : création de communauté (Étape 1, photo), modal cotisation (reçu), modal décaissement (justificatif, 2 boutons séparés), "Modifier mes informations" (photo de profil), KYC Étape 3 (capture document).
- ⚠️ Utilise `dart:io File` (choix explicite du produit) — **fonctionne sur Android/iOS/desktop mais pas sur Flutter Web** (pas de système de fichiers dans le navigateur). Aucun crash : simplement pas d'aperçu image sur cette plateforme précise.
- Setup requis côté natif (voir aussi `pubspec.yaml`) : `image_picker: ^1.2.2`, clés `NSPhotoLibraryUsageDescription`/`NSCameraUsageDescription` dans `ios/Runner/Info.plist`. Android : aucune configuration supplémentaire.
- `NetworkAvatar` (visages de démonstration via pravatar.cc) nécessite la permission `android.permission.INTERNET` dans `AndroidManifest.xml` — **déjà ajoutée**. Repli automatique sur l'icône générique si le réseau échoue.

### Localisation
- Convention générale : texte d'interface → clé de traduction ; contenu mock dynamique → texte brut. **Exception notable** : le fil de notifications de l'accueil (`notification_feed_model.dart`) a été entièrement converti en clés de traduction (titre/description/horodatage/groupe) suite à une demande explicite — à reproduire sur d'autres écrans si la même exigence s'applique ailleurs.
- Toujours vérifier l'absence de clé dupliquée entre les blocs `'fr'`/`'en'` après ajout — `const Map` ne tolère aucun doublon (erreur de compilation sinon).

### Assets à vérifier
- `assets/images/onboarding3.png` a été signalé comme potentiellement absent du dossier à un moment de la conception (contrairement à `onboarding1/2/4.png`) — à confirmer.
- Tous les assets référencés (`cycle_finish.png`, `kyc1.png`, `kyc3.png`, `onboarding1-4.png`) ont un repli visuel (`errorBuilder`) si le fichier est manquant — donc pas de crash, mais un placeholder générique s'affichera tant que le fichier n'est pas confirmé présent.

### Point d'entrée du KYC
- Le flux KYC est déclenché depuis le bouton **"M'identifier"** de la bannière "profil incomplet" sur l'écran Accueil (`onIdentify` dans `app_router.dart`, case `home`).
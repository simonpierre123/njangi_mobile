# Njangi — Documentation frontend (pour intégration API)

Ce document récapitule l'architecture front construite jusqu'ici : structure des dossiers, rôle de chaque fichier, et table de routage. Objectif : permettre à un développeur qui prend en main l'intégration API de savoir immédiatement **où brancher les données réelles**, sans avoir à relire tout l'historique de conception.

Toutes les données actuellement affichées viennent de fichiers `datasource/*_mock_datasource.dart` — ce sont les **seuls fichiers à remplacer** pour brancher l'API. Aucun écran ni widget ne devrait avoir besoin d'être modifié en profondeur pour ça, sauf ajout de gestion d'état de chargement/erreur (non géré pour l'instant, tout est synchrone en mémoire).

---

## 1. Stack et conventions

- **Flutter / Dart**, pas de package de state management (setState natif partout)
- **Navigation** : routes nommées + table centralisée (`lib/routes/app_router.dart`), pas de `go_router`
- **Internationalisation** : classe custom `AppLocalizations` (FR/EN), pas d'ARB/gen-l10n
- **Design tokens centralisés** : `AppColors`, `AppDimensions`, `AppTheme` — aucune couleur/dimension ne doit être écrite en dur ailleurs
- **Responsive** : `AppScale.init(context)` en haut de chaque écran + extensions `.w`/`.h` sur les nombres
- **Police** : Geist (déclarée dans `pubspec.yaml`, fichiers dans `assets/fonts/`)

---

## 2. Arborescence complète

```
njangi/
├── pubspec.yaml
├── assets/
│   ├── fonts/                              18 fichiers .ttf Geist
│   └── images/
│       ├── icone_name.png                  logo (grand, écran accueil)
│       ├── icone_njangui_no_white.png      logo (petit, footer onboarding)
│       └── subtle_pattern.png              motif déco (carte synthèse verte)
│
└── lib/
    ├── main.dart                           point d'entrée, détection langue auto
    │
    ├── routes/
    │   ├── app_routes.dart                 noms de routes (constantes)
    │   └── app_router.dart                 table de routage centralisée
    │
    ├── utils/
    │   ├── app_colors.dart                 palette complète de l'app
    │   ├── app_dimensions.dart             tailles de référence + scaling responsive
    │   └── app_theme.dart                  ThemeData global (police, boutons, textes)
    │
    ├── localization/
    │   └── app_localizations.dart          traductions FR/EN (classe custom)
    │
    ├── Models/                             modèles de données (structures, pas de logique)
    │   ├── community_model.dart            une communauté (card du dashboard)
    │   ├── community_admin_dashboard_model.dart   santé groupe, priorités, cycle, prêts (admin)
    │   ├── community_member_dashboard_model.dart  actions requises, cycle (membre)
    │   └── treasury_model.dart             position financière, collecte, prêts (trésorerie)
    │
    ├── datasource/                         ⚠️ DONNÉES MOCK — À REMPLACER PAR L'API
    │   ├── community_mock_datasource.dart          liste des communautés (dashboard)
    │   ├── community_admin_mock_datasource.dart    stats dashboard admin
    │   ├── community_member_mock_datasource.dart   stats dashboard membre
    │   └── community_treasury_mock_datasource.dart cotisations, collecte, prêts
    │
    ├── common/basewidget/                  composants réutilisés dans PLUSIEURS écrans
    │   ├── app_button.dart                 bouton primaire/secondaire (350×52 réf. Figma)
    │   ├── app_logo.dart                   logo Njangi (icône + wordmark)
    │   ├── app_dots_indicator.dart         indicateur de progression (onboarding)
    │   ├── app_badge.dart                  chip/badge générique
    │   ├── coming_soon_page.dart           écran placeholder générique
    │   ├── step_header.dart                en-tête "Étape X sur Y" (inscription/connexion)
    │   ├── pin_dots.dart                   4 cases de saisie PIN
    │   ├── numeric_keypad.dart             clavier numérique custom
    │   ├── info_banner.dart                bandeau conseil (ex: sécurité PIN)
    │   ├── otp_input_boxes.dart            6 cases de saisie OTP (clavier système)
    │   ├── stat_chip.dart                  pastille stat (ex: "3 Communautés")
    │   ├── activity_summary_card.dart      carte "Synthèse d'activité" (dashboard accueil)
    │   ├── app_search_field.dart           barre de recherche
    │   ├── app_bottom_nav_bar.dart         nav bar basse générique (items configurables)
    │   ├── app_fab.dart                    bouton flottant rond
    │   ├── community_card.dart             card communauté (liste dashboard)
    │   └── member_avatars_stack.dart       avatars membres empilés
    │
    └── screens/
        ├── onboarding/
        │   ├── onboarding_page.dart        carrousel 3 slides (PageView)
        │   └── widgets/onboarding_slide.dart
        │
        ├── auth/
        │   ├── auth_landing_page.dart      écran d'accueil (Créer un compte / Se connecter)
        │   ├── widgets/stat_pill.dart       pastille "+12%" (accueil)
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
        ├── home/                           TABLEAU DE BORD PRINCIPAL (post-connexion)
        │   ├── home_page.dart               accueil : synthèse, recherche, mes communautés
        │   └── widgets/
        │       ├── greeting_header.dart         "Bonjour, {nom} 👋"
        │       └── profile_incomplete_banner.dart bandeau profil à compléter (avec croix)
        │
        └── community/                      ESPACE D'UNE COMMUNAUTÉ (après clic sur une card)
            ├── widgets/
            │   └── community_app_bar.dart   en-tête partagé (nom, cycle, rôle) — home/trésorerie/membres
            │
            ├── home/                        onglet "Tableau de Bord" de la communauté
            │   ├── admin_dashboard_page.dart    vue ADMIN (rôle == 'ADMIN')
            │   ├── member_dashboard_page.dart   vue MEMBRE (tout autre rôle)
            │   └── widgets/
            │       ├── group_health_card.dart       carte verte "Santé du groupe" (partagée admin/membre)
            │       ├── priorities_card.dart          "Priorités de gestion" (admin)
            │       ├── quick_actions_grid.dart       grille actions rapides (générique, contenu variable)
            │       ├── cycle_progress_card.dart      "Cycle en cours" — vue admin (badge + barre)
            │       ├── members_status_card.dart      "Statut des membres" — grille 2×2 (admin)
            │       ├── loans_management_card.dart    "Gestion des prêts" (admin)
            │       ├── recent_activity_card.dart     "Activité récente" (partagée admin/membre)
            │       ├── required_action_card.dart     "Actions requises" (membre)
            │       ├── member_cycle_card.dart         "Cycle en cours" — vue membre (gros %)
            │       └── members_overview_card.dart    "Membres" — lignes colorées (membre)
            │
            ├── tresorerie/                  onglet "Trésorerie" de la communauté (3 sous-onglets internes)
            │   ├── treasury_page.dart           écran conteneur (Ma Trésorerie / Contributions / Prêts)
            │   └── widgets/
            │       ├── treasury_tab_selector.dart      sélecteur des 3 sous-onglets
            │       ├── financial_position_card.dart    "Ma position financière" (onglet Ma Trésorerie)
            │       ├── contribution_receipt_card.dart  carte reçu de cotisation
            │       ├── contribution_history_list.dart  historique de mes cotisations
            │       ├── collection_status_card.dart     "État de la collecte" (onglet Contributions)
            │       ├── member_filter_chips.dart        filtres Tous/À jour/En attente/En retard
            │       ├── member_contribution_row.dart    ligne contribution membre (réutilisée aussi pour prêts)
            │       ├── loan_summary_card.dart           "Mon prêt" — état prêt actif
            │       ├── loan_due_card.dart                prochaine échéance — état prêt actif
            │       ├── loan_notice_banner.dart           rappel remboursement — état prêt actif
            │       ├── no_active_loan_card.dart          état "aucun prêt en cours"
            │       ├── loan_eligibility_card.dart        "Votre éligibilité" — état sans prêt
            │       ├── request_loan_button.dart          CTA "Demander un prêt" — état sans prêt
            │       └── loan_how_it_works_card.dart       explication 3 étapes — état sans prêt
            │
            └── membres/                     ⚠️ PAS ENCORE CONSTRUIT (prochaine étape prévue)
```

---

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
| `welcome` | `/register/welcome` | `WelcomePage` (step 4/4) | — | `home` |
| `loginPhone` | `/login/phone` | `LoginPhonePage` | — | `loginOtp` |
| `loginOtp` | `/login/otp` | `VerifyOtpPage` (step 2/3) | `String` téléphone | `phoneVerified` (arg: `enterPin`) |
| `enterPin` | `/login/pin/enter` | `EnterPinPage` | — | `home` |
| `phoneVerified` | `/verified` | `PhoneVerifiedPage` | `String` nom de la route suivante | variable (voir arg) |
| `home` | `/home` | `HomePage` | — | `communityAdmin` / `communityMember` |
| `communityAdmin` | `/community/admin` | `AdminDashboardPage` | `CommunityModel` | `communityTreasury` (bottom nav) |
| `communityMember` | `/community/member` | `MemberDashboardPage` | `CommunityModel` | `communityTreasury` (bottom nav) |
| `communityTreasury` | `/community/treasury` | `TreasuryPage` | `CommunityModel` | — (pop vers dashboard) |
| `comingSoon` | `/coming-soon` | `ComingSoonPage` | `String` libellé affiché | — |

**Écran partagé `phoneVerified`** : reçoit en argument le *nom* de la route suivante (pas un widget), pour être réutilisable entre inscription et connexion sans dupliquer l'écran.

**Notes navigation** :
- `_push` = `pushNamed` (empile, retour possible) ; `_replace` = `pushReplacementNamed` (pas de retour).
- La bottom nav des écrans `community/*` ne fait que mettre à jour son état visuel local, **sauf** l'onglet "Trésorerie" qui navigue réellement (`onOpenTreasury`), et le retour "Tableau de Bord" depuis la Trésorerie (`pop`). Les onglets "Membres"/"Profil" ne sont pas encore branchés (écrans pas construits).

---

## 4. Ce qui reste à faire / points d'attention pour l'intégration API

- **Remplacer les 4 fichiers `datasource/*_mock_datasource.dart`** par de vrais appels API (repository pattern recommandé). Les `Models/*.dart` correspondants peuvent servir de DTO ou être adaptés.
- **Aucune gestion de chargement/erreur** n'existe actuellement (tout est synchrone, en mémoire) — à ajouter lors du branchement API (états `loading`/`error`/`data`).
- **`main.dart`** détecte la langue du téléphone au démarrage (`PlatformDispatcher`) mais ne persiste pas un choix manuel de langue — un `TODO` y est laissé pour brancher `shared_preferences`.
- **`AppButton`** n'a pas d'état "désactivé" visuel — certains écrans (PIN) bloquent l'action via un `onPressed` vide plutôt qu'un vrai style grisé (`TODO` laissé dans le code).
- **`screens/community/membres/`** n'existe pas encore — dossier à créer sur le même modèle que `home/` et `tresorerie/` (page conteneur + `widgets/` dédié).
- **`community_admin_mock_datasource.dart` et `community_member_mock_datasource.dart`** renvoient les mêmes données quelle que soit la communauté cliquée (un seul jeu de données mock) — à individualiser par communauté une fois l'API branchée.
- **`treasury_page.dart`** : l'onglet "Prêts" gère déjà les deux états (prêt actif / aucun prêt) via `loan: LoanInfo?` nullable — l'API doit juste renvoyer `null` quand il n'y a pas de prêt en cours.
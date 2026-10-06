import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../Controllers_distant/AuthController.dart';
import '../Controllers_distant/CycleController.dart';
import '../Controllers_distant/UserController.dart';
import '../Models/MembreGroupe.dart';
import '../Models/community_model.dart';
import '../Models/community_members_model.dart';
import '../Models/create_community_model.dart';
import '../Models/kyc_model.dart';
import '../common/basewidget/coming_soon_page.dart';
import '../datasource/community_admin_mock_datasource.dart';
import '../datasource/community_beneficiary_mock_datasource.dart';
import '../datasource/community_member_mock_datasource.dart';
import '../datasource/community_members_mock_datasource.dart';
import '../datasource/community_mock_datasource.dart';
import '../datasource/community_treasury_mock_datasource.dart';
import '../datasource/contribution_mock_datasource.dart';
import '../datasource/create_community_mock_datasource.dart';
import '../datasource/cycle_completion_mock_datasource.dart';
import '../datasource/kyc_mock_datasource.dart';
import '../datasource/notification_feed_mock_datasource.dart';
import '../datasource/notification_settings_mock_datasource.dart';
import '../datasource/profile_mock_datasource.dart';
import '../datasource/report_mock_datasource.dart';
import '../localization/app_localizations.dart';
import '../screens/auth/auth_landing_page.dart';
import '../screens/auth/login/enter_pin_page.dart';
import '../screens/auth/login/login_phone_page.dart';
import '../screens/auth/register/confirm_pin_page.dart';
import '../screens/auth/register/create_pin_page.dart';
import '../screens/auth/register/phone_verified_page.dart';
import '../screens/auth/register/pin_created_page.dart';
import '../screens/auth/register/register_phone_page.dart';
import '../screens/auth/register/verify_otp_page.dart';
import '../screens/auth/register/welcome_page.dart';
import '../screens/community/community_shell.dart';
import '../screens/community/creation/create_community_step1_page.dart';
import '../screens/community/creation/create_community_step2_page.dart';
import '../screens/community/creation/create_community_step3_page.dart';
import '../screens/community/creation/create_community_step4_page.dart';
import '../screens/community/creation/create_community_step5_page.dart';
import '../screens/community/rapport/detailed_report_page.dart';
import '../screens/community/rapport/financial_summary_page.dart';
import '../screens/community/tresorerie/contribution_detail_page.dart';
import '../screens/community/tresorerie/cycle_completed_page.dart';
import '../screens/community/tresorerie/disburse_funds_sheet.dart';
import '../screens/community/tresorerie/record_contribution_sheet.dart';
import '../screens/home/home_shell.dart';
import '../screens/kyc/kyc_capture_page.dart';
import '../screens/kyc/kyc_document_type_page.dart';
import '../screens/kyc/kyc_intro_page.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../screens/profil/edit_profile_page.dart';
import '../screens/profil/my_profile_page.dart';
import '../screens/profil/notifications_page.dart';
import '../screens/profil/preferences_page.dart';
import '../screens/profil/security_page.dart';
import '../utils/management/storage_manager.dart';
import 'app_routes.dart';

/// Table de routage centralisée. Les écrans ne connaissent que leurs
/// callbacks (onFinish, onContinue...) — c'est ici, et seulement ici,
/// que ces callbacks sont traduits en navigation réelle.
///
/// Depuis le passage au pattern "shell" (HomeShell / CommunityShell),
/// ajouter un nouvel onglet à l'accueil ou à l'espace communauté ne
/// touche plus qu'UN SEUL endroit (le shell concerné) — plus besoin de
/// câbler 5-6 écrans séparément comme avant.
class AppRouter {
  AppRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final sessionActive = ValueNotifier<bool>(false);

  static void _push(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(route, arguments: arguments);

  static Future<void> _pushAndWait(String route, {Object? arguments}) async {
    await navigatorKey.currentState!.pushNamed<Object?>(
      route,
      arguments: arguments,
    );
  }

  static void _replace(String route, {Object? arguments}) => navigatorKey
      .currentState!
      .pushReplacementNamed(route, arguments: arguments);

  static void _replaceAll(String route, {Object? arguments}) => navigatorKey
      .currentState!
      .pushNamedAndRemoveUntil(route, (r) => false, arguments: arguments);

  static void _openHome() {
    sessionActive.value = true;
    _replaceAll(AppRoutes.home);
  }

  static Future<void> _logout() async {
    sessionActive.value = false;
    await StorageManager.logout();
    _replaceAll(AppRoutes.authLanding);
  }

  static Future<void> lockSession() async {
    if (!sessionActive.value) return;

    final user = await StorageManager.getUser();
    if (user == null || user.telephone.isEmpty) {
      sessionActive.value = false;
      _replaceAll(AppRoutes.authLanding);
      return;
    }

    sessionActive.value = false;
    _replaceAll(
      AppRoutes.enterPin,
      arguments: {'telephone': user.telephone, 'locked': true},
    );
  }

  static void _pop() => navigatorKey.currentState!.pop();

  static void _popUntil(String route) =>
      navigatorKey.currentState!.popUntil(ModalRoute.withName(route));

  static void openCommunity(CommunityModel community) {
    if (community.cyclesLoaded && !community.hasCycle) {
      final type = switch (community.type.toUpperCase()) {
        'FAMILLE' => CommunityType.famille,
        'AMIS' => CommunityType.amis,
        'ENTREPRISE' => CommunityType.entreprise,
        'ASSOCIATION' => CommunityType.association,
        'AUTRE' => CommunityType.autre,
        _ => null,
      };
      _push(
        AppRoutes.createCommunityStep2,
        arguments: CommunityDraft(
          groupId: community.id,
          groupCode: community.groupCode,
          existingCommunity: community,
          name: community.name,
          description: community.description,
          type: type,
          expectedMemberCount: community.memberCount.toString(),
        ),
      );
      return;
    }
    _push(AppRoutes.communityShell, arguments: community);
  }

  static void _showRecordContributionSheet() {
    showModalBottomSheet(
      context: navigatorKey.currentState!.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Léger assombrissement — l'essentiel de la séparation visuelle
      // vient du flou (BackdropFilter) ci-dessous, pas d'un voile sombre.
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder:
          (sheetContext) => Stack(
            children: [
              // Flou plein écran qui laisse deviner la page derrière (nom
              // de la communauté visible en haut, comme sur la maquette).
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: const SizedBox.expand(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
                  ),
                  child: RecordContributionSheet(
                    // TODO (Njoya) : nom de communauté figé pour l'instant — le
                    // callback onQuickAction ne transporte que la clé de l'action,
                    // pas le contexte de la communauté active. À relier une fois
                    // l'API branchée.
                    communityName: 'Famille Bamiléké',
                    member: ContributionMockDatasource.memberDue,
                    onCancel: () => Navigator.of(sheetContext).pop(),
                    onSave: () {
                      Navigator.of(sheetContext).pop();
                      _push(AppRoutes.contributionDetail);
                    },
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static void _showDisburseFundsSheet(CommunityModel community) {
    showModalBottomSheet(
      context: navigatorKey.currentState!.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder:
          (sheetContext) => Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: const SizedBox.expand(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
                  ),
                  child: DisburseFundsSheet(
                    communityName: community.name,
                    beneficiary: CommunityBeneficiaryMockDatasource.current,
                    onCancel: () => Navigator.of(sheetContext).pop(),
                    onConfirm: () {
                      Navigator.of(sheetContext).pop();
                      _push(AppRoutes.cycleCompleted, arguments: community);
                    },
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static void _toggleLanguage() {
    final next = AppLocalizations.locale.value == 'fr' ? 'en' : 'fr';
    AppLocalizations.setLocale(next);
  }

  static CommunitySummary _communityMemberSummary(
    CommunityModel community, {
    required bool admin,
  }) {
    if (!community.membersLoaded) {
      return admin
          ? CommunityMembersMockDatasource.summaryAdmin
          : CommunityMembersMockDatasource.summaryMember;
    }

    final activeMembers =
        community.members
            .where((member) => member.active != '0' && member.statut == 'ACTIF')
            .length;
    final adminCount =
        community.members
            .where(
              (member) => member.role == 'ADMIN' || member.role == 'CO_ADMIN',
            )
            .length;

    return CommunitySummary(
      totalMembers: community.memberCount,
      adminCount: adminCount,
      activeCount: activeMembers,
      cycleLabel: '${community.cycleCurrent}/${community.cycleTotal}',
      lateCount:
          admin ? CommunityMembersMockDatasource.summaryAdmin.lateCount : null,
    );
  }

  static List<AdminMemberEntry> _adminMemberDirectory(
    CommunityModel community,
  ) {
    if (!community.membersLoaded) {
      return CommunityMembersMockDatasource.adminDirectory;
    }
    return List.generate(community.members.length, (index) {
      final member = community.members[index];
      final fallback =
          CommunityMembersMockDatasource.adminDirectory[index %
              CommunityMembersMockDatasource.adminDirectory.length];
      return AdminMemberEntry(
        name: member.displayName,
        role: member.role == 'MEMBRE' ? null : member.role,
        statusLine: fallback.statusLine,
        statusIcon: fallback.statusIcon,
        statusColor: fallback.statusColor,
        isHighlighted: fallback.isHighlighted,
        hasUrgentAction: fallback.hasUrgentAction,
      );
    });
  }

  static List<MemberDirectoryEntry> _memberDirectory(CommunityModel community) {
    if (!community.membersLoaded)
      return CommunityMembersMockDatasource.directory;
    return List.generate(community.members.length, (index) {
      final member = community.members[index];
      final fallback =
          CommunityMembersMockDatasource.directory[index %
              CommunityMembersMockDatasource.directory.length];
      return MemberDirectoryEntry(
        name: member.displayName,
        role: member.role == 'MEMBRE' ? null : member.role,
        memberSinceLabel:
            member.dateAdhesion?.split('T').first ?? fallback.memberSinceLabel,
        status: fallback.status,
        isHighlighted: fallback.isHighlighted,
      );
    });
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Fonction locale qui masque volontairement l'ancienne méthode
    // statique du même nom : chaque route créée porte désormais son
    // vrai nom (settings), ce qui est indispensable pour que
    // _popUntil (utilisé par "Modifier" en Étape 5) puisse la
    // retrouver dans la pile de navigation.
    PageRoute page(Widget child) => MaterialPageRoute(
      settings: settings,
      builder:
          (context) => ValueListenableBuilder<String>(
            valueListenable: AppLocalizations.locale,
            builder: (context, languageCode, _) {
              // Une clé liée à isCurrent détruit l'état de la page à chaque dialogue ouvert par-dessus.
              return KeyedSubtree(key: ValueKey(languageCode), child: child);
            },
          ),
    );

    switch (settings.name) {
      case AppRoutes.onboarding:
        return page(
          OnboardingPage(onFinish: () => _replace(AppRoutes.authLanding)),
        );

      case AppRoutes.authLanding:
        return page(
          AuthLandingPage(
            onCreateAccount: () => _push(AppRoutes.registerPhone),
            onLogin: () => _push(AppRoutes.loginPhone),
            onLanguageToggle: _toggleLanguage,
            onTermsTap:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: "Conditions d'utilisation",
                ),
            onPrivacyTap:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Politique de confidentialité',
                ),
          ),
        );

      // ---------------- Inscription ----------------

      case AppRoutes.registerPhone:
        return page(
          RegisterPhonePage(
            onBack: _pop,
            onLogin: () => _push(AppRoutes.loginPhone),
            onContinue:
                (phone) => _push(AppRoutes.registerOtp, arguments: phone),
          ),
        );

      case AppRoutes.registerOtp:
        final phone = settings.arguments as String;
        return page(
          VerifyOtpPage(
            phoneNumber: phone,
            step: 2,
            totalSteps: 4,
            onBack: _pop,
            onEditNumber: _pop,
            onResend: () {},
            onVerified: (code) async {
              final authController = AuthController();
              try {
                final response = await authController.register(
                  telephone: phone,
                  code: code,
                );

                if (response['success'] != true) {
                  throw Exception(
                    response['message'] ?? AppLocalizations.t('register_error'),
                  );
                }

                _push(AppRoutes.createPin, arguments: phone);
              } finally {
                authController.dispose();
              }
            },
          ),
        );

      case AppRoutes.createPin:
        final createPinArgs =
            settings.arguments is Map ? settings.arguments as Map : null;
        final phone =
            createPinArgs?['telephone'] as String? ??
            (settings.arguments is String ? settings.arguments as String : '');
        final isPinChange = createPinArgs?['changePin'] == true;
        final isPinReset = createPinArgs?['resetPin'] == true;
        final resetToken = createPinArgs?['resetToken'] as String?;
        return page(
          CreatePinPage(
            phoneNumber: phone,
            onBack: _pop,
            step: isPinChange ? 2 : 3,
            totalSteps: isPinChange ? 3 : 4,
            onPinCreated: (pin) {
              _push(
                AppRoutes.confirmPin,
                arguments: {
                  'pin': pin,
                  'telephone': phone,
                  'changePin': isPinChange,
                  'resetPin': isPinReset,
                  'resetToken': resetToken,
                },
              );
            },
          ),
        );

      case AppRoutes.confirmPin:
        final args = settings.arguments is Map ? settings.arguments as Map : {};
        final originalPin = (args['pin'] ?? '') as String;
        final telephone = (args['telephone'] ?? '') as String;
        final isPinChange = args['changePin'] == true;
        final isPinReset = args['resetPin'] == true;
        final resetToken = args['resetToken'] as String?;

        return page(
          ConfirmPinPage(
            originalPin: originalPin,
            telephone: telephone,
            onBack: _pop,
            resetToken: resetToken,
            step: isPinChange ? 3 : 4,
            totalSteps: isPinChange ? 3 : 4,
            onConfirmed: (_) {
              if (isPinChange) {
                _popUntil(AppRoutes.security);
              } else if (isPinReset) {
                _replaceAll(AppRoutes.enterPin, arguments: telephone);
              } else {
                _openHome();
              }
            },
          ),
        );

      case AppRoutes.pinCreated:
        final originalPin =
            settings.arguments is String ? settings.arguments as String : '';
        return page(
          PinCreatedPage(
            onContinue: () {
              if (originalPin.isNotEmpty) {
                _replace(AppRoutes.confirmPin, arguments: originalPin);
              } else {
                _replace(AppRoutes.confirmPin, arguments: '');
              }
            },
          ),
        );

      case AppRoutes.welcome:
        return page(
          WelcomePage(
            onBack: _pop,
            onStart: _openHome,
            onSetupProfile: () => _push(AppRoutes.editProfile),
          ),
        );

      // ---------------- Connexion ----------------

      case AppRoutes.loginPhone:
        final isForgotPin =
            settings.arguments is Map &&
            (settings.arguments as Map)['forgotPin'] == true;
        return page(
          LoginPhonePage(
            onBack: _pop,
            onRegister: () => _push(AppRoutes.registerPhone),
            onContinue:
                (phone) => _push(
                  AppRoutes.loginOtp,
                  arguments: {'telephone': phone, 'forgotPin': isForgotPin},
                ),
          ),
        );

      case AppRoutes.loginOtp:
        final otpArgs =
            settings.arguments is Map ? settings.arguments as Map : null;
        final phone =
            otpArgs?['telephone'] as String? ??
            (settings.arguments is String ? settings.arguments as String : '');
        final isForgotPin = otpArgs?['forgotPin'] == true;
        return page(
          VerifyOtpPage(
            phoneNumber: phone,
            step: 2,
            totalSteps: 3,
            onBack: _pop,
            onEditNumber: _pop,
            onResend: () {},
            onVerified: (code) async {
              final authController = AuthController();
              try {
                final response =
                    isForgotPin
                        ? await authController.verifyResetOtp(
                          telephone: phone,
                          code: code,
                        )
                        : await authController.verifyLoginOtp(
                          telephone: phone,
                          code: code,
                        );
                if (response['success'] != true) {
                  throw Exception(
                    response['message'] ??
                        AppLocalizations.t('pin_status_unavailable'),
                  );
                }

                if (!isForgotPin && response['has_pin'] == true) {
                  _push(AppRoutes.enterPin, arguments: phone);
                  return;
                }

                final resetToken = response['reset_token'] as String?;
                if (resetToken == null || resetToken.isEmpty) {
                  throw Exception(AppLocalizations.t('pin_status_unavailable'));
                }

                _push(
                  AppRoutes.createPin,
                  arguments: {
                    'telephone': phone,
                    'resetPin': true,
                    'resetToken': resetToken,
                  },
                );
              } finally {
                authController.dispose();
              }
            },
          ),
        );

      case AppRoutes.enterPin:
        final isLocked =
            settings.arguments is Map &&
            (settings.arguments as Map)['locked'] == true;
        final isPinChange =
            settings.arguments is Map &&
            (settings.arguments as Map)['changePin'] == true;
        final phone =
            settings.arguments is Map
                ? (settings.arguments as Map)['telephone'] as String? ?? ''
                : settings.arguments as String? ?? '';
        return page(
          EnterPinPage(
            phoneNumber: phone,
            onBack: isLocked ? () {} : _pop,
            canGoBack: !isLocked,
            allowBiometricUnlock: isLocked,
            onForgotPin:
                () =>
                    _push(AppRoutes.loginPhone, arguments: {'forgotPin': true}),
            onPinEntered: (_) {
              if (isPinChange) {
                _push(
                  AppRoutes.createPin,
                  arguments: {'telephone': phone, 'changePin': true},
                );
              } else {
                _openHome();
              }
            },
          ),
        );

      // ---------------- Accueil (shell) ----------------

      case AppRoutes.home:
        return page(
          HomeShell(
            communities: CommunityMockDatasource.empty,
            isProfileComplete: false,
            onIdentify: () => _push(AppRoutes.kycIntro),
            // Une seule route pour toute communauté, quel que soit son
            // rôle — le shell décide lui-même de la variante à afficher.
            onCommunityTap: openCommunity,
            onAddCommunity: () => _pushAndWait(AppRoutes.createCommunityStep1),
            notifications: NotificationFeedMockDatasource.items,
            user: ProfileMockDatasource.user,
            profileActivity: ProfileMockDatasource.activity,
            profileCommunities: const [],
            onProfileCommunityTap: (c) => openCommunity(c.community),
            onOpenMyProfile: () => _pushAndWait(AppRoutes.myProfile),
            onOpenSecurity: () => _push(AppRoutes.security),
            onOpenNotifications: () => _push(AppRoutes.notifications),
            onOpenPreferences: () => _push(AppRoutes.preferences),
            onOpenHelp: () => _push(AppRoutes.comingSoon, arguments: 'Aide'),
            onOpenAbout:
                () => _push(AppRoutes.comingSoon, arguments: 'À propos'),
            onLogout: _logout,
          ),
        );

      // ---------------- Espace communauté (shell) ----------------
      //
      // Une seule route pour Tableau de Bord + Trésorerie + Membres +
      // Profil (avant : 5 routes séparées). Le shell bascule seul entre
      // les variantes admin/membre selon community.role.

      case AppRoutes.communityShell:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        final isAdmin = community.role == 'ADMIN';
        final adminSummary = _communityMemberSummary(community, admin: true);
        final memberSummary = _communityMemberSummary(community, admin: false);
        final adminDirectory = _adminMemberDirectory(community);
        final memberDirectory = _memberDirectory(community);
        return page(
          CommunityShell(
            community: community,
            onBack: _pop,
            // Dashboard — TODO (Njoya) : mock commun à toutes les
            // communautés pour l'instant, à individualiser avec l'API.
            health: CommunityAdminMockDatasource.health,
            adminPriorities: CommunityAdminMockDatasource.priorities,
            memberRequiredActions:
                CommunityMemberMockDatasource.requiredActions,
            adminCycle: CommunityAdminMockDatasource.cycle,
            memberCycle: CommunityMemberMockDatasource.cycle,
            adminMemberStatus: CommunityAdminMockDatasource.memberStatus,
            memberMemberStatus: CommunityMemberMockDatasource.memberStatus,
            loans: CommunityAdminMockDatasource.loans,
            dashboardActivity:
                isAdmin
                    ? CommunityAdminMockDatasource.activity
                    : CommunityMemberMockDatasource.activity,
            onQuickAction: (action) {
              if (action == 'contributions') {
                _showRecordContributionSheet();
                return;
              }
              if (action == 'reports') {
                _push(AppRoutes.financialSummary, arguments: community);
                return;
              }
              _push(AppRoutes.comingSoon, arguments: action);
            },
            onPriorityTap:
                (p) => _push(AppRoutes.comingSoon, arguments: p.label),
            onSeeAllActivity:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: "Historique d'activité",
                ),
            onActionPay:
                (item) =>
                    _push(AppRoutes.comingSoon, arguments: item.actionLabel),
            onActionTap:
                (item) => _push(AppRoutes.comingSoon, arguments: item.title),
            // Trésorerie
            financialPosition:
                CommunityTreasuryMockDatasource.financialPosition,
            receipt: CommunityTreasuryMockDatasource.receipt,
            history: CommunityTreasuryMockDatasource.history,
            collection: CommunityTreasuryMockDatasource.collection,
            memberContributions:
                CommunityTreasuryMockDatasource.memberContributions,
            // TODO (Njoya) : mets loan/loanDue à CommunityTreasuryMockDatasource.loan /
            // .loanDue (au lieu de null) pour retester l'état "prêt actif".
            loan: null,
            loanDue: null,
            eligibility: CommunityTreasuryMockDatasource.eligibility,
            repaymentHistory: CommunityTreasuryMockDatasource.repaymentHistory,
            onSeeReceipt: () => _push(AppRoutes.comingSoon, arguments: 'Reçu'),
            onHistoryItemTap:
                (item) =>
                    _push(AppRoutes.comingSoon, arguments: item.cycleLabel),
            onSeeAllHistory:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Historique complet',
                ),
            onOpenDetailedReport:
                () => _push(AppRoutes.detailedReport, arguments: community),
            onRequestLoan:
                () =>
                    _push(AppRoutes.comingSoon, arguments: 'Demander un prêt'),
            currentBeneficiary: CommunityBeneficiaryMockDatasource.current,
            beneficiaryStats: CommunityBeneficiaryMockDatasource.stats,
            passageOrder: CommunityBeneficiaryMockDatasource.passageOrder,
            payoutHistory: CommunityBeneficiaryMockDatasource.payoutHistory,
            onDisburse: () => _showDisburseFundsSheet(community),
            onSeeAllPayoutHistory:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Historique des versements',
                ),
            // Membres
            adminSummary: adminSummary,
            memberSummary: memberSummary,
            adminDirectory: adminDirectory,
            memberDirectory: memberDirectory,
            growth: CommunityMembersMockDatasource.growth,
            trustScore: CommunityMembersMockDatasource.trustScore,
            onInviteMember:
                () =>
                    _push(AppRoutes.comingSoon, arguments: 'Inviter un membre'),
            onMemberMenuTap:
                (m) => _push(AppRoutes.comingSoon, arguments: m.name),
            onMemberUrgentAction:
                (m) => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Relancer ${m.name}',
                ),
            onMemberTap: (m) => _push(AppRoutes.comingSoon, arguments: m.name),
            // Profil (même contenu que dans HomeShell)
            user: ProfileMockDatasource.user,
            profileActivity: ProfileMockDatasource.activity,
            profileCommunities: ProfileMockDatasource.communities,
            onProfileCommunityTap:
                (c) => _push(AppRoutes.communityShell, arguments: c.community),
            onOpenMyProfile: () => _pushAndWait(AppRoutes.myProfile),
            onOpenSecurity: () => _push(AppRoutes.security),
            onOpenNotifications: () => _push(AppRoutes.notifications),
            onOpenPreferences: () => _push(AppRoutes.preferences),
            onOpenHelp: () => _push(AppRoutes.comingSoon, arguments: 'Aide'),
            onOpenAbout:
                () => _push(AppRoutes.comingSoon, arguments: 'À propos'),
            onLogout: _logout,
          ),
        );

      // ---------------- Profil (sous-pages poussées) ----------------

      case AppRoutes.myProfile:
        return page(
          MyProfilePage(
            user: ProfileMockDatasource.user,
            onBack: _pop,
            onEditInfo: () => _pushAndWait(AppRoutes.editProfile),
          ),
        );

      case AppRoutes.editProfile:
        return page(
          EditProfilePage(
            onCancel: _pop,
            onSave: _pop,
            onChangeNumber:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Modifier le numéro',
                ),
          ),
        );

      case AppRoutes.security:
        return page(
          SecurityPage(
            status: ProfileMockDatasource.security,
            onBack: _pop,
            onChangePin: () async {
              final user = await StorageManager.getUser();
              if (user == null || user.telephone.isEmpty) return;
              _push(
                AppRoutes.enterPin,
                arguments: {'telephone': user.telephone, 'changePin': true},
              );
            },
            onOpenConnectedDevices:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Appareils connectés',
                ),
            onLogoutAllDevices:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Déconnecter tous les appareils',
                ),
          ),
        );

      case AppRoutes.notifications:
        return page(
          NotificationsPage(
            masterEnabled: NotificationSettingsMockDatasource.masterEnabled,
            sections: NotificationSettingsMockDatasource.sections,
            onBack: _pop,
          ),
        );

      case AppRoutes.preferences:
        return page(
          PreferencesPage(
            onBack: _pop,
            onOpenAppearance:
                () => _push(AppRoutes.comingSoon, arguments: 'Apparence'),
            onOpenCurrency:
                () => _push(AppRoutes.comingSoon, arguments: 'Devise'),
            onOpenRegionalFormat:
                () => _push(AppRoutes.comingSoon, arguments: 'Format régional'),
          ),
        );

      case AppRoutes.createCommunityStep1:
        final draft =
            settings.arguments as CommunityDraft? ?? const CommunityDraft();
        return page(
          CreateCommunityStep1Page(
            draft: draft,
            onBack: _pop,
            onContinue:
                (updated) =>
                    _push(AppRoutes.createCommunityStep2, arguments: updated),
          ),
        );

      case AppRoutes.createCommunityStep2:
        final draft = settings.arguments as CommunityDraft;
        return page(
          CreateCommunityStep2Page(
            draft: draft,
            onBack: _pop,
            onContinue:
                (updated) =>
                    _push(AppRoutes.createCommunityStep3, arguments: updated),
          ),
        );

      case AppRoutes.createCommunityStep3:
        final draft = settings.arguments as CommunityDraft;
        return page(
          CreateCommunityStep3Page(
            draft: draft,
            onBack: _pop,
            onContinue:
                (updated) => _push(
                  AppRoutes.createCommunityStep4,
                  arguments:
                      updated.invitedMembers.isEmpty
                          ? updated.copyWith(
                            invitedMembers:
                                CreateCommunityMockDatasource.initialInvites,
                          )
                          : updated,
                ),
          ),
        );

      case AppRoutes.createCommunityStep4:
        final draft = settings.arguments as CommunityDraft;
        return page(
          CreateCommunityStep4Page(
            draft: draft,
            onBack: _pop,
            onContinue:
                (updated) =>
                    _push(AppRoutes.createCommunityStep5, arguments: updated),
            onGenerateLink:
                () =>
                    _push(AppRoutes.comingSoon, arguments: "Lien d'invitation"),
            onShowQrCode:
                () => _push(AppRoutes.comingSoon, arguments: 'QR Code'),
            onInviteByNumber:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Inviter par numéro',
                ),
            onChooseContacts:
                () =>
                    _push(AppRoutes.comingSoon, arguments: 'Choisir contacts'),
          ),
        );

      case AppRoutes.createCommunityStep5:
        final draft = settings.arguments as CommunityDraft;
        return page(
          CreateCommunityStep5Page(
            draft: draft,
            onBack: _pop,
            onCreate: () async {
              final groupId = draft.groupId;
              if (groupId == null || groupId.isEmpty) {
                return AppLocalizations.t('cycle_group_missing');
              }

              final result = await CycleController.createForGroup(
                groupId: groupId,
                draft: draft,
              );
              if (result['success'] != true) {
                return result['message']?.toString() ??
                    AppLocalizations.t('cycle_create_error');
              }

              _replaceAll(AppRoutes.home);
              return null;
            },
            onEditFinancial: () => _popUntil(AppRoutes.createCommunityStep2),
            onEditRules: () => _popUntil(AppRoutes.createCommunityStep3),
            onEditMembers: () => _popUntil(AppRoutes.createCommunityStep4),
          ),
        );

      case AppRoutes.contributionDetail:
        return page(
          ContributionDetailPage(
            detail: ContributionMockDatasource.detail,
            onBack: _pop,
            onShareReceipt:
                () =>
                    _push(AppRoutes.comingSoon, arguments: 'Partager le reçu'),
            onModify: () => _push(AppRoutes.comingSoon, arguments: 'Modifier'),
            // TODO (Njoya) : pas de vraie suppression — retour simple pour l'instant.
            onCancelRecording: _pop,
          ),
        );

      case AppRoutes.financialSummary:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        return page(
          FinancialSummaryPage(
            communityName: community.name,
            cycleLabel:
                'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
            role: community.role,
            summary: ReportMockDatasource.summary,
            evolution: ReportMockDatasource.contributionEvolution,
            participation: ReportMockDatasource.participation,
            loanDetails: ReportMockDatasource.loanDetails,
            recentActivity: ReportMockDatasource.recentActivity,
            onBack: _pop,
            onExport:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Exporter le rapport',
                ),
            onSeeFullHistory:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: "Historique d'activité",
                ),
            onOpenDetailedReport:
                () => _push(AppRoutes.detailedReport, arguments: community),
          ),
        );

      case AppRoutes.detailedReport:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        return page(
          DetailedReportPage(
            communityName: community.name,
            role: community.role,
            summary: ReportMockDatasource.detailedSummary,
            evolution: ReportMockDatasource.versementsEvolution,
            transactions: ReportMockDatasource.transactions,
            onBack: _pop,
            onSeeAllTransactions:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Toutes les opérations',
                ),
            onExport:
                () => _push(AppRoutes.comingSoon, arguments: 'Exporter PDF'),
          ),
        );

      case AppRoutes.cycleCompleted:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        return page(
          CycleCompletedPage(
            communityName: community.name,
            cycleLabel:
                'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
            role: community.role,
            closedDateLabel: CycleCompletionMockDatasource.closedDateLabel,
            stats: CycleCompletionMockDatasource.stats,
            beneficiaryHistory:
                CycleCompletionMockDatasource.beneficiaryHistory,
            onBack: _pop,
            onSeeFullList:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Liste complète des bénéficiaires',
                ),
            onExportReport:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Exporter le rapport',
                ),
            onStartNewCycle:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Démarrer un nouveau cycle',
                ),
            onSeeCyclesHistory:
                () => _push(
                  AppRoutes.comingSoon,
                  arguments: 'Historique des cycles',
                ),
          ),
        );

      case AppRoutes.kycIntro:
        return page(
          KycIntroPage(
            onBack: _pop,
            onStart: () => _push(AppRoutes.kycDocumentType),
            onLater: _pop,
          ),
        );

      case AppRoutes.kycDocumentType:
        return page(
          KycDocumentTypePage(
            options: KycMockDatasource.documentOptions,
            onBack: _pop,
            onContinue:
                (docType) => _push(
                  AppRoutes.kycCapture,
                  arguments: {'documentType': docType, 'isBackSide': false},
                ),
          ),
        );

      case AppRoutes.kycCapture:
        final args = settings.arguments is Map ? settings.arguments as Map : {};
        final documentType =
            args['documentType'] as KycDocumentTypeId? ??
            KycDocumentTypeId.nationalId;
        final isBackSide = args['isBackSide'] == true;
        final frontPath = args['frontPath'] as String?;
        return page(
          KycCapturePage(
            documentType: documentType,
            isBackSide: isBackSide,
            onBack: _pop,
            onPhotoReady: (path) async {
              if (!isBackSide && documentType != KycDocumentTypeId.passport) {
                _push(
                  AppRoutes.kycCapture,
                  arguments: {
                    'documentType': documentType,
                    'isBackSide': true,
                    'frontPath': path,
                  },
                );
                return null;
              }

              final user = await StorageManager.getUser();
              if (user == null) {
                return AppLocalizations.t('profile_load_error');
              }

              final documents = <String, File>{};
              if (documentType == KycDocumentTypeId.passport) {
                documents['passport'] = File(path);
              } else {
                if (frontPath == null || frontPath.isEmpty) {
                  return AppLocalizations.t('kyc_capture_error');
                }
                documents['cni_recto'] = File(frontPath);
                documents['cni_verso'] = File(path);
              }

              final response = await UserController.updateProfile(
                userId: user.id,
                data: const {},
                documents: documents,
              );
              if (response['success'] != true) {
                return response['message']?.toString() ??
                    AppLocalizations.t('kyc_save_error');
              }

              _replaceAll(AppRoutes.home);
              return null;
            },
          ),
        );

      // ---------------- Partagé ----------------

      case AppRoutes.phoneVerified:
        final nextRoute = settings.arguments as String;
        return page(PhoneVerifiedPage(onContinue: () => _replace(nextRoute)));

      case AppRoutes.comingSoon:
        final label = settings.arguments as String? ?? '';
        return page(ComingSoonPage(label: label));

      default:
        return page(
          OnboardingPage(onFinish: () => _replace(AppRoutes.authLanding)),
        );
    }
  }
}

/// Filet de sécurité pour le web : après un hot restart (ou un
/// rafraîchissement de page) alors que l'URL du navigateur pointe vers
/// une route de communauté, Flutter reconstruit cette route à partir de
/// l'URL seule — l'objet CommunityModel qui était en mémoire (passé en
/// argument) est perdu, settings.arguments devient null. Plutôt que de
/// planter (TypeError: Null n'est pas CommunityModel), on redirige
/// proprement vers l'accueil, le temps que l'utilisateur re-sélectionne
/// sa communauté.
class _MissingCommunityRedirect extends StatefulWidget {
  const _MissingCommunityRedirect();

  @override
  State<_MissingCommunityRedirect> createState() =>
      _MissingCommunityRedirectState();
}

class _MissingCommunityRedirectState extends State<_MissingCommunityRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AppRouter._replaceAll(AppRoutes.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

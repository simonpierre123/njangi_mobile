import 'dart:ui';

import 'package:flutter/material.dart';
import '../Models/community_model.dart';
import '../Models/create_community_model.dart';
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
import '../datasource/notification_feed_mock_datasource.dart';
import '../datasource/notification_settings_mock_datasource.dart';
import '../datasource/preferences_mock_datasource.dart';
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
import '../screens/onboarding/onboarding_page.dart';
import '../screens/profil/edit_profile_page.dart';
import '../screens/profil/my_profile_page.dart';
import '../screens/profil/notifications_page.dart';
import '../screens/profil/preferences_page.dart';
import '../screens/profil/security_page.dart';
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

  static void _push(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(route, arguments: arguments);

  static void _replace(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushReplacementNamed(route, arguments: arguments);

  static void _replaceAll(String route) =>
      navigatorKey.currentState!.pushNamedAndRemoveUntil(route, (r) => false);

  static void _pop() => navigatorKey.currentState!.pop();

  static void _popUntil(String route) =>
      navigatorKey.currentState!.popUntil(ModalRoute.withName(route));

  static void _showRecordContributionSheet() {
    showModalBottomSheet(
      context: navigatorKey.currentState!.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Léger assombrissement — l'essentiel de la séparation visuelle
      // vient du flou (BackdropFilter) ci-dessous, pas d'un voile sombre.
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder: (sheetContext) => Stack(
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
      builder: (sheetContext) => Stack(
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

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Fonction locale qui masque volontairement l'ancienne méthode
    // statique du même nom : chaque route créée porte désormais son
    // vrai nom (settings), ce qui est indispensable pour que
    // _popUntil (utilisé par "Modifier" en Étape 5) puisse la
    // retrouver dans la pile de navigation.
    PageRoute page(Widget child) => MaterialPageRoute(settings: settings, builder: (_) => child);

    switch (settings.name) {
      case AppRoutes.onboarding:
        return page(OnboardingPage(
          onFinish: () => _replace(AppRoutes.authLanding),
        ));

      case AppRoutes.authLanding:
        return page(AuthLandingPage(
          onCreateAccount: () => _push(AppRoutes.registerPhone),
          onLogin: () => _push(AppRoutes.loginPhone),
          onLanguageToggle: _toggleLanguage,
          onTermsTap: () =>
              _push(AppRoutes.comingSoon, arguments: "Conditions d'utilisation"),
          onPrivacyTap: () => _push(
            AppRoutes.comingSoon,
            arguments: 'Politique de confidentialité',
          ),
        ));

      // ---------------- Inscription ----------------

      case AppRoutes.registerPhone:
        return page(RegisterPhonePage(
          onBack: _pop,
          onLogin: () => _push(AppRoutes.loginPhone),
          onContinue: (phone) => _push(AppRoutes.registerOtp, arguments: phone),
        ));

      case AppRoutes.registerOtp:
        final phone = settings.arguments as String;
        return page(VerifyOtpPage(
          phoneNumber: phone,
          step: 2,
          totalSteps: 4,
          onBack: _pop,
          onEditNumber: _pop,
          onResend: () {},
          onVerified: (_) =>
              _replace(AppRoutes.phoneVerified, arguments: AppRoutes.createPin),
        ));

      case AppRoutes.createPin:
        return page(CreatePinPage(
          onBack: _pop,
          onPinCreated: (pin) => _push(AppRoutes.confirmPin, arguments: pin),
        ));

      case AppRoutes.confirmPin:
        final originalPin = settings.arguments as String;
        return page(ConfirmPinPage(
          originalPin: originalPin,
          onBack: _pop,
          onConfirmed: (_) => _replace(AppRoutes.pinCreated),
        ));

      case AppRoutes.pinCreated:
        return page(PinCreatedPage(
          onContinue: () => _replace(AppRoutes.welcome),
        ));

      case AppRoutes.welcome:
        return page(WelcomePage(
          onBack: _pop,
          onStart: () => _replace(AppRoutes.home),
          onSetupProfile: () => _push(AppRoutes.editProfile),
        ));

      // ---------------- Connexion ----------------

      case AppRoutes.loginPhone:
        return page(LoginPhonePage(
          onBack: _pop,
          onRegister: () => _push(AppRoutes.registerPhone),
          onContinue: (phone) => _push(AppRoutes.loginOtp, arguments: phone),
        ));

      case AppRoutes.loginOtp:
        final phone = settings.arguments as String;
        return page(VerifyOtpPage(
          phoneNumber: phone,
          step: 2,
          totalSteps: 3,
          onBack: _pop,
          onEditNumber: _pop,
          onResend: () {},
          onVerified: (_) =>
              _replace(AppRoutes.phoneVerified, arguments: AppRoutes.enterPin),
        ));

      case AppRoutes.enterPin:
        return page(EnterPinPage(
          onBack: _pop,
          onForgotPin: () =>
              _push(AppRoutes.comingSoon, arguments: 'Réinitialiser mon code'),
          onSubmit: (_) => _replace(AppRoutes.home),
        ));

      // ---------------- Accueil (shell) ----------------

      case AppRoutes.home:
        return page(HomeShell(
          // TODO (Njoya) : remplacer par le vrai nom/état venant de l'API.
          userName: 'Alex',
          communities: CommunityMockDatasource.sample,
          isProfileComplete: false,
          onIdentify: () => _push(AppRoutes.comingSoon, arguments: 'Identification'),
          // Une seule route pour toute communauté, quel que soit son
          // rôle — le shell décide lui-même de la variante à afficher.
          onCommunityTap: (c) => _push(AppRoutes.communityShell, arguments: c),
          onAddCommunity: () => _push(AppRoutes.createCommunityStep1),
          notifications: NotificationFeedMockDatasource.items,
          user: ProfileMockDatasource.user,
          profileActivity: ProfileMockDatasource.activity,
          profileCommunities: ProfileMockDatasource.communities,
          onProfileCommunityTap: (c) => _push(AppRoutes.communityShell, arguments: c.community),
          onOpenMyProfile: () => _push(AppRoutes.myProfile),
          onOpenSecurity: () => _push(AppRoutes.security),
          onOpenNotifications: () => _push(AppRoutes.notifications),
          onOpenPreferences: () => _push(AppRoutes.preferences),
          onOpenHelp: () => _push(AppRoutes.comingSoon, arguments: 'Aide'),
          onOpenAbout: () => _push(AppRoutes.comingSoon, arguments: 'À propos'),
          onLogout: () => _replaceAll(AppRoutes.authLanding),
        ));

      // ---------------- Espace communauté (shell) ----------------
      //
      // Une seule route pour Tableau de Bord + Trésorerie + Membres +
      // Profil (avant : 5 routes séparées). Le shell bascule seul entre
      // les variantes admin/membre selon community.role.

      case AppRoutes.communityShell:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        final isAdmin = community.role == 'ADMIN';
        return page(CommunityShell(
          community: community,
          onBack: _pop,
          // Dashboard — TODO (Njoya) : mock commun à toutes les
          // communautés pour l'instant, à individualiser avec l'API.
          health: CommunityAdminMockDatasource.health,
          adminPriorities: CommunityAdminMockDatasource.priorities,
          memberRequiredActions: CommunityMemberMockDatasource.requiredActions,
          adminCycle: CommunityAdminMockDatasource.cycle,
          memberCycle: CommunityMemberMockDatasource.cycle,
          adminMemberStatus: CommunityAdminMockDatasource.memberStatus,
          memberMemberStatus: CommunityMemberMockDatasource.memberStatus,
          loans: CommunityAdminMockDatasource.loans,
          dashboardActivity:
              isAdmin ? CommunityAdminMockDatasource.activity : CommunityMemberMockDatasource.activity,
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
          onPriorityTap: (p) => _push(AppRoutes.comingSoon, arguments: p.label),
          onSeeAllActivity: () =>
              _push(AppRoutes.comingSoon, arguments: "Historique d'activité"),
          onActionPay: (item) => _push(AppRoutes.comingSoon, arguments: item.actionLabel),
          onActionTap: (item) => _push(AppRoutes.comingSoon, arguments: item.title),
          // Trésorerie
          financialPosition: CommunityTreasuryMockDatasource.financialPosition,
          receipt: CommunityTreasuryMockDatasource.receipt,
          history: CommunityTreasuryMockDatasource.history,
          collection: CommunityTreasuryMockDatasource.collection,
          memberContributions: CommunityTreasuryMockDatasource.memberContributions,
          // TODO (Njoya) : mets loan/loanDue à CommunityTreasuryMockDatasource.loan /
          // .loanDue (au lieu de null) pour retester l'état "prêt actif".
          loan: null,
          loanDue: null,
          eligibility: CommunityTreasuryMockDatasource.eligibility,
          repaymentHistory: CommunityTreasuryMockDatasource.repaymentHistory,
          onSeeReceipt: () => _push(AppRoutes.comingSoon, arguments: 'Reçu'),
          onHistoryItemTap: (item) => _push(AppRoutes.comingSoon, arguments: item.cycleLabel),
          onSeeAllHistory: () =>
              _push(AppRoutes.comingSoon, arguments: 'Historique complet'),
          onOpenDetailedReport: () => _push(AppRoutes.detailedReport, arguments: community),
          onRequestLoan: () => _push(AppRoutes.comingSoon, arguments: 'Demander un prêt'),
          currentBeneficiary: CommunityBeneficiaryMockDatasource.current,
          beneficiaryStats: CommunityBeneficiaryMockDatasource.stats,
          passageOrder: CommunityBeneficiaryMockDatasource.passageOrder,
          payoutHistory: CommunityBeneficiaryMockDatasource.payoutHistory,
          onDisburse: () => _showDisburseFundsSheet(community),
          onSeeAllPayoutHistory: () =>
              _push(AppRoutes.comingSoon, arguments: 'Historique des versements'),
          // Membres
          adminSummary: CommunityMembersMockDatasource.summaryAdmin,
          memberSummary: CommunityMembersMockDatasource.summaryMember,
          adminDirectory: CommunityMembersMockDatasource.adminDirectory,
          memberDirectory: CommunityMembersMockDatasource.directory,
          growth: CommunityMembersMockDatasource.growth,
          trustScore: CommunityMembersMockDatasource.trustScore,
          onInviteMember: () => _push(AppRoutes.comingSoon, arguments: 'Inviter un membre'),
          onMemberMenuTap: (m) => _push(AppRoutes.comingSoon, arguments: m.name),
          onMemberUrgentAction: (m) =>
              _push(AppRoutes.comingSoon, arguments: 'Relancer ${m.name}'),
          onMemberTap: (m) => _push(AppRoutes.comingSoon, arguments: m.name),
          // Profil (même contenu que dans HomeShell)
          user: ProfileMockDatasource.user,
          profileActivity: ProfileMockDatasource.activity,
          profileCommunities: ProfileMockDatasource.communities,
          onProfileCommunityTap: (c) => _push(AppRoutes.communityShell, arguments: c.community),
          onOpenMyProfile: () => _push(AppRoutes.myProfile),
          onOpenSecurity: () => _push(AppRoutes.security),
          onOpenNotifications: () => _push(AppRoutes.notifications),
          onOpenPreferences: () => _push(AppRoutes.preferences),
          onOpenHelp: () => _push(AppRoutes.comingSoon, arguments: 'Aide'),
          onOpenAbout: () => _push(AppRoutes.comingSoon, arguments: 'À propos'),
          onLogout: () => _replaceAll(AppRoutes.authLanding),
        ));

      // ---------------- Profil (sous-pages poussées) ----------------

      case AppRoutes.myProfile:
        return page(MyProfilePage(
          user: ProfileMockDatasource.user,
          onBack: _pop,
          onEditInfo: () => _push(AppRoutes.editProfile),
        ));

      case AppRoutes.editProfile:
        return page(EditProfilePage(
          user: ProfileMockDatasource.user,
          onCancel: _pop,
          onSave: _pop,
          onChangePhoto: () => _push(AppRoutes.comingSoon, arguments: 'Modifier la photo'),
          onChangeNumber: () => _push(AppRoutes.comingSoon, arguments: 'Modifier le numéro'),
        ));

      case AppRoutes.security:
        return page(SecurityPage(
          status: ProfileMockDatasource.security,
          onBack: _pop,
          onChangePin: () => _push(AppRoutes.comingSoon, arguments: 'Modifier le code PIN'),
          onOpenConnectedDevices: () =>
              _push(AppRoutes.comingSoon, arguments: 'Appareils connectés'),
          onLogoutAllDevices: () =>
              _push(AppRoutes.comingSoon, arguments: 'Déconnecter tous les appareils'),
        ));

      case AppRoutes.notifications:
        return page(NotificationsPage(
          masterEnabled: NotificationSettingsMockDatasource.masterEnabled,
          sections: NotificationSettingsMockDatasource.sections,
          onBack: _pop,
        ));

      case AppRoutes.preferences:
        return page(PreferencesPage(
          onBack: _pop,
          onOpenAppearance: () => _push(AppRoutes.comingSoon, arguments: 'Apparence'),
          onOpenCurrency: () => _push(AppRoutes.comingSoon, arguments: 'Devise'),
          onOpenRegionalFormat: () => _push(AppRoutes.comingSoon, arguments: 'Format régional'),
        ));

      case AppRoutes.createCommunityStep1:
        final draft = settings.arguments as CommunityDraft? ?? const CommunityDraft();
        return page(CreateCommunityStep1Page(
          draft: draft,
          onBack: _pop,
          onContinue: (updated) => _push(AppRoutes.createCommunityStep2, arguments: updated),
        ));

      case AppRoutes.createCommunityStep2:
        final draft = settings.arguments as CommunityDraft;
        return page(CreateCommunityStep2Page(
          draft: draft,
          onBack: _pop,
          onContinue: (updated) => _push(AppRoutes.createCommunityStep3, arguments: updated),
        ));

      case AppRoutes.createCommunityStep3:
        final draft = settings.arguments as CommunityDraft;
        return page(CreateCommunityStep3Page(
          draft: draft,
          onBack: _pop,
          onContinue: (updated) => _push(
            AppRoutes.createCommunityStep4,
            arguments: updated.invitedMembers.isEmpty
                ? updated.copyWith(invitedMembers: CreateCommunityMockDatasource.initialInvites)
                : updated,
          ),
        ));

      case AppRoutes.createCommunityStep4:
        final draft = settings.arguments as CommunityDraft;
        return page(CreateCommunityStep4Page(
          draft: draft,
          onBack: _pop,
          onContinue: (updated) => _push(AppRoutes.createCommunityStep5, arguments: updated),
          onGenerateLink: () => _push(AppRoutes.comingSoon, arguments: "Lien d'invitation"),
          onShowQrCode: () => _push(AppRoutes.comingSoon, arguments: 'QR Code'),
          onInviteByNumber: () => _push(AppRoutes.comingSoon, arguments: 'Inviter par numéro'),
          onChooseContacts: () => _push(AppRoutes.comingSoon, arguments: 'Choisir contacts'),
        ));

      case AppRoutes.createCommunityStep5:
        final draft = settings.arguments as CommunityDraft;
        return page(CreateCommunityStep5Page(
          draft: draft,
          onBack: _pop,
          // TODO (Njoya) : pas d'API branchée — pousse un placeholder au
          // lieu de créer réellement la communauté et de revenir à l'accueil.
          onCreate: () => _push(AppRoutes.comingSoon, arguments: 'Communauté créée !'),
          onEditGeneral: () => _popUntil(AppRoutes.createCommunityStep1),
          onEditFinancial: () => _popUntil(AppRoutes.createCommunityStep2),
          onEditRules: () => _popUntil(AppRoutes.createCommunityStep3),
          onEditMembers: () => _popUntil(AppRoutes.createCommunityStep4),
        ));

      case AppRoutes.contributionDetail:
        return page(ContributionDetailPage(
          detail: ContributionMockDatasource.detail,
          onBack: _pop,
          onShareReceipt: () => _push(AppRoutes.comingSoon, arguments: 'Partager le reçu'),
          onModify: () => _push(AppRoutes.comingSoon, arguments: 'Modifier'),
          // TODO (Njoya) : pas de vraie suppression — retour simple pour l'instant.
          onCancelRecording: _pop,
        ));

      case AppRoutes.financialSummary:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        return page(FinancialSummaryPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          role: community.role,
          summary: ReportMockDatasource.summary,
          evolution: ReportMockDatasource.contributionEvolution,
          participation: ReportMockDatasource.participation,
          loanDetails: ReportMockDatasource.loanDetails,
          recentActivity: ReportMockDatasource.recentActivity,
          onBack: _pop,
          onExport: () => _push(AppRoutes.comingSoon, arguments: 'Exporter le rapport'),
          onSeeFullHistory: () => _push(AppRoutes.comingSoon, arguments: "Historique d'activité"),
          onOpenDetailedReport: () => _push(AppRoutes.detailedReport, arguments: community),
        ));

      case AppRoutes.detailedReport:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        return page(DetailedReportPage(
          communityName: community.name,
          role: community.role,
          summary: ReportMockDatasource.detailedSummary,
          evolution: ReportMockDatasource.versementsEvolution,
          transactions: ReportMockDatasource.transactions,
          onBack: _pop,
          onSeeAllTransactions: () => _push(AppRoutes.comingSoon, arguments: 'Toutes les opérations'),
          onExport: () => _push(AppRoutes.comingSoon, arguments: 'Exporter PDF'),
        ));

      case AppRoutes.cycleCompleted:
        final community = settings.arguments as CommunityModel?;
        if (community == null) return page(const _MissingCommunityRedirect());
        return page(CycleCompletedPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          role: community.role,
          closedDateLabel: CycleCompletionMockDatasource.closedDateLabel,
          stats: CycleCompletionMockDatasource.stats,
          beneficiaryHistory: CycleCompletionMockDatasource.beneficiaryHistory,
          onBack: _pop,
          onSeeFullList: () => _push(AppRoutes.comingSoon, arguments: 'Liste complète des bénéficiaires'),
          onExportReport: () => _push(AppRoutes.comingSoon, arguments: 'Exporter le rapport'),
          onStartNewCycle: () => _push(AppRoutes.comingSoon, arguments: 'Démarrer un nouveau cycle'),
          onSeeCyclesHistory: () => _push(AppRoutes.comingSoon, arguments: 'Historique des cycles'),
        ));

      // ---------------- Partagé ----------------

      case AppRoutes.phoneVerified:
        final nextRoute = settings.arguments as String;
        return page(PhoneVerifiedPage(
          onContinue: () => _replace(nextRoute),
        ));

      case AppRoutes.comingSoon:
        final label = settings.arguments as String? ?? '';
        return page(ComingSoonPage(label: label));

      default:
        return page(OnboardingPage(
          onFinish: () => _replace(AppRoutes.authLanding),
        ));
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
  State<_MissingCommunityRedirect> createState() => _MissingCommunityRedirectState();
}

class _MissingCommunityRedirectState extends State<_MissingCommunityRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => AppRouter._replaceAll(AppRoutes.home));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
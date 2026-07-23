import 'package:flutter/material.dart';
import '../Models/community_model.dart';
import '../common/basewidget/coming_soon_page.dart';
import '../datasource/community_admin_mock_datasource.dart';
import '../datasource/community_member_mock_datasource.dart';
import '../datasource/community_members_mock_datasource.dart';
import '../datasource/community_mock_datasource.dart';
import '../datasource/community_treasury_mock_datasource.dart';
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
import '../screens/community/home/admin_dashboard_page.dart';
import '../screens/community/home/member_dashboard_page.dart';
import '../screens/community/membres/admin_members_page.dart';
import '../screens/community/membres/members_page.dart';
import '../screens/community/tresorerie/treasury_page.dart';
import '../screens/home/home_page.dart';
import '../screens/onboarding/onboarding_page.dart';
import 'app_routes.dart';

/// Table de routage centralisée. Les écrans ne connaissent que leurs
/// callbacks (onFinish, onContinue...) — c'est ici, et seulement ici,
/// que ces callbacks sont traduits en navigation réelle.
///
/// Provisoire : à étoffer (ou remplacer par go_router) au fur et à
/// mesure que le reste de l'app (dashboard...) est construit.
class AppRouter {
  AppRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static void _push(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(route, arguments: arguments);

  static void _replace(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushReplacementNamed(route, arguments: arguments);

  static void _pop() => navigatorKey.currentState!.pop();

  static void _toggleLanguage() {
    final next = AppLocalizations.locale.value == 'fr' ? 'en' : 'fr';
    AppLocalizations.setLocale(next);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _page(OnboardingPage(
          onFinish: () => _replace(AppRoutes.authLanding),
        ));

      case AppRoutes.authLanding:
        return _page(AuthLandingPage(
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
        return _page(RegisterPhonePage(
          onBack: _pop,
          onLogin: () => _push(AppRoutes.loginPhone),
          onContinue: (phone) => _push(AppRoutes.registerOtp, arguments: phone),
        ));

      case AppRoutes.registerOtp:
        final phone = settings.arguments as String;
        return _page(VerifyOtpPage(
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
        return _page(CreatePinPage(
          onBack: _pop,
          onPinCreated: (pin) => _push(AppRoutes.confirmPin, arguments: pin),
        ));

      case AppRoutes.confirmPin:
        final originalPin = settings.arguments as String;
        return _page(ConfirmPinPage(
          originalPin: originalPin,
          onBack: _pop,
          onConfirmed: (_) => _replace(AppRoutes.pinCreated),
        ));

      case AppRoutes.pinCreated:
        return _page(PinCreatedPage(
          onContinue: () => _replace(AppRoutes.welcome),
        ));

      case AppRoutes.welcome:
        return _page(WelcomePage(
          onBack: _pop,
          onStart: () => _replace(AppRoutes.home),
          onSetupProfile: () =>
              _push(AppRoutes.comingSoon, arguments: 'Configurer mon profil'),
        ));

      // ---------------- Connexion ----------------

      case AppRoutes.loginPhone:
        return _page(LoginPhonePage(
          onBack: _pop,
          onRegister: () => _push(AppRoutes.registerPhone),
          onContinue: (phone) => _push(AppRoutes.loginOtp, arguments: phone),
        ));

      case AppRoutes.loginOtp:
        final phone = settings.arguments as String;
        return _page(VerifyOtpPage(
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
        return _page(EnterPinPage(
          onBack: _pop,
          onForgotPin: () =>
              _push(AppRoutes.comingSoon, arguments: 'Réinitialiser mon code'),
          onSubmit: (_) => _replace(AppRoutes.home),
        ));

      // ---------------- Dashboard ----------------

      case AppRoutes.home:
        return _page(HomePage(
          // TODO (Njoya) : remplacer par le vrai nom/état venant de l'API.
          userName: 'Alex',
          communities: CommunityMockDatasource.sample,
          isProfileComplete: false,
          onIdentify: () => _push(AppRoutes.comingSoon, arguments: 'Identification'),
          onCommunityTap: (c) => c.role == 'ADMIN'
              ? _push(AppRoutes.communityAdmin, arguments: c)
              : _push(AppRoutes.communityMember, arguments: c),
          onAddCommunity: () =>
              _push(AppRoutes.comingSoon, arguments: 'Créer une communauté'),
        ));

      case AppRoutes.communityAdmin:
        final community = settings.arguments as CommunityModel;
        return _page(AdminDashboardPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          // TODO (Njoya) : ces stats sont mock (communes à toute communauté
          // ADMIN pour l'instant) — à remplacer par les vraies données par
          // communauté une fois l'API branchée.
          health: CommunityAdminMockDatasource.health,
          priorities: CommunityAdminMockDatasource.priorities,
          cycle: CommunityAdminMockDatasource.cycle,
          memberStatus: CommunityAdminMockDatasource.memberStatus,
          loans: CommunityAdminMockDatasource.loans,
          activity: CommunityAdminMockDatasource.activity,
          onBack: _pop,
          onQuickAction: (action) => _push(AppRoutes.comingSoon, arguments: action),
          onPriorityTap: (p) => _push(AppRoutes.comingSoon, arguments: p.label),
          onManageMembers: () =>
              _push(AppRoutes.comingSoon, arguments: 'Gérer les membres'),
          onSeeLoanFiles: () => _push(AppRoutes.comingSoon, arguments: 'Dossiers de prêts'),
          onSeeAllActivity: () =>
              _push(AppRoutes.comingSoon, arguments: "Historique d'activité"),
          onOpenTreasury: () => _replace(AppRoutes.communityTreasury, arguments: community),
          onOpenMembers: () => _replace(AppRoutes.communityMembersAdmin, arguments: community),
        ));

      case AppRoutes.communityMember:
        final community = settings.arguments as CommunityModel;
        return _page(MemberDashboardPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          // TODO (Njoya) : mock commun à toutes les communautés non-admin
          // pour l'instant — à remplacer par les vraies données par
          // communauté une fois l'API branchée.
          health: CommunityMemberMockDatasource.health,
          requiredActions: CommunityMemberMockDatasource.requiredActions,
          cycle: CommunityMemberMockDatasource.cycle,
          memberStatus: CommunityMemberMockDatasource.memberStatus,
          activity: CommunityMemberMockDatasource.activity,
          onBack: _pop,
          onQuickAction: (action) => _push(AppRoutes.comingSoon, arguments: action),
          onActionPay: (item) => _push(AppRoutes.comingSoon, arguments: item.actionLabel),
          onActionTap: (item) => _push(AppRoutes.comingSoon, arguments: item.title),
          onSeeAllMembers: () => _push(AppRoutes.comingSoon, arguments: 'Tous les membres'),
          onSeeAllActivity: () =>
              _push(AppRoutes.comingSoon, arguments: "Historique d'activité"),
          onOpenTreasury: () => _replace(AppRoutes.communityTreasury, arguments: community),
          onOpenMembers: () => _replace(AppRoutes.communityMembers, arguments: community),
        ));

      case AppRoutes.communityTreasury:
        final community = settings.arguments as CommunityModel;
        return _page(TreasuryPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          // TODO (Njoya) : mock commun à toutes les communautés pour
          // l'instant — à remplacer par les vraies données par
          // communauté une fois l'API branchée.
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
          onBack: _pop,
          onSeeReceipt: () => _push(AppRoutes.comingSoon, arguments: 'Reçu'),
          onHistoryItemTap: (item) => _push(AppRoutes.comingSoon, arguments: item.cycleLabel),
          onSeeAllHistory: () =>
              _push(AppRoutes.comingSoon, arguments: 'Historique complet'),
          onSeeAllMembers: () => _push(AppRoutes.comingSoon, arguments: 'Tous les membres'),
          onRequestLoan: () => _push(AppRoutes.comingSoon, arguments: 'Demander un prêt'),
          onOpenDashboard: () => _replace(
            community.role == 'ADMIN' ? AppRoutes.communityAdmin : AppRoutes.communityMember,
            arguments: community,
          ),
          onOpenMembers: () => _replace(
            community.role == 'ADMIN' ? AppRoutes.communityMembersAdmin : AppRoutes.communityMembers,
            arguments: community,
          ),
        ));

      case AppRoutes.communityMembersAdmin:
        final community = settings.arguments as CommunityModel;
        return _page(AdminMembersPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          // TODO (Njoya) : mock commun à toutes les communautés pour
          // l'instant — à remplacer par les vraies données par
          // communauté une fois l'API branchée.
          summary: CommunityMembersMockDatasource.summaryAdmin,
          directory: CommunityMembersMockDatasource.adminDirectory,
          growth: CommunityMembersMockDatasource.growth,
          onBack: _pop,
          onOpenDashboard: () => _replace(AppRoutes.communityAdmin, arguments: community),
          onOpenTreasury: () => _replace(AppRoutes.communityTreasury, arguments: community),
          onInviteMember: () => _push(AppRoutes.comingSoon, arguments: 'Inviter un membre'),
          onMemberMenuTap: (m) => _push(AppRoutes.comingSoon, arguments: m.name),
          onMemberUrgentAction: (m) => _push(AppRoutes.comingSoon, arguments: 'Relancer ${m.name}'),
        ));

      case AppRoutes.communityMembers:
        final community = settings.arguments as CommunityModel;
        return _page(MembersPage(
          communityName: community.name,
          cycleLabel: 'Cycle ${community.cycleCurrent}/${community.cycleTotal}',
          // TODO (Njoya) : mock commun à toutes les communautés pour
          // l'instant — à remplacer par les vraies données par
          // communauté une fois l'API branchée.
          summary: CommunityMembersMockDatasource.summaryMember,
          directory: CommunityMembersMockDatasource.directory,
          trustScore: CommunityMembersMockDatasource.trustScore,
          onBack: _pop,
          onOpenDashboard: () => _replace(AppRoutes.communityMember, arguments: community),
          onOpenTreasury: () => _replace(AppRoutes.communityTreasury, arguments: community),
          onMemberTap: (m) => _push(AppRoutes.comingSoon, arguments: m.name),
        ));

      // ---------------- Partagé ----------------

      case AppRoutes.phoneVerified:
        final nextRoute = settings.arguments as String;
        return _page(PhoneVerifiedPage(
          onContinue: () => _replace(nextRoute),
        ));

      case AppRoutes.comingSoon:
        final label = settings.arguments as String? ?? '';
        return _page(ComingSoonPage(label: label));

      default:
        return _page(OnboardingPage(
          onFinish: () => _replace(AppRoutes.authLanding),
        ));
    }
  }

  static PageRoute _page(Widget child) => MaterialPageRoute(builder: (_) => child);
}
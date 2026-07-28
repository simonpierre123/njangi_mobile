import 'package:flutter/material.dart';
import '../../Models/community_admin_dashboard_model.dart';
import '../../Models/community_member_dashboard_model.dart';
import '../../Models/community_members_model.dart';
import '../../Models/community_model.dart';
import '../../Models/profile_model.dart';
import '../../Models/treasury_model.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../profil/profile_page.dart';
import 'home/admin_dashboard_page.dart';
import 'home/member_dashboard_page.dart';
import 'membres/admin_members_page.dart';
import 'membres/members_page.dart';
import 'tresorerie/treasury_page.dart';
import 'widgets/community_app_bar.dart';

/// Shell persistant de l'espace communauté : UN SEUL Scaffold, UNE SEULE
/// bottom nav, UN SEUL CommunityAppBar — le contenu (Dashboard/
/// Trésorerie/Membres/Profil) change via IndexedStack sans jamais se
/// reconstruire ni passer par le Navigator. Bascule automatiquement
/// entre les variantes admin/membre selon [community.role].
///
/// C'est ICI, et seulement ici, qu'on ajoute un futur 5e onglet — plus
/// besoin de toucher 5 fichiers différents comme avant.
///
/// Bonus permis par le shell : certaines actions qui poussaient un
/// placeholder "à venir" basculent maintenant directement sur l'onglet
/// pertinent (ex: "Gérer les membres" → onglet Membres) au lieu de
/// naviguer vers nulle part.
class CommunityShell extends StatefulWidget {
  const CommunityShell({
    super.key,
    required this.community,
    required this.onBack,
    // Dashboard
    required this.health,
    required this.adminPriorities,
    required this.memberRequiredActions,
    required this.adminCycle,
    required this.memberCycle,
    required this.adminMemberStatus,
    required this.memberMemberStatus,
    required this.loans,
    required this.dashboardActivity,
    required this.onQuickAction,
    required this.onPriorityTap,
    required this.onSeeAllActivity,
    required this.onActionPay,
    required this.onActionTap,
    // Trésorerie
    required this.financialPosition,
    required this.receipt,
    required this.history,
    required this.collection,
    required this.memberContributions,
    required this.loan,
    required this.loanDue,
    required this.eligibility,
    required this.repaymentHistory,
    required this.onSeeReceipt,
    required this.onHistoryItemTap,
    required this.onSeeAllHistory,
    required this.onOpenDetailedReport,
    required this.onRequestLoan,
    // Membres
    required this.adminSummary,
    required this.memberSummary,
    required this.adminDirectory,
    required this.memberDirectory,
    required this.growth,
    required this.trustScore,
    required this.onInviteMember,
    required this.onMemberMenuTap,
    required this.onMemberUrgentAction,
    required this.onMemberTap,
    // Profil
    required this.user,
    required this.profileActivity,
    required this.profileCommunities,
    required this.onProfileCommunityTap,
    required this.onOpenMyProfile,
    required this.onOpenSecurity,
    required this.onOpenNotifications,
    required this.onOpenPreferences,
    required this.onOpenHelp,
    required this.onOpenAbout,
    required this.onLogout,
  });

  final CommunityModel community;
  final VoidCallback onBack;

  final GroupHealthStats health;
  final List<PriorityItem> adminPriorities;
  final List<RequiredActionItem> memberRequiredActions;
  final CycleInfo adminCycle;
  final MemberCycleInfo memberCycle;
  final MemberStatusStats adminMemberStatus;
  final MemberStatusStats memberMemberStatus;
  final LoanStats loans;
  final List<ActivityItem> dashboardActivity;
  final ValueChanged<String> onQuickAction;
  final ValueChanged<PriorityItem> onPriorityTap;
  final VoidCallback onSeeAllActivity;
  final ValueChanged<RequiredActionItem> onActionPay;
  final ValueChanged<RequiredActionItem> onActionTap;

  final FinancialPosition financialPosition;
  final ContributionReceipt receipt;
  final List<ContributionHistoryItem> history;
  final CollectionStatus collection;
  final List<MemberContribution> memberContributions;
  final LoanInfo? loan;
  final LoanDueInfo? loanDue;
  final LoanEligibility eligibility;
  final List<MemberContribution> repaymentHistory;
  final VoidCallback onSeeReceipt;
  final ValueChanged<ContributionHistoryItem> onHistoryItemTap;
  final VoidCallback onSeeAllHistory;
  final VoidCallback onOpenDetailedReport;
  final VoidCallback onRequestLoan;

  final CommunitySummary adminSummary;
  final CommunitySummary memberSummary;
  final List<AdminMemberEntry> adminDirectory;
  final List<MemberDirectoryEntry> memberDirectory;
  final GrowthStats growth;
  final TrustScore trustScore;
  final VoidCallback onInviteMember;
  final ValueChanged<AdminMemberEntry> onMemberMenuTap;
  final ValueChanged<AdminMemberEntry> onMemberUrgentAction;
  final ValueChanged<MemberDirectoryEntry> onMemberTap;

  final UserProfile user;
  final ProfileActivity profileActivity;
  final List<ProfileCommunityEntry> profileCommunities;
  final ValueChanged<ProfileCommunityEntry> onProfileCommunityTap;
  final VoidCallback onOpenMyProfile;
  final VoidCallback onOpenSecurity;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenPreferences;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenAbout;
  final VoidCallback onLogout;

  @override
  State<CommunityShell> createState() => _CommunityShellState();
}

class _CommunityShellState extends State<CommunityShell> {
  int _tabIndex = 0;

  bool get _isAdmin => widget.community.role == 'ADMIN';

  void _goToTab(int index) => setState(() => _tabIndex = index);

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      // Le Profil n'a pas d'en-tête communauté (nom/cycle/rôle) — c'est
      // une section globale, pas propre à cette communauté.
      appBar: _tabIndex == 3
          ? null
          : CommunityAppBar(
              name: widget.community.name,
              cycleLabel: 'Cycle ${widget.community.cycleCurrent}/${widget.community.cycleTotal}',
              role: widget.community.role,
              onBack: widget.onBack,
            ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _tabIndex,
        onTap: _goToTab,
        items: [
          AppNavItem(icon: Icons.grid_view_rounded, label: AppLocalizations.t('community_nav_dashboard')),
          AppNavItem(icon: Icons.history, label: AppLocalizations.t('community_nav_treasury')),
          AppNavItem(icon: Icons.people_outline, label: AppLocalizations.t('community_nav_members')),
          AppNavItem(icon: Icons.person_outline, label: AppLocalizations.t('nav_profile')),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _tabIndex,
          children: [
              _isAdmin
                  ? AdminDashboardPage(
                      health: widget.health,
                      priorities: widget.adminPriorities,
                      cycle: widget.adminCycle,
                      memberStatus: widget.adminMemberStatus,
                      loans: widget.loans,
                      activity: widget.dashboardActivity,
                      onQuickAction: widget.onQuickAction,
                      onPriorityTap: widget.onPriorityTap,
                      // Bonus shell : bascule directement sur les onglets
                      // concernés au lieu d'un placeholder.
                      onManageMembers: () => _goToTab(2),
                      onSeeLoanFiles: () => _goToTab(1),
                      onSeeAllActivity: widget.onSeeAllActivity,
                    )
                  : MemberDashboardPage(
                      health: widget.health,
                      requiredActions: widget.memberRequiredActions,
                      cycle: widget.memberCycle,
                      memberStatus: widget.memberMemberStatus,
                      activity: widget.dashboardActivity,
                      onQuickAction: widget.onQuickAction,
                      onActionPay: widget.onActionPay,
                      onActionTap: widget.onActionTap,
                      onSeeAllMembers: () => _goToTab(2),
                      onSeeAllActivity: widget.onSeeAllActivity,
                    ),
              TreasuryPage(
                financialPosition: widget.financialPosition,
                receipt: widget.receipt,
                history: widget.history,
                collection: widget.collection,
                memberContributions: widget.memberContributions,
                loan: widget.loan,
                loanDue: widget.loanDue,
                eligibility: widget.eligibility,
                repaymentHistory: widget.repaymentHistory,
                onSeeReceipt: widget.onSeeReceipt,
                onHistoryItemTap: widget.onHistoryItemTap,
                onSeeAllHistory: widget.onSeeAllHistory,
                onOpenDetailedReport: widget.onOpenDetailedReport,
                onSeeAllMembers: () => _goToTab(2),
                onRequestLoan: widget.onRequestLoan,
              ),
              _isAdmin
                  ? AdminMembersPage(
                      summary: widget.adminSummary,
                      directory: widget.adminDirectory,
                      growth: widget.growth,
                      onInviteMember: widget.onInviteMember,
                      onMemberMenuTap: widget.onMemberMenuTap,
                      onMemberUrgentAction: widget.onMemberUrgentAction,
                    )
                  : MembersPage(
                      summary: widget.memberSummary,
                      directory: widget.memberDirectory,
                      trustScore: widget.trustScore,
                      onMemberTap: widget.onMemberTap,
                    ),
              ProfilePage(
                user: widget.user,
                activity: widget.profileActivity,
                communities: widget.profileCommunities,
                onCommunityTap: widget.onProfileCommunityTap,
                onOpenMyProfile: widget.onOpenMyProfile,
                onOpenSecurity: widget.onOpenSecurity,
                onOpenNotifications: widget.onOpenNotifications,
                onOpenPreferences: widget.onOpenPreferences,
                onOpenHelp: widget.onOpenHelp,
                onOpenAbout: widget.onOpenAbout,
                onLogout: widget.onLogout,
              ),
            ],
          ),
        ),
    );
  }
}
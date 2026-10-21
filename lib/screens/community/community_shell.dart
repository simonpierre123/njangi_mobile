import 'package:flutter/material.dart';
import '../../Controllers_distant/CycleController.dart';
import '../../Controllers_distant/CycleTontineTourController.dart';
import '../../ModeView/beneficiary_model.dart';
import '../../ModeView/community_admin_dashboard_model.dart';
import '../../ModeView/community_member_dashboard_model.dart';
import '../../ModeView/community_members_model.dart';
import '../../ModeView/community_model.dart';
import '../../ModeView/profile_model.dart';
import '../../ModeView/treasury_model.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/management/storage_manager.dart';
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
    required this.currentBeneficiary,
    required this.beneficiaryStats,
    required this.payoutHistory,
    required this.onDisburse,
    required this.onSeeAllPayoutHistory,
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
    required this.onAdminMemberTap,
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
  final CurrentBeneficiary currentBeneficiary;
  final BeneficiaryStats beneficiaryStats;
  final List<PayoutHistoryEntry> payoutHistory;
  final VoidCallback onDisburse;
  final VoidCallback onSeeAllPayoutHistory;

  final CommunitySummary adminSummary;
  final CommunitySummary memberSummary;
  final List<AdminMemberEntry> adminDirectory;
  final List<MemberDirectoryEntry> memberDirectory;
  final GrowthStats growth;
  final TrustScore trustScore;
  final VoidCallback onInviteMember;
  final ValueChanged<AdminMemberEntry> onMemberMenuTap;
  final ValueChanged<AdminMemberEntry> onMemberUrgentAction;
  final ValueChanged<AdminMemberEntry> onAdminMemberTap;
  final ValueChanged<MemberDirectoryEntry> onMemberTap;

  final UserProfile user;
  final ProfileActivity profileActivity;
  final List<ProfileCommunityEntry> profileCommunities;
  final ValueChanged<ProfileCommunityEntry> onProfileCommunityTap;
  final Future<void> Function() onOpenMyProfile;
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
  late UserProfile _profileUser;
  String? _cycleId;
  List<PassageOrderEntry> _passageOrder = const [];
  bool _isLoadingPassageOrder = true;
  String? _passageOrderError;

  @override
  void initState() {
    super.initState();
    _cycleId = widget.community.cycleId;
    _profileUser = widget.user;
    _loadProfileUser();
    _loadPassageOrder();
  }

  Future<void> _loadPassageOrder() async {
    if (!_isAdmin && !widget.community.tontineNextVisible) {
      setState(() => _isLoadingPassageOrder = false);
      return;
    }

    var cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (cycles != null && cycles.isNotEmpty) {
        final activeCycles = cycles.where(
          (cycle) => cycle.status == 'EN_COURS',
        );
        cycleId =
            activeCycles.isEmpty ? cycles.first.id : activeCycles.first.id;
      }
    }

    if (cycleId == null || cycleId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoadingPassageOrder = false;
        _passageOrderError = AppLocalizations.t('cycle_tontine_load_error');
      });
      return;
    }

    _cycleId = cycleId;
    final result = await CycleTontineTourController.getForCycle(cycleId);
    if (!mounted) return;
    if (result['success'] != true ||
        result['entries'] is! List<PassageOrderEntry>) {
      setState(() {
        _isLoadingPassageOrder = false;
        _passageOrderError =
            result['message']?.toString() ??
            AppLocalizations.t('cycle_tontine_load_error');
      });
      return;
    }

    setState(() {
      _passageOrder = List<PassageOrderEntry>.of(
        result['entries'] as List<PassageOrderEntry>,
      );
      _isLoadingPassageOrder = false;
      _passageOrderError = null;
    });
  }

  Future<List<PassageOrderEntry>?> _savePassageOrder(
    List<PassageOrderEntry> entries,
  ) async {
    final cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) return null;

    final result = await CycleTontineTourController.setOrder(
      cycleId: cycleId,
      entries: entries,
    );
    if (result['success'] != true ||
        result['entries'] is! List<PassageOrderEntry>) {
      return null;
    }

    final savedEntries = List<PassageOrderEntry>.of(
      result['entries'] as List<PassageOrderEntry>,
    );
    if (mounted) setState(() => _passageOrder = savedEntries);
    return savedEntries;
  }

  Future<void> _loadProfileUser() async {
    final user = await StorageManager.getUser();
    if (!mounted || user == null) return;
    setState(() => _profileUser = UserProfile.fromUserModel(user));
  }

  Future<void> _openMyProfile() async {
    await widget.onOpenMyProfile();
    await _loadProfileUser();
  }

  bool get _isAdmin => widget.community.role == 'ADMIN';

  GroupHealthStats get _healthWithCommunityCount {
    final total = widget.community.memberCount;
    return GroupHealthStats(
      healthPercent: widget.health.healthPercent,
      healthLabel: widget.health.healthLabel,
      cashBalance: widget.health.cashBalance,
      membersUpToDate: widget.health.membersUpToDate.clamp(0, total),
      membersTotal: total,
      pendingCount: widget.health.pendingCount,
      activeLoans: widget.health.activeLoans,
      lastUpdateLabel: widget.health.lastUpdateLabel,
    );
  }

  MemberStatusStats _memberStatusWithCommunityCount(MemberStatusStats stats) {
    final total = widget.community.memberCount;
    return MemberStatusStats(
      total: total,
      upToDate: stats.upToDate.clamp(0, total),
      pending: stats.pending.clamp(0, total),
      lateCount: stats.lateCount.clamp(0, total),
    );
  }

  CycleInfo get _adminCycleForCommunity {
    final total = widget.community.cycleTotal;
    final current = widget.community.cycleCurrent;
    return CycleInfo(
      currentCycle: current,
      totalCycle: total,
      progressPercent: total > 0 ? (current / total).clamp(0.0, 1.0) : 0,
      nextBeneficiary: widget.adminCycle.nextBeneficiary,
      remainingCycles: (total - current).clamp(0, total),
    );
  }

  MemberCycleInfo get _memberCycleForCommunity => MemberCycleInfo(
    progressPercent: widget.memberCycle.progressPercent,
    progressLabel: widget.memberCycle.progressLabel,
    nextBeneficiary: widget.memberCycle.nextBeneficiary,
    remainingCycles: (widget.community.cycleTotal -
            widget.community.cycleCurrent)
        .clamp(0, widget.community.cycleTotal),
    currentCycle: widget.community.cycleCurrent,
    totalCycle: widget.community.cycleTotal,
  );

  void _goToTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    if (index == 1) {
      _loadPassageOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      // Le Profil n'a pas d'en-tête communauté (nom/cycle/rôle) — c'est
      // une section globale, pas propre à cette communauté.
      appBar:
          _tabIndex == 3
              ? null
              : CommunityAppBar(
                name: widget.community.name,
                cycleLabel:
                    widget.community.hasCycle
                        ? 'Cycle ${widget.community.cycleCurrent}/${widget.community.cycleTotal}'
                        : '—',
                logoUrl: widget.community.logoUrl,
                memberCount: widget.community.memberCount,
                role: widget.community.role,
                onBack: widget.onBack,
              ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _tabIndex,
        onTap: _goToTab,
        items: [
          AppNavItem(
            icon: Icons.grid_view_rounded,
            label: AppLocalizations.t('community_nav_dashboard'),
          ),
          AppNavItem(
            icon: Icons.history,
            label: AppLocalizations.t('community_nav_treasury'),
          ),
          AppNavItem(
            icon: Icons.people_outline,
            label: AppLocalizations.t('community_nav_members'),
          ),
          AppNavItem(
            icon: Icons.person_outline,
            label: AppLocalizations.t('nav_profile'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _isAdmin
                ? AdminDashboardPage(
                  health: _healthWithCommunityCount,
                  priorities: widget.adminPriorities,
                  cycle: _adminCycleForCommunity,
                  memberStatus: _memberStatusWithCommunityCount(
                    widget.adminMemberStatus,
                  ),
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
                  health: _healthWithCommunityCount,
                  requiredActions: widget.memberRequiredActions,
                  cycle: _memberCycleForCommunity,
                  memberStatus: _memberStatusWithCommunityCount(
                    widget.memberMemberStatus,
                  ),
                  activity: widget.dashboardActivity,
                  onQuickAction: widget.onQuickAction,
                  onActionPay: widget.onActionPay,
                  onActionTap: widget.onActionTap,
                  onSeeAllMembers: () => _goToTab(2),
                  onSeeAllActivity: widget.onSeeAllActivity,
                ),
            TreasuryPage(
              isAdmin: _isAdmin,
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
              currentBeneficiary: widget.currentBeneficiary,
              beneficiaryStats: widget.beneficiaryStats,
              passageOrder: _passageOrder,
              passageOrderLoading: _isLoadingPassageOrder,
              passageOrderError: _passageOrderError,
              onReorderPassageOrder: _savePassageOrder,
              onRefresh: _loadPassageOrder,
              showPassageOrderToMembers: widget.community.tontineNextVisible,
              payoutHistory: widget.payoutHistory,
              onDisburse: widget.onDisburse,
              onSeeAllPayoutHistory: widget.onSeeAllPayoutHistory,
            ),
            _isAdmin
                ? AdminMembersPage(
                  summary: widget.adminSummary,
                  directory: widget.adminDirectory,
                  growth: widget.growth,
                  onInviteMember: widget.onInviteMember,
                  onMemberMenuTap: widget.onMemberMenuTap,
                  onMemberUrgentAction: widget.onMemberUrgentAction,
                  onMemberTap: widget.onAdminMemberTap,
                )
                : MembersPage(
                  summary: widget.memberSummary,
                  directory: widget.memberDirectory,
                  trustScore: widget.trustScore,
                  onMemberTap: widget.onMemberTap,
                ),
            ProfilePage(
              user: _profileUser,
              activity: widget.profileActivity,
              communities: widget.profileCommunities,
              onCommunityTap: widget.onProfileCommunityTap,
              onOpenMyProfile: _openMyProfile,
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

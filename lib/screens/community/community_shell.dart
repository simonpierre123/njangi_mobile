import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Controllers_distant/CycleCashBalanceController.dart';
import '../../Controllers_distant/CycleActivityController.dart';
import '../../Controllers_distant/CycleController.dart';
import '../../Controllers_distant/CycleDashboardPrioritiesController.dart';
import '../../Controllers_distant/CycleLoanDashboardController.dart';
import '../../Controllers_distant/CycleTontineContributionController.dart';
import '../../Controllers_distant/CycleTontineTourController.dart';
import '../../Models/Cycle.dart';
import '../../ModeView/beneficiary_model.dart';
import '../../ModeView/cycle_cash_balance_model.dart';
import '../../ModeView/cycle_dashboard_priorities_model.dart';
import '../../ModeView/community_admin_dashboard_model.dart';
import '../../ModeView/community_member_dashboard_model.dart';
import '../../ModeView/community_members_model.dart';
import '../../ModeView/community_model.dart';
import '../../ModeView/profile_model.dart';
import '../../ModeView/treasury_model.dart';
import '../../common/basewidget/app_bottom_nav_bar.dart';
import '../../localization/app_localizations.dart';
import '../../routes/app_route_observer.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_constants.dart';
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
    required this.adminCycle,
    required this.memberCycle,
    required this.adminMemberStatus,
    required this.memberMemberStatus,
    required this.loans,
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

  final CycleInfo adminCycle;
  final MemberCycleInfo memberCycle;
  final MemberStatusStats adminMemberStatus;
  final MemberStatusStats memberMemberStatus;
  final LoanStats loans;
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

class _CommunityShellState extends State<CommunityShell> with RouteAware {
  int _tabIndex = 0;
  late UserProfile _profileUser;
  String? _cycleId;
  CycleDashboardPriorities? _dashboardPriorities;
  CycleGroupHealth? _groupHealth;
  bool _isLoadingGroupHealth = true;
  bool _groupHealthLoadError = false;
  int _groupHealthLoadGeneration = 0;
  LoanStats _loanStats = LoanStats.loading;
  int _loanStatsLoadGeneration = 0;
  String _cycleCurrency = 'XAF';
  bool _isLoadingPriorities = true;
  String? _prioritiesError;
  int _prioritiesLoadGeneration = 0;
  String _cashBalanceText = '—';
  bool _isLoadingCashBalance = true;
  bool _cashBalanceError = false;
  int _cashBalanceLoadGeneration = 0;
  List<ActivityItem> _activity = const [];
  bool _isLoadingActivity = true;
  String? _activityError;
  int _activityLoadGeneration = 0;
  List<RequiredActionItem> _memberRequiredActions = const [];
  bool _isLoadingMemberRequiredActions = true;
  String? _memberRequiredActionsError;
  int _memberActionsLoadGeneration = 0;
  PageRoute<dynamic>? _communityRoute;
  List<PassageOrderEntry> _passageOrder = const [];
  bool _isLoadingPassageOrder = true;
  String? _passageOrderError;
  double? _tontineProgressPercent;
  int _passageOrderLoadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _cycleId = widget.community.cycleId;
    _profileUser = widget.user;
    _loadProfileUser();
    _loadPassageOrder();
    unawaited(_loadActivity());
    unawaited(_loadCashBalance());
    if (_isTreasurer) unawaited(_loadLoanDashboard());
    if (_isAdmin) unawaited(_loadDashboardPriorities());
    if (!_isAdmin) unawaited(_loadGroupHealth());
    if (!_isAdmin) unawaited(_loadMemberRequiredActions());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _communityRoute) {
      if (_communityRoute != null) appRouteObserver.unsubscribe(this);
      _communityRoute = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    unawaited(_loadCashBalance());
    unawaited(_loadActivity());
    unawaited(_loadPassageOrder());
    if (_isTreasurer) unawaited(_loadLoanDashboard());
    if (_isAdmin) unawaited(_loadDashboardPriorities());
    if (!_isAdmin) unawaited(_loadGroupHealth());
    if (!_isAdmin) unawaited(_loadMemberRequiredActions());
  }

  Future<void> _loadActivity() async {
    final generation = ++_activityLoadGeneration;
    if (mounted) {
      setState(() {
        _isLoadingActivity = true;
        _activityError = null;
      });
    }

    var cycleId = widget.community.cycleId ?? _cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (!mounted || generation != _activityLoadGeneration) return;
      final current = cycles?.where((cycle) => cycle.status == 'EN_COURS');
      cycleId =
          current?.isNotEmpty == true
              ? current!.first.id
              : cycles?.firstOrNull?.id;
    }

    if (cycleId == null || cycleId.isEmpty) {
      if (!mounted || generation != _activityLoadGeneration) return;
      setState(() {
        _isLoadingActivity = false;
        _activityError = AppLocalizations.t('history_load_error');
      });
      return;
    }

    _cycleId = cycleId;
    final activity = await CycleActivityController.getRecent(cycleId);
    if (!mounted || generation != _activityLoadGeneration) return;
    setState(() {
      _isLoadingActivity = false;
      if (activity == null) {
        _activityError = AppLocalizations.t('history_load_error');
      } else {
        _activity = activity;
        _activityError = null;
      }
    });
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadCashBalance() async {
    final generation = ++_cashBalanceLoadGeneration;
    if (mounted) setState(() => _isLoadingCashBalance = true);

    final cycles = await CycleController.getForGroup(widget.community.id);
    if (!mounted || generation != _cashBalanceLoadGeneration) return;
    final currentCycles =
        cycles?.where((cycle) => cycle.status == 'EN_COURS').toList() ?? [];
    final firstCycleId =
        cycles != null && cycles.isNotEmpty ? cycles.first.id : null;
    final cycleId =
        (currentCycles.isNotEmpty ? currentCycles.first.id : null) ??
        widget.community.cycleId ??
        _cycleId ??
        firstCycleId;

    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _cashBalanceText = '—';
        _isLoadingCashBalance = false;
        _cashBalanceError = false;
      });
      return;
    }

    _cycleId = cycleId;
    final CycleCashBalance? balance =
        await CycleCashBalanceController.getForCycle(cycleId);
    if (!mounted || generation != _cashBalanceLoadGeneration) return;

    setState(() {
      if (balance != null) {
        final amount = NumberFormat.decimalPattern(
          'fr_FR',
        ).format(balance.amount);
        final currency = balance.currency == 'XAF' ? 'FCFA' : balance.currency;
        _cashBalanceText = '$amount $currency';
        _cashBalanceError = false;
      } else {
        _cashBalanceText = '—';
        _cashBalanceError = true;
      }
      _isLoadingCashBalance = false;
    });
  }

  Future<void> _loadLoanDashboard() async {
    final generation = ++_loanStatsLoadGeneration;
    if (mounted) setState(() => _loanStats = LoanStats.loading);

    final cycles = await CycleController.getForGroup(widget.community.id);
    if (!mounted || generation != _loanStatsLoadGeneration) return;
    final activeCycles =
        cycles?.where((cycle) => cycle.status == 'EN_COURS').toList() ?? [];
    final fallbackCycleId =
        cycles != null && cycles.isNotEmpty ? cycles.first.id : null;
    final cycleId =
        (activeCycles.isNotEmpty ? activeCycles.first.id : null) ??
        widget.community.cycleId ??
        _cycleId ??
        fallbackCycleId;

    if (cycleId == null || cycleId.isEmpty) {
      setState(() => _loanStats = LoanStats.error);
      return;
    }

    _cycleId = cycleId;
    final stats = await CycleLoanDashboardController.getForCycle(cycleId);
    if (!mounted || generation != _loanStatsLoadGeneration) return;
    setState(() => _loanStats = stats ?? LoanStats.error);
  }

  Future<void> _loadDashboardPriorities() async {
    final generation = ++_prioritiesLoadGeneration;
    if (mounted) {
      setState(() {
        _isLoadingPriorities = true;
        _prioritiesError = null;
      });
    }

    final cycles = await CycleController.getForGroup(widget.community.id);
    if (!mounted || generation != _prioritiesLoadGeneration) return;

    String? activeCycleId;
    for (final cycle in cycles ?? []) {
      if (cycle.status == 'EN_COURS' && cycle.id?.isNotEmpty == true) {
        activeCycleId = cycle.id;
        break;
      }
    }
    final firstCycleId =
        cycles != null && cycles.isNotEmpty ? cycles.first.id : null;
    final cycleId =
        activeCycleId ?? widget.community.cycleId ?? _cycleId ?? firstCycleId;

    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _dashboardPriorities = null;
        _isLoadingPriorities = false;
        _prioritiesError = AppLocalizations.t(
          'dashboard_priorities_load_error',
        );
      });
      return;
    }

    _cycleId = cycleId;
    for (final cycle in cycles ?? []) {
      if (cycle.id == cycleId) {
        _cycleCurrency = cycle.currency ?? 'XAF';
        break;
      }
    }
    final priorities = await CycleDashboardPrioritiesController.getForCycle(
      cycleId,
    );
    if (!mounted || generation != _prioritiesLoadGeneration) return;

    setState(() {
      _isLoadingPriorities = false;
      if (priorities == null) {
        _dashboardPriorities = null;
        _prioritiesError = AppLocalizations.t(
          'dashboard_priorities_load_error',
        );
      } else {
        _dashboardPriorities = priorities;
        _prioritiesError = null;
      }
    });
  }

  Future<void> _loadGroupHealth() async {
    final generation = ++_groupHealthLoadGeneration;
    if (mounted) {
      setState(() {
        _isLoadingGroupHealth = true;
        _groupHealthLoadError = false;
      });
    }

    final cycles = await CycleController.getForGroup(widget.community.id);
    if (!mounted || generation != _groupHealthLoadGeneration) return;
    if (cycles == null) {
      setState(() {
        _groupHealth = null;
        _isLoadingGroupHealth = false;
        _groupHealthLoadError = true;
      });
      return;
    }

    Cycle? activeCycle;
    for (final cycle in cycles) {
      if (cycle.status == 'EN_COURS' &&
          cycle.id != null &&
          cycle.id!.isNotEmpty) {
        activeCycle = cycle;
        break;
      }
    }
    final cycleId =
        activeCycle?.id ??
        widget.community.cycleId ??
        (cycles.isNotEmpty ? cycles.first.id : null);
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _groupHealth = null;
        _isLoadingGroupHealth = false;
        _groupHealthLoadError = true;
      });
      return;
    }

    _cycleId = cycleId;
    final health = await CycleDashboardPrioritiesController.getGroupHealth(
      cycleId,
    );
    if (!mounted || generation != _groupHealthLoadGeneration) return;

    setState(() {
      _groupHealth = health;
      _isLoadingGroupHealth = false;
      _groupHealthLoadError = health == null;
    });
  }

  Future<void> _loadMemberRequiredActions() async {
    final generation = ++_memberActionsLoadGeneration;
    if (mounted) {
      setState(() {
        _isLoadingMemberRequiredActions = true;
        _memberRequiredActionsError = null;
      });
    }

    final cycles = await CycleController.getForGroup(widget.community.id);
    if (!mounted || generation != _memberActionsLoadGeneration) return;
    if (cycles == null) {
      setState(() {
        _memberRequiredActions = const [];
        _isLoadingMemberRequiredActions = false;
        _memberRequiredActionsError = AppLocalizations.t(
          'required_actions_load_error',
        );
      });
      return;
    }

    Cycle? cycle;
    for (final candidate in cycles) {
      if (candidate.status == 'EN_COURS' &&
          candidate.id != null &&
          candidate.id!.isNotEmpty) {
        cycle = candidate;
        break;
      }
    }
    final cycleId =
        cycle?.id ??
        widget.community.cycleId ??
        _cycleId ??
        (cycles.isNotEmpty ? cycles.first.id : null);
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _memberRequiredActions = const [];
        _isLoadingMemberRequiredActions = false;
        _memberRequiredActionsError = null;
      });
      return;
    }

    if (cycle == null) {
      for (final candidate in cycles) {
        if (candidate.id == cycleId) {
          cycle = candidate;
          break;
        }
      }
    }
    cycle ??= await CycleController.getById(cycleId);
    if (!mounted || generation != _memberActionsLoadGeneration) return;
    if (cycle == null) {
      setState(() {
        _memberRequiredActions = const [];
        _isLoadingMemberRequiredActions = false;
        _memberRequiredActionsError = AppLocalizations.t(
          'required_actions_load_error',
        );
      });
      return;
    }
    _cycleId = cycleId;
    if (!cycle.tontineActive) {
      setState(() {
        _memberRequiredActions = const [];
        _isLoadingMemberRequiredActions = false;
        _memberRequiredActionsError = null;
      });
      return;
    }

    final result = await CycleTontineContributionController.getContext(cycleId);
    if (!mounted || generation != _memberActionsLoadGeneration) return;
    if (result['success'] != true || result['data'] is! Map) {
      setState(() {
        _memberRequiredActions = const [];
        _isLoadingMemberRequiredActions = false;
        _memberRequiredActionsError =
            result['message']?.toString() ??
            AppLocalizations.t('required_actions_load_error');
      });
      return;
    }

    final data = Map<String, dynamic>.from(result['data'] as Map);
    final actions = <RequiredActionItem>[];
    final dueDate = _parseApiDate(data['date_echeance']);
    final openingDate = _parseApiDate(data['date_ouverture_cotisation']);
    final period = data['periode']?.toString();
    final operation = data['current_period_operation'];
    final operationData =
        operation is Map ? Map<String, dynamic>.from(operation) : null;
    final operationStatus = operationData?['statut']?.toString();

    if (period != null && period.isNotEmpty && dueDate != null) {
      if (operationStatus == 'EN_ATTENTE' || operationStatus == 'VALIDE') {
        actions.add(
          RequiredActionItem(
            icon: Icons.payments_outlined,
            title: AppLocalizations.t('required_contribution_title'),
            subtitle: AppLocalizations.t(
              operationStatus == 'VALIDE'
                  ? 'contribution_validated'
                  : 'contribution_pending',
            ),
          ),
        );
      } else {
        final amount = _formatContributionAmount(
          data['montant_cotisation'] ?? cycle.contributionAmount,
          data['devise']?.toString() ?? cycle.currency ?? 'XAF',
        );
        actions.add(
          RequiredActionItem(
            icon: Icons.payments_outlined,
            title: AppLocalizations.t('required_contribution_title'),
            subtitle: [
              if (operationStatus == 'REJETE')
                AppLocalizations.t('contribution_rejected'),
              '$amount • ${_paymentDeadlineLabel(data, openingDate, dueDate)}',
            ].join(' • '),
            actionLabel: AppLocalizations.t(
              operationStatus == 'REJETE' ? 'retry_payment' : 'pay_button',
            ),
          ),
        );
      }
    }

    final meetingTime = cycle.meetingTime;
    if (dueDate != null && meetingTime != null && meetingTime.isNotEmpty) {
      actions.add(
        RequiredActionItem(
          icon: Icons.event_outlined,
          title: AppLocalizations.t('group_meeting_title'),
          subtitle:
              '${_relativeDateLabel(dueDate)} • ${_formatMeetingTime(meetingTime)}',
        ),
      );
    }

    setState(() {
      _memberRequiredActions = actions;
      _isLoadingMemberRequiredActions = false;
      _memberRequiredActionsError = null;
    });
  }

  DateTime? _parseApiDate(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.length < 10) return null;
    return DateTime.tryParse(text.substring(0, 10));
  }

  String _formatContributionAmount(Object? value, String currency) {
    final amount = value is num ? value : num.tryParse(value?.toString() ?? '');
    if (amount == null) {
      return AppLocalizations.t('amount_unavailable');
    }
    final formatted = NumberFormat.decimalPattern(
      AppLocalizations.locale.value,
    ).format(amount);
    return '$formatted ${currency == 'XAF' ? 'FCFA' : currency}';
  }

  String _paymentDeadlineLabel(
    Map<String, dynamic> data,
    DateTime? openingDate,
    DateTime dueDate,
  ) {
    if (data['etat_fenetre_cotisation'] == 'AVANT_OUVERTURE' &&
        openingDate != null) {
      return _relativeDateLabel(
        openingDate,
        todayKey: 'payment_available_today',
        tomorrowKey: 'payment_available_tomorrow',
        daysKey: 'payment_available_in_days',
      );
    }
    return _relativeDateLabel(
      dueDate,
      todayKey: 'payment_due_today',
      tomorrowKey: 'payment_due_tomorrow',
      daysKey: 'payment_due_in_days',
      pastDaysKey: 'payment_overdue_days',
    );
  }

  String _relativeDateLabel(
    DateTime date, {
    String todayKey = 'relative_today',
    String tomorrowKey = 'relative_tomorrow',
    String daysKey = 'relative_in_days',
    String pastDaysKey = 'relative_days_ago',
  }) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);
    final days = target.difference(today).inDays;
    if (days == 0) return AppLocalizations.t(todayKey);
    if (days == 1) return AppLocalizations.t(tomorrowKey);
    if (days > 1) return AppLocalizations.t(daysKey, args: [days]);
    return AppLocalizations.t(pastDaysKey, args: [-days]);
  }

  String _formatMeetingTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 18,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    ).format(context);
  }

  List<PriorityItem> _priorityItems(CycleDashboardPriorities priorities) {
    String label(int count, String singularKey, String pluralKey) =>
        AppLocalizations.t(count == 1 ? singularKey : pluralKey, args: [count]);

    return [
      PriorityItem(
        icon: Icons.payment,
        actionKey: 'pending_contributions',
        label: label(
          priorities.pendingTontineContributions,
          'priority_tontine_pending_one',
          'priority_tontine_pending_many',
        ),
      ),
      PriorityItem(
        icon: Icons.description_outlined,
        actionKey: 'pending_loans',
        label: label(
          priorities.pendingLoanRequests,
          'priority_loan_pending_one',
          'priority_loan_pending_many',
        ),
      ),
      PriorityItem(
        icon: Icons.warning_amber_rounded,
        actionKey: 'overdue_members',
        label: label(
          priorities.overdueMembers,
          'priority_members_overdue_one',
          'priority_members_overdue_many',
        ),
        isAlert: true,
      ),
    ];
  }

  List<PriorityItem> get _adminPriorities {
    final priorities = _dashboardPriorities;
    return priorities == null ? const [] : _priorityItems(priorities);
  }

  Future<void> _handlePriorityTap(PriorityItem item) async {
    switch (item.actionKey) {
      case 'pending_contributions':
        await _showPendingContributions();
        return;
      case 'pending_loans':
        await _showPendingLoanRequests();
        return;
      case 'overdue_members':
        await _showOverdueMembers();
        return;
      default:
        widget.onPriorityTap(item);
    }
  }

  Future<void> _showOverdueMembers() async {
    final priorities = _dashboardPriorities;
    final members = priorities?.overdueMemberList ?? const [];
    final dueDate = priorities?.currentTourDueDate;
    final dueDateLabel =
        dueDate == null
            ? null
            : DateFormat.yMMMd(AppLocalizations.locale.value).format(dueDate);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceLg.w,
              AppDimensions.spaceSm.h,
              AppDimensions.spaceLg.w,
              AppDimensions.spaceLg.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t('overdue_members_title'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (dueDateLabel != null) ...[
                  SizedBox(height: AppDimensions.spaceXs.h),
                  Text(
                    AppLocalizations.t(
                      'overdue_members_due_date',
                      args: [dueDateLabel],
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                SizedBox(height: AppDimensions.spaceMd.h),
                if (members.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spaceLg.h,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.t('overdue_members_empty'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: MediaQuery.sizeOf(sheetContext).height * 0.55,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: members.length,
                      separatorBuilder:
                          (_, _) => const Divider(height: 1, indent: 56),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.errorContainer20,
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.alertRed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _showPendingContributions() async {
    final cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) return;
    final contributions =
        CycleDashboardPrioritiesController.getPendingContributions(cycleId);

    final selected = await showModalBottomSheet<PendingTontineContribution>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (sheetContext) => _priorityListSheet(
            context: sheetContext,
            title: AppLocalizations.t('pending_contributions_title'),
            emptyLabel: AppLocalizations.t('pending_contributions_empty'),
            loadError: AppLocalizations.t('pending_contributions_load_error'),
            future: contributions,
            itemCount: (items) => items.length,
            itemBuilder: (items, index) {
              final item = items[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.payment_outlined),
                ),
                title: Text(
                  item.memberName.isEmpty
                      ? AppLocalizations.t('member_label')
                      : item.memberName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${_formatPriorityAmount(item.amount)}'
                  '${item.period == null ? '' : ' • ${item.period}'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(sheetContext).pop(item);
                },
              );
            },
          ),
    );
    if (selected != null && mounted) {
      await _showContributionDetails(selected);
    }
  }

  Future<void> _showPendingLoanRequests() async {
    final cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) return;
    final requests = CycleDashboardPrioritiesController.getPendingLoanRequests(
      cycleId,
    );

    final selected = await showModalBottomSheet<PendingLoanRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (sheetContext) => _priorityListSheet(
            context: sheetContext,
            title: AppLocalizations.t('pending_loan_requests_title'),
            emptyLabel: AppLocalizations.t('pending_loan_requests_empty'),
            loadError: AppLocalizations.t('pending_loan_requests_load_error'),
            future: requests,
            itemCount: (items) => items.length,
            itemBuilder: (items, index) {
              final item = items[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.description_outlined),
                ),
                title: Text(
                  item.memberName.isEmpty
                      ? AppLocalizations.t('member_label')
                      : item.memberName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_formatPriorityAmount(item.amount)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(sheetContext).pop(item);
                },
              );
            },
          ),
    );
    if (selected != null && mounted) {
      await _showLoanRequestDetails(selected);
    }
  }

  Widget _priorityListSheet<T>({
    required BuildContext context,
    required String title,
    required String emptyLabel,
    required String loadError,
    required Future<List<T>?> future,
    required int Function(List<T>) itemCount,
    required Widget Function(List<T>, int) itemBuilder,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spaceLg.w,
        AppDimensions.spaceSm.h,
        AppDimensions.spaceLg.w,
        AppDimensions.spaceLg.h,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            Expanded(
              child: FutureBuilder<List<T>?>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data;
                  if (snapshot.hasError || items == null) {
                    return Center(
                      child: Text(
                        loadError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  if (itemCount(items) == 0) {
                    return Center(
                      child: Text(
                        emptyLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: itemCount(items),
                    separatorBuilder:
                        (_, _) => const Divider(height: 1, indent: 56),
                    itemBuilder: (_, index) => itemBuilder(items, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContributionDetails(
    PendingTontineContribution contribution,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceLg.w,
              AppDimensions.spaceSm.h,
              AppDimensions.spaceLg.w,
              AppDimensions.spaceLg.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contribution.memberName.isEmpty
                        ? AppLocalizations.t('member_label')
                        : contribution.memberName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceMd.h),
                  _priorityDetailRow(
                    AppLocalizations.t('contribution_amount_label'),
                    _formatPriorityAmount(contribution.amount),
                  ),
                  if (contribution.period != null)
                    _priorityDetailRow(
                      AppLocalizations.t('contribution_period_label'),
                      contribution.period!,
                    ),
                  if (contribution.operationDate != null)
                    _priorityDetailRow(
                      AppLocalizations.t('pending_item_date_label'),
                      DateFormat.yMMMd(
                        AppLocalizations.locale.value,
                      ).format(contribution.operationDate!),
                    ),
                  if (contribution.paymentMethod != null)
                    _priorityDetailRow(
                      AppLocalizations.t('payment_method_label'),
                      contribution.paymentMethod!,
                    ),
                  if (contribution.operator != null)
                    _priorityDetailRow(
                      AppLocalizations.t('payment_operator_label'),
                      contribution.operator!,
                    ),
                  if (contribution.paymentReference != null)
                    _priorityDetailRow(
                      AppLocalizations.t('payment_reference_label'),
                      contribution.paymentReference!,
                    ),
                  if (contribution.receiptPath != null) ...[
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Text(
                      AppLocalizations.t('tontine_receipt_label'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: AppDimensions.spaceSm.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _priorityImageUrl(contribution.receiptPath!),
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, _, _) => Container(
                              height: 100,
                              alignment: Alignment.center,
                              color: AppColors.inputBorder,
                              child: Text(
                                AppLocalizations.t(
                                  'tontine_receipt_load_error',
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showLoanRequestDetails(PendingLoanRequest request) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceLg.w,
              AppDimensions.spaceSm.h,
              AppDimensions.spaceLg.w,
              AppDimensions.spaceLg.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    request.memberName.isEmpty
                        ? AppLocalizations.t('member_label')
                        : request.memberName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceMd.h),
                  _priorityDetailRow(
                    AppLocalizations.t('loan_request_amount_label'),
                    _formatPriorityAmount(request.amount),
                  ),
                  if (request.createdAt != null)
                    _priorityDetailRow(
                      AppLocalizations.t('pending_item_date_label'),
                      DateFormat.yMMMd(
                        AppLocalizations.locale.value,
                      ).format(request.createdAt!),
                    ),
                  if (request.repaymentDate != null)
                    _priorityDetailRow(
                      AppLocalizations.t('loan_request_repayment_date_label'),
                      DateFormat.yMMMd(
                        AppLocalizations.locale.value,
                      ).format(request.repaymentDate!),
                    ),
                  if (request.reason != null)
                    _priorityDetailRow(
                      AppLocalizations.t('loan_request_reason_label'),
                      request.reason!,
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _priorityDetailRow(String label, String value) => Padding(
    padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );

  String _formatPriorityAmount(num amount) {
    final formatted = NumberFormat.decimalPattern(
      AppLocalizations.locale.value,
    ).format(amount);
    return '$formatted ${_cycleCurrency == 'XAF' ? 'FCFA' : _cycleCurrency}';
  }

  String _priorityImageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }

  Future<void> _loadPassageOrder() async {
    final generation = ++_passageOrderLoadGeneration;
    if (mounted) {
      setState(() {
        _isLoadingPassageOrder = true;
        _passageOrderError = null;
      });
    }

    var cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (!mounted || generation != _passageOrderLoadGeneration) return;
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
        _tontineProgressPercent = null;
        _passageOrder = const [];
        _passageOrderError = AppLocalizations.t('cycle_tontine_load_error');
      });
      return;
    }

    _cycleId = cycleId;
    final results = await Future.wait([
      CycleTontineTourController.getProgressForCycle(cycleId),
      CycleTontineTourController.getForCycle(cycleId),
    ]);
    if (!mounted || generation != _passageOrderLoadGeneration) return;
    final progressResult = results[0] as Map<String, dynamic>;
    final result = results[1] as Map<String, dynamic>;
    if (result['success'] != true ||
        result['entries'] is! List<PassageOrderEntry>) {
      setState(() {
        _isLoadingPassageOrder = false;
        _tontineProgressPercent = null;
        _passageOrder = const [];
        _passageOrderError =
            result['message']?.toString() ??
            AppLocalizations.t('cycle_tontine_load_error');
      });
      return;
    }

    final entries = List<PassageOrderEntry>.of(
      result['entries'] as List<PassageOrderEntry>,
    );
    final paidTours = progressResult['paidTours'];
    final totalTours = progressResult['totalTours'];
    final double? progressPercent =
        progressResult['success'] == true &&
                paidTours is int &&
                totalTours is int &&
                totalTours > 0
            ? (paidTours / totalTours).clamp(0.0, 1.0).toDouble()
            : entries.isEmpty
            ? null
            : entries.where((entry) => entry.isPaid).length / entries.length;
    setState(() {
      _passageOrder = entries;
      _tontineProgressPercent = progressPercent;
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

  bool get _isAdmin =>
      ['ADMIN', 'CO_ADMIN'].contains(widget.community.role?.toUpperCase());
  bool get _isTreasurer => widget.community.role?.toUpperCase() == 'TRESORIER';

  GroupHealthStats get _healthWithCommunityCount {
    final priorities = _dashboardPriorities;
    final memberHealth = _groupHealth;
    final score = priorities?.groupHealthScore ?? memberHealth?.score;
    final healthLoading =
        _isAdmin ? _isLoadingPriorities : _isLoadingGroupHealth;
    final healthLoadError =
        _isAdmin ? _prioritiesError != null : _groupHealthLoadError;
    final healthLabel =
        healthLoadError
            ? 'health_unavailable'
            : score == null
            ? 'health_insufficient_data'
            : score >= 80
            ? 'health_stable'
            : score >= 60
            ? 'health_attention'
            : 'health_critical';
    return GroupHealthStats(
      healthPercent: score,
      healthLabel: healthLabel,
      cashBalance: _cashBalanceText,
      membersUpToDate:
          priorities?.membersUpToDate ?? memberHealth?.membersUpToDate ?? 0,
      membersTotal:
          priorities?.totalMembers ??
          memberHealth?.totalMembers ??
          widget.community.memberCount,
      pendingCount:
          priorities?.pendingContributions ??
          memberHealth?.pendingContributions ??
          priorities?.pendingTontineContributions ??
          0,
      activeLoans: priorities?.activeLoans ?? memberHealth?.activeLoans ?? 0,
      lastUpdateLabel: AppLocalizations.t('health_last_updated_now'),
      isCashBalanceLoading: _isLoadingCashBalance,
      cashBalanceError: _cashBalanceError,
      isHealthLoading: healthLoading,
    );
  }

  MemberStatusStats get _memberStatusForDashboard {
    final priorities = _dashboardPriorities;
    final memberHealth = _groupHealth;
    final isLoading = _isAdmin ? _isLoadingPriorities : _isLoadingGroupHealth;
    final hasError =
        _isAdmin ? _prioritiesError != null : _groupHealthLoadError;
    final total = priorities?.totalMembers ?? memberHealth?.totalMembers ?? 0;
    final upToDate =
        priorities?.membersUpToDate ?? memberHealth?.membersUpToDate ?? 0;
    final pending =
        priorities?.membersPending ?? memberHealth?.membersPending ?? 0;
    final overdue =
        priorities?.membersOverdue ?? memberHealth?.membersOverdue ?? 0;

    return MemberStatusStats(
      total: total,
      upToDate: upToDate.clamp(0, total),
      pending: pending.clamp(0, total),
      lateCount: overdue.clamp(0, total),
      isLoading: isLoading,
      hasError: hasError,
    );
  }

  CycleInfo get _adminCycleForCommunity {
    final total = widget.community.cycleTotal;
    final current = widget.community.cycleCurrent;
    return CycleInfo(
      currentCycle: current,
      totalCycle: total,
      progressPercent: _tontineProgressPercent,
      nextBeneficiary: _nextTontineBeneficiary,
      remainingBeneficiaries: _remainingTontineBeneficiaries,
    );
  }

  String get _nextTontineBeneficiary {
    if (_isLoadingPassageOrder || _passageOrderError != null) return '—';
    if (!_isAdmin && !widget.community.tontineNextVisible) {
      return AppLocalizations.t('next_beneficiary_hidden');
    }
    for (final entry in _passageOrder) {
      if (!entry.isPaid) return entry.name;
    }
    return AppLocalizations.t('no_next_beneficiary');
  }

  int? get _remainingTontineBeneficiaries {
    if (_isLoadingPassageOrder || _passageOrderError != null) return null;
    return _passageOrder.where((entry) => !entry.isPaid).length;
  }

  MemberCycleInfo get _memberCycleForCommunity {
    final progressPercent = _tontineProgressPercent;
    final progressLabel =
        progressPercent == null
            ? AppLocalizations.t('progress_unavailable')
            : progressPercent >= 1
            ? AppLocalizations.t('cycle_completed')
            : AppLocalizations.t('cycle_in_progress');
    return MemberCycleInfo(
      progressPercent: progressPercent,
      progressLabel: progressLabel,
      nextBeneficiary: _nextTontineBeneficiary,
      remainingBeneficiaries: _remainingTontineBeneficiaries,
      currentCycle: widget.community.cycleCurrent,
      totalCycle: widget.community.cycleTotal,
    );
  }

  void _goToTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    if (index == 0) {
      unawaited(_loadPassageOrder());
      unawaited(_loadCashBalance());
      if (_isTreasurer) unawaited(_loadLoanDashboard());
      if (_isAdmin) unawaited(_loadDashboardPriorities());
      if (!_isAdmin) unawaited(_loadMemberRequiredActions());
    }
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
                  priorities: _adminPriorities,
                  isLoadingPriorities: _isLoadingPriorities,
                  prioritiesError: _prioritiesError,
                  onRetryPriorities:
                      () => unawaited(_loadDashboardPriorities()),
                  cycle: _adminCycleForCommunity,
                  memberStatus: _memberStatusForDashboard,
                  loans: _isTreasurer ? _loanStats : widget.loans,
                  activity: _activity,
                  isLoadingActivity: _isLoadingActivity,
                  activityError: _activityError,
                  onRetryActivity: () => unawaited(_loadActivity()),
                  onQuickAction: widget.onQuickAction,
                  onPriorityTap: _handlePriorityTap,
                  // Bonus shell : bascule directement sur les onglets
                  // concernés au lieu d'un placeholder.
                  onManageMembers: () => _goToTab(2),
                  onSeeLoanFiles: () => _goToTab(1),
                  onSeeAllActivity: widget.onSeeAllActivity,
                )
                : MemberDashboardPage(
                  isTreasurer: _isTreasurer,
                  health: _healthWithCommunityCount,
                  loans: _isTreasurer ? _loanStats : widget.loans,
                  requiredActions: _memberRequiredActions,
                  isLoadingRequiredActions: _isLoadingMemberRequiredActions,
                  requiredActionsError: _memberRequiredActionsError,
                  onRetryRequiredActions:
                      () => unawaited(_loadMemberRequiredActions()),
                  cycle: _memberCycleForCommunity,
                  memberStatus: _memberStatusForDashboard,
                  activity: _activity,
                  isLoadingActivity: _isLoadingActivity,
                  activityError: _activityError,
                  onRetryActivity: () => unawaited(_loadActivity()),
                  onQuickAction: widget.onQuickAction,
                  onActionPay: widget.onActionPay,
                  onActionTap: widget.onActionTap,
                  onSeeAllMembers: () => _goToTab(2),
                  onSeeAllActivity: widget.onSeeAllActivity,
                ),
            TreasuryPage(
              isAdmin: _isAdmin,
              isTreasurer: _isTreasurer,
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
                  groupId: widget.community.id,
                  currentUserRole: widget.community.role ?? '',
                  directory: widget.adminDirectory,
                  growth: widget.growth,
                  onInviteMember: widget.onInviteMember,
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

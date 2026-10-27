import 'package:flutter/material.dart';
import '../../../Controllers_distant/MembreGroupeController.dart';
import '../../../ModeView/community_members_model.dart';
import '../../../common/basewidget/app_search_field.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/admin_member_row.dart';
import 'widgets/community_summary_card.dart';
import 'widgets/growth_stats_card.dart';
import 'widgets/invite_member_button.dart';

/// Contenu de l'onglet "Membres" — vue admin (gestion, croissance,
/// invitation).
///
/// Ne possède plus de Scaffold/AppBar/bottom nav propres : c'est
/// [CommunityShell] qui les fournit désormais.
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_members_mock_datasource.dart.
class AdminMembersPage extends StatefulWidget {
  const AdminMembersPage({
    super.key,
    required this.summary,
    required this.groupId,
    required this.currentUserRole,
    required this.directory,
    required this.growth,
    required this.onInviteMember,
    required this.onMemberUrgentAction,
    this.onMemberTap,
  });

  final CommunitySummary summary;
  final String groupId;
  final String currentUserRole;
  final List<AdminMemberEntry> directory;
  final GrowthStats growth;
  final VoidCallback onInviteMember;
  final ValueChanged<AdminMemberEntry> onMemberUrgentAction;
  final ValueChanged<AdminMemberEntry>? onMemberTap;

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  int _filterIndex = 0;
  String _query = '';
  late List<AdminMemberEntry> _directory;
  late CommunitySummary _summary;
  final Set<String> _updatingMembers = {};

  @override
  void initState() {
    super.initState();
    _directory = List.of(widget.directory);
    _summary = widget.summary;
  }

  @override
  void didUpdateWidget(covariant AdminMembersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.directory != widget.directory) {
      _directory = List.of(widget.directory);
    }
    if (oldWidget.summary != widget.summary) {
      _summary = widget.summary;
    }
  }

  Future<void> _showMemberRoleMenu(AdminMemberEntry member) async {
    final userId = member.details.userId;
    if (userId == null || userId.isEmpty || _updatingMembers.contains(userId)) {
      return;
    }

    final currentRole =
        (member.details.role ?? member.role ?? 'MEMBRE').toUpperCase();
    final isCoAdmin = widget.currentUserRole.toUpperCase() == 'CO_ADMIN';
    if (isCoAdmin && currentRole == 'ADMIN') return;

    final availableRoles = <String>[
      if (!isCoAdmin) 'ADMIN',
      'CO_ADMIN',
      'TRESORIER',
      'SECRETARIAT',
      'MEMBRE',
    ];
    final selectedRole = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.spaceLg.w,
                    AppDimensions.spaceSm.h,
                    AppDimensions.spaceLg.w,
                    AppDimensions.spaceSm.h,
                  ),
                  child: Text(
                    AppLocalizations.t('member_role_menu_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final role in availableRoles)
                  ListTile(
                    title: Text(_roleLabel(role)),
                    trailing:
                        currentRole == role
                            ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryDark,
                            )
                            : null,
                    onTap: () => Navigator.of(context).pop(role),
                  ),
                SizedBox(height: AppDimensions.spaceSm.h),
                ],
              ),
            ),
          ),
    );

    if (selectedRole == null || !mounted) {
      return;
    }

    setState(() => _updatingMembers.add(userId));
    final result = await MembreGroupeController.updateRole(
      groupeId: widget.groupId,
      utilisateurId: userId,
      role: selectedRole,
    );
    if (!mounted) return;
    setState(() => _updatingMembers.remove(userId));

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ??
            AppLocalizations.t('member_role_update_error'),
      );
      return;
    }

    final updatedMember = member.copyWith(
      role: selectedRole == 'MEMBRE' ? null : selectedRole,
      details: member.details.copyWith(role: selectedRole),
    );
    setState(() {
      _directory = _directory
          .map(
            (entry) => entry.details.userId == userId ? updatedMember : entry,
          )
          .toList(growable: false);
      _summary = CommunitySummary(
        totalMembers: _summary.totalMembers,
        adminCount:
            _directory
                .where(
                  (entry) => [
                    'ADMIN',
                    'CO_ADMIN',
                  ].contains((entry.details.role ?? entry.role)?.toUpperCase()),
                )
                .length,
        activeCount: _summary.activeCount,
        cycleLabel: _summary.cycleLabel,
        lateCount: _summary.lateCount,
      );
    });
    _showMessage(AppLocalizations.t('member_role_update_success'));
  }

  String _roleLabel(String role) => switch (role) {
    'ADMIN' => AppLocalizations.t('role_admin'),
    'CO_ADMIN' => AppLocalizations.t('role_co_admin'),
    'TRESORIER' => AppLocalizations.t('role_treasurer'),
    'SECRETARIAT' => AppLocalizations.t('role_secretary'),
    _ => AppLocalizations.t('role_member'),
  };

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filterLabels = [
      AppLocalizations.t('filter_all'),
      AppLocalizations.t('filter_admin'),
      AppLocalizations.t('filter_member'),
      AppLocalizations.t('up_to_date'),
    ];

    final filtered =
        _directory.where((m) {
          final matchesFilter = switch (_filterIndex) {
            1 => m.role == 'ADMIN' || m.role == 'CO_ADMIN',
            2 => m.role == null,
            3 => m.statusColor == AppColors.primary,
            _ => true,
          };
          final matchesQuery =
              _query.isEmpty ||
              m.name.toLowerCase().contains(_query.toLowerCase());
          return matchesFilter && matchesQuery;
        }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH.w,
        vertical: AppDimensions.spaceSm.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunitySummaryCard(summary: _summary),
          SizedBox(height: AppDimensions.spaceLg.h),
          GrowthStatsCard(growth: widget.growth),
          SizedBox(height: AppDimensions.spaceLg.h),
          InviteMemberButton(onPressed: widget.onInviteMember),
          SizedBox(height: AppDimensions.spaceLg.h),
          AppSearchField(
            hint: AppLocalizations.t('search_member_hint'),
            onChanged: (v) => setState(() => _query = v),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          MemberFilterChips(
            labels: filterLabels,
            currentIndex: _filterIndex,
            onChanged: (i) => setState(() => _filterIndex = i),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          for (var i = 0; i < filtered.length; i++) ...[
            GestureDetector(
              onTap: () => widget.onMemberTap?.call(filtered[i]),
              child: AdminMemberRow(
                entry: filtered[i],
                onMenuTap:
                    filtered[i].details.userId == null ||
                            (widget.currentUserRole.toUpperCase() ==
                                    'CO_ADMIN' &&
                                (filtered[i].details.role ??
                                            filtered[i].role ??
                                            '')
                                        .toUpperCase() ==
                                    'ADMIN')
                        ? null
                        : () => _showMemberRoleMenu(filtered[i]),
                onUrgentAction: () => widget.onMemberUrgentAction(filtered[i]),
              ),
            ),
            if (i != filtered.length - 1)
              SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

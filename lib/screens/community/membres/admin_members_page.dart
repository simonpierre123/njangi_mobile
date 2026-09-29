import 'package:flutter/material.dart';
import '../../../Models/community_members_model.dart';
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
    required this.directory,
    required this.growth,
    required this.onInviteMember,
    required this.onMemberMenuTap,
    required this.onMemberUrgentAction,
  });

  final CommunitySummary summary;
  final List<AdminMemberEntry> directory;
  final GrowthStats growth;
  final VoidCallback onInviteMember;
  final ValueChanged<AdminMemberEntry> onMemberMenuTap;
  final ValueChanged<AdminMemberEntry> onMemberUrgentAction;

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  int _filterIndex = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filterLabels = [
      AppLocalizations.t('filter_all'),
      AppLocalizations.t('filter_admin'),
      AppLocalizations.t('filter_member'),
      AppLocalizations.t('up_to_date'),
    ];

    final filtered = widget.directory.where((m) {
      final matchesFilter = switch (_filterIndex) {
        1 => m.role == 'ADMIN',
        2 => m.role == null,
        3 => m.statusColor == AppColors.primary,
        _ => true,
      };
      final matchesQuery = _query.isEmpty || m.name.toLowerCase().contains(_query.toLowerCase());
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
          CommunitySummaryCard(summary: widget.summary),
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
            AdminMemberRow(
              entry: filtered[i],
              onMenuTap: () => widget.onMemberMenuTap(filtered[i]),
              onUrgentAction: () => widget.onMemberUrgentAction(filtered[i]),
            ),
            if (i != filtered.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}
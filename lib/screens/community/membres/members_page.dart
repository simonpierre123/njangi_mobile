import 'package:flutter/material.dart';
import '../../../Models/community_members_model.dart';
import '../../../common/basewidget/app_bottom_nav_bar.dart';
import '../../../common/basewidget/app_search_field.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import '../../widgets/community_app_bar.dart';
import 'widgets/community_summary_card.dart';
import 'widgets/member_directory_row.dart';
import 'widgets/trust_score_card.dart';

/// Onglet "Membres" — vue non-admin (annuaire des membres + score de
/// confiance du groupe).
///
/// TODO (Njoya) : remplacer les paramètres par le vrai flux de l'API —
/// alimenté pour l'instant par datasource/community_members_mock_datasource.dart.
class MembersPage extends StatefulWidget {
  const MembersPage({
    super.key,
    required this.communityName,
    required this.cycleLabel,
    required this.summary,
    required this.directory,
    required this.trustScore,
    required this.onBack,
    required this.onOpenDashboard,
    required this.onOpenTreasury,
    required this.onMemberTap,
  });

  final String communityName;
  final String cycleLabel;
  final CommunitySummary summary;
  final List<MemberDirectoryEntry> directory;
  final TrustScore trustScore;
  final VoidCallback onBack;
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenTreasury;
  final ValueChanged<MemberDirectoryEntry> onMemberTap;

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  int _navIndex = 2; // Membres
  int _filterIndex = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

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
        3 => m.status == MemberRowStatus.upToDate,
        _ => true,
      };
      final matchesQuery = _query.isEmpty || m.name.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommunityAppBar(
        name: widget.communityName,
        cycleLabel: widget.cycleLabel,
        onBack: widget.onBack,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 0) {
            widget.onOpenDashboard();
            return;
          }
          if (i == 1) {
            widget.onOpenTreasury();
            return;
          }
          setState(() => _navIndex = i);
        },
        items: [
          AppNavItem(icon: Icons.grid_view_rounded, label: AppLocalizations.t('community_nav_dashboard')),
          AppNavItem(icon: Icons.history, label: AppLocalizations.t('community_nav_treasury')),
          AppNavItem(icon: Icons.people_outline, label: AppLocalizations.t('community_nav_members')),
          AppNavItem(icon: Icons.person_outline, label: AppLocalizations.t('nav_profile')),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunitySummaryCard(summary: widget.summary),
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
                  onTap: () => widget.onMemberTap(filtered[i]),
                  child: MemberDirectoryRow(entry: filtered[i]),
                ),
                if (i != filtered.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
              ],
              SizedBox(height: AppDimensions.spaceLg.h),
              TrustScoreCard(score: widget.trustScore),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../ModeView/community_members_model.dart';
import '../../../common/basewidget/app_search_field.dart';
import '../../../common/basewidget/member_filter_chips.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/community_summary_card.dart';
import 'widgets/member_directory_row.dart';
import 'widgets/trust_score_card.dart';

/// Contenu de l'onglet "Membres" — vue non-admin (annuaire + score de
/// confiance du groupe).
///
/// Ne possède plus de Scaffold/AppBar/bottom nav propres : c'est
/// [CommunityShell] qui les fournit désormais.
///
class MembersPage extends StatefulWidget {
  const MembersPage({
    super.key,
    required this.summary,
    required this.directory,
    required this.trustScore,
    required this.onMemberTap,
    this.previewMemberPhotoUrls = const [],
  });

  final CommunitySummary summary;
  final List<MemberDirectoryEntry> directory;
  final TrustScore trustScore;
  final ValueChanged<MemberDirectoryEntry> onMemberTap;
  final List<String?> previewMemberPhotoUrls;

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
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

    final filtered =
        widget.directory.where((m) {
          final matchesFilter = switch (_filterIndex) {
            1 => m.role == 'ADMIN' || m.role == 'CO_ADMIN',
            2 => m.role == null,
            3 => m.status == MemberRowStatus.upToDate,
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
          CommunitySummaryCard(
            summary: widget.summary,
            previewMemberPhotoUrls: widget.previewMemberPhotoUrls,
          ),
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
            if (i != filtered.length - 1)
              SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceLg.h),
          TrustScoreCard(score: widget.trustScore),
          SizedBox(height: AppDimensions.spaceXl.h),
        ],
      ),
    );
  }
}

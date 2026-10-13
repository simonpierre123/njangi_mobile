import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import '../../Controllers_distant/CycleController.dart';
import '../../Controllers_distant/NotificationController.dart';
import '../../Models/Cycle.dart';
import '../../Models/Notification.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

class InvitationDetailPage extends StatefulWidget {
  const InvitationDetailPage({
    super.key,
    required this.notification,
    required this.onBack,
  });

  final Notification notification;
  final VoidCallback onBack;

  @override
  State<InvitationDetailPage> createState() => _InvitationDetailPageState();
}

class _InvitationDetailPageState extends State<InvitationDetailPage> {
  Cycle? _cycle;
  bool _loading = true;
  bool _accepting = false;
  bool _accepted = false;
  String? _loadError;

  String? get _cycleId =>
      widget.notification.cycleId ??
      widget.notification.payload?['cycle_id']?.toString();

  @override
  void initState() {
    super.initState();
    _loadCycle();
  }

  Future<void> _loadCycle() async {
    final cycleId = _cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = AppLocalizations.t('invitation_detail_error');
      });
      return;
    }

    setState(() {
      _loading = true;
      _loadError = null;
    });
    final cycle = await CycleController.getById(cycleId);
    if (!mounted) return;
    setState(() {
      _cycle = cycle;
      _loading = false;
      if (cycle == null) {
        _loadError = AppLocalizations.t('invitation_detail_error');
      }
    });
  }

  Future<void> _accept() async {
    if (_accepting || _accepted) return;
    setState(() => _accepting = true);
    final result = await NotificationController.acceptInvitation(
      widget.notification,
    );
    if (!mounted) return;
    setState(() {
      _accepting = false;
      _accepted = result['success'] == true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              AppLocalizations.t(
                result['success'] == true
                    ? 'invitation_accept_success'
                    : 'invitation_accept_error',
              ),
        ),
        backgroundColor:
            result['success'] == true ? AppColors.primaryDark : Colors.red,
      ),
    );
  }

  String _frequencyLabel(String? frequency) => switch (frequency
      ?.toUpperCase()) {
    'MENSUEL' || 'MENSUELLE' => AppLocalizations.t('freq_monthly_title'),
    'HEBDO' || 'HEBDOMADAIRE' => AppLocalizations.t('freq_weekly_title'),
    'BIHEBDO' ||
    'BIMENSUEL' ||
    'BIMENSUELLE' => AppLocalizations.t('freq_biweekly_title'),
    'AUTRE' => AppLocalizations.t('freq_custom_title'),
    _ => frequency ?? '—',
  };

  String _dateLabel(DateTime? date) {
    if (date == null) return '—';
    return DateFormat.yMMMd(
      AppLocalizations.locale.value,
    ).format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final notification = widget.notification;
    final cycle = _cycle;
    final groupName =
        cycle?.groupName ??
        notification.payload?['groupe_nom']?.toString() ??
        AppLocalizations.t('the_community');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('invitation_detail_title'),
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH.w,
                  vertical: AppDimensions.spaceMd.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                      decoration: BoxDecoration(
                        color: AppColors.tagMintBg,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.group_add_outlined,
                            color: AppColors.primaryDark,
                          ),
                          SizedBox(width: AppDimensions.spaceSm.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.spaceXs.h),
                                Text(
                                  notification.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    _sectionTitle('invitation_group_section'),
                    _detailRow('community_name_label', groupName),
                    if ((cycle?.groupType ?? '').isNotEmpty)
                      _detailRow('community_type_label', cycle!.groupType!),
                    if ((cycle?.groupCode ?? '').isNotEmpty)
                      _detailRow('invitation_group_code', cycle!.groupCode!),
                    if ((cycle?.groupDescription ?? '').isNotEmpty)
                      _detailRow('description_label', cycle!.groupDescription!),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    _sectionTitle('invitation_cycle_section'),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_loadError != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _loadError!,
                            style: const TextStyle(color: AppColors.alertRed),
                          ),
                          TextButton(
                            onPressed: _loadCycle,
                            child: Text(AppLocalizations.t('invite_retry')),
                          ),
                        ],
                      )
                    else ...[
                      _detailRow(
                        'cycle_word',
                        '${cycle?.number ?? '—'} · ${cycle?.status ?? '—'}',
                      ),
                      _detailRow(
                        'contribution_amount_label',
                        cycle?.contributionAmount == null
                            ? '—'
                            : '${cycle!.contributionAmount} ${cycle.currency ?? 'XAF'}',
                      ),
                      _detailRow(
                        'frequency_label',
                        _frequencyLabel(cycle?.frequency),
                      ),
                      _detailRow(
                        'start_date_label',
                        _dateLabel(cycle?.startDate),
                      ),
                      _detailRow(
                        'cycle_end_date_label',
                        _dateLabel(cycle?.endDate),
                      ),
                      _detailRow('due_day_label', cycle?.dueDay ?? '—'),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH.w,
                AppDimensions.spaceSm.h,
                AppDimensions.screenPaddingH.w,
                AppDimensions.spaceMd.h,
              ),
              child: AppButton(
                label: AppLocalizations.t(
                  _accepted
                      ? 'invitation_accepted_button'
                      : 'invitation_accept_button',
                ),
                icon: _accepted ? Icons.check_circle_outline : Icons.check,
                iconLeading: true,
                isLoading: _accepting,
                onPressed:
                    _loading || _loadError != null || _accepted
                        ? null
                        : _accept,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String key) => Padding(
    padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
    child: Text(
      AppLocalizations.t(key).toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    ),
  );

  Widget _detailRow(String labelKey, String value) => Padding(
    padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(
            AppLocalizations.t(labelKey),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

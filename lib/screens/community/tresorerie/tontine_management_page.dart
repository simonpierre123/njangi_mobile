import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleTontineManagementController.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';

class TontineManagementPage extends StatefulWidget {
  const TontineManagementPage({
    super.key,
    required this.community,
    required this.onBack,
    required this.onOpenHistory,
  });

  final CommunityModel community;
  final VoidCallback onBack;
  final VoidCallback onOpenHistory;

  @override
  State<TontineManagementPage> createState() => _TontineManagementPageState();
}

class _TontineManagementPageState extends State<TontineManagementPage> {
  Map<String, dynamic>? _overview;
  String? _cycleId;
  String? _error;
  bool _loading = true;
  bool _closing = false;
  String? _busyMembershipId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    var cycleId = _cycleId ?? widget.community.cycleId;
    if (cycleId == null || cycleId.isEmpty) {
      final cycles = await CycleController.getForGroup(widget.community.id);
      if (cycles != null && cycles.isNotEmpty) {
        final active = cycles.where((cycle) => cycle.status == 'EN_COURS');
        cycleId = (active.isEmpty ? cycles.first : active.first).id;
      }
    }
    if (!mounted) return;
    if (cycleId == null || cycleId.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.t('tontine_management_load_error');
      });
      return;
    }
    _cycleId = cycleId;
    final result = await CycleTontineManagementController.load(cycleId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true && result['data'] is Map) {
        _overview = Map<String, dynamic>.from(result['data'] as Map);
        _error = null;
      } else {
        _error =
            result['message']?.toString() ??
            AppLocalizations.t('tontine_management_load_error');
      }
    });
  }

  List<Map<String, dynamic>> _maps(dynamic value) =>
      value is List
          ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : const [];

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _name(Map<String, dynamic>? member) {
    if (member == null) return AppLocalizations.t('member_label');
    final first = member['prenom']?.toString().trim() ?? '';
    final last = member['nom']?.toString().trim() ?? '';
    final fullName = [first, last].where((part) => part.isNotEmpty).join(' ');
    return fullName.isEmpty
        ? member['utilisateur_nom']?.toString() ??
            AppLocalizations.t('member_label')
        : fullName;
  }

  String _amount(dynamic value, {String? currency}) {
    final number = num.tryParse(value?.toString() ?? '');
    final formatted =
        number == null
            ? '0'
            : NumberFormat.decimalPattern(
              AppLocalizations.locale.value,
            ).format(number);
    return '$formatted ${currency ?? _overview?['devise'] ?? 'XAF'}';
  }

  String _imageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openContribution(
    Map<String, dynamic> member,
    Map<String, dynamic> operation,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _name(member),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      AppLocalizations.t('contribution_amount_label'),
                      _amount(operation['montant']),
                    ),
                    _detailRow(
                      AppLocalizations.t('contribution_period_label'),
                      operation['periode']?.toString() ?? '—',
                    ),
                    _detailRow(
                      AppLocalizations.t('payment_method_label'),
                      operation['mode_paiement']?.toString() ?? '—',
                    ),
                    _detailRow(
                      AppLocalizations.t('payment_reference_label'),
                      operation['reference_paiement']?.toString() ?? '—',
                    ),
                    if (operation['is_simulation'] == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.t('payment_test_badge'),
                        style: const TextStyle(color: AppColors.alertRed),
                      ),
                    ],
                    if ((operation['preuve_paiement']?.toString() ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.t('tontine_receipt_label'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl(operation['preuve_paiement'].toString()),
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
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
                    if (operation['statut']?.toString() == 'EN_ATTENTE') ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _decide(operation, 'REJETE');
                              },
                              child: Text(
                                AppLocalizations.t('tontine_reject_button'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _decide(operation, 'VALIDE');
                              },
                              child: Text(
                                AppLocalizations.t('tontine_validate_button'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, textAlign: TextAlign.end),
        ),
      ],
    ),
  );

  Future<void> _decide(
    Map<String, dynamic> operation,
    String decision,
  ) async {
    final cycleId = _cycleId;
    final operationId = operation['id']?.toString();
    if (cycleId == null || operationId == null) return;

    String? reason;
    if (decision == 'REJETE') {
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(AppLocalizations.t('tontine_reject_title')),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.t('tontine_reject_reason'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppLocalizations.t('cancel_button')),
                ),
                TextButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) Navigator.pop(dialogContext, text);
                  },
                  child: Text(AppLocalizations.t('tontine_reject_button')),
                ),
              ],
            ),
      );
      controller.dispose();
      if (reason == null || reason.isEmpty) return;
    }

    final result = await CycleTontineManagementController.review(
      cycleId: cycleId,
      operationId: operationId,
      decision: decision,
      reason: reason,
    );
    if (!mounted) return;
    _message(
      result['message']?.toString() ??
          AppLocalizations.t('tontine_contribution_review_error'),
    );
    if (result['success'] == true) await _load();
  }

  Future<void> _sendReminder(Map<String, dynamic> member) async {
    final cycleId = _cycleId;
    final tourId = _map(_overview?['tour_courant'])?['id']?.toString();
    final membershipId = member['id']?.toString();
    if (cycleId == null || tourId == null || membershipId == null) return;
    setState(() => _busyMembershipId = membershipId);
    final result = await CycleTontineManagementController.remind(
      cycleId: cycleId,
      tourId: tourId,
      membershipId: membershipId,
    );
    if (!mounted) return;
    setState(() => _busyMembershipId = null);
    _message(
      result['message']?.toString() ??
          AppLocalizations.t('tontine_reminder_error'),
    );
  }

  Future<void> _closePeriod() async {
    final cycleId = _cycleId;
    final tourId = _map(_overview?['tour_courant'])?['id']?.toString();
    if (cycleId == null || tourId == null || _closing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.t('tontine_close_period_title')),
            content: Text(
              AppLocalizations.t('tontine_close_period_confirmation'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(AppLocalizations.t('cancel_button')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(AppLocalizations.t('tontine_close_period_button')),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    setState(() => _closing = true);
    final result = await CycleTontineManagementController.closePeriod(
      cycleId: cycleId,
      tourId: tourId,
    );
    if (!mounted) return;
    setState(() => _closing = false);
    _message(
      result['message']?.toString() ??
          AppLocalizations.t('tontine_period_close_error'),
    );
    if (result['success'] == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    final tour = _map(overview?['tour_courant']);
    final members = _maps(overview?['membres']);
    final validated =
        members.where((member) {
          final operation = _map(member['operation']);
          return operation?['statut'] == 'VALIDE';
        }).length;
    final pending =
        members.where((member) {
          return _map(member['operation'])?['statut'] == 'EN_ATTENTE';
        }).toList();
    final unpaid =
        members.where((member) {
          final operation = _map(member['operation']);
          return operation?['statut'] != 'VALIDE' &&
              operation?['statut'] != 'EN_ATTENTE';
        }).toList();
    final collected = members.fold<num>(0, (total, member) {
      final operation = _map(member['operation']);
      if (operation?['statut'] == 'VALIDE') {
        return total + (num.tryParse(operation?['montant']?.toString() ?? '') ?? 0);
      }
      return total;
    });
    final deadline = DateTime.tryParse(tour?['date_echeance']?.toString() ?? '');
    final periodEnded =
        deadline != null &&
        DateUtils.dateOnly(DateTime.now()).isAfter(DateUtils.dateOnly(deadline));
    final everyonePaid = members.isNotEmpty && validated == members.length;
    final canClose =
        tour != null &&
        pending.isEmpty &&
        (everyonePaid || periodEnded);
    final currency = overview?['devise']?.toString() ?? 'XAF';

    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.t('tontine_management_title'),
        onBack: widget.onBack,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _LoadError(message: _error!, onRetry: _load)
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onOpenHistory,
                      icon: const Icon(Icons.archive_outlined),
                      label: Text(
                        AppLocalizations.t('tontine_history_button'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (tour == null)
                      _EmptyPeriod(onOpenHistory: widget.onOpenHistory)
                    else ...[
                      _PeriodCard(
                        communityName: widget.community.name,
                        period: tour['periode']?.toString() ??
                            'TOUR-${tour['ordre'] ?? ''}',
                        dueDate: tour['date_echeance']?.toString(),
                        validated: validated,
                        memberCount: members.length,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: AppLocalizations.t(
                                'tontine_collected_amount',
                              ),
                              value: _amount(collected, currency: currency),
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              label: AppLocalizations.t(
                                'tontine_validated_count',
                              ),
                              value: '$validated/${members.length}',
                              icon: Icons.verified_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: AppLocalizations.t(
                                'tontine_pending_count',
                              ),
                              value: '${pending.length}',
                              icon: Icons.hourglass_top,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              label: AppLocalizations.t(
                                'tontine_unpaid_count',
                              ),
                              value: '${unpaid.length}',
                              icon: Icons.person_off_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionHeading(
                        title: AppLocalizations.t(
                          'tontine_pending_contributions',
                        ),
                        count: pending.length,
                      ),
                      if (pending.isEmpty)
                        _EmptyHint(
                          text: AppLocalizations.t(
                            'tontine_no_pending_contributions',
                          ),
                        )
                      else
                        for (final member in pending)
                          _ContributionTile(
                            name: _name(member),
                            amount: _amount(
                              _map(member['operation'])?['montant'],
                              currency: currency,
                            ),
                            onTap: () => _openContribution(
                              member,
                              _map(member['operation'])!,
                            ),
                          ),
                      const SizedBox(height: 24),
                      _SectionHeading(
                        title: AppLocalizations.t('tontine_members_to_remind'),
                        count: unpaid.length,
                      ),
                      if (unpaid.isEmpty)
                        _EmptyHint(
                          text: AppLocalizations.t(
                            'tontine_no_members_to_remind',
                          ),
                        )
                      else
                        for (final member in unpaid)
                          _UnpaidMemberTile(
                            name: _name(member),
                            status: _map(member['operation'])?['statut']
                                ?.toString(),
                            busy: _busyMembershipId == member['id']?.toString(),
                            onRemind: () => _sendReminder(member),
                          ),
                      const SizedBox(height: 24),
                      if (pending.isNotEmpty)
                        _EmptyHint(
                          text: AppLocalizations.t(
                            'tontine_close_pending_blocked',
                          ),
                          danger: true,
                        )
                      else if (!canClose)
                        _EmptyHint(
                          text: AppLocalizations.t(
                            'tontine_close_period_not_ready',
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              canClose && !_closing ? _closePeriod : null,
                          icon:
                              _closing
                                  ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.archive_outlined),
                          label: Text(
                            AppLocalizations.t('tontine_close_period_button'),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.communityName,
    required this.period,
    required this.dueDate,
    required this.validated,
    required this.memberCount,
  });

  final String communityName;
  final String period;
  final String? dueDate;
  final int validated;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(dueDate ?? '');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            communityName,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            period,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.t('tontine_deadline_label')}: '
            '${date == null ? '—' : DateFormat.yMMMd(AppLocalizations.locale.value).format(date)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: memberCount == 0 ? 0 : validated / memberCount,
            backgroundColor: Colors.white24,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Text(
            '$validated/$memberCount ${AppLocalizations.t('tontine_members_paid')}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 120),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.inputBorder),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryDark),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.tagMintBg,
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ContributionTile extends StatelessWidget {
  const _ContributionTile({
    required this.name,
    required this.amount,
    required this.onTap,
  });

  final String name;
  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(name),
      subtitle: Text('$amount · ${AppLocalizations.t('tontine_status_pending')}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _UnpaidMemberTile extends StatelessWidget {
  const _UnpaidMemberTile({
    required this.name,
    required this.status,
    required this.busy,
    required this.onRemind,
  });

  final String name;
  final String? status;
  final bool busy;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
      title: Text(name),
      subtitle: Text(
        status == 'REJETE'
            ? AppLocalizations.t('tontine_status_rejected')
            : AppLocalizations.t('tontine_status_unpaid'),
      ),
      trailing: TextButton.icon(
        onPressed: busy ? null : onRemind,
        icon:
            busy
                ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.notifications_active_outlined, size: 18),
        label: Text(AppLocalizations.t('tontine_remind_button')),
      ),
    ),
  );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Text(
      text,
      style: TextStyle(
        color: danger ? AppColors.alertRed : AppColors.textSecondary,
      ),
    ),
  );
}

class _EmptyPeriod extends StatelessWidget {
  const _EmptyPeriod({required this.onOpenHistory});

  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        const Icon(Icons.event_available_outlined, size: 52),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.t('tontine_no_active_period'),
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: onOpenHistory,
          child: Text(AppLocalizations.t('tontine_history_button')),
        ),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.t('invite_retry')),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Controllers_distant/CycleController.dart';
import '../../../Controllers_distant/CycleTontineManagementController.dart';
import '../../../ModeView/community_model.dart';
import '../../../common/basewidget/simple_app_bar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';

class TontineHistoryPage extends StatefulWidget {
  const TontineHistoryPage({
    super.key,
    required this.community,
    required this.onBack,
  });

  final CommunityModel community;
  final VoidCallback onBack;

  @override
  State<TontineHistoryPage> createState() => _TontineHistoryPageState();
}

class _TontineHistoryPageState extends State<TontineHistoryPage> {
  Map<String, dynamic>? _overview;
  String? _cycleId;
  String? _error;
  bool _loading = true;

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

  String _amount(dynamic value, String currency) {
    final number = num.tryParse(value?.toString() ?? '');
    final formatted =
        number == null
            ? '0'
            : NumberFormat.decimalPattern(
              AppLocalizations.locale.value,
            ).format(number);
    return '$formatted $currency';
  }

  String _imageUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.imageBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
  }

  Future<void> _showArchive(Map<String, dynamic> tour) async {
    final currency = _overview?['devise']?.toString() ?? 'XAF';
    final contributions = _maps(tour['cotisations']);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => SafeArea(
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.72,
              maxChildSize: 0.94,
              builder:
                  (context, scrollController) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '${AppLocalizations.t('tontine_history_period')} '
                        'TOUR-${tour['ordre'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.t('tontine_archive_read_only')} '
                        '· ${tour['date_cloture'] ?? tour['paye_le'] ?? '—'}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      if (contributions.isEmpty)
                        Text(
                          AppLocalizations.t(
                            'tontine_archive_no_contributions',
                          ),
                        )
                      else
                        for (final operation in contributions)
                          _ArchivedContribution(
                            name: _name(_map(operation['membre'])),
                            amount: _amount(operation['montant'], currency),
                            status: operation['statut']?.toString() ?? '',
                            receipt: operation['preuve_paiement']?.toString(),
                            imageUrl: _imageUrl,
                          ),
                    ],
                  ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tours =
        _maps(_overview?['tours'])
            .where(
              (tour) =>
                  tour['date_cloture'] != null || tour['statut'] == 'PAYE',
            )
            .toList()
          ..sort(
            (a, b) => (int.tryParse(b['ordre']?.toString() ?? '') ?? 0)
                .compareTo(int.tryParse(a['ordre']?.toString() ?? '') ?? 0),
          );
    final currency = _overview?['devise']?.toString() ?? 'XAF';

    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.t('tontine_archive_title'),
        onBack: widget.onBack,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _load,
                        child: Text(AppLocalizations.t('invite_retry')),
                      ),
                    ],
                  ),
                ),
              )
              : tours.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.t('tontine_history_empty'),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tours.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    final contributions = _maps(tour['cotisations']);
                    final validated = contributions.where(
                      (operation) => operation['statut'] == 'VALIDE',
                    );
                    final total = validated.fold<num>(
                      0,
                      (sum, operation) =>
                          sum +
                          (num.tryParse(
                                operation['montant']?.toString() ?? '',
                              ) ??
                              0),
                    );
                    final closedAt =
                        tour['date_cloture']?.toString() ??
                        tour['paye_le']?.toString() ??
                        '—';
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.archive_outlined),
                        ),
                        title: Text(
                          '${AppLocalizations.t('tontine_history_period')} '
                          'TOUR-${tour['ordre'] ?? ''}',
                        ),
                        subtitle: Text(
                          '${AppLocalizations.t('tontine_archive_closed_at')}: '
                          '$closedAt\n'
                          '${validated.length} · ${_amount(total, currency)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showArchive(tour),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class _ArchivedContribution extends StatelessWidget {
  const _ArchivedContribution({
    required this.name,
    required this.amount,
    required this.status,
    required this.receipt,
    required this.imageUrl,
  });

  final String name;
  final String amount;
  final String status;
  final String? receipt;
  final String Function(String) imageUrl;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status == 'VALIDE'
                ? AppLocalizations.t('tontine_status_validated')
                : status == 'REJETE'
                ? AppLocalizations.t('tontine_status_rejected')
                : AppLocalizations.t('tontine_status_pending'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if ((receipt ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl(receipt!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Text(AppLocalizations.t('tontine_receipt_load_error')),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

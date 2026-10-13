import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../Models/Invitation.dart';
import '../../../../ModeView/create_community_model.dart';
import '../../../../common/basewidget/app_button.dart';
import '../../../../common/basewidget/app_text_field.dart';
import '../../../../common/basewidget/shimmer_loading.dart';
import '../../../../common/basewidget/simple_app_bar.dart';
import '../../../../datasource/invitation_repository.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/app_dimensions.dart';
import 'invite_simulation_banner.dart';

/// Invitation depuis les contacts : chaque contact choisi reçoit un lien
/// personnel par WhatsApp ou SMS ; ouvert, il ajoute l'utilisateur au
/// groupe (ou le dirige vers le Play Store s'il n'a pas l'application).
class InviteContactsPage extends StatefulWidget {
  const InviteContactsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.onBack,
    required this.onDone,
  });

  final String groupId;
  final String groupName;
  final VoidCallback onBack;
  final ValueChanged<List<InvitedMember>> onDone;

  @override
  State<InviteContactsPage> createState() => _InviteContactsPageState();
}

class _InviteContactsPageState extends State<InviteContactsPage> {
  final InvitationRepository _repository = InvitationRepository.instance;
  final Map<String, InvitedMember> _invited = {};
  final Set<String> _inviting = {};
  final TextEditingController _searchController = TextEditingController();
  List<PhoneContact> _contacts = const [];
  bool _loading = true;
  bool _sending = false;

  List<PhoneContact> get _filteredContacts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _contacts;
    }
    final normalizedQuery = query.replaceAll(RegExp(r'\D'), '');
    return _contacts.where((contact) {
      final phoneDigits = contact.phone.replaceAll(RegExp(r'\D'), '');
      final matchesName = contact.name.toLowerCase().contains(query);
      final matchesPhone =
          normalizedQuery.isEmpty
              ? false
              : phoneDigits.contains(normalizedQuery);
      return matchesName || matchesPhone;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final status = await Permission.contacts.status;
      if (!mounted) return;
      if (status.isDenied ||
          status.isPermanentlyDenied ||
          status.isRestricted) {
        final requested = await Permission.contacts.request();
        if (!mounted) return;
        if (!requested.isGranted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.t('invite_error_generic')),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final contacts = await ContactsService.getContacts(withThumbnails: false);
      if (!mounted) return;

      final rows = <PhoneContact>[];
      final seen = <String>{};

      for (final contact in contacts) {
        final candidatePhones = contact.phones ?? const <Item>[];
        if (candidatePhones.isEmpty) continue;

        for (final phone in candidatePhones) {
          final rawNumber = (phone.value ?? '').trim();
          if (rawNumber.isEmpty) continue;

          final normalized = rawNumber.replaceAll(RegExp(r'\D'), '');
          if (normalized.isEmpty || seen.contains(normalized)) continue;

          seen.add(normalized);
          rows.add(
            PhoneContact(
              name:
                  (contact.displayName ?? '').trim().isNotEmpty
                      ? (contact.displayName ?? '').trim()
                      : 'Contact',
              phone: rawNumber,
            ),
          );
        }
      }

      rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      setState(() {
        _contacts = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError();
    }
  }

  Future<void> _inviteContact(PhoneContact contact) async {
    final phone = contact.phone;
    if (_invited.containsKey(phone) || _inviting.contains(phone)) return;

    setState(() => _inviting.add(phone));

    try {
      final invitations = await _repository.inviteContacts(
        groupId: widget.groupId,
        contacts: [contact],
      );
      if (!mounted) return;

      final invitation = invitations.firstOrNull;
      if (invitation == null) {
        throw StateError('Invitation not created');
      }

      setState(() {
        _invited[phone] = InvitedMember.fromInvitation(invitation);
        _inviting.remove(phone);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.t('invite_sent_simulated'))),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _inviting.remove(phone));
        _showError();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.t('invite_error_generic')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final hasInvited = _invited.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('invite_contacts_title'),
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH.w,
                  vertical: AppDimensions.spaceSm.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InviteSimulationBanner(),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    Text(
                      AppLocalizations.t('invite_contacts_desc'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label:
                          AppLocalizations.t(
                            'invite_contacts_search_label',
                          ).toUpperCase(),
                      hint: AppLocalizations.t('invite_contacts_search_hint'),
                      controller: _searchController,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    if (_loading)
                      Shimmer(
                        child: Column(
                          children: [
                            for (var i = 0; i < 4; i++) ...[
                              SkeletonBox(
                                width: double.infinity,
                                height: 56,
                                radius: AppDimensions.radiusMd,
                              ),
                              SizedBox(height: AppDimensions.spaceSm.h),
                            ],
                          ],
                        ),
                      )
                    else if (_filteredContacts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.t('invite_contacts_no_result'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      for (final contact in _filteredContacts)
                        _ContactTile(
                          contact: contact,
                          invited: _invited.containsKey(contact.phone),
                          inviting: _inviting.contains(contact.phone),
                          onInvite: () => _inviteContact(contact),
                        ),
                    if (hasInvited) ...[
                      SizedBox(height: AppDimensions.spaceMd.h),
                      Text(
                        AppLocalizations.t(
                          'invite_message_preview',
                        ).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXs.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppDimensions.spaceMd.w),
                        decoration: BoxDecoration(
                          color: AppColors.tagMintBg,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.t(
                            'invite_message_template',
                            args: [
                              widget.groupName,
                              '${AppConstants.inviteBaseUrl}…',
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
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
                label:
                    hasInvited
                        ? '${AppLocalizations.t('invite_done_button')} (${_invited.length})'
                        : AppLocalizations.t('invite_done_button'),
                icon: Icons.check_circle_outline,
                iconLeading: true,
                isLoading: _sending,
                onPressed:
                    hasInvited
                        ? () => widget.onDone(_invited.values.toList())
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.invited,
    required this.inviting,
    required this.onInvite,
  });

  final PhoneContact contact;
  final bool invited;
  final bool inviting;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final initials =
        contact.name.trim().isNotEmpty
            ? contact.name
                .trim()
                .split(RegExp(r'\s+'))
                .take(2)
                .map((part) => part[0].toUpperCase())
                .join()
            : 'C';

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
      padding: EdgeInsets.all(AppDimensions.spaceSm.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: invited ? AppColors.primaryDark : AppColors.inputBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: invited ? AppColors.tagMintBg : AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          SizedBox(
            width: 116,
            child: ElevatedButton(
              onPressed: (invited || inviting) ? null : onInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    invited ? AppColors.tagMintBg : AppColors.primaryDark,
                foregroundColor:
                    invited ? AppColors.primaryDark : AppColors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                inviting
                    ? AppLocalizations.t('invite_send_sms')
                    : invited
                    ? AppLocalizations.t('invite_sent_badge')
                    : AppLocalizations.t('invite_send_sms'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

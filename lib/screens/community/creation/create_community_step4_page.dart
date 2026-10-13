import 'package:flutter/material.dart';
import '../../../ModeView/create_community_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../datasource/invitation_repository.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/invite_action_grid.dart';
import 'widgets/invited_member_row.dart';

/// Créer une communauté — Étape 4/5 : inviter des membres.
///
/// Chaque action ouvre sa page et renvoie les membres invités ;
/// elles passent par [InvitationRepository] (simulé pour l'instant).
typedef InviteAction4 = Future<List<InvitedMember>?> Function();

class CreateCommunityStep4Page extends StatefulWidget {
  const CreateCommunityStep4Page({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onContinue,
    required this.onGenerateLink,
    required this.onShowQrCode,
    required this.onInviteByNumber,
    required this.onChooseContacts,
    this.standalone = false,
  });

  final CommunityDraft draft;
  final VoidCallback onBack;
  final ValueChanged<CommunityDraft> onContinue;
  final InviteAction4 onGenerateLink;
  final InviteAction4 onShowQrCode;
  final InviteAction4 onInviteByNumber;
  final InviteAction4 onChooseContacts;

  /// Ouverte depuis l'onglet Membres : hors assistant, sans numéro d'étape.
  final bool standalone;

  @override
  State<CreateCommunityStep4Page> createState() =>
      _CreateCommunityStep4PageState();
}

class _CreateCommunityStep4PageState extends State<CreateCommunityStep4Page> {
  late List<InvitedMember> _invited = List.of(widget.draft.invitedMembers);

  void _removeInvite(InvitedMember member) {
    setState(() => _invited.remove(member));
    final id = member.invitationId;
    if (id != null) InvitationRepository.instance.revoke(id);
  }

  Future<void> _open(InviteAction4 action) async {
    final added = await action();
    if (!mounted || added == null) return;
    setState(() {
      for (final member in added) {
        final exists = _invited.any(
          (m) => member.phone.isNotEmpty && m.phone == member.phone,
        );
        if (!exists) _invited.add(member);
      }
    });
  }

  void _continue() {
    widget.onContinue(widget.draft.copyWith(invitedMembers: _invited));
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH.w,
              ),
              child:
                  widget.standalone
                      ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spaceSm.h,
                          ),
                          child: IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimary,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      )
                      : StepHeader(
                        step: 4,
                        totalSteps: 5,
                        onBack: widget.onBack,
                      ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(
                      AppLocalizations.t('invite_members_title'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('invite_members_subtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    InviteActionGrid(
                      actions: [
                        InviteAction(
                          icon: Icons.link,
                          title: AppLocalizations.t('invite_link_title'),
                          subtitle: AppLocalizations.t('invite_link_subtitle'),
                          onTap: () => _open(widget.onGenerateLink),
                        ),
                        InviteAction(
                          icon: Icons.qr_code,
                          title: AppLocalizations.t('qr_code_title'),
                          subtitle: AppLocalizations.t('qr_code_subtitle'),
                          onTap: () => _open(widget.onShowQrCode),
                        ),
                        InviteAction(
                          icon: Icons.person_add_alt_outlined,
                          title: AppLocalizations.t('invite_by_number_title'),
                          subtitle: AppLocalizations.t(
                            'invite_by_number_subtitle',
                          ),
                          onTap: () => _open(widget.onInviteByNumber),
                        ),
                        InviteAction(
                          icon: Icons.contacts_outlined,
                          title: AppLocalizations.t('choose_contacts_title'),
                          subtitle: AppLocalizations.t(
                            'choose_contacts_subtitle',
                          ),
                          onTap: () => _open(widget.onChooseContacts),
                        ),
                      ],
                    ),
                    if (_invited.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spaceLg.h),
                      Text(
                        AppLocalizations.t(
                          'invitations_sent_section',
                        ).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      for (var i = 0; i < _invited.length; i++) ...[
                        InvitedMemberRow(
                          member: _invited[i],
                          onRemove: () => _removeInvite(_invited[i]),
                        ),
                        if (i != _invited.length - 1)
                          SizedBox(height: AppDimensions.spaceSm.h),
                      ],
                    ],
                    SizedBox(height: AppDimensions.spaceLg.h),
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
              child:
                  widget.standalone
                      ? AppButton(
                        label: AppLocalizations.t('invite_done_button'),
                        onPressed: widget.onBack,
                      )
                      : Column(
                        children: [
                          AppButton(
                            label: AppLocalizations.t('continue_button'),
                            icon: Icons.arrow_forward,
                            onPressed: _continue,
                          ),
                          SizedBox(height: AppDimensions.spaceSm.h),
                          AppButton(
                            label: AppLocalizations.t('invite_later_button'),
                            variant: AppButtonVariant.secondary,
                            onPressed: _continue,
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

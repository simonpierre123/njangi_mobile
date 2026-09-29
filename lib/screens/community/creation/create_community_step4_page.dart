import 'package:flutter/material.dart';
import '../../../Models/create_community_model.dart';
import '../../../common/basewidget/app_button.dart';
import '../../../common/basewidget/step_header.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';
import 'widgets/invite_action_grid.dart';
import 'widgets/invited_member_row.dart';

/// Créer une communauté — Étape 4/5 : inviter des membres.
///
/// TODO (Njoya) : les 4 actions de la grille (lien, QR code, numéro,
/// contacts) ne sont pas encore fonctionnelles (pas de vrai partage/
/// contacts branché) — elles renvoient vers un placeholder pour
/// l'instant. Le retrait ("x") d'une invitation déjà envoyée, lui,
/// fonctionne réellement (état local).
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
  });

  final CommunityDraft draft;
  final VoidCallback onBack;
  final ValueChanged<CommunityDraft> onContinue;
  final VoidCallback onGenerateLink;
  final VoidCallback onShowQrCode;
  final VoidCallback onInviteByNumber;
  final VoidCallback onChooseContacts;

  @override
  State<CreateCommunityStep4Page> createState() => _CreateCommunityStep4PageState();
}

class _CreateCommunityStep4PageState extends State<CreateCommunityStep4Page> {
  late List<InvitedMember> _invited = List.of(widget.draft.invitedMembers);

  void _removeInvite(InvitedMember member) {
    setState(() => _invited.remove(member));
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
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
              child: StepHeader(step: 4, totalSteps: 5, onBack: widget.onBack),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(AppLocalizations.t('invite_members_title'), style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('invite_members_subtitle'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    InviteActionGrid(
                      actions: [
                        InviteAction(
                          icon: Icons.link,
                          title: AppLocalizations.t('invite_link_title'),
                          subtitle: AppLocalizations.t('invite_link_subtitle'),
                          onTap: widget.onGenerateLink,
                        ),
                        InviteAction(
                          icon: Icons.qr_code,
                          title: AppLocalizations.t('qr_code_title'),
                          subtitle: AppLocalizations.t('qr_code_subtitle'),
                          onTap: widget.onShowQrCode,
                        ),
                        InviteAction(
                          icon: Icons.person_add_alt_outlined,
                          title: AppLocalizations.t('invite_by_number_title'),
                          subtitle: AppLocalizations.t('invite_by_number_subtitle'),
                          onTap: widget.onInviteByNumber,
                        ),
                        InviteAction(
                          icon: Icons.contacts_outlined,
                          title: AppLocalizations.t('choose_contacts_title'),
                          subtitle: AppLocalizations.t('choose_contacts_subtitle'),
                          onTap: widget.onChooseContacts,
                        ),
                      ],
                    ),
                    if (_invited.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spaceLg.h),
                      Text(
                        AppLocalizations.t('invitations_sent_section').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      for (var i = 0; i < _invited.length; i++) ...[
                        InvitedMemberRow(member: _invited[i], onRemove: () => _removeInvite(_invited[i])),
                        if (i != _invited.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
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
              child: Column(
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
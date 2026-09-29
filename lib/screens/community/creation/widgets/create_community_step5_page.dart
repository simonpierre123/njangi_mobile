import 'package:flutter/material.dart';
import '../../../../Models/create_community_model.dart';
import '../../../../common/basewidget/app_button.dart';
import '../../../../common/basewidget/step_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';
import '../widgets/review_section_card.dart';
import '../widgets/rules_checklist_item.dart';

/// Créer une communauté — Étape 5/5 : révision finale avant création.
/// Gère nativement les deux cas de figure : avec ou sans membres
/// invités (la carte "Membres invités" n'apparaît que si la liste
/// n'est pas vide).
class CreateCommunityStep5Page extends StatefulWidget {
  const CreateCommunityStep5Page({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onCreate,
    required this.onEditGeneral,
    required this.onEditFinancial,
    required this.onEditRules,
    required this.onEditMembers,
  });

  final CommunityDraft draft;
  final VoidCallback onBack;
  final VoidCallback onCreate;
  final VoidCallback onEditGeneral;
  final VoidCallback onEditFinancial;
  final VoidCallback onEditRules;
  final VoidCallback onEditMembers;

  @override
  State<CreateCommunityStep5Page> createState() => _CreateCommunityStep5PageState();
}

class _CreateCommunityStep5PageState extends State<CreateCommunityStep5Page> {
  bool _confirmed = false;

  static const _monthsFr = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formatDate(DateTime d) {
    final isFr = AppLocalizations.locale.value == 'fr';
    final month = (isFr ? _monthsFr : _monthsEn)[d.month - 1];
    return isFr ? '${d.day} $month ${d.year}' : '$month ${d.day}, ${d.year}';
  }

  void _handleCreate() {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.t('confirm_required_message'))),
      );
      return;
    }
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);
    final draft = widget.draft;
    final hasInvites = draft.invitedMembers.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
              child: StepHeader(step: 5, totalSteps: 5, onBack: widget.onBack),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spaceSm.h),
                    Text(
                      AppLocalizations.t('almost_done_title'),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t('review_subtitle'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),

                    // Informations générales
                    ReviewSectionCard(
                      icon: Icons.info_outline,
                      title: AppLocalizations.t('general_info_title'),
                      onEdit: widget.onEditGeneral,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                ),
                                child: const Icon(Icons.groups_outlined, size: 20, color: AppColors.textSecondary),
                              ),
                              SizedBox(width: AppDimensions.spaceSm.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft.name.isEmpty ? '—' : draft.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    '${AppLocalizations.t('type_label_prefix')} ${draft.type != null ? AppLocalizations.t(draft.type!.labelKey) : '—'}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.spaceSm.h),
                          Text(
                            AppLocalizations.t('description_label').toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            draft.description.isEmpty ? '—' : draft.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),

                    // Configuration financière
                    ReviewSectionCard(
                      icon: Icons.credit_card_outlined,
                      title: AppLocalizations.t('financial_config_title'),
                      onEdit: widget.onEditFinancial,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ReviewField(
                                  label: AppLocalizations.t('cotisation_label').toUpperCase(),
                                  value: draft.contributionAmount.isEmpty ? '—' : '${draft.contributionAmount} FCFA',
                                  emphasized: true,
                                ),
                              ),
                              Expanded(
                                child: _ReviewField(
                                  label: AppLocalizations.t('frequency_label').toUpperCase(),
                                  value: draft.frequency != null ? AppLocalizations.t(draft.frequency!.titleKey) : '—',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.spaceSm.h),
                          Row(
                            children: [
                              Expanded(
                                child: _ReviewField(
                                  label: AppLocalizations.t('start_date_label').toUpperCase(),
                                  value: draft.startDate != null ? _formatDate(draft.startDate!) : '—',
                                ),
                              ),
                              Expanded(
                                child: _ReviewField(
                                  label: AppLocalizations.t('due_day_label').toUpperCase(),
                                  value: draft.dueDayLabel ?? '—',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),

                    // Règles
                    ReviewSectionCard(
                      icon: Icons.shield_outlined,
                      title: AppLocalizations.t('rules_short_title'),
                      onEdit: widget.onEditRules,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RulesChecklistItem(
                            enabled: draft.allowLoans,
                            label: AppLocalizations.t(draft.allowLoans ? 'rules_loans_enabled' : 'rules_loans_disabled'),
                          ),
                          RulesChecklistItem(
                            enabled: draft.penaltiesEnabled,
                            label: AppLocalizations.t(draft.penaltiesEnabled ? 'rules_penalties_enabled' : 'rules_penalties_disabled'),
                          ),
                          RulesChecklistItem(
                            enabled: draft.adminValidationRequired,
                            label: AppLocalizations.t(
                              draft.adminValidationRequired ? 'rules_admin_validation_enabled' : 'rules_admin_validation_disabled',
                            ),
                          ),
                          RulesChecklistItem(
                            enabled: draft.collectiveValidation,
                            label: AppLocalizations.t(
                              draft.collectiveValidation ? 'collective_validation_title' : 'rules_admin_validation_disabled',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Membres invités — uniquement si des invitations existent.
                    if (hasInvites) ...[
                      SizedBox(height: AppDimensions.spaceMd.h),
                      ReviewSectionCard(
                        icon: Icons.people_outline,
                        title: AppLocalizations.t('invited_members_card_title'),
                        onEdit: widget.onEditMembers,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 56,
                              height: 36,
                              child: Stack(
                                children: [
                                  for (var i = 0; i < draft.invitedMembers.length && i < 2; i++)
                                    Positioned(
                                      left: i * 26.0,
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: draft.invitedMembers[i].avatarBg,
                                        child: Text(
                                          draft.invitedMembers[i].initials,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: draft.invitedMembers[i].avatarColor),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppDimensions.spaceSm.w),
                            Text(
                              '${draft.invitedMembers.length} ${AppLocalizations.t('invitations_sent_label')}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: AppDimensions.spaceLg.h),

                    InkWell(
                      onTap: () => setState(() => _confirmed = !_confirmed),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _confirmed,
                            onChanged: (v) => setState(() => _confirmed = v ?? false),
                            activeColor: AppColors.primaryDark,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                AppLocalizations.t('confirm_checkbox_label'),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
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
                    label: AppLocalizations.t('create_community_button'),
                    icon: Icons.arrow_forward,
                    onPressed: _handleCreate,
                  ),
                  SizedBox(height: AppDimensions.spaceSm.h),
                  AppButton(
                    label: AppLocalizations.t('back_button'),
                    variant: AppButtonVariant.secondary,
                    onPressed: widget.onBack,
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

class _ReviewField extends StatelessWidget {
  const _ReviewField({required this.label, required this.value, this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 16 : 13,
            fontWeight: FontWeight.w700,
            color: emphasized ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
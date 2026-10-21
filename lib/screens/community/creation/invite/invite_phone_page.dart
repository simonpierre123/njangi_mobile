import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../Models/Invitation.dart';
import '../../../../ModeView/create_community_model.dart';
import '../../../../common/basewidget/app_button.dart';
import '../../../../common/basewidget/app_text_field.dart';
import '../../../../common/basewidget/shimmer_loading.dart';
import '../../../../common/basewidget/simple_app_bar.dart';
import '../../../../datasource/invitation_repository.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Recherche les comptes existants et permet aussi d'inviter un numéro inscrit
/// qui n'a pas encore de compte.
class InvitePhonePage extends StatefulWidget {
  const InvitePhonePage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.cycleId,
    required this.onBack,
    required this.onDone,
  });

  final String groupId;
  final String groupName;
  final String? cycleId;
  final VoidCallback onBack;
  final ValueChanged<List<InvitedMember>> onDone;

  @override
  State<InvitePhonePage> createState() => _InvitePhonePageState();
}

class _InvitePhonePageState extends State<InvitePhonePage> {
  static const _minDigits = 3;

  final InvitationRepository _repository = InvitationRepository.instance;
  final TextEditingController _controller = TextEditingController();
  final Map<String, InvitedMember> _invited = {};
  final Set<String> _inviting = {};
  Timer? _debounce;
  int _searchId = 0;
  List<RegisteredUser> _results = const [];
  bool _searching = false;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < _minDigits) {
      _searchId++;
      setState(() {
        _results = const [];
        _searching = false;
        _searched = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    final id = ++_searchId;
    try {
      final results = await _repository.searchUsersByPhone(query);
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = results;
        _searching = false;
        _searched = true;
      });
    } catch (_) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = const [];
        _searching = false;
        _searched = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.t('invite_search_error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _invite(RegisteredUser user) async {
    if (_invited.containsKey(user.phone) || !_inviting.add(user.phone)) return;
    setState(() {});
    try {
      final invitation = await _repository.inviteUser(
        groupId: widget.groupId,
        groupName: widget.groupName,
        cycleId: widget.cycleId,
        user: user,
      );
      if (!mounted) return;
      setState(
        () => _invited[user.phone] = InvitedMember.fromInvitation(invitation),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.t(_inviteResultKey(invitation.pushSent)),
          ),
          backgroundColor:
              invitation.pushSent == false ? Colors.orange : Colors.green,
        ),
      );
    } catch (error) {
      if (mounted) {
        _showError(
          error is InviteFlowException
              ? error.message
              : AppLocalizations.t('invite_persist_error'),
        );
      }
    } finally {
      _inviting.remove(user.phone);
      if (mounted) setState(() {});
    }
  }

  String _inviteResultKey(bool? pushSent) => switch (pushSent) {
    true => 'invite_sent_success',
    false => 'invite_saved_no_push',
    null => 'invite_saved_success',
  };

  Future<void> _inviteUnregisteredNumber() async {
    final phone = _controller.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8 ||
        _invited.containsKey(phone) ||
        !_inviting.add(phone)) {
      return;
    }

    setState(() {});
    try {
      final invitation = await _repository.invitePhone(
        groupId: widget.groupId,
        groupName: widget.groupName,
        cycleId: widget.cycleId,
        phone: phone,
      );
      if (!mounted) return;
      setState(
        () => _invited[phone] = InvitedMember.fromInvitation(invitation),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.t('invite_saved_no_push')),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (error) {
      if (mounted) {
        _showError(
          error is InviteFlowException
              ? error.message
              : AppLocalizations.t('invite_persist_error'),
        );
      }
    } finally {
      _inviting.remove(phone);
      if (mounted) setState(() {});
    }
  }

  void _showError([String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? AppLocalizations.t('invite_error_generic')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t('invite_phone_title'),
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH.w,
                  vertical: AppDimensions.spaceSm.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t('invite_phone_desc'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    AppTextField(
                      label:
                          AppLocalizations.t(
                            'invite_phone_label',
                          ).toUpperCase(),
                      hint: AppLocalizations.t('invite_phone_hint'),
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      onChanged: _onChanged,
                    ),
                    SizedBox(height: AppDimensions.spaceXs.h),
                    Text(
                      AppLocalizations.t(
                        'invite_phone_helper',
                        args: ['$_minDigits'],
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceMd.h),
                    _buildResults(),
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
                label: AppLocalizations.t('invite_done_button'),
                onPressed: () => widget.onDone(_invited.values.toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_searching) {
      return Shimmer(
        child: Column(
          children: [
            for (var i = 0; i < 2; i++) ...[
              SkeletonBox(
                height: 56,
                width: double.infinity,
                radius: AppDimensions.radiusMd,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
            ],
          ],
        ),
      );
    }
    if (_searched && _results.isEmpty) {
      final phone = _controller.text.trim();
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMd.h),
        child: Column(
          children: [
            Text(
              AppLocalizations.t('invite_phone_no_result'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (digits.length >= 8) ...[
              SizedBox(height: AppDimensions.spaceMd.h),
              AppButton(
                label: AppLocalizations.t('invite_phone_unregistered_button'),
                icon: Icons.person_add_alt_1,
                isLoading: _inviting.contains(phone),
                onPressed:
                    _inviting.contains(phone)
                        ? null
                        : _inviteUnregisteredNumber,
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final user in _results) ...[
          _UserTile(
            user: user,
            invited: _invited.containsKey(user.phone),
            inviting: _inviting.contains(user.phone),
            onTap: () => _invite(user),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
        ],
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.invited,
    required this.inviting,
    required this.onTap,
  });

  final RegisteredUser user;
  final bool invited;
  final bool inviting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: invited || inviting ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.tagMintBg,
                child: Text(
                  user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
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
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (inviting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (invited)
                Text(
                  AppLocalizations.t('invite_sent_badge'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                )
              else
                const Icon(
                  Icons.person_add_alt_outlined,
                  color: AppColors.primaryDark,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

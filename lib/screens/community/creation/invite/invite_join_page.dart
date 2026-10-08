import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../Models/Invitation.dart';
import '../../../../Models/create_community_model.dart';
import '../../../../common/basewidget/app_button.dart';
import '../../../../common/basewidget/shimmer_loading.dart';
import '../../../../common/basewidget/simple_app_bar.dart';
import '../../../../datasource/invitation_repository.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/app_dimensions.dart';
import '../widgets/invited_member_row.dart';
import 'fake_qr_code.dart';
import 'invite_simulation_banner.dart';

/// Invitation par lien ou par QR code : un jeton d'adhésion unique
/// que n'importe quel utilisateur inscrit peut utiliser pour rejoindre
/// le groupe (et son cycle).
class InviteJoinPage extends StatefulWidget {
  const InviteJoinPage({
    super.key,
    required this.groupId,
    required this.method,
    required this.onBack,
    required this.onDone,
  }) : assert(method == InvitationMethod.link || method == InvitationMethod.qr);

  final String groupId;
  final InvitationMethod method;
  final VoidCallback onBack;
  final ValueChanged<List<InvitedMember>> onDone;

  @override
  State<InviteJoinPage> createState() => _InviteJoinPageState();
}

class _InviteJoinPageState extends State<InviteJoinPage> {
  final InvitationRepository _repository = InvitationRepository.instance;
  final GlobalKey _qrKey = GlobalKey();
  final List<InvitedMember> _joined = [];
  Invitation? _invitation;
  bool _loading = true;
  bool _failed = false;
  bool _simulating = false;

  bool get _isQr => widget.method == InvitationMethod.qr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final invitation = await _repository.createJoinToken(
        groupId: widget.groupId,
        method: widget.method,
      );
      if (!mounted) return;
      setState(() {
        _invitation = invitation;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _copyLink() async {
    final link = _invitation?.link;
    if (link == null) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.t('invite_link_copied'))),
    );
  }

  Future<void> _shareInvitation() async {
    final invitation = _invitation;
    final link = invitation?.link;
    if (invitation == null || link == null) return;

    try {
      if (!_isQr) {
        await SharePlus.instance.share(ShareParams(text: link));
        return;
      }

      final renderObject = _qrKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return;

      final image = await renderObject.toImage(pixelRatio: 3);
      final imageData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (imageData == null) throw StateError('QR image could not be created');

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              imageData.buffer.asUint8List(),
              mimeType: 'image/png',
            ),
          ],
          fileNameOverrides: ['njangi-invitation.png'],
          text: link,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.t('invite_error_generic'))),
      );
    }
  }

  Future<void> _simulateJoin() async {
    final invitation = _invitation;
    if (invitation == null || _simulating) return;
    setState(() => _simulating = true);
    try {
      final joined = await _repository.simulateJoin(invitation);
      if (!mounted) return;
      final member = InvitedMember.fromInvitation(joined);
      setState(() {
        if (_joined.every((m) => m.phone != member.phone)) _joined.add(member);
      });
    } finally {
      if (mounted) setState(() => _simulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(
        title: AppLocalizations.t(
          _isQr ? 'invite_qr_title' : 'invite_link_title',
        ),
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
                      AppLocalizations.t(
                        _isQr ? 'invite_qr_desc' : 'invite_link_desc',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceLg.h),
                    _buildToken(),
                    if (_invitation != null) ...[
                      SizedBox(height: AppDimensions.spaceMd.h),
                      AppButton(
                        label: AppLocalizations.t('invite_share_button'),
                        icon: Icons.share_outlined,
                        iconLeading: true,
                        onPressed: _shareInvitation,
                      ),
                      if (!_isQr) SizedBox(height: AppDimensions.spaceSm.h),
                      if (!_isQr)
                        AppButton(
                          label: AppLocalizations.t('invite_link_copy'),
                          icon: Icons.copy_outlined,
                          iconLeading: true,
                          onPressed: _copyLink,
                        ),
                      if (!_isQr) SizedBox(height: AppDimensions.spaceSm.h),
                      AppButton(
                        label: AppLocalizations.t(
                          _isQr
                              ? 'invite_simulate_scan'
                              : 'invite_simulate_open',
                        ),
                        variant: AppButtonVariant.secondary,
                        isLoading: _simulating,
                        onPressed: _simulateJoin,
                      ),
                    ],
                    if (_joined.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spaceLg.h),
                      Text(
                        AppLocalizations.t(
                          'invite_joined_section',
                        ).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceSm.h),
                      for (final member in _joined) ...[
                        InvitedMemberRow(member: member),
                        SizedBox(height: AppDimensions.spaceSm.h),
                      ],
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
                label: AppLocalizations.t('invite_done_button'),
                onPressed: () => widget.onDone(List.of(_joined)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToken() {
    if (_loading) {
      return Shimmer(
        child: SkeletonBox(
          width: double.infinity,
          height: _isQr ? 220 : 56,
          radius: AppDimensions.radiusMd,
        ),
      );
    }
    if (_failed || _invitation == null) {
      return Column(
        children: [
          Text(
            AppLocalizations.t('invite_error_generic'),
            style: const TextStyle(color: AppColors.alertRed, fontSize: 12),
          ),
          TextButton(
            onPressed: _load,
            child: Text(AppLocalizations.t('invite_retry')),
          ),
        ],
      );
    }
    if (_isQr) {
      return Center(
        child: RepaintBoundary(
          key: _qrKey,
          child: InvitationQrCode(data: _invitation!.link!, size: 220),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            _invitation!.link!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: AppDimensions.spaceXs.h),
          Text(
            AppLocalizations.t(
              'invite_link_fallback',
              args: [AppConstants.playStoreUrl],
            ),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

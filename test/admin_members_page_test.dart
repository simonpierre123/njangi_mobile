import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_members_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/screens/community/membres/admin_members_page.dart';
import 'package:njangi/utils/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin can assign a group role from the member overflow menu', (
    tester,
  ) async {
    await AppLocalizations.load();
    final adapter = _RoleUpdateAdapter();
    ApiService.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AdminMembersPage(
            summary: const CommunitySummary(
              totalMembers: 2,
              adminCount: 1,
              activeCount: 2,
              cycleLabel: '1/1',
            ),
            groupId: 'group-id',
            currentUserRole: 'ADMIN',
            directory: [
              const AdminMemberEntry(
                name: 'Membre Test',
                statusLine: 'À jour',
                statusIcon: Icons.circle,
                statusColor: AppColors.primary,
                details: MemberPersonalDetails(
                  userId: 'member-id',
                  role: 'MEMBRE',
                ),
              ),
            ],
            growth: const GrowthStats(newMembersLabel: '0', percent: 0),
            onInviteMember: () {},
            onMemberUrgentAction: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Membre Test'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Trésorier'), findsOneWidget);
    expect(find.text(AppLocalizations.t('role_co_admin')), findsOneWidget);

    await tester.tap(find.text('Trésorier'));
    await tester.pumpAndSettle();

    expect(
      adapter.request?.uri.path,
      '/api/groupes/group-id/membres/member-id/role',
    );
    final requestData = adapter.request?.data;
    expect(requestData is String ? jsonDecode(requestData) : requestData, {
      'role': 'TRESORIER',
    });
    expect(find.text('Trésorier'), findsOneWidget);
    expect(find.text('Le rôle du membre a été mis à jour.'), findsOneWidget);
  });

}

class _RoleUpdateAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {'role': 'TRESORIER'},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/home_financial_summary_model.dart';
import 'package:njangi/screens/home/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'financial summary formats grouped amounts without merging currencies',
    () {
      const summary = HomeFinancialSummary(
        actionCount: 3,
        debtTotalsByCurrency: {'XAF': 75000, 'USD': 1200},
        contributionTotalsByCurrency: {'XAF': 10000},
      );

      expect(
        summary.formattedDebtAmount(xafLabel: 'FCFA'),
        '75 000 FCFA · 1 200 USD',
      );
      expect(
        summary.formattedContributionAmount(xafLabel: 'FCFA'),
        '10 000 FCFA',
      );
      expect(summary.actionCount, 3);
    },
  );

  test('financial summary reads debt and current contributions separately', () {
    final summary = HomeFinancialSummary.fromJson({
      'nombre_actions': 2,
      'totaux_dettes_par_devise': {'XAF': 25000},
      'totaux_cotisations_par_devise': {'XAF': 10000},
      'totaux_par_devise': {'XAF': 35000},
    });

    expect(summary.actionCount, 2);
    expect(summary.formattedDebtAmount(xafLabel: 'FCFA'), '25 000 FCFA');
    expect(
      summary.formattedContributionAmount(xafLabel: 'FCFA'),
      '10 000 FCFA',
    );
  });

  testWidgets(
    'home displays zero obligations and zero actions when none are due',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomePage(
              userName: 'Utilisateur',
              userPhotoUrl: null,
              greetingSubtitleKey: 'greeting_subtitle',
              communities: const [],
              financialActionCount: 0,
              debtAmount: '0 FCFA',
              currentContributionAmount: '0 FCFA',
              isProfileComplete: true,
              onIdentify: () {},
              onCommunityTap: (_) {},
              onRefresh: () async {},
              onLock: () async {},
            ),
          ),
        ),
      );

      expect(find.text('0 FCFA'), findsNWidgets(2));
      expect(find.text('0'), findsNWidgets(2));
      expect(find.textContaining('Impossible de charger'), findsNothing);
    },
  );
}

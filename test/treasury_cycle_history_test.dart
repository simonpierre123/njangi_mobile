import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/Models/Cycle.dart';
import 'package:njangi/ModeView/treasury_model.dart';

void main() {
  final cycles = [
    const Cycle(id: 'closed-2', number: 2, status: 'TERMINEE'),
    const Cycle(id: 'pending-6', number: 6, status: 'EN_ATTENTE'),
    const Cycle(id: 'current-5', number: 5, status: 'EN_COURS'),
    const Cycle(id: 'closed-4', number: 4, status: 'TERMINEE'),
    const Cycle(id: 'closed-3', number: 3, status: 'TERMINEE'),
  ];

  test('cycle history contains current and closed cycles, newest first', () {
    final history = cycleHistoryFromCycles(cycles);

    expect(history.map((cycle) => cycle.id).toList(), [
      'current-5',
      'closed-4',
      'closed-3',
      'closed-2',
    ]);
    expect(history.first.isCurrent, isTrue);
    expect(history.skip(1).every((cycle) => !cycle.isCurrent), isTrue);
  });

  test('cycle history initially shows three and expands to every cycle', () {
    final history = cycleHistoryFromCycles(cycles);

    expect(
      visibleCycleHistory(history, expanded: false).map((cycle) => cycle.id),
      ['current-5', 'closed-4', 'closed-3'],
    );
    expect(
      visibleCycleHistory(history, expanded: true).map((cycle) => cycle.id),
      ['current-5', 'closed-4', 'closed-3', 'closed-2'],
    );
  });

  test('history with at most three cycles needs no expansion', () {
    final history = cycleHistoryFromCycles(cycles).take(3).toList();

    expect(visibleCycleHistory(history, expanded: false), hasLength(3));
  });
}

import 'package:edunexus/data/app_state.dart';
import 'package:edunexus/data/models.dart';
import 'package:edunexus/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen renders', (tester) async {
    await tester.pumpWidget(EduNexusApp(state: AppState()));
    expect(find.text('EduNexus'), findsOneWidget);
    expect(find.text('Get OTP'), findsOneWidget);
  });

  test('teacher leave approval is visible to the parent', () {
    final s = AppState();
    final pending = s.leavesFor('c1').firstWhere((l) => l.status == LeaveStatus.pending);
    s.decideLeave(pending, true);
    expect(s.leavesFor('c1').first.status, LeaveStatus.approved);
  });

  test('partial fee payment spreads across items', () {
    final s = AppState();
    final items = s.feesFor('c1').where((f) => !f.isPaid).take(2).toList();
    final before = items.fold<double>(0, (a, f) => a + f.balance);
    s.payFees('c1', items, 'UPI', partial: 10000);
    final after = items.fold<double>(0, (a, f) => a + f.balance);
    expect(before - after, 10000);
  });
}

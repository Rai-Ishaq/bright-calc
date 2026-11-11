import 'package:flutter_test/flutter_test.dart';
import 'package:bright_calc/main.dart';

void main() {
  testWidgets('Calculator app load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BrightCalcApp());

    // Verify that the title is present
    expect(find.text('Bright Calculator'), findsOneWidget);
  });
}
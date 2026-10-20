import 'package:flutter_test/flutter_test.dart';
import 'package:wafra_app/main.dart';

void main() {
  testWidgets('Wafra discount app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WafraDiscountApp());
    expect(find.text('More For Less'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}

import 'package:emora_mobile_app/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmoraApp());

    expect(find.text('Emora'), findsOneWidget);
  });
}

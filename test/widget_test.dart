import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/main.dart';

void main() {
  testWidgets('app starts with NEXO title', (tester) async {
    await tester.pumpWidget(const NexoApp());
    await tester.pumpAndSettle();

    expect(find.text('NEXO'), findsOneWidget);
  });
}

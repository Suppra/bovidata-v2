import 'package:flutter_test/flutter_test.dart';

import 'package:bovidata_new/main.dart';

void main() {
  testWidgets('BoviData app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BoviDataApp());

    // Verify that the login screen is shown initially
    expect(find.text('BoviData'), findsOneWidget);
    expect(find.text('Sistema de Gestión de Ganado'), findsOneWidget);
  });
}

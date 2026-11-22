import 'package:flutter_test/flutter_test.dart';
import 'package:climap_flutter/main.dart';

void main() {
  testWidgets('Carga la aplicación correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MiAplicacionClima());
    expect(find.byType(MiAplicacionClima), findsOneWidget);
  });
}

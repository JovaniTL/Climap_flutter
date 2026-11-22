import 'package:flutter_test/flutter_test.dart';
import 'package:climap_flutter/main.dart';

void main() {
  testWidgets('Carga la aplicación con sus 3 pestañas y vista inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MiAplicacionClima());

    expect(find.byType(MiAplicacionClima), findsOneWidget);
    expect(find.text('Clima'), findsOneWidget);
    expect(find.text('Comparar'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('¡Consulta el clima de cualquier ciudad!'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
  });
}

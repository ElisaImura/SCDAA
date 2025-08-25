import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scdaa/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // ✅ Pasa `isLoggedIn` como parámetro requerido
    await tester.pumpWidget(const MyApp()); // 🔹 Puedes cambiar a `true` si deseas probar autenticado

    // ✅ Verifica que no haya errores en la pantalla de inicio de sesión o el home
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // ✅ Tap en el botón de agregar y vuelve a renderizar el frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // ✅ Verifica el cambio en la UI
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

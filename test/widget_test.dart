import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:testflutter/main.dart';

void main() {
  testWidgets(
    'Muestra estado vacío y luego agrega un gasto reflejando balances',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));

      // Estado vacío inicial.
      expect(find.text('Todavía no hay gastos registrados'), findsOneWidget);

      // Ir al formulario.
      await tester.tap(find.text('Agregar gasto'));
      await tester.pumpAndSettle();

      // Intentar guardar vacío: debe validar y no navegar.
      await tester.tap(find.text('Guardar gasto'));
      await tester.pump();
      expect(find.text('Ingresa un nombre para el gasto'), findsOneWidget);

      // Completar el formulario.
      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del gasto'), 'Cena');
      await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '100');
      await tester.tap(find.text('Guardar gasto'));
      await tester.pumpAndSettle();

      // Vuelve a la lista y muestra el gasto y el balance.
      expect(find.text('Cena'), findsOneWidget);
      expect(find.text('\$100.00'), findsWidgets);
    },
  );
}

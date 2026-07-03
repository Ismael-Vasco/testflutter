# Gastos Compartidos (Split Expenses)

App de Flutter para registrar los gastos de un grupo fijo de 4 personas y ver,
en tiempo real, cuánto debe pagar o recibir cada una respecto al promedio del
grupo.

## Estructura del proyecto

```
lib/
  models/
    person.dart              # Enum con las 4 personas fijas del grupo
    expense.dart              # Modelo de un gasto (nombre, monto, quién pagó)
  state/
    expenses_provider.dart    # Estado (Riverpod) + cálculo derivado de balances
  utils/
    currency_formatter.dart   # Formato de moneda consistente (2 decimales)
  router/
    app_router.dart           # Navegación con go_router
  screens/
    expenses_list_screen.dart # Lista de gastos + balances + estado vacío
    add_expense_screen.dart   # Formulario con validación
  main.dart
```

## Requisitos previos

- Flutter 3.44+ (channel stable) y Dart 3.12+.
- Un dispositivo/emulador Android para `flutter run`, o simplemente Android
  Studio/`flutter build apk` para generar el instalable.

## Cómo ejecutar la app

```bash
flutter pub get
flutter run
```

## Cómo generar el APK

```bash
flutter build apk --release
```

El instalable queda en `build/app/outputs/flutter-apk/app-release.apk`
(ya fue generado y verificado en este repo). Para instalarlo en un dispositivo
conectado por ADB:

```bash
flutter install
```

## Cómo correr los tests

```bash
flutter analyze
flutter test
```

## Reflexión: decisiones de diseño

Elegí **Riverpod** por sobre Cubit/BLoC porque esta app tiene un único estado
compartido (la lista de gastos) del que se deriva todo lo demás (balances,
lista renderizada, estado vacío), y Riverpod resuelve exactamente ese caso con
muy poco boilerplate: un `StateNotifierProvider` guarda los gastos y un
`Provider` derivado (`balancesProvider`) recalcula los balances automáticamente
vía `ref.watch` cada vez que la lista cambia, sin necesidad de emitir eventos
ni declarar estados intermedios como haría BLoC. Para una app de este tamaño
(una lista, un formulario y un cálculo derivado) BLoC habría añadido
ceremonia innecesaria (eventos, estados sellados) y Cubit habría quedado corto
para expresar limpiamente la relación reactiva entre gastos y balances sin
recalcular manualmente en cada pantalla. Para el cálculo del balance decidí
que el promedio siempre se divide entre las 4 personas fijas (no solo entre
quienes ya pagaron algo), porque el balance representa cuánto le toca a cada
uno del total del grupo, no un promedio de participantes activos; así, alguien
que nunca pagó nada arranca con balance negativo (debe) apenas existe un gasto
en el grupo, que es el comportamiento esperado en una app de gastos
compartidos. También centralicé el formato de moneda en un solo helper
(`formatCurrency`) para garantizar 2 decimales consistentes en la lista, el
formulario y los chips de balance, evitando que redondeos distintos aparezcan
en distintas pantallas.

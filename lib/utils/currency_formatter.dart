import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 2,
);

/// Formatea un monto con exactamente 2 decimales de forma consistente
/// en toda la app (lista, formulario y balances), redondeando cuando
/// la suma o el promedio generan más decimales.
String formatCurrency(double value) => _currencyFormat.format(value);

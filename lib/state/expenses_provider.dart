import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../models/person.dart';

const _uuid = Uuid();

/// Fuente única de verdad para los gastos registrados.
///
/// Se eligió un [StateNotifier] con Riverpod: al reemplazar `state` con una
/// nueva lista, cualquier provider derivado (como [balancesProvider]) que
/// haga `ref.watch` se recalcula y notifica automáticamente a la UI, sin
/// necesidad de recargar la pantalla manualmente.
class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super(const []);

  void addExpense({
    required String name,
    required double amount,
    required Person paidBy,
  }) {
    state = [
      ...state,
      Expense(
        id: _uuid.v4(),
        name: name,
        amount: amount,
        paidBy: paidBy,
        createdAt: DateTime.now(),
      ),
    ];
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>(
  (ref) => ExpensesNotifier(),
);

/// Balance calculado de una persona respecto al promedio del grupo.
class PersonBalance {
  final Person person;
  final double totalPaid;
  final double balance;

  const PersonBalance({
    required this.person,
    required this.totalPaid,
    required this.balance,
  });

  /// true si la persona debe recibir dinero (se muestra en verde).
  bool get shouldReceive => balance > 0;
}

/// Provider derivado: recalcula los balances cada vez que cambia la lista
/// de gastos. Criterio de cálculo (definido por el ejercicio):
/// balance = (monto total pagado por la persona) - (promedio del grupo).
/// El promedio se calcula siempre sobre las 4 personas fijas, hayan pagado
/// o no algún gasto, ya que el balance representa "cuánto le corresponde
/// pagar a cada uno" del total del grupo.
final balancesProvider = Provider<List<PersonBalance>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
  final average = total / Person.values.length;

  return Person.values.map((person) {
    final paid = expenses
        .where((e) => e.paidBy == person)
        .fold<double>(0, (sum, e) => sum + e.amount);
    return PersonBalance(
      person: person,
      totalPaid: paid,
      balance: paid - average,
    );
  }).toList();
});

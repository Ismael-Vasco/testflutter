import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/expense.dart';
import '../models/person.dart';
import '../state/expenses_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/balance_summary_card.dart';

const _logoAsset = 'assets/branding/splitExpenses.png';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<Expense> _items;

  @override
  void initState() {
    super.initState();
    // La lista se muestra con el gasto más reciente primero.
    _items = ref.read(expensesProvider).reversed.toList();
  }

  void _syncItems(List<Expense> providerExpenses) {
    final next = providerExpenses.reversed.toList();

    if (next.length > _items.length) {
      final previousIds = _items.map((e) => e.id).toSet();
      for (var i = 0; i < next.length; i++) {
        if (!previousIds.contains(next[i].id)) {
          _items.insert(i, next[i]);
          _listKey.currentState?.insertItem(
            i,
            duration: const Duration(milliseconds: 350),
          );
        }
      }
    } else if (next.length < _items.length) {
      final nextIds = next.map((e) => e.id).toSet();
      for (var i = _items.length - 1; i >= 0; i--) {
        if (!nextIds.contains(_items[i].id)) {
          final removed = _items.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _AnimatedExpenseTile(
              expense: removed,
              animation: animation,
              onTap: null,
              onDeleteConfirmed: null,
            ),
            duration: const Duration(milliseconds: 250),
          );
        }
      }
    } else {
      // Mismo tamaño: probablemente una edición in-place, solo refrescamos datos.
      setState(() => _items = next);
    }
  }

  Future<bool> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text('¿Seguro que quieres eliminar "${expense.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _deleteExpense(Expense expense) {
    ref.read(expensesProvider.notifier).removeExpense(expense.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${expense.name}" eliminado'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<Expense>>(expensesProvider, (previous, next) {
      _syncItems(next);
    });

    final isEmpty = ref.watch(expensesProvider).isEmpty;
    final balances = ref.watch(balancesProvider);
    final totalSpent = balances.fold<double>(0, (sum, b) => sum + b.totalPaid);
    final average = balances.isEmpty ? 0.0 : totalSpent / balances.length;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(_logoAsset, fit: BoxFit.contain),
          ),
        ),
        title: const Text('Split Expenses'),
      ),
      body: isEmpty
          ? const _EmptyExpensesView()
          : Column(
              children: [
                BalanceSummaryCard(
                  balances: balances,
                  totalSpent: totalSpent,
                  average: average,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gastos registrados',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    initialItemCount: _items.length,
                    itemBuilder: (context, index, animation) {
                      final expense = _items[index];
                      return _AnimatedExpenseTile(
                        expense: expense,
                        animation: animation,
                        onTap: () => context.push('/edit', extra: expense),
                        onDeleteConfirmed: () async {
                          final confirmed = await _confirmDelete(expense);
                          if (confirmed) {
                            _deleteExpense(expense);
                          }
                          return confirmed;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar gasto'),
      ),
    );
  }
}

class _EmptyExpensesView extends StatelessWidget {
  const _EmptyExpensesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_logoAsset, width: 140, height: 140, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              'Todavía no hay gastos registrados',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega el primer gasto del grupo para empezar a\n'
              'calcular los balances entre las 4 personas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila animada de un gasto: aparece con fade + slide al agregarse, y se
/// puede deslizar hacia la izquierda para eliminarla (con confirmación) o
/// tocarla para editarla.
class _AnimatedExpenseTile extends StatelessWidget {
  const _AnimatedExpenseTile({
    required this.expense,
    required this.animation,
    required this.onTap,
    required this.onDeleteConfirmed,
  });

  final Expense expense;
  final Animation<double> animation;
  final VoidCallback? onTap;
  final Future<bool> Function()? onDeleteConfirmed;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SizeTransition(
        sizeFactor: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: Dismissible(
            key: ValueKey(expense.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => onDeleteConfirmed?.call() ?? Future.value(false),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: Colors.red.shade600,
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: Column(
              children: [
                ListTile(
                  onTap: onTap,
                  leading: const CircleAvatar(child: Icon(Icons.receipt)),
                  title: Text(expense.name),
                  subtitle: Text('Pagó ${expense.paidBy.displayName}'),
                  trailing: Text(
                    formatCurrency(expense.amount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

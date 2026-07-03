import 'package:flutter/material.dart';

import '../models/person.dart';
import '../state/expenses_provider.dart';
import '../utils/currency_formatter.dart';

/// Tarjeta con el resumen del grupo y una barra comparativa por persona,
/// para tener de un vistazo quién debe más y quién debe recibir más.
class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    super.key,
    required this.balances,
    required this.totalSpent,
    required this.average,
  });

  final List<PersonBalance> balances;
  final double totalSpent;
  final double average;

  @override
  Widget build(BuildContext context) {
    final maxAbsBalance = balances.fold<double>(
      0,
      (max, b) => b.balance.abs() > max ? b.balance.abs() : max,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'Gasto total',
                    value: formatCurrency(totalSpent),
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Promedio por persona',
                    value: formatCurrency(average),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final balance in balances)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _BalanceBarRow(
                  balance: balance,
                  maxAbsBalance: maxAbsBalance,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _BalanceBarRow extends StatelessWidget {
  const _BalanceBarRow({required this.balance, required this.maxAbsBalance});

  final PersonBalance balance;
  final double maxAbsBalance;

  @override
  Widget build(BuildContext context) {
    final color = balance.shouldReceive ? Colors.green.shade600 : Colors.red.shade600;
    final fraction = maxAbsBalance == 0 ? 0.0 : (balance.balance.abs() / maxAbsBalance).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            balance.person.displayName,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Theme.of(context).colorScheme.surface,
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  widthFactor: fraction,
                  child: Container(height: 10, color: color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            formatCurrency(balance.balance),
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/expense.dart';
import '../models/person.dart';
import '../state/expenses_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.expenseToEdit});

  /// Si viene distinto de null, la pantalla actúa en modo edición sobre
  /// este gasto en lugar de crear uno nuevo.
  final Expense? expenseToEdit;

  bool get isEditing => expenseToEdit != null;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late Person _selectedPayer;

  @override
  void initState() {
    super.initState();
    final editing = widget.expenseToEdit;
    _nameController = TextEditingController(text: editing?.name ?? '');
    _amountController = TextEditingController(
      text: editing != null ? editing.amount.toStringAsFixed(2) : '',
    );
    _selectedPayer = editing?.paidBy ?? Person.values.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un nombre para el gasto';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un monto';
    }
    final normalized = value.trim().replaceAll(',', '.');
    final amount = double.tryParse(normalized);
    if (amount == null) {
      return 'Ingresa un número válido';
    }
    if (amount <= 0) {
      return 'El monto debe ser mayor que cero';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final amount = double.parse(_amountController.text.trim().replaceAll(',', '.'));
    final name = _nameController.text.trim();
    final notifier = ref.read(expensesProvider.notifier);

    if (widget.isEditing) {
      notifier.updateExpense(
        widget.expenseToEdit!.id,
        name: name,
        amount: amount,
        paidBy: _selectedPayer,
      );
    } else {
      notifier.addExpense(name: name, amount: amount, paidBy: _selectedPayer);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEditing ? 'Gasto actualizado' : 'Gasto agregado'),
        duration: const Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar gasto' : 'Agregar gasto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del gasto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.short_text),
              ),
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              validator: _validateAmount,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Person>(
              initialValue: _selectedPayer,
              decoration: const InputDecoration(
                labelText: '¿Quién pagó?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: [
                for (final person in Person.values)
                  DropdownMenuItem(
                    value: person,
                    child: Text(person.displayName),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPayer = value);
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: Icon(widget.isEditing ? Icons.check : Icons.add),
              label: Text(widget.isEditing ? 'Guardar cambios' : 'Guardar gasto'),
            ),
          ],
        ),
      ),
    );
  }
}

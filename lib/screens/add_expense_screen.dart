import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/person.dart';
import '../state/expenses_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  Person _selectedPayer = Person.values.first;

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
    ref.read(expensesProvider.notifier).addExpense(
          name: _nameController.text.trim(),
          amount: amount,
          paidBy: _selectedPayer,
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar gasto')),
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
              icon: const Icon(Icons.check),
              label: const Text('Guardar gasto'),
            ),
          ],
        ),
      ),
    );
  }
}

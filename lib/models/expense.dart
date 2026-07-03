import 'person.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final Person paidBy;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidBy,
    required this.createdAt,
  });
}

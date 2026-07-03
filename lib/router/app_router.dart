import 'package:go_router/go_router.dart';

import '../screens/add_expense_screen.dart';
import '../screens/expenses_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'expenses',
      builder: (context, state) => const ExpensesListScreen(),
    ),
    GoRoute(
      path: '/add',
      name: 'add-expense',
      builder: (context, state) => const AddExpenseScreen(),
    ),
  ],
);

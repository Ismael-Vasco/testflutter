import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/expense.dart';
import '../screens/add_expense_screen.dart';
import '../screens/expenses_list_screen.dart';

/// Transición compartida: fade + slide sutil desde abajo, para que la
/// navegación entre la lista y el formulario se sienta pulida.
CustomTransitionPage<T> _buildPageWithTransition<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'expenses',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state: state,
        child: const ExpensesListScreen(),
      ),
    ),
    GoRoute(
      path: '/add',
      name: 'add-expense',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state: state,
        child: const AddExpenseScreen(),
      ),
    ),
    GoRoute(
      path: '/edit',
      name: 'edit-expense',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state: state,
        child: AddExpenseScreen(expenseToEdit: state.extra as Expense?),
      ),
    ),
  ],
);

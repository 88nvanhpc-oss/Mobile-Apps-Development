import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/expense_provider.dart';
import 'screens/root_screen.dart';
import 'theme/app_theme.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ExpenseProvider>().themeMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const RootScreen(),
    );
  }
}

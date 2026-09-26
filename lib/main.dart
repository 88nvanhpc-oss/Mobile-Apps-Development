import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/transaction_repository.dart';
import 'providers/expense_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.initialize();
  final provider = ExpenseProvider(TransactionRepository(), notifications);
  await provider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const ExpenseTrackerApp(),
    ),
  );
}

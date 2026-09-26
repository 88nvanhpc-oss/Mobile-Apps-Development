import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/transaction_repository.dart';
import '../models/expense_transaction.dart';
import '../services/notification_service.dart';

enum TransactionSort { dateNewest, dateOldest, amountHigh, amountLow }

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._repository, this._notifications);

  final TransactionRepository _repository;
  final NotificationService _notifications;
  final _uuid = const Uuid();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  List<ExpenseTransaction> _transactions = [];
  bool _loading = true;
  bool _syncing = false;
  String? _error;
  TransactionType? _typeFilter;
  String? _categoryFilter;
  TransactionSort _sort = TransactionSort.dateNewest;
  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = false;
  int _reminderHour = 20;
  int _reminderMinute = 0;

  List<ExpenseTransaction> get transactions => _transactions;
  bool get loading => _loading;
  bool get syncing => _syncing;
  String? get error => _error;
  TransactionType? get typeFilter => _typeFilter;
  String? get categoryFilter => _categoryFilter;
  TransactionSort get sort => _sort;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  static const expenseCategories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Hóa đơn',
    'Giải trí',
    'Sức khỏe',
    'Giáo dục',
    'Khác',
  ];

  static const incomeCategories = [
    'Lương',
    'Thưởng',
    'Đầu tư',
    'Kinh doanh',
    'Quà tặng',
    'Khác',
  ];

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getBool('dark_mode') == true
        ? ThemeMode.dark
        : ThemeMode.light;
    _notificationsEnabled = prefs.getBool('notifications') ?? false;
    _reminderHour = prefs.getInt('reminder_hour') ?? 20;
    _reminderMinute = prefs.getInt('reminder_minute') ?? 0;

    if (_notificationsEnabled) {
      await _notifications.scheduleDaily(_reminderHour, _reminderMinute);
    }

    await reload();
    _connectivitySubscription = _repository.connectivityChanges.listen((result) {
      if (!result.contains(ConnectivityResult.none)) sync();
    });
  }

  List<ExpenseTransaction> get visibleTransactions {
    final list = _transactions.where((item) {
      if (_typeFilter != null && item.type != _typeFilter) return false;
      if (_categoryFilter != null && item.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case TransactionSort.dateNewest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSort.dateOldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSort.amountHigh:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSort.amountLow:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  double get currentMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((item) =>
            item.type == TransactionType.income &&
            item.date.year == now.year &&
            item.date.month == now.month)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get currentMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((item) =>
            item.type == TransactionType.expense &&
            item.date.year == now.year &&
            item.date.month == now.month)
        .fold(0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get expenseByCategory {
    final now = DateTime.now();
    final result = <String, double>{};
    for (final item in _transactions) {
      if (item.type != TransactionType.expense ||
          item.date.year != now.year ||
          item.date.month != now.month) {
        continue;
      }
      result[item.category] = (result[item.category] ?? 0) + item.amount;
    }
    return result;
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      _transactions = await _repository.getTransactions();
      _error = null;
    } catch (_) {
      _error = 'Không thể đọc dữ liệu cục bộ';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    final transaction = ExpenseTransaction(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note.trim(),
    );
    await _repository.add(transaction);
    await reload();
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await _repository.update(transaction);
    await reload();
  }

  Future<void> deleteTransaction(ExpenseTransaction transaction) async {
    await _repository.delete(transaction);
    await reload();
  }

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    notifyListeners();
    try {
      await _repository.syncPending();
      _transactions = await _repository.getTransactions();
      _error = null;
    } catch (_) {
      _error = 'Chưa thể đồng bộ. Dữ liệu vẫn được lưu trên máy.';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  void setTypeFilter(TransactionType? value) {
    _typeFilter = value;
    if (_categoryFilter != null && !availableCategories.contains(_categoryFilter)) {
      _categoryFilter = null;
    }
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setSort(TransactionSort value) {
    _sort = value;
    notifyListeners();
  }

  List<String> get availableCategories {
    if (_typeFilter == TransactionType.income) return incomeCategories;
    if (_typeFilter == TransactionType.expense) return expenseCategories;
    return {...expenseCategories, ...incomeCategories}.toList();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);
    if (enabled) {
      await _notifications.scheduleDaily(_reminderHour, _reminderMinute);
    } else {
      await _notifications.cancelDaily();
    }
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    if (_notificationsEnabled) {
      await _notifications.scheduleDaily(time.hour, time.minute);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

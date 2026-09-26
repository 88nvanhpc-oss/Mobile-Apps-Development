import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense_transaction.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            remote_id INTEGER,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT NOT NULL,
            sync_state INTEGER NOT NULL DEFAULT 1
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<ExpenseTransaction>> getTransactions({bool includeDeleted = false}) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: includeDeleted ? null : 'sync_state != ?',
      whereArgs: includeDeleted ? null : [SyncState.delete.index],
      orderBy: 'date DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  Future<List<ExpenseTransaction>> getPending() async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'sync_state != ?',
      whereArgs: [SyncState.synced.index],
      orderBy: 'date ASC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  Future<void> upsert(ExpenseTransaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> hardDelete(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}

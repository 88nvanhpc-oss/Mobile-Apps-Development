import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/expense_transaction.dart';
import 'api_client.dart';
import 'local_database.dart';

class TransactionRepository {
  TransactionRepository({
    LocalDatabase? localDatabase,
    ApiClient? apiClient,
    Connectivity? connectivity,
  })  : _local = localDatabase ?? LocalDatabase.instance,
        _api = apiClient ?? ApiClient(),
        _connectivity = connectivity ?? Connectivity();

  final LocalDatabase _local;
  final ApiClient _api;
  final Connectivity _connectivity;

  Stream<List<ConnectivityResult>> get connectivityChanges =>
      _connectivity.onConnectivityChanged;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<List<ExpenseTransaction>> getTransactions() {
    return _local.getTransactions();
  }

  Future<void> add(ExpenseTransaction transaction) async {
    final pending = transaction.copyWith(syncState: SyncState.create);
    await _local.upsert(pending);
    if (await isOnline) await _syncOne(pending);
  }

  Future<void> update(ExpenseTransaction transaction) async {
    final state = transaction.remoteId == null ? SyncState.create : SyncState.update;
    final pending = transaction.copyWith(syncState: state);
    await _local.upsert(pending);
    if (await isOnline) await _syncOne(pending);
  }

  Future<void> delete(ExpenseTransaction transaction) async {
    if (transaction.remoteId == null) {
      await _local.hardDelete(transaction.id);
      return;
    }
    final pending = transaction.copyWith(syncState: SyncState.delete);
    await _local.upsert(pending);
    if (await isOnline) await _syncOne(pending);
  }

  Future<void> syncPending() async {
    if (!await isOnline) return;
    await _api.readTransactions();
    final pending = await _local.getPending();
    for (final transaction in pending) {
      try {
        await _syncOne(transaction);
      } catch (_) {}
    }
  }

  Future<void> _syncOne(ExpenseTransaction transaction) async {
    if (transaction.syncState == SyncState.create) {
      final remoteId = await _api.createTransaction(transaction);
      await _local.upsert(
        transaction.copyWith(
          remoteId: remoteId,
          syncState: SyncState.synced,
        ),
      );
      return;
    }

    if (transaction.syncState == SyncState.update) {
      await _api.updateTransaction(transaction);
      await _local.upsert(transaction.copyWith(syncState: SyncState.synced));
      return;
    }

    if (transaction.syncState == SyncState.delete) {
      final remoteId = transaction.remoteId;
      if (remoteId != null) await _api.deleteTransaction(remoteId);
      await _local.hardDelete(transaction.id);
    }
  }
}

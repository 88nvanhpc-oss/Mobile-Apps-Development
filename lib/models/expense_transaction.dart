enum TransactionType { income, expense }

enum SyncState { synced, create, update, delete }

class ExpenseTransaction {
  final String id;
  final int? remoteId;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String note;
  final SyncState syncState;

  const ExpenseTransaction({
    required this.id,
    this.remoteId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
    this.syncState = SyncState.create,
  });

  ExpenseTransaction copyWith({
    String? id,
    int? remoteId,
    bool clearRemoteId = false,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
    SyncState? syncState,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      remoteId: clearRemoteId ? null : remoteId ?? this.remoteId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      syncState: syncState ?? this.syncState,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'sync_state': syncState.index,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as String,
      remoteId: map['remote_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.byName(map['type'] as String),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: (map['note'] as String?) ?? '',
      syncState: SyncState.values[(map['sync_state'] as int?) ?? 0],
    );
  }

  Map<String, dynamic> toApiData() {
    return {
      'localId': id,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}

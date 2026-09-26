import 'package:expense_tracker/models/expense_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transaction map round trip', () {
    final source = ExpenseTransaction(
      id: 'abc',
      amount: 120000,
      type: TransactionType.expense,
      category: 'Ăn uống',
      date: DateTime(2026, 9, 26),
      note: 'Bữa trưa',
    );

    final restored = ExpenseTransaction.fromMap(source.toMap());

    expect(restored.id, source.id);
    expect(restored.amount, source.amount);
    expect(restored.type, source.type);
    expect(restored.category, source.category);
    expect(restored.note, source.note);
  });
}

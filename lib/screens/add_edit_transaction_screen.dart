import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_transaction.dart';
import '../providers/expense_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  const AddEditTransactionScreen({super.key, this.transaction});

  final ExpenseTransaction? transaction;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  late String _category;
  late DateTime _date;
  bool _saving = false;

  bool get editing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _amountController = TextEditingController(
      text: transaction == null ? '' : transaction.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _type = transaction?.type ?? TransactionType.expense;
    _category = transaction?.category ?? ExpenseProvider.expenseCategories.first;
    _date = transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get categories => _type == TransactionType.expense
      ? ExpenseProvider.expenseCategories
      : ExpenseProvider.incomeCategories;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final provider = context.read<ExpenseProvider>();
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    try {
      if (editing) {
        await provider.updateTransaction(
          widget.transaction!.copyWith(
            amount: amount,
            type: _type,
            category: _category,
            date: _date,
            note: _noteController.text,
          ),
        );
      } else {
        await provider.addTransaction(
          amount: amount,
          type: _type,
          category: _category,
          date: _date,
          note: _noteController.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu giao dịch')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Chi'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Thu'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() {
                    _type = value.first;
                    _category = categories.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: '₫',
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return 'Nhập số tiền lớn hơn 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(editing ? 'Lưu thay đổi' : 'Thêm giao dịch'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

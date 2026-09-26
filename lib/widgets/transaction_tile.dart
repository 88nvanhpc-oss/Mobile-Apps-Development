import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;

  IconData get icon {
    switch (transaction.category) {
      case 'Ăn uống':
        return Icons.restaurant_rounded;
      case 'Mua sắm':
        return Icons.shopping_bag_rounded;
      case 'Di chuyển':
        return Icons.directions_car_rounded;
      case 'Hóa đơn':
        return Icons.receipt_long_rounded;
      case 'Giải trí':
        return Icons.movie_rounded;
      case 'Sức khỏe':
        return Icons.favorite_rounded;
      case 'Giáo dục':
        return Icons.school_rounded;
      case 'Lương':
        return Icons.account_balance_wallet_rounded;
      case 'Thưởng':
        return Icons.card_giftcard_rounded;
      case 'Đầu tư':
        return Icons.trending_up_rounded;
      case 'Kinh doanh':
        return Icons.storefront_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final date = DateFormat('dd/MM/yyyy').format(transaction.date);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          transaction.note.isEmpty ? date : '$date • ${transaction.note}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${money.format(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (transaction.syncState != SyncState.synced)
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(Icons.cloud_upload_outlined, size: 15),
              ),
          ],
        ),
      ),
    );
  }
}

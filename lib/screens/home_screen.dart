import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_transaction.dart';
import '../providers/expense_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openEditor(BuildContext context, [ExpenseTransaction? transaction]) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => AddEditTransactionScreen(
          transaction: transaction,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final items = provider.visibleTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiêu của tôi'),
        actions: [
          IconButton(
            onPressed: provider.syncing ? null : provider.sync,
            icon: provider.syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm'),
      ),
      body: SafeArea(
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: provider.sync,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SummaryCard(
                                  title: 'Thu tháng này',
                                  amount: provider.currentMonthIncome,
                                  icon: Icons.south_west_rounded,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                SummaryCard(
                                  title: 'Chi tháng này',
                                  amount: provider.currentMonthExpense,
                                  icon: Icons.north_east_rounded,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            if (provider.error != null) ...[
                              const SizedBox(height: 12),
                              MaterialBanner(
                                content: Text(provider.error!),
                                actions: [
                                  TextButton(
                                    onPressed: provider.sync,
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              'Giao dịch',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('Tất cả'),
                                    selected: provider.typeFilter == null,
                                    onSelected: (_) => provider.setTypeFilter(null),
                                  ),
                                  const SizedBox(width: 8),
                                  FilterChip(
                                    label: const Text('Chi'),
                                    selected: provider.typeFilter == TransactionType.expense,
                                    onSelected: (_) => provider.setTypeFilter(
                                      TransactionType.expense,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilterChip(
                                    label: const Text('Thu'),
                                    selected: provider.typeFilter == TransactionType.income,
                                    onSelected: (_) => provider.setTypeFilter(
                                      TransactionType.income,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String?>(
                                    value: provider.categoryFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Danh mục',
                                      isDense: true,
                                    ),
                                    items: [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Tất cả'),
                                      ),
                                      ...provider.availableCategories.map(
                                        (item) => DropdownMenuItem<String?>(
                                          value: item,
                                          child: Text(item),
                                        ),
                                      ),
                                    ],
                                    onChanged: provider.setCategoryFilter,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<TransactionSort>(
                                    value: provider.sort,
                                    decoration: const InputDecoration(
                                      labelText: 'Sắp xếp',
                                      isDense: true,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: TransactionSort.dateNewest,
                                        child: Text('Ngày mới nhất'),
                                      ),
                                      DropdownMenuItem(
                                        value: TransactionSort.dateOldest,
                                        child: Text('Ngày cũ nhất'),
                                      ),
                                      DropdownMenuItem(
                                        value: TransactionSort.amountHigh,
                                        child: Text('Tiền cao nhất'),
                                      ),
                                      DropdownMenuItem(
                                        value: TransactionSort.amountLow,
                                        child: Text('Tiền thấp nhất'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) provider.setSort(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    if (items.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Xóa giao dịch?'),
                                        content: const Text(
                                          'Giao dịch sẽ bị xóa khỏi danh sách.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Hủy'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              },
                              onDismissed: (_) => provider.deleteTransaction(item),
                              child: TransactionTile(
                                transaction: item,
                                onTap: () => _openEditor(context, item),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

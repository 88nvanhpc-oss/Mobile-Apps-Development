import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, ExpenseProvider provider) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: provider.reminderHour,
        minute: provider.reminderMinute,
      ),
    );
    if (result != null) await provider.setReminderTime(result);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(
        hour: provider.reminderHour,
        minute: provider.reminderMinute,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Chế độ tối'),
                    subtitle: const Text('Đổi giao diện sáng hoặc tối'),
                    value: provider.themeMode == ThemeMode.dark,
                    onChanged: provider.setDarkMode,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Nhắc ghi chi tiêu'),
                    subtitle: const Text('Gửi thông báo mỗi ngày'),
                    value: provider.notificationsEnabled,
                    onChanged: provider.setNotifications,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: provider.notificationsEnabled,
                    leading: const Icon(Icons.schedule_rounded),
                    title: const Text('Giờ nhắc'),
                    subtitle: Text(time),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: provider.notificationsEnabled
                        ? () => _pickTime(context, provider)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_sync_outlined),
                title: const Text('Đồng bộ dữ liệu'),
                subtitle: const Text('SQLite cục bộ và REST API'),
                trailing: provider.syncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: provider.syncing ? null : provider.sync,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

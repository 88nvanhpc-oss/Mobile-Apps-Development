# Expense Tracker

Ứng dụng quản lý thu chi cá nhân bằng Flutter.

## Chức năng

- Thêm, sửa, xóa giao dịch thu/chi
- Lọc theo loại và danh mục
- Sắp xếp theo ngày hoặc số tiền
- Lưu SQLite và dùng được khi offline
- Đồng bộ CRUD với JSONPlaceholder
- Biểu đồ chi tiêu theo danh mục
- Dark mode
- Nhắc nhở hằng ngày
- Tự đồng bộ lại khi có mạng

## Cài đặt

Windows:

```bat
setup.bat
flutter run
```

macOS/Linux:

```bash
chmod +x setup.sh
./setup.sh
flutter run
```

## Package

- provider
- sqflite
- dio
- connectivity_plus
- shared_preferences
- flutter_local_notifications
- timezone
- fl_chart
- intl
- uuid

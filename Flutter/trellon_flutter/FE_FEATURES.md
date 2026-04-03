# 📱 Mô Tả Chức Năng Hiện Tại của Frontend (FE) - Trello Clone

> Tài liệu này mô tả các tính năng và giao diện hiện có của ứng dụng Flutter **Trello Clone** (apptreolon).

---

## 1. Các Tính Năng Chính

Ứng dụng hiện được tổ chức thành 5 tab chính thông qua thanh điều hướng phía dưới (Bottom Navigation Bar) và một trang chi tiết.

### 1.1. Tab: Bảng (Board List)
Đây là trang chủ của ứng dụng sau khi đăng nhập.
- **Quản lý Workspace**: Hiển thị danh sách các "Không gian làm việc" (Workspace) của người dùng. Mỗi workspace có thể đóng/mở để xem danh sách bảng bên trong.
- **Danh sách Bảng (Boards)**: Hiển thị các bảng thuộc từng Workspace với màu sắc nhận diện riêng.
- **Tìm kiếm**: Thanh tìm kiếm phía trên giúp người dùng nhanh chóng tìm thấy bảng cần thiết.
- **Truy cập nhanh Hộp thư**: Một thẻ (card) tiện ích hiển thị số lượng thông báo mới trong hộp thư đến.
- **Tạo mới**: Nút (+) trên thanh tiêu đề hỗ trợ việc thêm bảng mới (hiện đang là UI placeholder).

### 1.2. Tab: Hộp thư đến (Inbox)
- **Thông báo**: Hiển thị danh sách các hoạt động liên quan đến người dùng như: được gắn thẻ vào card, được mời vào bảng, hoặc nhắc nhở ngày đến hạn.
- **Tương tác**: Cho phép người dùng theo dõi các thay đổi quan trọng mà không cần vào từng bảng.

### 1.3. Tab: Kế hoạch (Planner)
- **Quản lý thời gian**: Hiển thị các công việc (Cards) có gắn ngày đến hạn (Due Date) dưới dạng danh sách hoặc lịch trình.
- **Theo dõi tiến độ**: Giúp người dùng có cái nhìn tổng quan về khối lượng công việc theo tuần/tháng.

### 1.4. Tab: Hoạt động (Activity)
- **Lịch sử thay đổi**: Hiển thị dòng thời gian (Timeline) các hành động diễn ra trên tất cả các bảng mà người dùng tham gia.
- **Cập nhật realtime**: Giúp nắm bắt ai đã di chuyển thẻ, sửa nội dung hoặc thêm bình luận mới.

### 1.3. Tab: Tài khoản (Profile)
- **Thông tin cá nhân**: Hiển thị Avatar, tên người dùng, email và các thông tin cơ bản khác.
- **Cài đặt**: Các tùy chọn cấu hình ứng dụng (Dark mode, ngôn ngữ, thông báo).
- **Đăng xuất**: Chức năng thoát khỏi tài khoản hiện tại.

### 1.5. Trang Chi tiết Bảng (Board Detail)
Giao diện đặc trưng của Trello.
- **Danh sách (Lists)**: Hiển thị các cột như "Cần làm", "Đang làm", "Hoàn thành" dưới dạng cuộn ngang.
- **Thẻ (Cards)**: Các thẻ công việc nằm trong từng cột, hiển thị tiêu đề, mô tả ngắn và ngày đến hạn.
- **Chi tiết Thẻ**: Khi nhấn vào thẻ, một Bottom Sheet sẽ hiện lên hiển thị đầy đủ thông tin chi tiết, nhãn trạng thái (In Progress, Done,...) và các tùy chọn khác.
- **Thao tác nhanh**: Cho phép thêm thẻ mới vào cột hoặc thêm cột mới vào bảng.

---

## 2. Cấu Trúc Điều hướng & UI/UX

### 2.1. Main Shell (Vỏ bọc chính)
- Sử dụng `MainShell` để quản lý việc chuyển đổi giữa 5 tab chính.
- Áp dụng `IndexedStack` để duy trì trạng thái của từng trang khi người dùng chuyển tab (không load lại trang từ đầu).
- System Overlay được tùy chỉnh để thanh trạng thái (StatusBar) trong suốt, tạo cảm giác hiện đại.

### 2.2. Giao diện (Aesthetics)
- **Hệ thống màu sắc**: Sử dụng bảng màu tối (Dark Mode) sang trọng với các màu chủ đạo (`AppColors.primary`), màu nền (`AppColors.background`) và màu bề mặt (`AppColors.surface`).
- **Typography**: Sử dụng font chữ hiện đại, phân tầng rõ ràng giữa tiêu đề (Bold 28) và nội dung (Size 14-15).
- **Hiệu ứng**: Các hiệu ứng chuyển tab, nhấn nút (InkWell) và chuyển trang (Navigator) mượt mà.

---

## 3. Kiến Trúc Kỹ Thuật (Technical Overview)

- **Framework**: Flutter 3.x.
- **Kiến trúc**: Clean Architecture chia làm 3 lớp (Domain, Data, Presentation) giúp tách biệt business logic và UI.
- **Quản lý trạng thái**: BLoC/Cubit (đang trong quá trình tích hợp đầy đủ).
- **Dữ liệu**: Hiện tại đang sử dụng **Mock Data** (BoardMockData) để phục vụ việc phát triển và kiểm thử giao diện một cách độc lập trước khi kết nối với Backend C#.
- **Thư viện chính**:
  - `get_it`: Service Locator để quản lý Dependency Injection.
  - `flutter_bloc`: Quản lý luồng dữ liệu và trạng thái.

---

## 4. Trạng Thái Hoàn Thiện

| Tính năng | Giao diện (UI) | Logic/Data | Ghi chú |
|-----------|----------------|------------|---------|
| Board List| ✅ Hoàn thiện  | ✅ Mock Data| Đầy đủ Workspace & Search |
| Board Detail| ✅ Hoàn thiện | ✅ Mock Data| Hỗ trợ cuộn ngang & Bottom Sheet |
| Inbox     | ✅ Hoàn thiện  | ✅ Mock Data| Giao diện danh sách thông báo |
| Planner   | ✅ Hoàn thiện  | ✅ Mock Data| Giao diện lịch trình/công việc |
| Activity  | ✅ Hoàn thiện  | ✅ Mock Data| Giao diện dòng thời gian |
| Profile   | ✅ Hoàn thiện  | ✅ Mock Data| Giao diện thông tin & Cài đặt |
| Auth      | 🟡 Đang làm    | ❌ Chưa có | Mới có trang Login placeholder |

---
*Ngày cập nhật: 21/03/2026*

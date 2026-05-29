# Kiểm thử Khói (Smoke Test) - Thông báo trước khi Hợp nhất

Mục tiêu: Đây là Định nghĩa hoàn thành (Definition of Done) thủ công trước khi hợp nhất (merge) tính năng thông báo.

Quy tắc hợp nhất (merge):

- Nếu cả 6 kịch bản bên dưới đạt (pass): được phép hợp nhất (merge) tính năng thông báo.
- Nếu bất kỳ kịch bản nào không đạt (fail): mở báo cáo lỗi (bug ticket), đính kèm minh chứng (evidence), và không hợp nhất.
- Kiểm thử khói (Smoke test) cần chạy với backend thật, SignalR thật, và có ít nhất 2 phiên (session) đăng nhập song song.

## Điều kiện tiên quyết

- Backend đang chạy và ứng dụng Flutter kết nối đúng địa chỉ API base URL.
- User A và User B đều đăng nhập được.
- User A có quyền thao tác trên bảng (board)/thẻ (card) để giao thẻ (assign), đọc tất cả, xóa thông báo.
- User B có ít nhất 1 thiết bị hoặc trình duyệt đang mở màn hình Hoạt động/Thông báo (Activity/Notifications).
- Bật bảng điều khiển console/nhật ký log để chụp minh chứng (evidence) khi cần mở báo cáo lỗi (bug ticket).

## Các kịch bản bắt buộc

| # | Kịch bản | Cách kiểm thử | Kết quả mong đợi | Trạng thái | Minh chứng / Ghi chú |
|---|---|---|---|---|---|
| 1 | Nhận thông báo thời gian thực | User A giao thẻ (assign card) cho User B, sau đó xem thiết bị của User B | User B nhận được thông báo ngay lập tức, huy hiệu hiển thị/số lượng chưa đọc tăng | Không đạt | |
| 2 | Đồng bộ đọc tất cả (NotificationReadAll) | User A mở 2 tab trình duyệt/thiết bị, đánh dấu đọc tất cả thông báo ở tab 1 | Tab 2 tự động cập nhật số lượng chưa đọc (unread) = 0, danh sách không bị lệch trạng thái | Đạt | Kiểm thử thủ công |
| 3 | Nhấn vào thông báo về thẻ | Nhấn vào thông báo liên quan đến thẻ (card) | Mở đúng màn hình chi tiết thẻ | Đạt | Kiểm thử thủ công |
| 4 | Nhấn vào thông báo về bảng/không gian làm việc | Nhấn vào thông báo liên quan đến bảng (board) hoặc không gian làm việc (workspace) | Mở đúng bảng hoặc không gian làm việc tương ứng | Đạt | Kiểm thử thủ công |
| 5 | Thẻ bị xóa trước khi nhấn vào | Xóa thẻ, sau đó nhấn vào thông báo của thẻ đó | Hiển thị thanh thông báo lỗi (snackbar) rõ ràng, ứng dụng không bị sập (crash) | Không đạt | |
| 6 | Xóa thông báo thời gian thực | User A xóa thông báo, sau đó xem thiết bị của User B | Thông báo tự động biến mất khỏi danh sách của User B | Đạt | Kiểm thử thủ công |

## Quy tắc báo cáo lỗi (Bug Ticket)

Nếu không đạt (fail), báo cáo lỗi phải có:

- Số thứ tự kịch bản (Scenario number).
- Người dùng/thiết bị đã sử dụng để kiểm thử.
- Kết quả mong đợi đối chiếu với kết quả thực tế (Expected vs actual result).
- Ảnh chụp màn hình/video nếu là lỗi giao diện (UI).
- Nhật ký Backend (backend log) hoặc Flutter console log nếu có.
- Kết luận: Không hợp nhất (merge) cho đến khi kịch bản đạt (pass) trở lại.
- **Lưu ý thực tế:** Các đợt kiểm thử hiện tại được thực hiện hoàn toàn bằng tay (kiểm thử thủ công), không lưu trữ/chụp ảnh màn hình hay trích xuất log làm minh chứng đi kèm.

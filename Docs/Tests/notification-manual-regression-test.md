# Kiểm thử Hồi quy Thủ công - Thông báo

Mục tiêu: Checklist này dùng để kiểm thử thủ công (test tay) các phần thông báo đã hiện thực (implement), bao gồm tab, realtime, xóa/hoàn tác xóa, điều hướng, và reminder ngày hết hạn theo lịch trình. File này không thay thế `notification-smoke-test.md`; smoke test vẫn là Definition of Done (Định nghĩa hoàn thành) trước khi hợp nhất (merge).

Phạm vi kiểm thử:

- Thông báo được tạo từ server (server-generated notifications) từ các sự kiện nghiệp vụ (business events) thực tế.
- 3 tab trong phần Hoạt động (Activity): All (Tất cả), Sent to me (Gửi cho tôi - chỉ các thông báo trực tiếp chưa đọc), Read (Đã đọc).
- Số lượng tin chưa đọc (Unread count), đánh dấu đã đọc (mark read), đánh dấu đã đọc tất cả (mark all read), xóa/hoàn tác xóa (delete/undo delete).
- SignalR thời gian thực (realtime) cho các hành động: created (tạo), read (đọc), read-all (đọc tất cả), delete (xóa).
- Nhấn vào thông báo để chuyển hướng đến thẻ (card)/bảng (board)/không gian làm việc (workspace).
- Các trường hợp đối tượng mục tiêu đã cũ/hết hạn (stale target) không gây sập ứng dụng (crash).

Ngoài phạm vi:

- Thông báo đẩy ở cấp độ hệ điều hành (OS-level push notification).

## Điều kiện tiên quyết

- Backend thật đang chạy và ứng dụng Flutter trỏ đúng địa chỉ API base URL.
- Có ít nhất 2 người dùng: User A và User B.
- User A có quyền chủ sở hữu/quản trị viên (owner/admin) trên không gian làm việc/bảng (workspace/board) kiểm thử.
- User B đang mở ứng dụng trên ít nhất 1 thiết bị. Một số kịch bản (scenario) yêu cầu User B mở 2 phiên (session) song song.
- Màn hình Hoạt động/Thông báo (Activity/Notifications) của User B đang được mở khi kiểm thử thời gian thực (realtime).
- Nếu kịch bản bị lỗi (fail): chụp ảnh màn hình/quay video và ghi lại log backend/Flutter nếu có.

## Các kịch bản kiểm thử hồi quy

| # | Nhóm | Kịch bản | Cách kiểm thử | Kết quả mong đợi | Trạng thái | Minh chứng / Ghi chú |
|---|---|---|---|---|---|---|
| 1 | Sự kiện nghiệp vụ | Giao thẻ (Card assignment) tạo thông báo | User A giao thẻ (assign card) cho User B | User B nhận được thông báo mới loại assign, hiển thị ở All và Sent to me, số lượng chưa đọc (unread count) tăng | Đạt | Kiểm thử thủ công |
| 2 | Sự kiện nghiệp vụ | Hủy giao thẻ (Card unassignment) tạo thông báo | User A xóa User B khỏi thẻ | User B nhận được thông báo đã bị xóa khỏi thẻ, hiển thị ở All và Sent to me | Đạt | Kiểm thử thủ công |
| 3 | Sự kiện nghiệp vụ | Thêm thành viên vào bảng tạo thông báo | User A thêm User B vào bảng (board) | User B nhận được thông báo đã được thêm vào bảng, nhấn vào chuyển hướng đến bảng thành công | Đạt | Kiểm thử thủ công |
| 4 | Sự kiện nghiệp vụ | Thay đổi vai trò trên bảng tạo thông báo | User A thay đổi vai trò (role) của User B trong bảng | User B nhận được thông báo thay đổi vai trò, hiển thị ở tab Sent to me | Đạt | Kiểm thử thủ công |
| 5 | Sự kiện nghiệp vụ | Thêm thành viên/thay đổi vai trò trong không gian làm việc tạo thông báo | User A thêm User B vào không gian làm việc (workspace) hoặc thay đổi vai trò trong không gian làm việc | User B nhận được thông báo về không gian làm việc, nhấn vào chuyển hướng đến không gian làm việc thành công | Đạt | Kiểm thử thủ công |
| 6 | Nhắc tên (Mention) | Nhắc tên chỉ gửi cho thành viên hợp lệ | User A bình luận nhắc tên `@userB` trong thẻ mà User B là thành viên thẻ | User B nhận được thông báo nhắc tên; người dùng không phải thành viên thẻ sẽ không nhận | Không đạt | |
| 7 | Nhắc tên (Mention) | Nhắc tên trùng lặp không tạo thông báo trùng lặp | User A bình luận lặp lại cùng một nhắc tên User B nhiều lần | User B chỉ nhận duy nhất 1 thông báo cho bình luận đó | Không đạt | |
| 8 | Thay đổi hạn chót | Thiết lập/thay đổi hạn chót tạo thông báo | User A thiết lập hoặc thay đổi hạn chót (due date) của thẻ mà User B được giao | User B nhận được thông báo thay đổi hạn chót, hiển thị ở All và Sent to me | Đạt | Kiểm thử thủ công |
| 9 | Lọc tab | Tab All hiển thị đầy đủ thông báo | Mở Hoạt động (Activity) của User B ở tab All sau các sự kiện trên | Tab All hiển thị thông báo mới theo thứ tự mới nhất xếp trước | Đạt | Kiểm thử thủ công |
| 10 | Lọc tab | Tab Sent to me chỉ hiển thị thông báo trực tiếp chưa đọc | Chuyển sang tab Sent to me | Các thông báo giao thẻ, hủy giao, nhắc tên, bảng/không gian làm việc, thay đổi hạn chót chưa đọc hiển thị đúng; thông báo đã đọc chuyển sang tab Đã đọc và không còn nằm ở Sent to me | Đạt | Kiểm thử thủ công |
| 11 | Lọc tab | Tab Đã đọc chỉ hiển thị thông báo đã đọc | Chuyển sang tab Đã đọc | Chỉ các thông báo đã đọc hiển thị; mục chưa đọc không xuất hiện cho đến khi được đánh dấu đã đọc hoặc đọc tất cả | Đạt | Kiểm thử thủ công |
| 12 | Thời gian thực | NotificationCreated thời gian thực | User B đang mở màn hình Hoạt động, User A tạo sự kiện mới | User B nhận được thông báo ngay lập tức mà không cần vuốt để tải lại (pull-to-refresh), số lượng chưa đọc tăng | Không đạt | |
| 13 | Thời gian thực | NotificationRead thời gian thực | User B mở cùng tài khoản trên 2 phiên (session), đánh dấu đã đọc 1 thông báo ở phiên 1 | Phiên 2 tự động cập nhật thông báo đó thành đã đọc và số lượng chưa đọc giảm | Không đạt | |
| 14 | Thời gian thực | NotificationReadAll thời gian thực | User B mở 2 phiên, nhấp vào đánh dấu tất cả đã đọc ở phiên 1 | Phiên 2 số lượng chưa đọc về 0; tab Đã đọc hiển thị các mục đã đọc sau khi cập nhật/tải lại; tab All đánh dấu các mục đã tải thành đã đọc; tab Sent to me không còn hiển thị các mục vừa đọc | Không đạt | |
| 15 | Thời gian thực | NotificationDeleted thời gian thực | User B mở 2 phiên, xóa 1 thông báo ở phiên 1 | Phiên 2 tự động loại bỏ thông báo đó khỏi danh sách và số lượng chưa đọc cập nhật tương ứng nếu mục đó chưa đọc | Không đạt | |
| 16 | Trải nghiệm xóa | Xóa có thể hoàn tác (Undo) | User B vuốt/xóa thông báo, nhấn Undo trước khi hết thời gian chờ (timeout) | Thông báo được khôi phục trong danh sách, không bị xóa trên máy chủ (server) | Đạt | Kiểm thử thủ công |
| 17 | Trải nghiệm xóa | Xóa sau khi hết thời gian chờ | User B xóa thông báo và không nhấn Undo | Thông báo bị xóa thực sự; tải lại danh sách sẽ không thấy xuất hiện lại | Đạt | Kiểm thử thủ công |
| 18 | Điều hướng | Nhấn vào thông báo về thẻ | Nhấn vào thông báo có chứa `cardId` hợp lệ | Ứng dụng mở đúng chi tiết thẻ, đúng ngữ cảnh bảng/thẻ | Đạt | Kiểm thử thủ công |
| 19 | Điều hướng | Nhấn vào thông báo về bảng | Nhấn vào thông báo có chứa `boardId` hợp lệ | Ứng dụng mở đúng chi tiết bảng | Đạt | Kiểm thử thủ công |
| 20 | Điều hướng | Nhấn vào thông báo về không gian làm việc | Nhấn vào thông báo có chứa `workspaceId` hợp lệ | Ứng dụng mở đúng không gian làm việc/menu tương ứng | Đạt | Kiểm thử thủ công |
| 21 | Điều hướng | Đối tượng mục tiêu đã bị xóa không sập ứng dụng | Tạo thông báo về thẻ, xóa thẻ, sau đó nhấn vào thông báo cũ | Ứng dụng hiển thị thanh thông báo lỗi (snackbar) rõ ràng và không bị sập (crash) | Không đạt | |
| 22 | Trải nghiệm tab | Chuyển tab không tải trùng lặp rõ ràng | Bật Network/console, nhấn All/Sent to me/Đã đọc chậm một lần ở mỗi tab | Mỗi lần chuyển tab chỉ có đúng 1 yêu cầu (request) tải thông báo chính cho tab mới | Đạt | Kiểm thử thủ công |
| 23 | Tải lại trang | Vuốt để tải lại vẫn giữ đúng tab | Đang ở tab Sent to me hoặc Đã đọc, tiến hành vuốt để tải lại (pull-to-refresh) | Gửi đúng yêu cầu tải lại cho tab hiện tại, danh sách không bị đặt lại về tab All sai lệch | Đạt | Kiểm thử thủ công |
| 24 | Bảo mật | Người dùng không thể đọc/xóa thông báo của người dùng khác | Đăng nhập User A, thử đánh dấu đã đọc/xóa thông báo theo ID của User B bằng công cụ API | API không cho phép thực hiện thành công; thông báo của User B vẫn còn nguyên | Đạt | Kiểm thử thủ công |
| 25 | Khóa POST thủ công | Việc tự tạo thông báo thủ công bị khóa | Gọi API `POST /v1/api/notifications` bằng tài khoản người dùng đã đăng nhập | API trả về mã lỗi 403, không cho phép tạo thông báo tùy ý | Đạt | Kiểm thử thủ công |
| 26 | Reminder hạn chót | Nhắc trước 1 ngày | User A đặt hạn chót của thẻ được giao cho User B vào khoảng dưới 24 giờ và trên 1 giờ từ hiện tại, đợi scheduler tối đa 15 phút | User B nhận 1 thông báo reminder; tải lại nhiều lần hoặc đợi thêm một chu kỳ scheduler không tạo bản trùng cho cùng mốc | Chưa test | |
| 27 | Reminder hạn chót | Nhắc trước 1 giờ | User A đặt hạn chót của thẻ được giao cho User B vào khoảng dưới 1 giờ nhưng chưa quá hạn, đợi scheduler tối đa 15 phút | User B nhận 1 thông báo reminder mốc 1 giờ; không tạo bản trùng cho cùng mốc | Chưa test | |
| 28 | Reminder hạn chót | Nhắc khi đến hạn | User A đặt hạn chót bằng hiện tại hoặc đã quá hạn nhẹ cho thẻ được giao cho User B, đợi scheduler tối đa 15 phút | User B nhận 1 thông báo reminder mốc đến hạn; không tạo bản trùng cho cùng mốc | Chưa test | |
| 29 | Reminder hạn chót | Bỏ qua thẻ hoàn thành hoặc không có assignee | Đặt hạn chót phù hợp reminder cho thẻ đã hoàn thành hoặc thẻ không có người được giao | Không có notification reminder mới được gửi | Chưa test | |
| 30 | Reminder hạn chót | Đổi/xóa hạn chót reset lịch sử gửi | Sau khi một mốc reminder đã gửi, đổi hạn chót hoặc xóa rồi đặt lại hạn chót vào cùng cửa sổ reminder | Lịch sử gửi của thẻ được reset; mốc reminder có thể gửi lại đúng 1 lần theo hạn chót mới | Chưa test | |

## Quy tắc Đạt / Không đạt (Pass / Fail)

- Đạt (Pass) khi kịch bản cho kết quả đúng và không xảy ra sập ứng dụng (crash)/ngoại lệ (exception) bất thường.
- Không đạt (Fail) khi giao diện (UI) hiển thị sai, lệch số lượng tin chưa đọc, thời gian thực không đồng bộ, điều hướng sai mục tiêu, API cho phép thao tác trái phép, hoặc phải tải lại trang mới hiển thị sự kiện thời gian thực.
- Chưa test khi kịch bản mới được bổ sung vào checklist nhưng chưa có lần kiểm thử tay thực tế.
- Nếu không đạt: mở báo cáo lỗi (bug ticket) trước khi merge nếu lỗi đó ảnh hưởng tới luồng thông báo cốt lõi (core flow).

## Minh chứng được đề xuất

- Ghi lại ngày/giờ kiểm thử và môi trường kiểm thử.
- Ảnh chụp màn hình tab Hoạt động (Activity) trước/sau khi thực hiện với số lượng tin chưa đọc.
- Video ngắn minh họa hoạt động thời gian thực trên 2 phiên (session).
- Nhật ký hệ thống (log) của Backend khi tạo/xóa/đọc thông báo.
- Nhật ký console (log) của Flutter nếu xuất hiện ngoại lệ (exception) điều hướng/thời gian thực.
- **Lưu ý thực tế:** Các đợt kiểm thử hiện tại được thực hiện hoàn toàn bằng tay (kiểm thử thủ công), không lưu trữ/chụp ảnh màn hình hay trích xuất log làm minh chứng đi kèm.

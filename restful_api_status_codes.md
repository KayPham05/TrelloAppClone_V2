# Tài liệu Cấu trúc HTTP Status Codes trong RESTful API

Tài liệu này cung cấp danh sách và ý nghĩa chi tiết của các mã trạng thái HTTP (HTTP Status Codes) thường được sử dụng khi thiết kế và phát triển RESTful API. Việc sử dụng đúng mã trạng thái giúp hệ thống đồng nhất, chuẩn hóa dữ liệu và giúp Client (Frontend/Mobile) dễ dàng xử lý logic.

---

## Tổng quan các nhóm mã (Status Code Categories)

HTTP Status Codes được chia thành 5 nhóm chính dựa trên chữ số đầu tiên:

* **1xx: Informational (Thông tin)** – Yêu cầu đã được tiếp nhận, hệ thống đang tiếp tục xử lý.
* **2xx: Success (Thành công)** – Yêu cầu đã được tiếp nhận, hiểu và xử lý thành công.
* **3xx: Redirection (Điều hướng)** – Client cần thực hiện thêm thao tác để hoàn thành yêu cầu.
* **4xx: Client Error (Lỗi phía Client)** – Yêu cầu chứa cú pháp sai hoặc không thể thực hiện được do lỗi từ phía gửi.
* **5xx: Server Error (Lỗi phía Server)** – Server gặp lỗi trong quá trình xử lý một yêu cầu hợp lệ.

---

## Chi tiết các Status Codes thông dụng

### 2xx: Success (Thành công)

Mã trạng thái trả về khi hành động của Client được xử lý hoàn tất và thành công tại Server.

* **`200 OK` (Thành công chung)**
    * *Ý nghĩa:* Yêu cầu thành công. Dữ liệu trả về phụ thuộc vào HTTP Method (GET: trả về dữ liệu, PUT/PATCH: trả về trạng thái hoặc dữ liệu đã cập nhật).
    * *Ví dụ:* Lấy danh sách sản phẩm thành công, cập nhật thông tin cá nhân thành công.
* **`201 Created` (Đã tạo thành công)**
    * *Ý nghĩa:* Yêu cầu thành công và một tài nguyên (Resource) mới đã được tạo ra thành công trên hệ thống. Thường dùng cho phương thức `POST`.
    * *Ví dụ:* Đăng ký tài khoản mới thành công, tạo mới một bài viết thành công.
* **`202 Accepted` (Đã tiếp nhận)**
    * *Ý nghĩa:* Yêu cầu đã được tiếp nhận để xử lý, nhưng chưa xử lý xong (thường dùng cho các tác vụ bất đồng bộ - Async Jobs, hàng đợi - Queue).
    * *Ví dụ:* Client gửi yêu cầu xuất file báo cáo nặng, server nhận lệnh và xử lý ngầm dưới nền.
* **`204 No Content` (Thành công không trả về dữ liệu)**
    * *Ý nghĩa:* Yêu cầu xử lý thành công nhưng không cần trả về bất kỳ dữ liệu nào trong phần Body. Thường dùng cho phương thức `DELETE`.
    * *Ví dụ:* Xóa thành công một bài viết.

---

### 3xx: Redirection (Điều hướng)

Mã trạng thái thông báo Client cần thực hiện điều hướng đến một đường dẫn khác.

* **`301 Moved Permanently` (Di chuyển vĩnh viễn)**
    * *Ý nghĩa:* Tài nguyên đã được chuyển vĩnh viễn sang một URI mới. Các request sau này nên dùng URI mới này.
* **`302 Found / Moved Temporarily` (Di chuyển tạm thời)**
    * *Ý nghĩa:* Tài nguyên tạm thời nằm ở một URI khác, nhưng trong tương lai vẫn có thể dùng URI cũ.
* **`304 Not Modified` (Không thay đổi - Dùng cho Caching)**
    * *Ý nghĩa:* Tài nguyên không có thay đổi gì so với phiên bản Client đang lưu trong bộ nhớ đệm (Cache). Client có thể tái sử dụng dữ liệu cũ mà không cần Server tải lại.

---

### 4xx: Client Error (Lỗi phía Client)

Mã trạng thái khi lỗi xuất phát từ phía Client (gửi sai dữ liệu, sai định dạng, chưa đăng nhập, hoặc không có quyền...).

* **`400 Bad Request` (Yêu cầu không hợp lệ)**
    * *Ý nghĩa:* Server không thể hiểu hoặc xử lý request do sai cú pháp, thiếu tham số bắt buộc, dữ liệu gửi lên không đúng định dạng JSON.
    * *Ví dụ:* Gửi thiếu trường `username` khi đăng ký, hoặc định dạng email sai cú pháp.
* **`401 Unauthorized` (Chưa xác thực danh tính)**
    * *Ý nghĩa:* Client chưa thực hiện đăng nhập hoặc Token xác thực (JWT/API Key) gửi kèm đã hết hạn/không hợp lệ. Server không biết người gửi là ai.
    * *Ví dụ:* Truy cập trang Dashboard cá nhân nhưng chưa đăng nhập hoặc Token bị sai.
* **`403 Forbidden` (Bị cấm truy cập / Lỗi phân quyền)**
    * *Ý nghĩa:* Server hiểu Client là ai (đã đăng nhập), nhưng Client **không có đủ quyền hạn** để thực hiện hành động này, hoặc tài khoản đang rơi vào trạng thái bị hạn chế.
    * *Ví dụ:* * Tài khoản Member cố tình vào link của Admin để xóa người dùng.
        * Tài khoản bị khóa (Locked Account) hoặc chưa xác thực Email nên bị hệ thống chặn lại (như case của bạn).
* **`404 Not Found` (Không tìm thấy)**
    * *Ý nghĩa:* Tài nguyên hoặc đường dẫn API không tồn tại trên hệ thống.
    * *Ví dụ:* Vào đường dẫn `/api/v1/user-not-exist` hoặc tìm bài viết có ID `999999` không tồn tại trong database.
* **`405 Method Not Allowed` (Phương thức không được hỗ trợ)**
    * *Ý nghĩa:* Đường dẫn API có tồn tại, nhưng không hỗ trợ HTTP Method được gọi.
    * *Ví dụ:* Đường dẫn `/api/v1/login` chỉ nhận `POST`, nhưng Client cố tình gọi bằng `GET`.
* **`409 Conflict` (Xung đột dữ liệu)**
    * *Ý nghĩa:* Yêu cầu không thể hoàn thành vì xung đột trạng thái dữ liệu hiện tại trong hệ thống.
    * *Ví dụ:* Đăng ký tài khoản với Email đã tồn tại trong Database.
* **`422 Unprocessable Entity` (Dữ liệu không hợp lệ về mặt nghiệp vụ)**
    * *Ý nghĩa:* Cú pháp request gửi lên thì đúng (JSON chuẩn), nhưng dữ liệu bên trong không vượt qua được vòng kiểm tra logic (Validation Error).
    * *Ví dụ:* Gửi mật khẩu chỉ có 4 ký tự trong khi hệ thống yêu cầu tối thiểu 8 ký tự, hoặc số tiền rút lớn hơn số dư tài khoản.
* **`429 Too Many Requests` (Quá tải yêu cầu)**
    * *Ý nghĩa:* Client đã gửi quá nhiều request trong một khoảng thời gian ngắn vượt ngưỡng cho phép (Spam/DDOS). Thường dùng cho tính năng Rate Limiting.

---

### 5xx: Server Error (Lỗi phía Server)

Mã trạng thái khi lỗi phát sinh từ nội bộ hệ thống của Backend, dù Client đã gửi đúng request.

* **`500 Internal Server Error` (Lỗi nội bộ Server)**
    * *Ý nghĩa:* Lỗi chung của Server khi gặp sự cố không mong muốn (Crash code, lỗi logic code Backend nhảy vào khối `catch`, lỗi kết nối Database...).
* **`502 Bad Gateway` (Lỗi Gateway)**
    * *Ý nghĩa:* Máy chủ đóng vai trò làm Proxy hoặc Gateway nhận được phản hồi không hợp lệ từ máy chủ tuyến sau (Upstream Server). Thường gặp khi Nginx/Apache không kết nối được tới ứng dụng NodeJS/Java/PHP ở phía sau.
* **`503 Service Unavailable` (Dịch vụ không sẵn sàng)**
    * *Ý nghĩa:* Server tạm thời không thể xử lý request do đang bị quá tải hoặc đang trong quá trình bảo trì hệ thống.
* **`504 Gateway Timeout` (Hết thời gian phản hồi)**
    * *Ý nghĩa:* Máy chủ Gateway không nhận được phản hồi kịp thời từ máy chủ tuyến sau trong khoảng thời gian quy định (Timeout).

---

## Nguyên tắc vàng khi thiết kế RESTful API Status Codes

1.  **Nhất quán (Consistency):** Hãy áp dụng chung một bộ quy chuẩn cho toàn dự án. Đừng để API này dùng `400` báo lỗi validation, API khác lại dùng `422`.
2.  **Luôn đính kèm Error Message rõ ràng cho lỗi 4xx:** Đừng chỉ trả về code `400` trống rỗng. Hãy trả về thêm mã lỗi nội bộ (`errorCode`) và lời nhắn (`message`) để Frontend biết lỗi gì mà hiển thị cho người dùng.
3.  **Phân biệt rõ 401 và 403:** * `401` = Bạn là ai? Hãy đăng nhập đi (Who are you? Authenticate please).
    * `403` = Tôi biết bạn là ai rồi, nhưng bạn không được phép làm việc này (I know you, but you don't have permission).

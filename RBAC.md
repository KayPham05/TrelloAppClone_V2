# Hệ thống Phân quyền (RBAC) - TrellOn

Bảng dưới đây mô tả chi tiết các quyền hạn dựa trên vai trò (Role-Based Access Control) được triển khai trong hệ thống TrellOn cho cả Workspace và Board.

## 1. Phân quyền Không gian làm việc (Workspace)

| Tính năng | Workspace Owner | Workspace Admin | Workspace Member | Workspace Viewer |
| :--- | :---: | :---: | :---: | :---: |
| **Quản lý Workspace** (Sửa/Xóa) | ✅ | ✅ | ❌ | ❌ |
| **Quản lý thành viên** (Mời/Xóa) | ✅ | ✅ | ❌ | ❌ |
| **Thay đổi vai trò thành viên** | ✅ | ⚠️ (1) | ❌ | ❌ |
| **Tạo Bảng (Board) mới** | ✅ | ✅ | ✅ | ❌ |
| **Xem danh sách Board** | ✅ | ✅ | ✅ | ✅ |

*(1) Workspace Admin chỉ có thể thay đổi vai trò lên mức tối tối đa là Member (không thể bổ nhiệm Admin/Owner).*

---

## 2. Phân quyền Bảng (Board)

| Tính năng | Board Owner | Board Admin | Board Editor | Board Viewer |
| :--- | :---: | :---: | :---: | :---: |
| **Xóa Bảng** | ✅ | ❌ | ❌ | ❌ |
| **Quản lý Bảng** (Tên, Background) | ✅ | ✅ | ❌ | ❌ |
| **Quản lý thành viên Board** | ✅ | ✅ | ❌ | ❌ |
| **Thao tác Danh sách** (Tạo/Sửa) | ✅ | ✅ | ✅ | ❌ |
| **Xóa Danh sách** | ✅ | ✅ | ❌ | ❌ |
| **Tạo/Sửa Thẻ (Card)** | ✅ | ✅ | ✅ | ❌ |
| **Xóa Thẻ (Card)** | ✅ | ✅ | ❌ | ❌ |
| **Bình luận (Comment)** | ✅ | ✅ | ✅ | ❌ |
| **Di chuyển Card** | ✅ | ✅ | ✅ | ❌ |

---

## 3. Cơ chế Kế thừa & Đặc biệt (Inheritance)

Hệ thống triển khai cơ chế kế thừa quyền hạn từ Workspace xuống Board để đảm bảo tính quản trị:

*   **Workspace Admin/Owner**: Tự động có quyền **Edit/Manage** trên tất cả các Board thuộc Workspace đó, ngay cả khi không phải là thành viên trực tiếp của Board.
*   **Workspace Owner**: Là người duy nhất có quyền **Xóa** bất kỳ Board nào trong Workspace của mình.
*   **Thẻ cá nhân (Inbox)**: Đối với các thẻ không nằm trong Board (thẻ cá nhân), chỉ người sở hữu (Creator) mới có quyền chỉnh sửa/xóa.
*   **Độ ưu tiên vai trò (Role Priority)**:
    *   `Owner (3)` > `Admin (2)` > `Member/Editor (1)` > `Viewer (0)`.

---
*Tài liệu này được trích xuất từ logic thực tế trong `AuthorizationService.cs`.*

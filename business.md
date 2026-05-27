# Tài Liệu Phân Tích & Thiết Kế Hệ Thống Trello Clone

> **Ứng dụng:** TrellOn – Hệ thống quản lý công việc theo mô hình Kanban  
> **Nền tảng:** Flutter (Mobile) + ASP.NET Core 9 (Backend API) + SQL Server  
> **Phiên bản tài liệu:** 1.0  

---

# PHẦN 1: PHÂN TÍCH HỆ THỐNG

---

## 1.1 Sơ Đồ Phân Cấp Chức Năng (BFD)

```
TrellOn – Hệ thống quản lý công việc
│
├── 1. Quản lý Tài khoản & Xác thực
│   ├── 1.1 Đăng ký tài khoản
│   │   ├── 1.1.1 Nhập thông tin đăng ký (email, mật khẩu, tên)
│   │   └── 1.1.2 Xác minh email (gửi OTP / token)
│   ├── 1.2 Đăng nhập
│   │   ├── 1.2.1 Đăng nhập bằng email + mật khẩu (JWT)
│   │   └── 1.2.2 Đăng nhập qua OAuth (Google, v.v.)
│   ├── 1.3 Xác thực hai yếu tố (2FA)
│   │   ├── 1.3.1 Bật/tắt 2FA
│   │   ├── 1.3.2 Xác thực TOTP code
│   │   └── 1.3.3 Dùng backup code
│   ├── 1.4 Quản lý phiên đăng nhập (session / refresh token)
│   └── 1.5 Quên & đặt lại mật khẩu
│
├── 2. Quản lý Hồ sơ Người dùng
│   ├── 2.1 Xem & chỉnh sửa thông tin cá nhân (tên, bio)
│   ├── 2.2 Thay đổi avatar (tải lên Cloudinary)
│   └── 2.3 Xem lịch sử hoạt động cá nhân
│
├── 3. Quản lý Không gian Làm việc (Workspace)
│   ├── 3.1 Tạo workspace mới
│   ├── 3.2 Xem danh sách workspace của tôi
│   ├── 3.3 Chỉnh sửa thông tin workspace
│   ├── 3.4 Xóa workspace
│   └── 3.5 Quản lý thành viên workspace
│       ├── 3.5.1 Mời thành viên vào workspace
│       ├── 3.5.2 Thay đổi vai trò thành viên (Admin / Member)
│       └── 3.5.3 Xóa thành viên khỏi workspace
│
├── 4. Quản lý Bảng (Board)
│   ├── 4.1 Tạo bảng mới (cá nhân / trong workspace)
│   ├── 4.2 Xem danh sách bảng
│   │   ├── 4.2.1 Bảng gần đây (Recent Boards)
│   │   ├── 4.2.2 Bảng cá nhân
│   │   └── 4.2.3 Bảng trong workspace nhóm
│   ├── 4.3 Chỉnh sửa bảng
│   │   ├── 4.3.1 Đổi tên bảng
│   │   ├── 4.3.2 Thay đổi phông nền (ảnh / màu sắc từ Cloudinary)
│   │   └── 4.3.3 Thay đổi quyền hiển thị (Private / Public / Workspace)
│   ├── 4.4 Chuyển bảng sang workspace khác (Transfer)
│   ├── 4.5 Xóa / Lưu trữ bảng
│   └── 4.6 Quản lý thành viên bảng
│       ├── 4.6.1 Thêm thành viên vào bảng
│       ├── 4.6.2 Cập nhật vai trò thành viên (Owner / Admin / Member / Guest)
│       └── 4.6.3 Xóa thành viên khỏi bảng
│
├── 5. Quản lý Danh sách (List / Column)
│   ├── 5.1 Tạo danh sách mới trong bảng
│   ├── 5.2 Đổi tên danh sách
│   ├── 5.3 Xóa danh sách
│   └── 5.4 Sắp xếp lại thứ tự các danh sách (kéo-thả / reorder)
│
├── 6. Quản lý Thẻ Công việc (Card)
│   ├── 6.1 Tạo thẻ mới trong danh sách
│   ├── 6.2 Xem chi tiết thẻ
│   ├── 6.3 Chỉnh sửa thẻ
│   │   ├── 6.3.1 Đổi tiêu đề / mô tả
│   │   ├── 6.3.2 Đặt ngày hết hạn (Due date)
│   │   ├── 6.3.3 Thay đổi trạng thái thẻ (To Do / In Progress / Completed)
│   │   └── 6.3.4 Đặt phông nền thẻ
│   ├── 6.4 Di chuyển thẻ
│   │   ├── 6.4.1 Kéo-thả giữa các danh sách trong cùng bảng
│   │   └── 6.4.2 Sắp xếp lại vị trí trong danh sách
│   ├── 6.5 Phân công người thực hiện (Card Member)
│   │   ├── 6.5.1 Thêm thành viên vào thẻ
│   │   └── 6.5.2 Xóa thành viên khỏi thẻ
│   ├── 6.6 Gắn nhãn màu (Label)
│   │   ├── 6.6.1 Thêm nhãn vào thẻ
│   │   └── 6.6.2 Gỡ nhãn khỏi thẻ
│   ├── 6.7 Danh sách việc cần làm (Todo Items / Checklist)
│   │   ├── 6.7.1 Thêm todo item
│   │   ├── 6.7.2 Đánh dấu hoàn thành
│   │   └── 6.7.3 Xóa todo item
│   ├── 6.8 Bình luận trên thẻ
│   │   ├── 6.8.1 Viết bình luận
│   │   ├── 6.8.2 Chỉnh sửa bình luận
│   │   └── 6.8.3 Xóa bình luận
│   ├── 6.9 Đính kèm tệp tin (File Attachment)
│   │   ├── 6.9.1 Tải tệp lên (Cloudinary)
│   │   └── 6.9.2 Xóa tệp đính kèm
│   └── 6.10 Xóa thẻ
│
├── 7. Hộp thư đến (Inbox / UserInboxCard)
│   ├── 7.1 Xem danh sách thẻ được phân công
│   └── 7.2 Điều hướng đến thẻ từ inbox
│
├── 8. Thông báo (Notification)
│   ├── 8.1 Nhận thông báo khi có thay đổi liên quan
│   ├── 8.2 Xem danh sách thông báo chưa đọc
│   └── 8.3 Đánh dấu thông báo đã đọc
│
└── 9. [Tương lai] Các tính năng mở rộng
    ├── 9.1 Lịch (Calendar view) – xem card theo due date
    ├── 9.2 Tích hợp chatbot / AI
    ├── 9.3 Báo cáo & thống kê tiến độ
    ├── 9.4 Tích hợp API bên thứ ba (Zapier, Slack…)
    └── 9.5 Thông báo nhắc việc (Reminder / Push Notification)
```

---

## 1.2 Bảng Phân Tích: Tiến Trình, Tác Nhân và Hồ Sơ

| STT | Tiến trình | Tác nhân chính | Tác nhân phụ | Hồ sơ đầu vào | Hồ sơ đầu ra |
|-----|-----------|---------------|--------------|---------------|--------------|
| 1 | Đăng ký / Xác minh email | Người dùng mới | Hệ thống email | Thông tin đăng ký | Tài khoản + email xác nhận |
| 2 | Đăng nhập (JWT) | Người dùng | Hệ thống JWT | Email + mật khẩu | Access token + Refresh token |
| 3 | Xác thực 2FA | Người dùng | Hệ thống TOTP | OTP code / backup code | Phiên đăng nhập hợp lệ |
| 4 | Tạo Workspace | Chủ sở hữu | — | Tên & mô tả workspace | Workspace mới |
| 5 | Mời thành viên Workspace | Chủ sở hữu / Admin | Người được mời | UserUId + Role | WorkspaceMember record |
| 6 | Tạo Board | Người dùng | — | Tên, workspace, background | Board mới |
| 7 | Chuyển Board sang Workspace | Owner của Board | — | BoardId + WorkspaceId đích | Board được cập nhật workspace |
| 8 | Tạo List | Admin / Member Board | — | Tên danh sách | List mới trong Board |
| 9 | Tạo Card | Thành viên Board | — | Tiêu đề + ListId | Card mới |
| 10 | Kéo-thả Card | Thành viên Board | — | CardId + ListId đích + vị trí | Card được cập nhật vị trí |
| 11 | Kéo-thả List | Admin Board | — | ListId + vị trí mới | Thứ tự lists được cập nhật |
| 12 | Phân công thành viên Card | Thành viên Board | Người được phân công | CardId + UserUId | CardMember record + Notification |
| 13 | Bình luận trên Card | Thành viên Board | — | CardId + Nội dung | Comment record |
| 14 | Đính kèm tệp | Thành viên Board | Cloudinary | CardId + File | FileUrl record |
| 15 | Hoàn thành Todo Item | Thành viên Board | — | TodoItemId + trạng thái | TodoItem cập nhật |
| 16 | Xem Bảng Gần Đây | Người dùng | — | UserUId | Danh sách 4 Board gần nhất |
| 17 | Nhận & đọc Notification | Người dùng | — | UserUId | Danh sách thông báo |
| 18 | Tải lên / thay đổi Avatar | Người dùng | Cloudinary | File ảnh | AvatarUrl |
| 19 | Xóa Board / List / Card | Owner / Admin | — | Entity ID | Xóa khỏi DB |
| 20 | Ghi nhật ký hoạt động | Hệ thống | — | Hành động + Actor | Activity record |

---

## 1.3 Biểu Đồ Luồng Dữ Liệu (DFD)

### Mức 0 – Ngữ cảnh (Context Diagram)

```mermaid
graph LR
    U(( Người dùng))
    A(( Admin Workspace<br>/Board))
    E(( Email Server))
    C(( Cloudinary CDN))

    U -- "Đăng nhập/Đăng ký\nQuản lý thẻ/bảng\nBình luận/Phân công" --> SYS[ TrellOn System]
    A -- "Quản lý workspace\nPhân quyền thành viên\nChuyển board" --> SYS
    SYS -- "JWT Token\nThông báo\nDữ liệu bảng/thẻ" --> U
    SYS -- "Gửi OTP/Xác minh\nEmail thông báo" --> E
    E -- "Kết quả xác minh" --> SYS
    SYS -- "Upload file/ảnh" --> C
    C -- "URL media" --> SYS
```

---

### Mức 1 – Đỉnh (Level 0 DFD)

```mermaid
graph TB
    U((Người dùng))
    A((Admin))

    P1[1.0\nXác thực &\nTài khoản]
    P2[2.0\nQuản lý\nWorkspace]
    P3[3.0\nQuản lý\nBoard]
    P4[4.0\nQuản lý\nList & Card]
    P5[5.0\nThông báo &\nHoạt động]

    DS1[(D1: Users)]
    DS2[(D2: Workspaces\n& Members)]
    DS3[(D3: Boards\n& BoardMembers)]
    DS4[(D4: Lists\n& Cards)]
    DS5[(D5: Notifications\n& Activities)]

    U -- "Thông tin đăng nhập" --> P1
    P1 -- "Lưu/truy vấn user" --> DS1
    P1 -- "Token hợp lệ" --> U

    A --> P2
    P2 -- "CRUD workspace/members" --> DS2
    P2 -- "Danh sách workspace" --> U

    U --> P3
    A --> P3
    P3 -- "CRUD board/members" --> DS3
    P3 -- "Đọc workspace" --> DS2
    P3 -- "Danh sách board" --> U

    U --> P4
    P4 -- "CRUD list/card/comment/todo" --> DS4
    P4 -- "Đọc board" --> DS3
    P4 -- "Kết quả" --> U

    P4 -- "Ghi hoạt động" --> DS5
    P3 -- "Ghi hoạt động" --> DS5
    P5 -- "Đọc/Ghi thông báo" --> DS5
    P5 -- "Push notification" --> U
```

---

### Mức 2 – Dưới Đỉnh: Tiến trình 1.0 – Quản lý Người dùng (User)

```mermaid
graph TB
    U((Người dùng))
    E((Email Server))
    C((Cloudinary))

    P11[1.1\nĐăng ký\n& Xác minh Email]
    P12[1.2\nĐăng nhập\n& Cấp Token]
    P13[1.3\nXác thực\n2FA]
    P14[1.4\nQuản lý\nHồ sơ]
    P15[1.5\nĐặt lại\nMật khẩu]

    DS1[(D1: Users\n& Sessions)]
    DS2[(D2: UserOtp\n& BackupCodes)]

    U -- "Thông tin đăng ký" --> P11
    P11 -- "Lưu User (chưa xác minh)" --> DS1
    P11 -- "Gửi OTP xác minh" --> E
    E -- "Token xác minh" --> P11
    P11 -- "Kích hoạt tài khoản" --> DS1
    P11 -- "Đăng ký thành công" --> U

    U -- "Email + Password" --> P12
    P12 -- "Đọc User" --> DS1
    P12 -- "Tạo JWT + Lưu Session" --> DS1
    P12 -- "Access/Refresh Token" --> U

    U -- "OTP / Backup Code" --> P13
    P13 -- "Đọc Secret / BackupCode" --> DS2
    P13 -- "Xác nhận / Huỷ BackupCode" --> DS2
    P13 -- "Phiên hợp lệ" --> U

    U -- "Thông tin cập nhật / Avatar" --> P14
    P14 -- "Upload avatar" --> C
    C -- "AvatarUrl" --> P14
    P14 -- "UPDATE User" --> DS1
    P14 -- "Hồ sơ mới" --> U

    U -- "Email" --> P15
    P15 -- "Tạo OTP" --> DS2
    P15 -- "Gửi email đặt lại" --> E
    P15 -- "Cập nhật PasswordHash" --> DS1
    P15 -- "Xác nhận thành công" --> U
```

---

### Mức 2 – Dưới Đỉnh: Tiến trình 2.0 – Quản lý Workspace

```mermaid
graph TB
    OW((Admin\nWorkspace))
    U((Thành viên))

    P21[2.1\nTạo / Sửa / Xóa\nWorkspace]
    P22[2.2\nQuản lý\nThành viên WS]
    P23[2.3\nXem danh sách\nWorkspace]

    DS1[(D1: Users)]
    DS2[(D2: Workspaces)]
    DS3[(D3: WorkspaceMembers)]
    DS5[(D5: Notifications)]

    OW -- "Tên, mô tả" --> P21
    P21 -- "CRUD Workspace" --> DS2
    P21 -- "Kết quả" --> OW

    OW -- "UserUId + Role" --> P22
    P22 -- "Đọc User" --> DS1
    P22 -- "INSERT / UPDATE / DELETE WorkspaceMember" --> DS3
    P22 -- "INSERT Notification (mời/xoá)" --> DS5
    P22 -- "Kết quả" --> OW

    U -- "UserUId" --> P23
    P23 -- "SELECT Workspaces WHERE member" --> DS3
    P23 -- "Đọc thông tin WS" --> DS2
    P23 -- "Danh sách workspace" --> U
```

---

### Mức 2 – Dưới Đỉnh: Tiến trình 3.0 – Quản lý Board

```mermaid
graph TB
    OW((Owner\nBoard))
    MB((Thành viên\nBoard))
    C((Cloudinary))

    P31[3.1\nTạo / Sửa / Xóa\nBoard]
    P32[3.2\nXem danh sách\nBoard]
    P33[3.3\nThay đổi\nBackground]
    P34[3.4\nChuyển Board\nsang Workspace]
    P35[3.5\nQuản lý\nThành viên Board]

    DS2[(D2: Workspaces\n& WsMembers)]
    DS3[(D3: Boards)]
    DS4[(D4: BoardMembers)]
    DS6[(D6: UserRecentBoards)]
    DS5[(D5: Notifications)]

    OW -- "Tên, visibility, workspace" --> P31
    P31 -- "CRUD Board" --> DS3
    P31 -- "Kết quả" --> OW

    MB -- "UserUId" --> P32
    P32 -- "SELECT cá nhân + workspace" --> DS3
    P32 -- "Đọc RecentBoards" --> DS6
    P32 -- "Danh sách Board" --> MB

    OW -- "File / URL ảnh" --> P33
    P33 -- "Upload" --> C
    C -- "BackgroundUrl" --> P33
    P33 -- "UPDATE Board.BackgroundUrl" --> DS3
    P33 -- "URL mới" --> OW

    OW -- "BoardId + WorkspaceId đích" --> P34
    P34 -- "Kiểm tra quyền Owner" --> DS4
    P34 -- "UPDATE Board (WorkspaceUId / IsPersonal)" --> DS3
    P34 -- "INSERT WsMembers (thành viên chưa có)" --> DS2
    P34 -- "Kết quả" --> OW

    OW -- "UserUId + Role" --> P35
    P35 -- "INSERT / UPDATE / DELETE BoardMember" --> DS4
    P35 -- "INSERT Notification" --> DS5
    P35 -- "Kết quả" --> OW
```

---

### Mức 2 – Dưới Đỉnh: Tiến trình 5.0 – Thông báo & Hoạt động

```mermaid
graph TB
    U((Người dùng))
    SYS((Hệ thống\n[tiến trình khác]))

    P51[5.1\nTạo &\nGửi thông báo]
    P52[5.2\nXem & Đọc\nthông báo]
    P53[5.3\nGhi nhật ký\nhoạt động]

    DS5N[(D5a: Notifications)]
    DS5A[(D5b: Activities)]
    DS1[(D1: Users)]

    SYS -- "Sự kiện (phân công, mời, cập nhật)" --> P51
    P51 -- "Đọc thông tin recipient" --> DS1
    P51 -- "INSERT Notification" --> DS5N
    P51 -- "Thông báo realtime" --> U

    U -- "UserUId" --> P52
    P52 -- "SELECT Notifications WHERE recipientId" --> DS5N
    P52 -- "Danh sách thông báo" --> U
    U -- "Đánh dấu đã đọc" --> P52
    P52 -- "UPDATE Notification.Read = true" --> DS5N

    SYS -- "Hành động + Actor" --> P53
    P53 -- "INSERT Activity" --> DS5A
    U -- "UserUId" --> P53
    P53 -- "SELECT Activities" --> DS5A
    P53 -- "Lịch sử hoạt động" --> U
```

---

### Mức 2 – Dưới Đỉnh: Tiến trình 6.0 – Hộp thư đến (Inbox)

```mermaid
graph TB
    U((Người dùng))
    SYS(Hệ thống\n[CardMember])

    P61[6.1\nThêm Card\nvào Inbox]
    P62[6.2\nXem danh sách\nInbox]
    P63[6.3\nĐiều hướng\nđến Card]

    DS_IC[(D7: UserInboxCards)]
    DS_C[(D4b: Cards\n& Lists)]
    DS_B[(D3: Boards)]

    SYS -- "CardId + UserUId (được phân công)" --> P61
    P61 -- "INSERT UserInboxCard (nếu chưa tồn tại)" --> DS_IC
    P61 -- "Thêm vào inbox" --> U

    U -- "UserUId" --> P62
    P62 -- "SELECT InboxCards JOIN Cards JOIN Lists JOIN Boards" --> DS_IC
    P62 -- "Danh sách thẻ được phân công" --> U

    U -- "Chọn thẻ" --> P63
    P63 -- "Đọc CardId + BoardId" --> DS_C
    P63 -- "Điều hướng đến Board + Card" --> U
```

---

### Mức 2 – Dưới Đỉnh: Tiến trình 4.0 – Quản lý List & Card


```mermaid
graph TB
    U((Người dùng))

    P41[4.1\nQuản lý\nDanh sách]
    P42[4.2\nQuản lý\nThẻ]
    P43[4.3\nQuản lý nội dung\nThẻ chi tiết]
    P44[4.4\nDi chuyển\nThẻ/Danh sách]

    DS3[(D3: Boards)]
    DS4[(D4: Lists)]
    DS5[(D5: Cards)]
    DS6[(D6: Comments\nTodos\nLabels\nFiles)]

    U -- "Tạo/Sửa/Xóa list" --> P41
    P41 -- "CRUD List" --> DS4
    P41 -- "Đọc Board" --> DS3

    U -- "Tạo/Sửa/Xóa card" --> P42
    P42 -- "CRUD Card" --> DS5
    P42 -- "Đọc List" --> DS4

    U -- "Bình luận/Todo/Label/File" --> P43
    P43 -- "CRUD nội dung" --> DS6
    P43 -- "Đọc Card" --> DS5

    U -- "Kéo-thả" --> P44
    P44 -- "Cập nhật position/listId" --> DS5
    P44 -- "Cập nhật position list" --> DS4
```

---

## 1.4 Use Case Diagram

```mermaid
graph TB
    subgraph Actors
        A(( Người dùng\nmới))
        B(( Thành viên\nBoard))
        C(( Admin /\nOwner Board))
        D(( Admin\nWorkspace))
    end

    subgraph "Xác thực & Tài khoản"
        UC1[Đăng ký tài khoản]
        UC2[Đăng nhập]
        UC3[Xác thực 2FA]
        UC4[Đặt lại mật khẩu]
        UC5[Cập nhật hồ sơ]
    end

    subgraph "Workspace"
        UC6[Tạo workspace]
        UC7[Xem/Sửa workspace]
        UC8[Quản lý thành viên WS]
    end

    subgraph "Board"
        UC9[Tạo board]
        UC10[Xem danh sách board]
        UC11[Đổi tên / Background board]
        UC12[Thay đổi Visibility]
        UC13[Chuyển Board sang WS khác]
        UC14[Quản lý thành viên Board]
    end

    subgraph "List & Card"
        UC15[Tạo / Sắp xếp List]
        UC16[Tạo / Xem Card]
        UC17[Chỉnh sửa Card]
        UC18[Kéo-thả Card / List]
        UC19[Phân công thành viên Card]
        UC20[Gắn nhãn Label]
        UC21[Thêm Checklist / Todo]
        UC22[Bình luận]
        UC23[Đính kèm tệp]
    end

    subgraph "Thông báo"
        UC24[Nhận thông báo]
        UC25[Xem Inbox Card]
    end

    A --> UC1
    A --> UC2
    B --> UC2
    B --> UC3
    B --> UC4
    B --> UC5
    B --> UC10
    B --> UC15
    B --> UC16
    B --> UC17
    B --> UC18
    B --> UC19
    B --> UC20
    B --> UC21
    B --> UC22
    B --> UC23
    B --> UC24
    B --> UC25
    C --> UC9
    C --> UC11
    C --> UC12
    C --> UC13
    C --> UC14
    D --> UC6
    D --> UC7
    D --> UC8
```

### 1.4.1 Đặc tả chi tiết các Use Case

#### Nhóm 1: Xác thực và Tài khoản

```mermaid
graph TB
    subgraph "Xác thực & Tài khoản"
        UC1(UC1: Đăng ký)
        UC2(UC2: Đăng nhập)
        UC3(UC3: Xác thực 2FA)
        UC4(UC4: Đặt lại mật khẩu)
        UC5(UC5: Cập nhật hồ sơ)
        UC1 -.->|include| UC1a(Xác minh Email)
        UC2 -.->|extend| UC3
    end
    U((Người dùng))
    E((Email Server))
    C((Cloudinary))
    
    U --> UC1
    U --> UC2
    U --> UC4
    U --> UC5
    UC1a --- E
    UC4 --- E
    UC5 --- C
```

**UC1: Đăng ký tài khoản**
- **Tác nhân:** Người dùng mới.
- **Tiền điều kiện:** Người dùng chưa có tài khoản hoặc email chưa được đăng ký.
- **Hậu điều kiện:** Tài khoản được tạo và ở trạng thái "Chờ xác minh" hoặc "Đã kích hoạt".
- **Luồng sự kiện:**
  1. Người dùng chọn chức năng Đăng ký.
  2. Hệ thống hiển thị form nhập: Tên, Email, Mật khẩu.
  3. Người dùng nhập thông tin và nhấn "Đăng ký".
  4. Hệ thống kiểm tra hợp lệ: Email đúng định dạng, chưa tồn tại, mật khẩu đủ độ mạnh.
  5. Hệ thống gửi mã OTP xác nhận về email của người dùng.
  6. Người dùng nhập mã OTP vào ứng dụng.
  7. Hệ thống xác thực mã và kích hoạt tài khoản.
- **Ngoại lệ:** Email đã tồn tại -> Hệ thống yêu cầu đăng nhập hoặc dùng email khác.

**UC2: Đăng nhập**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Người dùng nhập Email và Mật khẩu.
  2. Hệ thống kiểm tra thông tin đăng nhập trong DB.
  3. Nếu chính xác, hệ thống kiểm tra cài đặt 2FA.
  4. Nếu không bật 2FA, hệ thống tạo mã JWT (AccessToken & RefreshToken) và trả về cho App.
  5. Nếu bật 2FA, chuyển sang UC3.
- **Ngoại lệ:** Sai mật khẩu quá 5 lần -> Khóa tài khoản tạm thời.

**UC3: Xác thực 2FA**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Sau khi nhập đúng email/mật khẩu, hệ thống yêu cầu mã xác thực.
  2. Người dùng mở app xác thực (Google Authenticator) hoặc kiểm tra email lấy mã.
  3. Người dùng nhập mã vào hệ thống.
  4. Hệ thống kiểm tra mã hợp lệ và cấp quyền truy cập.

**UC4: Đặt lại mật khẩu**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Người dùng chọn "Quên mật khẩu" tại màn hình đăng nhập.
  2. Nhập email đăng ký.
  3. Hệ thống kiểm tra sự tồn tại của email và gửi link/mã đặt lại mật khẩu.
  4. Người dùng sử dụng link/mã để nhập mật khẩu mới.
  5. Hệ thống cập nhật PasswordHash mới vào DB.

**UC5: Cập nhật hồ sơ**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Người dùng truy cập "Cài đặt tài khoản".
  2. Thay đổi thông tin: Tên hiển thị, Bio, hoặc tải lên ảnh đại diện mới.
  3. Hệ thống tải ảnh lên Cloudinary (nếu có) và lưu URL vào DB.
  4. Phản hồi cập nhật thành công.

#### Nhóm 2: Quản lý Không gian làm việc (Workspace)

```mermaid
graph TB
    subgraph "Workspace"
        UC6(UC6: Tạo Workspace)
        UC7(UC7: Xem/Sửa Workspace)
        UC8(UC8: Quản lý thành viên)
    end
    A((Admin WS))
    O((Owner WS))
    M((Thành viên))
    
    A --> UC6
    A --> UC7
    O --> UC8
    UC8 -- "Mời/Xóa" --- M
```

**UC6: Tạo Workspace**
- **Tác nhân:** Admin Workspace.
- **Luồng sự kiện:**
  1. Người dùng nhấn "Tạo Workspace mới".
  2. Nhập tên Workspace, loại hình và mô tả.
  3. Hệ thống tạo bản ghi Workspace và mặc định gán người tạo là "Owner".
  4. Workspace hiển thị trên danh sách bên trái.

**UC7: Xem/Sửa Workspace**
- **Tác nhân:** Thành viên (Xem), Admin (Sửa).
- **Luồng sự kiện:**
  1. Người dùng chọn một Workspace từ danh sách.
  2. Hệ thống hiển thị thông tin chung và danh sách các bảng bên trong.
  3. Admin có thể sửa tên hoặc xóa Workspace (chỉ dành cho Owner).

**UC8: Quản lý thành viên Workspace**
- **Tác nhân:** Admin Workspace.
- **Luồng sự kiện:**
  1. Admin mở tab "Members" trong Workspace.
  2. Nhấn "Invite" và nhập Email của thành viên muốn mời.
  3. Hệ thống kiểm tra User hiện có và gửi thông báo mời.
  4. Admin có thể thay đổi vai trò (Admin/Member) hoặc xóa thành viên khỏi WS.

#### Nhóm 3: Quản lý Bảng (Board)

```mermaid
graph TB
    subgraph "Board Management"
        UC9(UC9: Tạo Board)
        UC10(UC10: Danh sách Board)
        UC11(UC11: Chỉnh sửa Board)
        UC12(UC12: Visibility)
        UC13(UC13: Chuyển Workspace)
        UC14(UC14: Quản lý thành viên)
    end
    A((Admin Board))
    O((Owner Board))
    C((Cloudinary))
    
    A --> UC9
    A --> UC10
    A --> UC11
    A --> UC12
    A --> UC14
    O --> UC13
    UC9 --- C
    UC11 --- C
```

**UC9: Tạo Board**
- **Tác nhân:** Owner/Admin Board.
- **Luồng sự kiện:**
  1. Người dùng nhấn "Create Board".
  2. Nhập tên Board, chọn Background (Màu hoặc Ảnh từ thư viện Cloudinary).
  3. Chọn Workspace để chứa Board (hoặc chọn No Workspace cho Board cá nhân).
  4. Chọn quyền hiển thị (Private, Workspace, Public).
  5. Hệ thống khởi tạo Board và 3 List mặc định (To Do, Doing, Done).

**UC10: Xem danh sách Board**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Hệ thống tự động tải danh sách Board người dùng có quyền truy cập.
  2. Phân loại theo: Board gần đây, Starred Boards, và Board theo từng Workspace.

**UC11: Chỉnh sửa trang trí Board**
- **Tác nhân:** Admin Board.
- **Luồng sự kiện:**
  1. Truy cập cài đặt Board.
  2. Thay đổi tên Board hoặc chọn Background mới.
  3. Hệ thống cập nhật giao diện ngay lập tức cho tất cả người dùng đang xem.

**UC12: Thay đổi Visibility**
- **Tác nhân:** Admin Board.
- **Luồng sự kiện:**
  1. Admin thay đổi trạng thái từ Private sang Workspace hoặc Public.
  2. Hệ thống cập nhật quyền truy cập: Public cho phép mọi người xem, Workspace cho phép thành viên WS xem.

**UC13: Chuyển Board sang Workspace khác**
- **Tác nhân:** Owner Board.
- **Luồng sự kiện:**
  1. Chọn chức năng "Move Board".
  2. Chọn Workspace đích.
  3. Hệ thống cập nhật WorkspaceUId của Board và thông báo cho các thành viên liên quan.

**UC14: Quản lý thành viên Board**
- **Tác nhân:** Admin Board.
- **Luồng sự kiện:**
  1. Chọn "Members" trong Board.
  2. Tìm kiếm thành viên theo tên hoặc email.
  3. Thêm thành viên vào Board và gán vai trò.
  4. Hệ thống tạo thông báo mời tham gia Board.

#### Nhóm 4: Quản lý List & Card

```mermaid
graph TB
    subgraph "List & Card"
        UC15(UC15: Quản lý List)
        UC16(UC16: Tạo/Xem Card)
        UC17(UC17: Chỉnh sửa Card)
        UC18(UC18: Di chuyển Card)
        UC19(UC19: Phân công)
        UC20(UC20: Gắn nhãn)
        UC21(UC21: Checklist/Todo)
        UC22(UC22: Bình luận)
        UC23(UC23: Đính kèm)
    end
    M((Thành viên))
    C((Cloudinary))
    S((Server API))
    
    M --> UC15
    M --> UC16
    M --> UC17
    M --> UC18
    M --> UC19
    M --> UC20
    M --> UC21
    M --> UC22
    M --> UC23
    UC18 --- S
    UC23 --- C
```

**UC15: Tạo / Sắp xếp List**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Nhấn "Add List" ở cuối danh sách các cột.
  2. Nhập tên List và Enter.
  3. Người dùng có thể kéo thả List để thay đổi thứ tự ưu tiên các cột.

**UC16: Tạo / Xem Card**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Nhấn "Add Card" trong một List cụ thể.
  2. Nhập tiêu đề nhanh.
  3. Nhấn vào Card đã tạo để mở màn hình "Card Detail" hiển thị đầy đủ thông tin.

**UC17: Chỉnh sửa Card**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Tại màn hình Card Detail, người dùng sửa tiêu đề hoặc thêm mô tả (Markdown support).
  2. Chọn "Due Date" để đặt ngày hoàn thành công việc.
  3. Hệ thống tự động lưu các thay đổi nhỏ.

**UC18: Kéo-thả Card (Di chuyển)**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Người dùng kéo Card từ List A sang List B.
  2. Hoặc kéo Card lên/xuống trong cùng List A để đổi vị trí.
  3. Hệ thống lưu position mới và cập nhật ListId tương ứng trong DB.

**UC19: Phân công thành viên Card**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Trong Card Detail, chọn mục "Members".
  2. Tick chọn các thành viên trong Board tham gia thẻ này.
  3. Hệ thống tạo bản ghi `CardMember` và gửi thông báo cho người được phân công.

**UC20: Gắn nhãn Label**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Chọn "Labels".
  2. Chọn các nhãn màu có sẵn hoặc tạo nhãn mới với màu sắc tùy chỉnh.
  3. Nhãn hiển thị ngay trên mặt trước của Card.

**UC21: Thêm Checklist/Todo**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Chọn "Checklist", nhập tên checklist.
  2. Thêm các đầu việc (Todo items).
  3. Khi người dùng tick hoàn thành, hệ thống cập nhật thanh tiến độ (%) của Card.

**UC22: Bình luận (Comment)**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Nhập nội dung vào ô Comment phía dưới Card Detail.
  2. Hệ thống lưu bình luận kèm thời gian và thông tin người viết.
  3. Các thành viên khác theo dõi thẻ này sẽ nhận được thông báo.

**UC23: Đính kèm tệp**
- **Tác nhân:** Thành viên Board.
- **Luồng sự kiện:**
  1. Chọn "Attachments" -> "Computer".
  2. Chọn tệp tin.
  3. Hệ thống upload lên Cloudinary, lưu URL và hiển thị danh sách tệp đính kèm trong Card.

#### Nhóm 5: Thông báo & Hộp thư

```mermaid
graph TB
    subgraph "Notification & Inbox"
        UC24(UC24: Nhận thông báo)
        UC25(UC25: Xem Inbox Card)
    end
    U((Người dùng))
    S((Server API))
    
    S -- "Push" --> UC24
    UC24 --- U
    U --> UC25
```

**UC24: Nhận thông báo**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Khi có sự kiện: Được mời vào Board/WS, được phân công Card, hoặc có comment mới.
  2. Hệ thống tạo bản ghi Notification.
  3. Người dùng thấy chấm đỏ tại Icon thông báo và có thể xem danh sách.

**UC25: Xem Inbox Card**
- **Tác nhân:** Người dùng.
- **Luồng sự kiện:**
  1. Người dùng truy cập tab "Inbox".
  2. Hệ thống hiển thị tất cả các Card mà người dùng được phân công trên toàn bộ hệ thống.
  3. Người dùng nhấn vào Card để nhảy trực tiếp đến Board chứa Card đó.

---

## 1.5 Activity Diagram – Quy trình tạo và xử lý thẻ công việc

```mermaid
flowchart TD
    Start([Bắt đầu]) --> Login[Đăng nhập hệ thống]
    Login --> Auth{Xác thực\nthành công?}
    Auth -- Không --> Login
    Auth -- Có --> ViewBoard[Mở Board]
    ViewBoard --> SelectList[Chọn Danh sách]
    SelectList --> CreateCard[Nhấn Tạo thẻ mới]
    CreateCard --> EnterTitle[Nhập tiêu đề thẻ]
    EnterTitle --> SaveCard[Lưu thẻ]
    SaveCard --> CardDetail{Mở Chi tiết\nthẻ?}
    CardDetail -- Không --> ViewBoard
    CardDetail -- Có --> AddInfo[Thêm thông tin]
    AddInfo --> ParallelActions{Thao tác}
    ParallelActions --> SetDue[Đặt Due Date]
    ParallelActions --> AssignMember[Phân công\nthành viên]
    ParallelActions --> AddLabel[Gắn nhãn]
    ParallelActions --> AddTodo[Thêm Checklist]
    ParallelActions --> WriteComment[Viết bình luận]
    SetDue --> Notify[Hệ thống gửi\nthông báo]
    AssignMember --> Notify
    Notify --> UpdateStatus{Cập nhật\ntrạng thái?}
    AddLabel --> UpdateStatus
    AddTodo --> UpdateStatus
    WriteComment --> UpdateStatus
    UpdateStatus -- Drag & Drop --> MoveCard[Di chuyển thẻ\ngiữa các list]
    MoveCard --> LogActivity[Ghi nhật ký\nhoạt động]
    UpdateStatus -- Xong --> LogActivity
    LogActivity --> End([Kết thúc])
```

---

## 1.6 Sơ đồ Trạng thái (State Diagram)

### 1.6.1 Trạng thái Tài khoản Người dùng
Mô tả vòng đời của một tài khoản từ khi đăng ký đến khi hoạt động hoặc bị khóa.

```mermaid
stateDiagram-v2
    [*] --> Unverified: Đăng ký thành công
    Unverified --> Verified: Xác minh Email (OTP)
    Unverified --> [*]: Quá hạn xác minh
    Verified --> Active: Đăng nhập lần đầu
    Active --> Locked: Nhập sai mật khẩu > 5 lần
    Locked --> Active: Admin mở khóa hoặc Reset Pass
    Active --> Deactivated: Người dùng tự đóng tài khoản
    Deactivated --> [*]
```

### 1.6.2 Trạng thái Thẻ công việc (Card)
Mô tả sự luân chuyển của một thẻ công việc thông qua các trạng thái xử lý.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Created: Tạo thẻ mới
    Created --> ToDo: Thêm vào danh sách chờ
    ToDo --> InProgress: Bắt đầu thực hiện
    InProgress --> InReview: Gửi yêu cầu kiểm tra
    InReview --> Done: Admin phê duyệt
    InReview --> ToDo: Cần sửa đổi
    Done --> Archived: Lưu trữ (sau khi hoàn thành)
    Archived --> ToDo: Khôi phục
    Archived --> [*]: Xóa vĩnh viễn
```

---

## 1.7 Sơ đồ BPMN (Business Process Model and Notation)

### 1.7.1 Quy trình xử lý và hoàn thành thẻ công việc
Dưới đây là sơ đồ quy trình nghiệp vụ phối hợp giữa các vai trò trong một Board.

```mermaid
graph TB
    subgraph Member["Thành viên thực hiện (Member)"]
        direction TB
        M_Start([Bắt đầu]) --> M_Create[Nhận việc / Tạo Card]
        M_Create --> M_Work[Thực hiện công việc]
        M_Work --> M_Update[Cập nhật Checklist/Tệp đính kèm]
        M_Update --> M_Submit[Chuyển trạng thái sang Review]
    end

    subgraph Admin["Quản lý / Người duyệt (Admin/Owner)"]
        direction TB
        M_Submit --> A_Review{Kiểm tra kết quả}
        A_Review -- "Không đạt" --> A_Comment[Viết bình luận phản hồi]
        A_Comment --> M_Work
        A_Review -- "Đạt" --> A_Close[Chuyển thẻ sang Done]
    end

    subgraph System["Hệ thống (TrellOn)"]
        direction TB
        A_Close --> S_Noti[Gửi thông báo hoàn thành]
        S_Noti --> S_Log[Ghi nhật ký hoạt động Activity]
        S_Log --> S_End([Kết thúc quy trình])
    end
```

### 1.7.2 Quy trình mời và phân quyền thành viên
Quy trình nghiệp vụ khi một Admin mời người dùng mới vào hệ thống làm việc.

```mermaid
graph LR
    subgraph "Admin (Trình gửi)"
        Start_I([Bắt đầu]) --> Invite[Gửi lời mời qua Email]
    end

    subgraph "System (Xử lý)"
        Invite --> Check_U{User đã có<br/>tài khoản?}
        Check_U -- "Chưa" --> Send_E[Gửi link đăng ký + mời]
        Check_U -- "Rồi" --> Add_WS[Gán vào danh sách chờ]
        Send_E --> Reg[Người dùng đăng ký]
        Reg --> Add_WS
    end

    subgraph "Member (Trình nhận)"
        Add_WS --> Accept[Chấp nhận lời mời]
        Accept --> Access[Truy cập Workspace/Board]
        Access --> End_I([Kết thúc])
    end
```

---

# PHẦN 2: THIẾT KẾ HỆ THỐNG

---

## 2.1 Class Diagram (Biểu Đồ Lớp)

```mermaid
classDiagram
    class User {
        +String UserUId
        +String UserName
        +String Email
        +String PasswordHash
        +bool IsEmailVerified
        +String? AvatarUrl
        +String Bio
        +bool IsTwoFactorEnabled
        +String StatusAccount
        +DateTime CreatedAt
    }

    class Workspace {
        +String WorkspaceUId
        +String Name
        +String? Description
        +String Status
        +DateTime CreatedAt
        +String OwnerUId
    }

    class WorkspaceMembers {
        +String WorkspaceMemberUId
        +String WorkspaceUId
        +String UserUId
        +String Role
        +DateTime JoinedAt
    }

    class Board {
        +String BoardUId
        +String BoardName
        +bool IsPersonal
        +String Visibility
        +String Status
        +String? BackgroundUrl
        +String UserUId
        +String? WorkspaceUId
        +DateTime CreatedAt
    }

    class BoardMember {
        +String BoardMemberUId
        +String BoardUId
        +String UserUId
        +String BoardRole
        +DateTime JoinedAt
    }

    class List {
        +String ListUId
        +String ListName
        +int Position
        +String Status
        +String BoardUId
    }

    class Card {
        +String CardUId
        +String? Title
        +String? Description
        +DateTime? DueDate
        +int Position
        +String? Status
        +String? BackgroundUrl
        +String UserUId
        +String? ListUId
        +DateTime CreatedAt
    }

    class CardMember {
        +String CardMemberUId
        +String CardUId
        +String UserUId
        +DateTime AssignedAt
    }

    class CardLabel {
        +String CardLabelUId
        +String CardUId
        +String LabelName
        +String Color
    }

    class Comment {
        +String CommentUId
        +String Content
        +String UserUId
        +String CardUId
        +DateTime CreatedAt
    }

    class TodoItem {
        +String TodoItemUId
        +String Content
        +bool IsCompleted
        +String CardUId
    }

    class FileUrl {
        +String FileId
        +String Url
        +String FileName
        +String CardUId
    }

    class Notification {
        +String NotiId
        +String RecipientId
        +String? ActorId
        +NotificationType Type
        +String Title
        +String Message
        +bool Read
        +DateTime CreatedAt
    }

    class Activity {
        +String ActivityId
        +String UserUId
        +String Description
        +DateTime CreatedAt
    }

    class UserRecentBoard {
        +String UserRecentBoardUId
        +String UserUId
        +String BoardUId
        +DateTime LastVisitedAt
    }

    class UserInboxCard {
        +String InboxCardUId
        +String UserUId
        +String CardUId
    }

    User "1" --> "0..*" Workspace : owns
    User "1" --> "0..*" Board : owns
    User "1" --> "0..*" BoardMember : has memberships
    User "1" --> "0..*" WorkspaceMembers : has memberships
    User "1" --> "0..*" Comment : writes
    User "1" --> "0..*" Activity : performs
    User "1" --> "0..*" Notification : receives
    User "1" --> "0..*" UserRecentBoard : tracks
    User "1" --> "0..*" UserInboxCard : inbox

    Workspace "1" --> "0..*" Board : contains
    Workspace "1" --> "0..*" WorkspaceMembers : has

    Board "1" --> "0..*" List : has
    Board "1" --> "0..*" BoardMember : has

    List "1" --> "0..*" Card : contains

    Card "1" --> "0..*" CardMember : assigned to
    Card "1" --> "0..*" CardLabel : has labels
    Card "1" --> "0..*" Comment : has comments
    Card "1" --> "0..*" TodoItem : has todos
    Card "1" --> "0..*" FileUrl : has files
    Card "1" --> "0..*" UserInboxCard : in inbox
```

---

### 2.1.1 Bảng Mô Tả Thực Thể

| Thực thể | Thuộc tính chính | Khóa chính | Khóa ngoại | Mục đích |
|---------|----------------|-----------|-----------|---------|
| **User** | UserName, Email, PasswordHash, AvatarUrl, IsTwoFactorEnabled | UserUId | RoleId | Lưu thông tin tài khoản và xác thực |
| **Workspace** | Name, Description, Status | WorkspaceUId | OwnerUId (→User) | Không gian làm việc nhóm |
| **WorkspaceMembers** | Role, JoinedAt | WorkspaceMemberUId | WorkspaceUId, UserUId | Quản lý thành viên workspace với phân quyền |
| **Board** | BoardName, IsPersonal, Visibility, BackgroundUrl | BoardUId | UserUId (→User), WorkspaceUId (→Workspace) | Bảng kanban, cốt lõi của hệ thống |
| **BoardMember** | BoardRole, JoinedAt | BoardMemberUId | BoardUId, UserUId | Phân quyền thành viên trong board |
| **List** | ListName, Position, Status | ListUId | BoardUId (→Board) | Cột trong bảng kanban (To Do, In Progress...) |
| **Card** | Title, Description, DueDate, Position, Status | CardUId | ListUId (→List), UserUId | Đơn vị công việc cụ thể |
| **CardMember** | AssignedAt | CardMemberUId | CardUId, UserUId | Phân công người thực hiện thẻ |
| **CardLabel** | LabelName, Color | CardLabelUId | CardUId (→Card) | Nhãn màu phân loại thẻ |
| **Comment** | Content, CreatedAt | CommentUId | CardUId, UserUId | Thảo luận trên thẻ |
| **TodoItem** | Content, IsCompleted | TodoItemUId | CardUId (→Card) | Checklist công việc nhỏ trong thẻ |
| **FileUrl** | Url, FileName | FileId | CardUId (→Card) | Tệp đính kèm trên thẻ (lưu qua Cloudinary) |
| **Notification** | Type, Title, Message, Read | NotiId | RecipientId, ActorId (→User) | Thông báo sự kiện trong hệ thống |
| **Activity** | Description, CreatedAt | ActivityId | UserUId (→User) | Nhật ký hoạt động người dùng |
| **UserRecentBoard** | LastVisitedAt | UserRecentBoardUId | UserUId, BoardUId | Lịch sử truy cập board gần đây (tối đa 4) |
| **UserInboxCard** | — | InboxCardUId | UserUId, CardUId | Hộp thư: thẻ được phân công cho user |

---

## 2.2 Sequence Diagram

### 2.2.1 Đăng nhập và lấy danh sách Board

```mermaid
sequenceDiagram
    actor U as Người dùng
    participant App as Flutter App
    participant API as ASP.NET Core API
    participant DB as SQL Server
    participant Cache as Local Storage

    U->>App: Nhập email + mật khẩu
    App->>API: POST /v1/api/auth/login
    API->>DB: SELECT User WHERE Email = ?
    DB-->>API: User record
    API->>API: Verify PasswordHash (BCrypt)
    alt 2FA bật
        API-->>App: Yêu cầu OTP
        App->>U: Hiển thị màn hình OTP
        U->>App: Nhập OTP
        App->>API: POST /v1/api/auth/verify-2fa
    end
    API->>API: Tạo JWT AccessToken
    API-->>App: { accessToken, refreshToken }
    App->>Cache: Lưu token + userId
    App->>API: GET /v1/api/board?userUId=...
    API->>DB: SELECT Boards (personal + workspace)
    DB-->>API: Board list + recent boards
    API-->>App: JSON Board list
    App->>U: Hiển thị trang chủ
```

---

### 2.2.2 Kéo-thả thẻ giữa các danh sách (Optimistic Update)

```mermaid
sequenceDiagram
    actor U as Người dùng
    participant App as Flutter App
    participant Cubit as BoardDetailCubit
    participant API as ASP.NET Core API
    participant DB as SQL Server

    U->>App: Kéo Card từ List A sang List B (vị trí X)
    App->>Cubit: moveCard(card, sourceListId, targetListId, insertIndex)
    Cubit->>Cubit: Lưu _previousLists (rollback snapshot)
    Cubit->>Cubit: Optimistic update: cập nhật UI ngay lập tức
    Cubit-->>App: emit BoardDetailLoaded (lists mới)
    App->>U: UI ngay lập tức phản hồi

    Cubit->>API: PUT /v1/api/cards/{cardId}/move?newListId=...
    API->>DB: UPDATE Card SET ListUId = ?, Position = ?
    DB-->>API: Success

    alt Thành công
        API-->>Cubit: 200 OK
    else Thất bại
        API-->>Cubit: 4xx/5xx Error
        Cubit->>Cubit: Rollback về _previousLists
        Cubit-->>App: emit BoardDetailLoaded (lists cũ + transientError)
        App->>U: Hiển thị SnackBar lỗi
    end
```

---

### 2.2.3 Chuyển Board sang Workspace khác

```mermaid
sequenceDiagram
    actor OW as Owner Board
    participant App as Flutter App
    participant Sheet as TransferWorkspaceSheet
    participant Cubit as BoardDetailCubit
    participant API as ASP.NET Core API
    participant DB as SQL Server

    OW->>App: Mở Board Settings → Chọn "Không gian làm việc"
    App->>Sheet: Hiển thị TransferWorkspaceSheet
    Sheet->>API: GET /v1/api/workspace?userUId=...
    API->>DB: SELECT Workspaces WHERE UserUId = ?
    DB-->>API: Danh sách workspace
    API-->>Sheet: Workspace list (có dấu tích WS hiện tại)
    OW->>Sheet: Chọn Workspace đích / Không gian cá nhân
    Sheet->>Sheet: Hiển thị Dialog xác nhận
    OW->>Sheet: Xác nhận chuyển
    Sheet->>Cubit: transferBoardWorkspace(newWorkspaceId, name)
    Cubit->>API: POST /v1/api/boardMember/{boardId}/transfer-workspace?newWorkspaceUId=...
    API->>API: Kiểm tra requester là Owner
    alt Chuyển về Personal
        API->>DB: UPDATE Board SET WorkspaceUId = NULL, IsPersonal = true
    else Chuyển sang Workspace mới
        API->>DB: UPDATE Board SET WorkspaceUId = ?, IsPersonal = false
        API->>DB: INSERT WorkspaceMembers (các thành viên board chưa có)
    end
    DB-->>API: Success
    API-->>Cubit: 200 OK { message }
    Cubit->>Cubit: emit state mới với workspaceId mới
    Cubit-->>App: SnackBar " Đã chuyển bảng thành công"
```

---

### 2.2.4 Phân công thành viên thẻ và gửi thông báo

```mermaid
sequenceDiagram
    actor A as Thành viên Board
    participant App as Flutter App
    participant API as ASP.NET Core API
    participant DB as SQL Server

    A->>App: Mở Card → Tab Thành viên
    App->>API: GET /v1/api/boardMember/{boardId}/members
    API->>DB: SELECT BoardMembers JOIN Users
    DB-->>API: Danh sách thành viên board
    API-->>App: Member list

    A->>App: Chọn thêm thành viên vào card
    App->>API: POST /v1/api/cardMember/{cardId}/add?userUId=...
    API->>DB: INSERT CardMember
    API->>DB: INSERT UserInboxCard (nếu chưa có)
    API->>DB: INSERT Notification (type=CardAssigned, recipientId=userUId)
    DB-->>API: Success
    API-->>App: 200 OK
    App->>A: UI cập nhật danh sách thành viên card

    Note over DB,App: Thành viên được phân công nhận thông báo<br/>khi mở app lần tiếp theo
```

---

## 2.3 Activity Diagram (Mức Thiết Kế)

### 2.3.1 Thuật toán xử lý Đăng nhập + 2FA

```mermaid
flowchart TD
    S([Start]) --> Input[Nhận email + password]
    Input --> FindUser{Tìm User\ntrong DB?}
    FindUser -- Không tìm thấy --> ErrUser[Trả về 401\nUser không tồn tại]
    ErrUser --> End1([End])

    FindUser -- Tìm thấy --> CheckPwd{BCrypt.Verify\n(password, hash)?}
    CheckPwd -- Sai --> ErrPwd[Trả về 401\nSai mật khẩu]
    ErrPwd --> End2([End])

    CheckPwd -- Đúng --> CheckEmail{IsEmailVerified?}
    CheckEmail -- Không --> ErrEmail[Trả về 403\nEmail chưa xác minh]
    ErrEmail --> End3([End])

    CheckEmail -- Có --> Check2FA{IsTwoFactorEnabled?}
    Check2FA -- Không --> GenToken[Tạo JWT AccessToken\n+ RefreshToken]
    Check2FA -- Có --> Return2FA[Trả về 200\n+ flag require2FA]
    Return2FA --> Wait[Client gửi OTP code]
    Wait --> VerifyOTP{TOTP.Verify\n(secret, code)?}
    VerifyOTP -- Sai --> CheckBackup{Backup Code\nhợp lệ?}
    CheckBackup -- Không --> ErrOTP[Trả về 401\nSai OTP]
    ErrOTP --> End4([End])
    CheckBackup -- Có --> GenToken
    VerifyOTP -- Đúng --> GenToken

    GenToken --> SaveSession[Lưu UserSession\nvào DB]
    SaveSession --> LogActivity[Ghi Activity\n'User signed in']
    LogActivity --> Response[Trả về 200\n{ accessToken, refreshToken }]
    Response --> End5([End])
```

---

### 2.3.2 Thuật toán xử lý di chuyển thẻ (Move Card)

```mermaid
flowchart TD
    S([Start]) --> CheckAuth{User là thành viên\nBoard?}
    CheckAuth -- Không --> Err403[Trả về 403]
    Err403 --> End1([End])

    CheckAuth -- Có --> GetCard{Tìm Card\ntrong DB?}
    GetCard -- Không --> Err404[Trả về 404]
    Err404 --> End2([End])

    GetCard -- Có --> GetTargetList{Tìm List đích\ntrong cùng Board?}
    GetTargetList -- Không --> Err400[Trả về 400\nList không hợp lệ]
    Err400 --> End3([End])

    GetTargetList -- Có --> UpdateCard[UPDATE Card:\nListUId = target\nPosition = insertIndex]
    UpdateCard --> ShiftPositions[Cập nhật Position\ncác card còn lại trong\ncả 2 list]
    ShiftPositions --> SaveDB[SaveChangesAsync]
    SaveDB --> LogActivity[Ghi Activity]
    LogActivity --> Response[Trả về 200 OK]
    Response --> End4([End])
```

---

### 2.3.3 Thuật toán lưu Board gần đây (Recent Board)

```mermaid
flowchart TD
    S([Start: User mở Board]) --> LoadBoard[loadBoard được gọi]
    LoadBoard --> SaveRecent[saveRecentBoardUseCase\n(userUId, boardId)]

    SaveRecent --> CheckExist{UserRecentBoard\ntồn tại?}
    CheckExist -- Có --> UpdateTime[UPDATE LastVisitedAt = Now]
    CheckExist -- Không --> InsertNew[INSERT UserRecentBoard mới]

    UpdateTime --> CountAll[Đếm tổng record\ncủa userUId]
    InsertNew --> CountAll

    CountAll --> CheckLimit{Count > 4?}
    CheckLimit -- Không --> SaveDB[SaveChangesAsync]
    CheckLimit -- Có --> DeleteOld[Xóa các record cũ\n vượt quá 4 mục\norderd by LastVisitedAt DESC]
    DeleteOld --> SaveDB

    SaveDB --> End([End])
```

---

*Tài liệu được tạo tự động dựa trên phân tích mã nguồn thực tế của dự án TrellOn.*
*Cập nhật lần cuối: 2026-05-10*

<a id="readme-top"></a>

# 📋 Trellon - Trello App Clone 

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/KayPham05/TrelloAppClone_V2">
    <img src="https://raw.githubusercontent.com/KayPham05/TrelloAppClone_V2/main/.github/logo.png" alt="Logo" width="350 px" height="120 px" onerror="this.src='https://via.placeholder.com/350x120?text=Trellon+Logo'">
  </a>

  <h2 align="center">Trellon - Task Management System</h2>

  <p align="center">
    Trellon là một hệ thống quản lý công việc hoàn chỉnh, giúp tổ chức boards, lists, cards và tasks một cách hiệu quả và dễ dàng!
    <br />
    <a href="https://github.com/KayPham05/TrelloAppClone_V2"><strong>Khám phá tài liệu »</strong></a>
    <br />
    <br />
    <a href="https://github.com/KayPham05/TrelloAppClone_V2">Xem Demo</a>
    &middot;
    <a href="https://github.com/KayPham05/TrelloAppClone_V2/issues/new?labels=bug&template=bug-report---.md">Báo lỗi</a>
    &middot;
    <a href="https://github.com/KayPham05/TrelloAppClone_V2/issues/new?labels=enhancement&template=feature-request---.md">Yêu cầu tính năng</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Mục lục</summary>
  <ol>
    <li>
      <a href="#about-the-project">Về dự án</a>
      <ul>
        <li><a href="#built-with">Công nghệ sử dụng</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Bắt đầu</a>
      <ul>
        <li><a href="#prerequisites">Yêu cầu</a></li>
        <li><a href="#installation">Cài đặt</a></li>
      </ul>
    </li>
    <li><a href="#usage">Sử dụng</a></li>
    <li><a href="#contributing">Đóng góp</a></li>
    <li><a href="#license">Giấy phép</a></li>
    <li><a href="#contact">Liên hệ</a></li>
    <li><a href="#acknowledgments">Lời cảm ơn</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## 🎯 Về dự án

[![Product Name Screen Shot][product-screenshot]](https://github.com/KayPham05/TrelloAppClone_V2)

Trellon là một nền tảng quản lý công việc và dự án, sao chép lại các tính năng cốt lõi của Trello. Dự án bao gồm **Backend Web API** linh hoạt và ứng dụng **Mobile (Flutter)** mạnh mẽ, hỗ trợ quản lý theo mô hình **Workspace → Board → List → Card → TodoItem**.

Cấu trúc chính của hệ thống:
* **Backend:** ASP.NET Core 8 Web API chuẩn RESTful, xác thực JWT, phân quyền, và quản lý cộng tác.
* **Mobile App:** Phát triển bằng Flutter theo Clean Architecture, giao diện hiện đại và mượt mà.
* **Web App:** (Đang lên kế hoạch) Phát triển bằng React để đồng bộ trải nghiệm trên trình duyệt.

Các chức năng chính:
* **Xác thực:** Đăng ký, đăng nhập, Google OAuth, Email OTP (6 số), và 2FA.
* **Workspace:** Quản lý không gian làm việc chung, mời thành viên và phân quyền.
* **Board:** Quản lý bảng dự án (Công khai, Workspace, hoặc Cá nhân).
* **List & Card:** Tổ chức công việc theo cột và thẻ bài với khả năng kéo thả (trên App).
* **Todo & Checklist:** Quản lý các subtasks chi tiết bên trong mỗi Card.
* **Tương tác:** Bình luận (Comment), Gắn nhãn (Label), và Gán người thực hiện (Assignee).
* **Thông báo:** Hệ thống Activity Log và Notification thời gian thực cho người dùng.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- BUILT WITH -->
## 🧱 Công nghệ sử dụng

Dự án này được phát triển sử dụng các framework, thư viện và công nghệ sau:

**Backend (C# ASP.NET Core):**
* [![.NET][dotnet]][dotnet-url]
* [![C#][csharp]][csharp-url]
* [![ASP.NET Core][aspnet]][aspnet-url]
* [![SQL Server][sqlserver]][sqlserver-url]
* [![Entity Framework][ef]][ef-url]

**Mobile Frontend (Flutter):**
* [![Flutter][flutter]][flutter-url]
* **Clean Architecture:** Domain - Data - Presentation layers.
* **State Management:** flutter_bloc (Cubit).
* **Networking:** Dio + Interceptor (Auto refresh token).

**Web Frontend (Planned):**
* [![React][react]][react-url]
* [![TailwindCSS][tailwind]][tailwind-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## 🚀 Bắt đầu

Làm theo các bước sau để thiết lập dự án trên máy local.

### Yêu cầu

Đảm bảo bạn đã cài đặt các phần mềm sau:

* **Backend:** [.NET SDK 8.0](https://dotnet.microsoft.com/en-us/download/dotnet) & [SQL Server](https://www.microsoft.com/sql-server).
* **Mobile:** [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản > 3.11.0).
* **IDE:** Visual Studio 2022 (cho C#) và VS Code hoặc Android Studio (cho Flutter).

### Cài đặt

#### 1. Backend (ASP.NET Core API)
1. Di chuyển vào thư mục backend:
   ```sh
   cd "C#/TodoAppAPI"
   ```
2. Khôi phục packages:
   ```sh
   dotnet restore
   ```
3. Cấu hình connection string trong `appsettings.json` (thay đổi Server name cho phù hợp):
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=TrellonDB;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```
4. Chạy migrations để tạo database:
   ```sh
   dotnet ef database update
   ```
5. Chạy dự án:
   ```sh
   dotnet run
   ```

#### 2. Mobile App (Flutter)
1. Di chuyển vào thư mục app:
   ```sh
   cd "Flutter/trellon_flutter"
   ```
2. Cài đặt các thư viện Dart:
   ```sh
   flutter pub get
   ```
3. Cấu hình Base URL trong `lib/core/network/dio_client.dart` (trỏ về IP của máy chạy Backend).
4. Chạy ứng dụng trên Emulator hoặc thiết bị thật:
   ```sh
   flutter run
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## 🖥️ Sử dụng

Sau khi cài đặt, bạn có thể truy cập Swagger UI để kiểm tra API: `https://localhost:PORT/swagger/index.html`.

**Các Endpoint API chính:**

| Nhóm | Endpoint chính | Mô tả |
|------|----------------|-------|
| **Auth** | `/v1/api/login/*` | Đăng ký, Đăng nhập, OTP, 2FA |
| **Workspace** | `/v1/api/workspace/*` | CRUD Workspace, Invite members |
| **Board** | `/v1/api/boards/*` | Quản lý bảng và thành viên bảng |
| **Card** | `/v1/api/cards/*` | Quản lý thẻ, trạng thái, vị trí |
| **Checklist** | `/v1/api/todoItem/*` | Quản lý subtasks bên trong Card |
| **Inbox** | `/v1/api/user-inbox/*` | Thẻ được gán cho người dùng |

Chi tiết hơn về kiến trúc và sơ đồ dữ liệu, vui lòng xem tại [Trellon.md](Trellon.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## 🤝 Đóng góp

Đóng góp là điều làm cho cộng đồng open source trở thành một nơi tuyệt vời. Mọi đóng góp đều được trân trọng!

1. Fork dự án
2. Tạo Branch chức năng (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên Branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

### Top contributors:

<a href="https://github.com/KayPham05/TrelloAppClone_V2/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=KayPham05/TrelloAppClone_V2" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## 📜 Giấy phép

Được phân phối theo giấy phép MIT. Xem `LICENSE.txt` để biết thêm thông tin.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## 📬 Liên hệ

**Phạm Tấn Kha** - [KayPham05](https://github.com/KayPham05)

Link dự án: [https://github.com/KayPham05/TrelloAppClone_V2](https://github.com/KayPham05/TrelloAppClone_V2)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## 🙌 Lời cảm ơn

Các tài nguyên và công cụ hữu ích trong quá trình phát triển dự án:

* [Microsoft Docs](https://learn.microsoft.com/)
* [Flutter Documentation](https://docs.flutter.dev/)
* [Trello](https://trello.com/) - Nguồn cảm hứng chính.
* [Shields.io](https://shields.io) & [Contrib.rocks](https://contrib.rocks).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
[dotnet]: https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white  
[dotnet-url]: https://dotnet.microsoft.com/  
[csharp]: https://img.shields.io/badge/C%23-239120?style=for-the-badge&logo=csharp&logoColor=white  
[csharp-url]: https://learn.microsoft.com/dotnet/csharp/  
[sqlserver]: https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white  
[sqlserver-url]: https://www.microsoft.com/sql-server  
[ef]: https://img.shields.io/badge/Entity%20Framework-512BD4?style=for-the-badge&logo=dotnet&logoColor=white  
[ef-url]: https://learn.microsoft.com/ef/  
[react]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[react-url]: https://reactjs.org/
[flutter]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[flutter-url]: https://flutter.dev/
[tailwind]: https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white
[tailwind-url]: https://tailwindcss.com/
[aspnet]: https://img.shields.io/badge/ASP.NET_Core-512BD4?style=for-the-badge&logo=dotnet&logoColor=white
[aspnet-url]: https://learn.microsoft.com/aspnet/core/

[contributors-shield]: https://img.shields.io/github/contributors/KayPham05/TrelloAppClone_V2.svg?style=for-the-badge
[contributors-url]: https://github.com/KayPham05/TrelloAppClone_V2/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/KayPham05/TrelloAppClone_V2.svg?style=for-the-badge
[forks-url]: https://github.com/KayPham05/TrelloAppClone_V2/network/members
[stars-shield]: https://img.shields.io/github/stars/KayPham05/TrelloAppClone_V2.svg?style=for-the-badge
[stars-url]: https://github.com/KayPham05/TrelloAppClone_V2/stargazers
[issues-shield]: https://img.shields.io/github/issues/KayPham05/TrelloAppClone_V2.svg?style=for-the-badge
[issues-url]: https://github.com/KayPham05/TrelloAppClone_V2/issues
[license-shield]: https://img.shields.io/github/license/KayPham05/TrelloAppClone_V2.svg?style=for-the-badge
[license-url]: https://github.com/KayPham05/TrelloAppClone_V2/blob/main/LICENSE.txt
[product-screenshot]: https://via.placeholder.com/1280x720?text=Trellon+Preview+Screenshot

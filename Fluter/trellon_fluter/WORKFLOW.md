<a id="readme-top"></a>

# 📋 Trellon - Trello Clone Mobile App

<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<br />
<div align="center">
  <h2 align="center">Trellon - Workflow & Mobile Architecture</h2>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Mục lục</summary>
  <ol>
    <li><a href="#architecture">Kiến trúc dự án</a></li>
    <li><a href="#directory-structure">Phân tích cấu trúc thư mục</a></li>
    <li><a href="#tech-stack">Công nghệ sử dụng</a></li>
    <li><a href="#workflow">Luồng hoạt động</a></li>
    <li><a href="#getting-started">Hướng dẫn cài đặt & Chạy dự án</a></li>
  </ol>
</details>

<!-- ARCHITECTURE -->

## 🏗️ Kiến trúc dự án (Architecture)

Dự án áp dụng kiến trúc **Clean Architecture** kết hợp với cách phân chia thư mục theo **Feature-first Layering**. Cách tiếp cận này giúp mã nguồn dễ bảo trì, mở rộng và kiểm thử độc lập.

Mỗi tính năng (Feature) được chia thành 3 lớp chính:

- **Presentation**: UI (Widgets) và Quản lý trạng thái (BLoC).
- **Domain**: Chứa nghiệp vụ (Entities, UseCases, Repository Interfaces). Đây là trung tâm của ứng dụng.
- **Data**: Hiện thực hóa Repository, gọi API (Data Sources) và chuyển đổi dữ liệu (Models).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- DIRECTORY STRUCTURE -->

## 📂 Phân tích cấu trúc thư mục

Dựa trên cấu trúc thực tế của dự án:

| Thư mục                      | Mô tả ý nghĩa                                                                                                                 |
| :--------------------------- | :---------------------------------------------------------------------------------------------------------------------------- |
| `lib/core/network`           | Cấu hình **DioClient** (tương tự Axios). Xử lý BaseUrl, Timeout và **Interceptors** để tự động đính kèm JWT Token vào Header. |
| `lib/features/auth`          | Module xác thực: Xử lý Đăng nhập, Đăng ký và quản lý trạng thái phiên làm việc của người dùng.                                |
| `lib/features/board`         | Module quản lý bảng: Hiển thị danh sách các không gian làm việc và các bảng (Boards) của người dùng.                          |
| `lib/features/board_detail`  | **Module quan trọng nhất**: Xử lý logic kéo thả (Drag & Drop) để sắp xếp lại các List và Card bên trong một Board.            |
| `lib/init_dependencies.dart` | Nơi cấu hình Dependency Injection (DI) toàn cục.                                                                              |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- TECH STACK -->

## 🛠️ Tech Stack (Công nghệ sử dụng)

Dự án sử dụng các thư viện mạnh mẽ và phổ biến nhất trong hệ sinh thái Flutter:

- 🌐 **[dio](https://pub.dev/packages/dio)**: Xử lý các yêu cầu HTTP/Network (tương tự Axios trong JS).
- 🧠 **[flutter_bloc](https://pub.dev/packages/flutter_bloc)**: Quản lý trạng thái (State Management) theo luồng sự kiện.
- 💉 **[get_it](https://pub.dev/packages/get_it)**: Service Locator cho Dependency Injection.
- 🔐 **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)**: Lưu trữ nhạy cảm (JWT Token) an toàn trên thiết bị.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- WORKFLOW -->

## 🔄 Luồng hoạt động (Workflow)

Mọi yêu cầu dữ liệu đều tuân thủ luồng một chiều nghiêm ngặt:

1.  **UI (Page/Widget)**: Người dùng tương tác (ví dụ: nhấn nút Login).
2.  **BLoC (Presentation)**: Nhận sự kiện từ UI, phát ra trạng thái `Loading`, và gọi đến UseCase tương ứng.
3.  **UseCase (Domain)**: Thực hiện logic nghiệp vụ cụ thể.
4.  **Repository (Data/Domain)**: Trung gian quyết định lấy dữ liệu từ Remote (API) hay Local (Cache).
5.  **Data Source (Data)**: Sử dụng **Dio** để thực hiện call API thực tế.
6.  **Result**: Dữ liệu trả ngược lại theo luồng: `Data Source -> Repository -> UseCase -> BLoC -> UI` để cập nhật giao diện.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## 🚀 Hướng dẫn cài đặt & Chạy dự án

Để bắt đầu với dự án, hãy đảm bảo bạn đã cài đặt Flutter SDK và thực hiện các bước sau:

**Bước 1: Tải các thư viện phụ thuộc**

```bash
flutter pub get
```

**Bước 2: Chạy dự án (Debug Mode)**

```bash
flutter run
```

**Lưu ý:** Nếu bạn thêm mới các Model JSON, hãy chạy lệnh sau để generate code (nếu sử dụng `json_serializable`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

✍️ _Dự án được duy trì và phát triển bởi đội ngũ Trellon Team._

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->

[contributors-shield]: https://img.shields.io/github/contributors/YourUsername/Trellon.svg?style=for-the-badge
[contributors-url]: https://github.com/YourUsername/Trellon/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/YourUsername/Trellon.svg?style=for-the-badge
[forks-url]: https://github.com/YourUsername/Trellon/network/members
[stars-shield]: https://img.shields.io/github/stars/YourUsername/Trellon.svg?style=for-the-badge
[stars-url]: https://github.com/YourUsername/Trellon/stargazers
[issues-shield]: https://img.shields.io/github/issues/YourUsername/Trellon.svg?style=for-the-badge
[issues-url]: https://github.com/YourUsername/Trellon/issues
[license-shield]: https://img.shields.io/github/license/YourUsername/Trellon.svg?style=for-the-badge
[license-url]: https://github.com/YourUsername/Trellon/blob/master/LICENSE

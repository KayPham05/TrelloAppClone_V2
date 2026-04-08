# 📁 PROJECT STRUCTURE — Trello Clone (apptreolon)

> Tài liệu mô tả chi tiết cấu trúc dự án Flutter **Trello Clone**, dựa trên phân tích code thực tế.  
> Ngày cập nhật: 17/03/2026

---

## 1. Sơ đồ cây thư mục `lib`

```
lib/
├── main.dart                          # Entry point của ứng dụng
├── routes.dart                        # Định nghĩa các named routes
├── init_dependencies.dart             # Khởi tạo Dependency Injection (GetIt)
│
├── core/                              # Tầng Core — dùng chung cho toàn project
│   ├── common_widgets/
│   │   └── custom_button.dart         # Widget button tái sử dụng
│   ├── constants/
│   │   ├── api_endpoints.dart         # Các endpoint API (baseUrl, ...)
│   │   ├── app_colors.dart            # Bảng màu ứng dụng
│   │   └── app_images.dart            # Đường dẫn ảnh/assets
│   ├── errors/
│   │   └── failures.dart              # Định nghĩa lỗi (Failure, ServerFailure)
│   ├── network/
│   │   ├── dio_client.dart            # Cấu hình HTTP client (Dio)
│   │   └── interceptors/
│   │       └── auth_interceptor.dart  # Interceptor gắn JWT token
│   ├── services/
│   │   └── storage_service.dart       # Lưu trữ cục bộ (Secure Storage)
│   └── utils/
│       └── formatters.dart            # Tiện ích format ngày/text
│
└── features/                          # Tầng Features — tổ chức theo feature
    ├── auth/                          # Feature: Xác thực
    │   ├── domain/
    │   │   └── entities/
    │   │       └── user_entity.dart   # Entity người dùng
    │   └── presentation/
    │       └── pages/
    │           └── login_page.dart    # Trang đăng nhập
    │
    ├── board/                         # Feature: Quản lý Board (ĐẦY ĐỦ 3 LAYER)
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── board_remote_datasource.dart  # Abstract DataSource
    │   │   ├── models/
    │   │   │   └── board_model.dart               # Model (fromJson)
    │   │   └── repositories/
    │   │       └── board_repository_impl.dart     # Triển khai repository
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── board_entity.dart              # Entity Board
    │   │   ├── repositories/
    │   │   │   └── i_board_repository.dart        # Abstract repository
    │   │   └── usecases/
    │   │       └── get_user_boards_usecase.dart   # UseCase lấy danh sách board
    │   └── presentation/
    │       ├── bloc/
    │       │   └── board_bloc.dart                # BLoC quản lý state
    │       ├── pages/
    │       │   └── board_list_page.dart           # Trang danh sách board
    │       └── widgets/
    │           └── board_card_item.dart           # Widget card board
    │
    ├── board_detail/                  # Feature: Chi tiết Board
    │   └── presentation/
    │       └── pages/
    │           └── board_detail_page.dart  # Trang chi tiết board
    │
    ├── profile/                       # Feature: Trang cá nhân
    │   └── presentation/
    │       └── pages/
    │           └── profile_page.dart      # Trang profile
    │
    └── workspace/                     # Feature: Workspace
        └── presentation/
            └── pages/
                └── workspace_page.dart    # Trang workspace
```

---

## 2. Mô tả tổng quan kiến trúc

Dự án áp dụng **Clean Architecture** kết hợp với **Feature-First Organization**. Cấu trúc chia thành **2 phần lớn**:

### 2.1. `core/` — Tầng chia sẻ (Shared Layer)
Chứa các thành phần dùng chung cho toàn bộ ứng dụng: widget, hằng số, network, error handling, services, utilities. Không phụ thuộc vào bất kỳ feature nào.

### 2.2. `features/` — Tầng tính năng (Feature Layer)
Mỗi feature được tổ chức theo kiến trúc Clean Architecture với **3 layer chính**:

| Layer | Thư mục | Vai trò |
|-------|---------|---------|
| **Domain** | `domain/` | Chứa Entity, Abstract Repository, UseCase — **trung tâm kiến trúc**, không phụ thuộc framework |
| **Data** | `data/` | Chứa Model, DataSource, Repository Implementation — triển khai chi tiết truy xuất dữ liệu |
| **Presentation** | `presentation/` | Chứa Page, Widget, BLoC — giao diện và quản lý state |

### 2.3. Sơ đồ Clean Architecture

```
┌──────────────────────────────────────────────────┐
│                 PRESENTATION                      │
│  (Pages, Widgets, BLoC)                          │
│  Phụ thuộc vào: Domain (UseCases, Entities)      │
├──────────────────────────────────────────────────┤
│                    DOMAIN                         │
│  (Entities, Abstract Repositories, UseCases)     │
│  Không phụ thuộc vào bất kỳ layer nào            │
├──────────────────────────────────────────────────┤
│                     DATA                          │
│  (Models, DataSources, Repository Impl)          │
│  Phụ thuộc vào: Domain (Entities, Repositories)  │
└──────────────────────────────────────────────────┘
```

### 2.4. Dependency Injection
- Sử dụng **GetIt** (`get_it` package) làm Service Locator.
- Khởi tạo tại `init_dependencies.dart` với biến global `serviceLocator`.
- Hàm `initDependencies()` được gọi trong `main()` trước khi `runApp()`.

### 2.5. Routing
- Sử dụng **Named Routes** qua `MaterialApp.routes`.
- Được định nghĩa tập trung tại `routes.dart` (class `AppRoutes`).
- Các route hiện có:
  - `/` → `LoginPage`
  - `/boards` → `BoardListPage`

---

## 3. Mô tả chi tiết từng tầng (layer)

### 3.1. `core/` — Tầng chia sẻ

#### 3.1.1. `core/common_widgets/`
| File | Class | Vai trò |
|------|-------|---------|
| `custom_button.dart` | `CustomButton` (StatelessWidget) | Widget button tái sử dụng, hiện render `ElevatedButton` cơ bản |

- **Phụ thuộc**: `flutter/material.dart`
- **Được dùng bởi**: Tất cả các feature khi cần button chung

#### 3.1.2. `core/constants/`
| File | Class | Vai trò |
|------|-------|---------|
| `api_endpoints.dart` | `ApiEndpoints` | Chứa static const `baseUrl` = `https://api.example.com` |
| `app_colors.dart` | `AppColors` | Chứa static const Color `primary` = `Colors.blue` |
| `app_images.dart` | `AppImages` | Chứa static const String `logo` = `assets/images/logo.png` |

- **Phụ thuộc**: `app_colors.dart` import `flutter/material.dart` (cho kiểu `Color`); các file còn lại là pure Dart
- **Được dùng bởi**: Toàn bộ project

#### 3.1.3. `core/errors/`
| File | Class | Vai trò |
|------|-------|---------|
| `failures.dart` | `Failure` (abstract) | Base class cho tất cả lỗi, chứa `message` |
| | `ServerFailure` extends `Failure` | Lỗi từ server |

- **Phụ thuộc**: Pure Dart, không import Flutter
- **Được dùng bởi**: Data layer (repository), Presentation layer (BLoC)

#### 3.1.4. `core/network/`
| File | Class | Vai trò |
|------|-------|---------|
| `dio_client.dart` | `DioClient` | Cấu hình HTTP client Dio (chưa triển khai, có comment) |
| `interceptors/auth_interceptor.dart` | `AuthInterceptor` | Interceptor gắn JWT token vào request (chưa triển khai) |

- **Phụ thuộc**: Pure Dart (dự kiến sẽ import `dio`)
- **Được dùng bởi**: Data layer → DataSource

#### 3.1.5. `core/services/`
| File | Class | Vai trò |
|------|-------|---------|
| `storage_service.dart` | `StorageService` | Quản lý lưu trữ cục bộ (dự kiến Flutter Secure Storage) |

- **Phụ thuộc**: Pure Dart (dự kiến sẽ import `flutter_secure_storage`)
- **Được dùng bởi**: Auth feature, network interceptor

#### 3.1.6. `core/utils/`
| File | Class | Vai trò |
|------|-------|---------|
| `formatters.dart` | `Formatters` | Tiện ích format ngày/text (chưa triển khai) |

- **Phụ thuộc**: Pure Dart
- **Được dùng bởi**: Presentation layer khi cần format dữ liệu hiển thị

---

### 3.2. `features/auth/` — Feature Xác thực

**Trạng thái**: Mới có Domain + Presentation (chưa có Data layer)

#### Domain Layer
| File | Class | Vai trò |
|------|-------|---------|
| `domain/entities/user_entity.dart` | `UserEntity` | Entity người dùng với 2 field: `id` (String), `email` (String) |

- **Phụ thuộc**: Pure Dart — **KHÔNG import Flutter**
- **Được dùng bởi**: Presentation layer, data layer (khi tạo)

#### Presentation Layer
| File | Class | Vai trò |
|------|-------|---------|
| `presentation/pages/login_page.dart` | `LoginPage` (StatelessWidget) | Trang đăng nhập, hiện hiển thị text placeholder |

- **Phụ thuộc**: `flutter/material.dart`
- **Là route mặc định** (route `/`)

#### Thiếu (cần bổ sung khi hoàn thiện)
- `data/datasources/` — DataSource cho API auth
- `data/models/` — UserModel (fromJson/toJson)
- `data/repositories/` — AuthRepositoryImpl
- `domain/repositories/` — IAuthRepository (abstract)
- `domain/usecases/` — LoginUseCase, RegisterUseCase, ...
- `presentation/bloc/` — AuthBloc

---

### 3.3. `features/board/` — Feature Quản lý Board ⭐

**Trạng thái**: Đầy đủ cả 3 layer — **Đây là feature mẫu (reference feature)**

#### Domain Layer
| File | Class | Vai trò |
|------|-------|---------|
| `domain/entities/board_entity.dart` | `BoardEntity` | Entity board: `id` (String), `title` (String) |
| `domain/repositories/i_board_repository.dart` | `IBoardRepository` (abstract) | Contract cho repository, method: `getUserBoards()` → `Future<List<BoardEntity>>` |
| `domain/usecases/get_user_boards_usecase.dart` | `GetUserBoardsUseCase` | UseCase lấy danh sách board, nhận `IBoardRepository` qua constructor, có method `call()` |

- **Phụ thuộc**: Pure Dart — `IBoardRepository` chỉ import entities trong cùng domain
- **Quy tắc Dependency**: UseCase phụ thuộc abstract Repository, KHÔNG phụ thuộc implementation

#### Data Layer
| File | Class | Vai trò |
|------|-------|---------|
| `data/models/board_model.dart` | `BoardModel` | Model có `fromJson()` factory, fields: `id`, `title` |
| `data/datasources/board_remote_datasource.dart` | `BoardRemoteDataSource` (abstract) | Định nghĩa contract cho remote data source |
| `data/repositories/board_repository_impl.dart` | `BoardRepositoryImpl` implements `IBoardRepository` | Triển khai cụ thể repository, override `getUserBoards()` |

- **Phụ thuộc**: Import `BoardEntity` từ domain, import `IBoardRepository` từ domain
- **Được phụ thuộc bởi**: DI container (init_dependencies.dart)

#### Presentation Layer
| File | Class | Vai trò |
|------|-------|---------|
| `presentation/bloc/board_bloc.dart` | `BoardBloc` | Quản lý state cho Board (chưa triển khai, dự kiến dùng flutter_bloc) |
| `presentation/pages/board_list_page.dart` | `BoardListPage` (StatelessWidget) | Trang danh sách board |
| `presentation/widgets/board_card_item.dart` | `BoardCardItem` (StatelessWidget) | Widget hiển thị 1 board item dùng `Card` + `ListTile` |

- **Phụ thuộc**: `flutter/material.dart`, domain layer (entities, usecases)
- **Được dùng bởi**: Router (`/boards` route)

---

### 3.4. `features/board_detail/` — Feature Chi tiết Board

**Trạng thái**: Chỉ có Presentation layer

| File | Class | Vai trò |
|------|-------|---------|
| `presentation/pages/board_detail_page.dart` | `BoardDetailPage` (StatelessWidget) | Hiển thị chi tiết board (Reorderable List & Card) |

- **Phụ thuộc**: `flutter/material.dart`
- **Thiếu**: Domain layer, Data layer

---

### 3.5. `features/profile/` — Feature Trang cá nhân

**Trạng thái**: Chỉ có Presentation layer

| File | Class | Vai trò |
|------|-------|---------|
| `presentation/pages/profile_page.dart` | `ProfilePage` (StatelessWidget) | Trang profile người dùng |

- **Phụ thuộc**: `flutter/material.dart`
- **Thiếu**: Domain layer, Data layer

---

### 3.6. `features/workspace/` — Feature Workspace

**Trạng thái**: Chỉ có Presentation layer

| File | Class | Vai trò |
|------|-------|---------|
| `presentation/pages/workspace_page.dart` | `WorkspacePage` (StatelessWidget) | Trang workspace |

- **Phụ thuộc**: `flutter/material.dart`
- **Thiếu**: Domain layer, Data layer

---

## 4. Luồng dữ liệu (Data Flow)

Dựa trên code thực tế của feature `board` (feature hoàn chỉnh nhất):

### 4.1. Luồng đi (Request Flow): UI → Server

```
┌─────────────────┐     ┌──────────────────────┐     ┌───────────────────────┐     ┌────────────────────────┐
│   BoardListPage │ ──► │ GetUserBoardsUseCase  │ ──► │ IBoardRepository      │ ──► │ BoardRemoteDataSource  │
│   (Presentation)│     │ (Domain/UseCases)     │     │ (Domain/Repositories) │     │ (Data/DataSources)     │
│                 │     │                       │     │                       │     │                        │
│ Gọi usecase     │     │ Gọi repository.       │     │ Interface abstract    │     │ Gọi API qua DioClient │
│ thông qua BLoC  │     │ getUserBoards()       │     │ (Dependency Inversion)│     │                        │
└─────────────────┘     └──────────────────────┘     └───────────────────────┘     └────────────────────────┘
```

**Chi tiết từng bước (dựa trên code):**

1. **UI (`BoardListPage`)** → Trigger event trong `BoardBloc`
2. **BLoC (`BoardBloc`)** → Gọi `GetUserBoardsUseCase.call()`
3. **UseCase (`GetUserBoardsUseCase`)** → Gọi `repository.getUserBoards()`
   - UseCase chỉ biết **abstract** `IBoardRepository`, không biết implementation
4. **Repository (`BoardRepositoryImpl`)** → implements `IBoardRepository`
   - Gọi `BoardRemoteDataSource` để fetch data
5. **DataSource (`BoardRemoteDataSource`)** → Gọi API qua `DioClient`

### 4.2. Luồng về (Response Flow): Server → UI

```
┌────────────────────────┐     ┌───────────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│ BoardRemoteDataSource  │ ──► │ BoardRepositoryImpl   │ ──► │ GetUserBoardsUseCase  │ ──► │  BoardListPage  │
│ (Data/DataSources)     │     │ (Data/Repositories)   │     │ (Domain/UseCases)     │     │  (Presentation) │
│                        │     │                       │     │                       │     │                 │
│ Trả về JSON →          │     │ Convert BoardModel    │     │ Trả về List<Board     │     │ Hiển thị bằng  │
│ BoardModel.fromJson()  │     │ → BoardEntity         │     │ Entity>               │     │ BoardCardItem  │
└────────────────────────┘     └───────────────────────┘     └──────────────────────┘     └─────────────────┘
```

**Chi tiết từng bước:**

1. **DataSource** → Nhận JSON từ API, dùng `BoardModel.fromJson()` để parse
2. **Repository** → Convert `BoardModel` → `BoardEntity` (data layer → domain layer)
3. **UseCase** → Trả về `List<BoardEntity>` cho BLoC
4. **BLoC** → Emit state mới với danh sách entities
5. **UI** → Rebuild widget tree, hiển thị các `BoardCardItem`

### 4.3. Vai trò của Dependency Injection

```
init_dependencies.dart
│
├── Đăng ký: BoardRemoteDataSource (implementation)
├── Đăng ký: IBoardRepository → BoardRepositoryImpl(dataSource)
├── Đăng ký: GetUserBoardsUseCase(repository)
└── Đăng ký: BoardBloc(useCase)
```

Nhờ **GetIt**, presentation layer chỉ cần gọi `serviceLocator<BoardBloc>()` mà không cần biết toàn bộ dependency chain phía sau.

---

## 5. Quy ước đặt tên (Naming Convention)

### 5.1. Tên file (File naming)
| Quy ước | Ví dụ |
|---------|-------|
| `snake_case` cho tất cả file `.dart` | `board_entity.dart`, `login_page.dart` |
| Hậu tố `_entity` cho entity | `user_entity.dart`, `board_entity.dart` |
| Hậu tố `_model` cho model | `board_model.dart` |
| Hậu tố `_page` cho trang | `login_page.dart`, `board_list_page.dart` |
| Hậu tố `_bloc` cho BLoC | `board_bloc.dart` |
| Hậu tố `_usecase` cho UseCase | `get_user_boards_usecase.dart` |
| Tiền tố `i_` cho abstract repository | `i_board_repository.dart` |
| Hậu tố `_impl` cho implementation | `board_repository_impl.dart` |
| Hậu tố `_datasource` cho data source | `board_remote_datasource.dart` |

### 5.2. Tên class (Class naming)
| Quy ước | Ví dụ |
|---------|-------|
| `PascalCase` | `BoardEntity`, `LoginPage`, `BoardBloc` |
| Entity: `{Feature}Entity` | `UserEntity`, `BoardEntity` |
| Model: `{Feature}Model` | `BoardModel` |
| Page: `{Feature}Page` | `LoginPage`, `BoardListPage` |
| Widget: `{Feature}{Role}` | `BoardCardItem`, `CustomButton` |
| BLoC: `{Feature}Bloc` | `BoardBloc` |
| UseCase: `{Action}{Feature}UseCase` | `GetUserBoardsUseCase` |
| Repository (abstract): `I{Feature}Repository` | `IBoardRepository` |
| Repository (impl): `{Feature}RepositoryImpl` | `BoardRepositoryImpl` |
| DataSource: `{Feature}RemoteDataSource` | `BoardRemoteDataSource` |
| Failure: `{Type}Failure` | `ServerFailure` |

### 5.3. Tên thư mục (Folder naming)
| Quy ước | Ví dụ |
|---------|-------|
| `snake_case` | `board_detail/`, `common_widgets/` |
| Feature folder = tên feature | `auth/`, `board/`, `profile/` |
| Layer folder = tên layer | `data/`, `domain/`, `presentation/` |
| Sub-folder theo vai trò | `entities/`, `models/`, `usecases/`, `bloc/`, `pages/`, `widgets/` |

---

## 6. Quy tắc quan trọng cho AI khi làm việc với project này

### 6.1. Khi tạo feature mới — Danh sách file/folder cần tạo

Tham khảo feature `board` (feature mẫu đầy đủ nhất). Khi tạo feature mới tên `{feature_name}`:

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   └── {feature_name}_remote_datasource.dart   # Abstract class DataSource
│   ├── models/
│   │   └── {feature_name}_model.dart                # Model với fromJson/toJson
│   └── repositories/
│       └── {feature_name}_repository_impl.dart      # Implements I{Feature}Repository
├── domain/
│   ├── entities/
│   │   └── {feature_name}_entity.dart               # Entity thuần Dart
│   ├── repositories/
│   │   └── i_{feature_name}_repository.dart          # Abstract class repository
│   └── usecases/
│       └── {action}_{feature_name}_usecase.dart      # UseCase class với method call()
└── presentation/
    ├── bloc/
    │   └── {feature_name}_bloc.dart                  # BLoC/Cubit quản lý state
    ├── pages/
    │   └── {feature_name}_page.dart                  # Page widget
    └── widgets/
        └── {feature_name}_{widget_name}.dart         # Widget con tái sử dụng
```

**Sau khi tạo feature:**
1. Đăng ký DI tại `init_dependencies.dart`
2. Thêm route tại `routes.dart` (nếu cần navigation)

### 6.2. Những điều KHÔNG ĐƯỢC vi phạm ❌

| # | Quy tắc | Giải thích |
|---|---------|------------|
| 1 | **Domain layer KHÔNG được import `package:flutter/...`** | Domain phải là pure Dart, không phụ thuộc framework |
| 2 | **Domain layer KHÔNG được import từ Data layer** | Dependency Inversion: Domain chỉ định nghĩa abstract, Data triển khai |
| 3 | **Presentation KHÔNG được import trực tiếp từ Data layer** | Presentation chỉ biết Domain (thông qua UseCase và Entity) |
| 4 | **KHÔNG đặt business logic trong Widget/Page** | Logic phải nằm trong UseCase (domain) hoặc BLoC (presentation) |
| 5 | **KHÔNG import feature A vào feature B** | Các feature phải độc lập. Giao tiếp qua core hoặc shared abstraction |
| 6 | **Entity KHÔNG có method `fromJson`/`toJson`** | Serialization thuộc Data layer (Model), không phải Domain |
| 7 | **KHÔNG sử dụng `serviceLocator` trực tiếp trong Widget** | Inject dependency thông qua BLoC/Cubit, không gọi GetIt trong Widget |

### 6.3. Các Pattern đang được dùng nhất quán

#### Pattern 1: Abstract Repository trong Domain
```dart
// Domain Layer — Chỉ định nghĩa contract
abstract class IBoardRepository {
  Future<List<BoardEntity>> getUserBoards();
}

// Data Layer — Triển khai cụ thể
class BoardRepositoryImpl implements IBoardRepository {
  @override
  Future<List<BoardEntity>> getUserBoards() { ... }
}
```

#### Pattern 2: UseCase với method `call()`
```dart
class GetUserBoardsUseCase {
  final IBoardRepository repository;  // Inject abstract, không inject impl
  GetUserBoardsUseCase(this.repository);

  Future<List<BoardEntity>> call() async {
    return await repository.getUserBoards();
  }
}
```

#### Pattern 3: Entity vs Model
```dart
// Domain: Entity thuần Dart, chỉ chứa fields
class BoardEntity {
  final String id;
  final String title;
  BoardEntity({required this.id, required this.title});
}

// Data: Model có serialization
class BoardModel {
  final String id;
  final String title;
  BoardModel({required this.id, required this.title});
  factory BoardModel.fromJson(Map<String, dynamic> json) { ... }
}
```

#### Pattern 4: Abstract DataSource
```dart
// Data Layer — Định nghĩa abstract trước
abstract class BoardRemoteDataSource {
  // Methods for fetching boards
}
```

#### Pattern 5: Failure hierarchy
```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}
class ServerFailure extends Failure {
  ServerFailure(super.message);
}
```

#### Pattern 6: Service Locator (GetIt)
```dart
final serviceLocator = GetIt.instance;
Future<void> initDependencies() async {
  // Đăng ký tất cả dependencies tại đây
}
```

#### Pattern 7: Centralized Routing
```dart
class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginPage(),
    '/boards': (context) => const BoardListPage(),
  };
}
```

### 6.4. Checklist nhanh khi thêm code mới

- [ ] Entity mới → `features/{name}/domain/entities/`
- [ ] Model mới → `features/{name}/data/models/` (có `fromJson`)
- [ ] Abstract Repository → `features/{name}/domain/repositories/i_{name}_repository.dart`
- [ ] Repository Impl → `features/{name}/data/repositories/{name}_repository_impl.dart`
- [ ] UseCase mới → `features/{name}/domain/usecases/{action}_{name}_usecase.dart`
- [ ] BLoC mới → `features/{name}/presentation/bloc/{name}_bloc.dart`
- [ ] Page mới → `features/{name}/presentation/pages/{name}_page.dart`
- [ ] Widget mới → `features/{name}/presentation/widgets/{name}_{widget}.dart`
- [ ] Đăng ký DI → `init_dependencies.dart`
- [ ] Thêm Route → `routes.dart`
- [ ] Widget dùng chung → `core/common_widgets/`
- [ ] Hằng số mới → `core/constants/`
- [ ] Kiểu lỗi mới → `core/errors/failures.dart`

---

## 7. Dependencies hiện tại (từ `pubspec.yaml`)

| Package | Vai trò |
|---------|---------|
| `flutter` SDK | Framework chính |
| `cupertino_icons` ^1.0.8 | Icon iOS style |
| `get_it` | Service Locator / Dependency Injection (sử dụng trong `init_dependencies.dart`) |

> **⚠️ Lưu ý**: `get_it` được import trong code nhưng chưa được khai báo trong `pubspec.yaml`. Cần thêm `get_it` vào `dependencies` trước khi build.

---

## 8. Trạng thái phát triển các Feature

| Feature | Domain | Data | Presentation | Trạng thái |
|---------|--------|------|--------------|------------|
| `auth` | ✅ Entity | ❌ | ✅ Page | 🟡 Chưa hoàn chỉnh |
| `board` | ✅ Entity, Repository, UseCase | ✅ Model, DataSource, RepoImpl | ✅ BLoC, Page, Widget | 🟢 Đầy đủ cấu trúc |
| `board_detail` | ❌ | ❌ | ✅ Page | 🔴 Chỉ có UI |
| `profile` | ❌ | ❌ | ✅ Page | 🔴 Chỉ có UI |
| `workspace` | ❌ | ❌ | ✅ Page | 🔴 Chỉ có UI |

---

> 📌 **Ghi chú**: Feature `board` là feature tham chiếu (reference) khi tạo feature mới. Luôn lấy cấu trúc của `board` làm mẫu.

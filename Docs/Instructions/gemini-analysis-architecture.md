# Luồng kiến trúc Gemini Analysis

## Mục tiêu

Tính năng Gemini Analysis dùng Gemini API để phân tích tiến độ dự án trong TrelloAppClone_V2. Backend chịu trách nhiệm gom dữ liệu, kiểm quyền, gọi Gemini và trả báo cáo có cấu trúc. Flutter chỉ gọi API nội bộ của backend, không gọi Gemini trực tiếp và không giữ API key.

## Luồng tổng quan

```mermaid
flowchart TD
    A(["📱 Flutter\nGET /v1/api/analysis/board/{boardUId}"])
    B["GeminiAnalysisController\nValidate userUId & route params"]
    C{{"💾 IMemoryCache\nCache hit?"}}
    D(["200 OK\ncached = true"])
    E["GeminiAnalysisService\nKiểm tra board tồn tại"]
    F["AuthorizationService\nCanAnalyze(userUId, boardUId)"]
    G(["403 Forbidden"])
    H["TodoDbContext\nĐọc lists · cards · checklist · labels · due dates"]
    I["ProjectAnalysisSnapshot\nRút gọn dữ liệu + tính deterministic metrics"]
    J["ProjectAnalysisPromptBuilder\nTạo prompt + JSON schema"]
    K["GeminiClient\nPOST generateContent"]
    L{{"☁️ Gemini REST API\nThành công?"}}
    M["Validate & merge\nmetrics + Gemini output"]
    N["Fallback\nmetric-only response"]
    O["IMemoryCache\nStore TTL 5 phút"]
    P(["200 OK\nProjectAnalysisDto"])

    A --> B
    B --> C
    C -->|"✅ Hit"| D
    C -->|"❌ Miss"| E
    E --> F
    F -->|"❌ Forbidden"| G
    F -->|"✅ Authorized"| H
    H --> I
    I --> J
    J --> K
    K --> L
    L -->|"✅ OK"| M
    L -->|"❌ Lỗi"| N
    M --> O
    N --> O
    O --> P

    style A fill:#1a73e8,color:#fff,stroke:none
    style D fill:#1a73e8,color:#fff,stroke:none
    style P fill:#15803d,color:#fff,stroke:none
    style G fill:#b91c1c,color:#fff,stroke:none
    style C fill:#7c3aed,color:#fff,stroke:none
    style L fill:#7c3aed,color:#fff,stroke:none
    style N fill:#92400e,color:#fff,stroke:none
    style I fill:#0f4c3a,color:#fff,stroke:none
```

## Kiến trúc lớp

```mermaid
graph TD
    subgraph Flutter["📱 Flutter Client"]
        UI["Board Detail UI"]
    end

    subgraph Backend["🖥️ ASP.NET Core Backend"]
        CTRL["GeminiAnalysisController"]
        SVC["GeminiAnalysisService\n(Orchestrator)"]
        AUTHZ["AuthorizationService"]
        SNAP["ProjectAnalysisSnapshot"]
        BUILDER["ProjectAnalysisPromptBuilder"]
        CLIENT["GeminiClient"]
        CACHE["IMemoryCache\n(5 phút)"]
        DTO["ProjectAnalysisDto"]
    end

    subgraph DataLayer["🗄️ Data Layer"]
        DB[("TodoDbContext / SQL Server")]
    end

    subgraph External["☁️ External"]
        GEMINI["Gemini REST API\ngenerativelanguage.googleapis.com"]
    end

    UI -->|"GET /v1/api/analysis/board/{id}"| CTRL
    CTRL --> SVC
    SVC --> CACHE
    SVC --> AUTHZ
    SVC --> DB
    DB --> SNAP
    SNAP --> BUILDER
    BUILDER --> CLIENT
    CLIENT -->|"POST generateContent"| GEMINI
    GEMINI -->|"JSON response"| CLIENT
    CLIENT --> SVC
    SVC --> DTO
    DTO --> CTRL
    CTRL -->|"200 OK"| UI

    style Flutter fill:#1a73e8,color:#fff
    style Backend fill:#1e293b,color:#fff
    style DataLayer fill:#0f4c3a,color:#fff
    style External fill:#5f3dc4,color:#fff
```

## Vai trò từng lớp

### Flutter

- Gọi API backend qua Dio.
- Không gọi Gemini API trực tiếp.
- Không lưu Gemini API key.
- Hiển thị báo cáo gồm tiến độ tổng quan, metrics, risks, suggestions và inferred milestones.
- Với MVP, chỉ expose nút phân tích AI ở Board Detail cho người có quyền Admin/Editor.

### GeminiAnalysisController

Controller nhận request từ Flutter:

```http
GET /v1/api/analysis/workspace/{workspaceUId}?userUId={userUId}
GET /v1/api/analysis/board/{boardUId}?userUId={userUId}
GET /v1/api/analysis/card/{cardUId}?userUId={userUId}
```

Controller chỉ làm việc mỏng:

- Kiểm tra `userUId` không rỗng.
- Gọi `IGeminiAnalysisService`.
- Chuyển kết quả service thành HTTP status:
  - `200 OK` khi thành công.
  - `403 Forbidden` khi user không có quyền.
  - `404 Not Found` khi workspace/board/card không tồn tại.
  - `400 Bad Request` khi thiếu dữ liệu bắt buộc.

### AuthorizationService

Backend kiểm quyền trước khi gom dữ liệu và gọi Gemini.

| Scope | Owner | Admin | Editor | Viewer |
|---|:---:|:---:|:---:|:---:|
| Board analysis | ✅ | ✅ | ✅ | ❌ |
| Workspace analysis | ✅ | ✅ | ❌ | ❌ |
| Card analysis | ✅ | ✅ | ✅ | ❌ |

> **Lý do:** Báo cáo AI tổng hợp nhiều thông tin nhạy cảm → quyền phân tích chặt hơn quyền xem thông thường.

### GeminiAnalysisService

Đây là lớp orchestration chính.

Service thực hiện:

1. Kiểm tra workspace/board/card có tồn tại không.
2. Kiểm tra quyền truy cập qua `AuthorizationService`.
3. Đọc dữ liệu thật từ `TodoDbContext`.
4. Tạo snapshot rút gọn chỉ chứa dữ liệu cần cho phân tích.
5. Tính metrics deterministic từ DB.
6. Tạo prompt và JSON schema.
7. Gọi `IGeminiClient`.
8. Validate kết quả Gemini.
9. Trả `ProjectAnalysisDto`.

Nếu Gemini lỗi, service vẫn trả báo cáo metric-only để frontend không bị crash.

### TodoDbContext

Nguồn dữ liệu chính là database hiện có.

Dữ liệu dùng cho phân tích:

- Board name.
- Lists.
- Cards.
- Card status.
- Card due date.
- Todo items/checklist.
- Card labels.

Dữ liệu không gửi sang Gemini:

- JWT.
- Refresh token.
- Email user.
- Avatar URL.
- API key.
- Attachment URL, trừ khi sau này có yêu cầu rõ ràng.

### ProjectAnalysisSnapshot

Snapshot là dữ liệu đã được rút gọn từ DB trước khi đưa vào prompt.

Ví dụ snapshot board gồm:

- `scopeType`: `board`
- `scopeUId`
- `title`
- danh sách list
- danh sách card
- checklist count
- completed checklist count
- due date
- label names

Snapshot giúp Gemini chỉ nhìn thấy dữ liệu cần thiết, giảm rủi ro lộ thông tin và giảm token.

### Metrics deterministic

Metric là phần đáng tin cậy vì được tính từ DB, không phụ thuộc Gemini.

Các metric chính:

- Tổng số card.
- Số card hoàn thành.
- Số card quá hạn.
- Tổng số todo item/checklist.
- Số todo item đã hoàn thành.
- Overall progress.

Gemini không được tự tính lại metric. Gemini chỉ diễn giải trên metric và snapshot đã cung cấp.

### ProjectAnalysisPromptBuilder

Prompt builder tạo:

- Prompt tiếng Việt/tiếng Anh có ràng buộc rõ.
- Snapshot JSON.
- Metrics đã tính sẵn.
- JSON schema bắt buộc cho Gemini response.

Ràng buộc chính trong prompt:

- Chỉ dùng dữ liệu snapshot.
- Không bịa card ID, deadline, member hoặc milestone.
- Trả lời bằng tiếng Việt.
- Không trả text ngoài JSON.
- Giới hạn số risk/suggestion.

### GeminiClient

`GeminiClient` gọi Gemini bằng REST API:

```http
POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent
Header: x-goog-api-key: {GeminiSettings.ApiKey}
Header: Content-Type: application/json
```

API key chỉ nằm trong backend config/user-secrets/env var.

Request có `generationConfig.responseFormat` để ép Gemini trả JSON theo schema.

### ProjectAnalysisDto

Đây là response cuối cùng trả về Flutter.

Response gồm:

- `scopeType`
- `scopeUId`
- `title`
- `overallProgress`
- `summary`
- `risks`
- `suggestions`
- `metrics`
- `breakdown`
- `inferredMilestones`
- `generatedAt`
- `model`
- `cached`

## Fallback khi Gemini lỗi

```mermaid
flowchart TD
    A(["GeminiClient.GenerateAsync"])
    A --> B{"Gemini trả response?"}
    B -->|"✅ Thành công"| C{"JSON hợp lệ theo schema?"}
    C -->|"✅ Hợp lệ"| D["Merge metrics + Gemini output"]
    D --> E(["ProjectAnalysisDto đầy đủ"])
    C -->|"❌ Sai schema / parse lỗi"| F
    B -->|"❌ Timeout / Quota / API error"| F
    B -->|"❌ API key chưa cấu hình"| F
    F[/"Fallback mode"/]
    F --> G["summary = \"AI temporarily unavailable\""]
    F --> H["risks = [] · suggestions = [] · milestones = []"]
    F --> I["metrics vẫn đầy đủ từ DB"]
    G & H & I --> J(["ProjectAnalysisDto metric-only"])

    style E fill:#15803d,color:#fff
    style J fill:#92400e,color:#fff
    style F fill:#7c3aed,color:#fff
```

## Cache

```mermaid
flowchart LR
    A(["Service nhận request"]) --> B{"Cache hit?\nkey = analysis:{scope}:{uid}:{model}"}
    B -->|"✅ Hit"| C["Trả cached dto\ncached = true"]
    B -->|"❌ Miss"| D["Thực thi full pipeline"]
    D --> E["Lưu vào cache\nTTL = 5 phút"]
    E --> F(["Trả dto mới"])
    C --> G(["Response về Flutter"])
    F --> G

    style C fill:#1d4ed8,color:#fff
    style D fill:#1e293b,color:#fff
```

**Cache key format:** `analysis:{scopeType}:{scopeUId}:{userUId}:{model}`

| Mục tiêu | Lợi ích |
|---|---|
| Giảm gọi Gemini lặp lại | Tiết kiệm quota / cost |
| Giảm latency | Phản hồi nhanh cho các lần xem gần nhau |
| Giảm tải DB | Snapshot chỉ query 1 lần / 5 phút |

> Hiện tại chưa lưu lịch sử report vào DB. DB history là phase sau.

## Nguyên tắc thiết kế chính

- Backend là nơi duy nhất gọi Gemini.
- API key không bao giờ đi xuống Flutter.
- DB metrics là nguồn tin cậy.
- Gemini chỉ diễn giải, cảnh báo rủi ro và gợi ý hành động.
- Response Gemini luôn phải được validate.
- Feature vẫn hoạt động ở chế độ metric-only khi Gemini lỗi.
- Viewer không được phân tích board.


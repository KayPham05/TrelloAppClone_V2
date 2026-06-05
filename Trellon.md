# Kabo â€” Workspace, Board & Task Management System

> **Kabo** lÃ  má»™t ná»n táº£ng quáº£n lÃ½ cÃ´ng viá»‡c vÃ  dá»± Ã¡n, sao chÃ©p láº¡i cÃ¡c tÃ­nh nÄƒng cá»‘t lÃµi cá»§a Trello.
> Dá»± Ã¡n tá»± phÃ¡t triá»ƒn báº±ng **C# ASP.NET Core 8** cho Backend, **Flutter** (Clean Architecture) cho á»©ng dá»¥ng Mobile, vÃ  dá»± kiáº¿n sáº½ thÃªm á»©ng dá»¥ng Web báº±ng **React**.

---

## 1. Tech Stack Tá»•ng Quan

### Backend (REST API)

| ThÃ nh pháº§n | CÃ´ng nghá»‡ | Ghi chÃº |
| --- | --- | --- |
| Framework | **ASP.NET Core 8.0** Web API | XÃ¢y dá»±ng API chuáº©n REST |
| NgÃ´n ngá»¯ | **C# 12** | |
| CSDL | SQL Server | DÃ¹ng **EF Core 9.0.8** lÃ m ORM |
| XÃ¡c thá»±c | JWT & BCrypt | Token base (Access & Refresh) |
| Email / OTP | MailKit | Gá»­i Email xÃ¡c nháº­n mÃ£ OTP, tÃ­nh nÄƒng 2FA |
| API Docs | Swagger | Cho phÃ©p test dá»… dÃ ng tá»« trÃ¬nh duyá»‡t |
| KhÃ¡c | Docker | ÄÃ£ cáº¥u hÃ¬nh `Dockerfile` cho phÃ©p build |

### Frontend Mobile (App)

| ThÃ nh pháº§n | CÃ´ng nghá»‡ | Ghi chÃº |
| --- | --- | --- |
| Framework | **Flutter** (Dart ^3.11.0) | Cross platform |
| Kiáº¿n trÃºc | Clean Architecture | Chia lÃ m Domain - Data - Presentation |
| State Management | **flutter_bloc** 8.1.3 | Quáº£n lÃ½ theo cáº¥u trÃºc Bloc/Cubit |
| Networking | Dio + CookieJar | Há»— trá»£ cáº¥u hÃ¬nh base URL & Authen-Interceptor (tá»± refesh JWT Token) |
| UI | Material & Custom Dark Theme | `primary: #579DFF`, `background: #1D2125` |

### Web Frontend (Káº¿ Hoáº¡ch)

| ThÃ nh pháº§n | CÃ´ng nghá»‡ | Ghi chÃº |
| --- | --- | --- |
| Framework | **React** (Dá»± kiáº¿n SPA) | Káº¿t ná»‘i cÃ¹ng má»™t API |

---

## 2. Cáº¥u TrÃºc Dá»± Ãn

### SÆ¡ Ä‘á»“ luá»“ng á»©ng dá»¥ng

```mermaid
graph LR
    FlutterApp["Mobile App (Flutter)"] -- REST API --> Backend["ASP.NET Core API (:5293)"]
    WebApp["Web App (React - Planned)"] -- REST API --> Backend
    Backend -- EF Core --> Database[(SQL Server LocalDB)]
    Backend -- MailKit --> SMTP["Email Service"]
```

### ThÆ° má»¥c dá»± Ã¡n

```text
TrelloAppClone_V2/
â”œâ”€â”€ C#/TodoAppAPI/                  # Backend 
â”‚   â”œâ”€â”€ Configurations/             # EF Core configurations cho cÃ¡c Entity
â”‚   â”œâ”€â”€ Controllers/                # 16 REST API controllers 
â”‚   â”œâ”€â”€ Data/                       # TodoDbContext mapping cÃ¡c Entity tá»›i CSDL
â”‚   â”œâ”€â”€ DTOs/                       # CÃ¡c Data Transfer Objects 
â”‚   â”œâ”€â”€ Interfaces/                 # CÃ¡c Abstract Interfaces dÃ¹ng cho DI
â”‚   â”œâ”€â”€ Models/                     # Entity Classes (User, Board, Card, List, Workspace...)
â”‚   â”œâ”€â”€ Service/                    # Chá»©a má»i Bussiness Logic (VD: AuthService, CardService...)
â”‚   â”‚   â”œâ”€â”€ Email/                  # Gá»­i Email Service
â”‚   â”‚   â””â”€â”€ JWT/                    # Token Creation
â”‚   â”œâ”€â”€ Seeders/                    # Class táº¡o dá»¯ liá»‡u má»“i
â”‚   â”œâ”€â”€ appsettings.json            # Cáº¥u hÃ¬nh chuá»—i káº¿t ná»‘i vÃ  thÃ´ng sá»‘ cáº¥u hÃ¬nh khÃ¡c
â”‚   â””â”€â”€ Program.cs                  # DI Setup vÃ  Middleware 
â”‚
â”œâ”€â”€ Flutter/kabo_flutter/          # Mobile Frontend App
â”‚   â”œâ”€â”€ lib/
â”‚   â”‚   â”œâ”€â”€ core/                   # Shared Modules dÃ¹ng chung cho á»©ng dá»¥ng
â”‚   â”‚   â”‚   â”œâ”€â”€ common_widgets/
â”‚   â”‚   â”‚   â”œâ”€â”€ constants/
â”‚   â”‚   â”‚   â”œâ”€â”€ network/            # DioClient & HTTP Interceptors
â”‚   â”‚   â”‚   â””â”€â”€ services/           # Storage (Local Data)
â”‚   â”‚   â”‚
â”‚   â”‚   â”œâ”€â”€ features/               # PhÃ¢n chia á»©ng dá»¥ng theo tá»«ng chá»©c nÄƒng (Feature-based)
â”‚   â”‚   â”‚   â”œâ”€â”€ activity/
â”‚   â”‚   â”‚   â”œâ”€â”€ auth/               # XÃ¡c thá»±c, 2FA, OTP
â”‚   â”‚   â”‚   â”œâ”€â”€ board/              # TÃ­nh nÄƒng chÃ­nh Ä‘á»ƒ quáº£n lÃ½ Báº£ng
â”‚   â”‚   â”‚   â”œâ”€â”€ card/               
â”‚   â”‚   â”‚   â”œâ”€â”€ inbox/
â”‚   â”‚   â”‚   â”œâ”€â”€ planner/
â”‚   â”‚   â”‚   â””â”€â”€ profile/
â”‚   â”‚   â”‚
â”‚   â”‚   â”œâ”€â”€ init_dependencies.dart  # File chá»©a Service Locator Registration cho cÃ¡c Model
â”‚   â”‚   â”œâ”€â”€ main.dart               # Theme setup vÃ  khá»Ÿi táº¡o 
â”‚   â”‚   â””â”€â”€ routes.dart             # Named routes (/login, /home...vv)
â”‚   â””â”€â”€ pubspec.yaml                # Khai bÃ¡o packages cá»§a Flutter
â”‚
â””â”€â”€ Web/                            # React Project (Dá»± kiáº¿n xÃ¢y dá»±ng sau nÃ y)
```

---

## 3. Kiáº¿n TrÃºc Dá»¯ Liá»‡u (Backend Entities)

CÆ¡ cháº¿ quáº£n lÃ½ á»©ng dá»¥ng cho phÃ©p User thuá»™c vá» tá»• chá»©c Workspace, hay táº¡o Báº£ng riÃªng.
ÄÃ¢y lÃ  cÃ¡c báº£ng Models vÃ  má»‘i liÃªn káº¿t:

1. **User (TÃ i khoáº£n):** Quáº£n lÃ½ thÃ´ng tin xÃ¡c thá»±c, Tráº¡ng thÃ¡i tÃ i khoáº£n vÃ  2FA. `UserUId` lÃ  khÃ³a chÃ­nh dáº¡ng GUID string.
2. **Workspace (KhÃ´ng gian lÃ m viá»‡c):** NÆ¡i chá»©a dá»± Ã¡n team, bao gá»“m `WorkspaceMemberDto` lÆ°u quyá»n háº¡n cá»§a ngÆ°á»i dÃ¹ng trong tá»• chá»©c. 
3. **Board (Báº£ng):** Má»™t dá»± Ã¡n thuá»™c Workspace (hoáº·c Personal/cÃ¡ nhÃ¢n). Quáº£n lÃ½ thÃ nh viÃªn qua `BoardMember`.
4. **List (Danh sÃ¡ch):** CÃ¡c tráº¡ng thÃ¡i cá»™t tháº» trong `Board` (VD: TODO, DOING, DONE...). Quyáº¿t Ä‘á»‹nh theo trÆ°á»ng `Position`.
5. **Card (Tháº»):** ÄÆ¡n vá»‹ cÃ´ng viá»‡c thuá»™c vá» `List` (náº¿u khÃ´ng náº±m trong List tá»©c thuá»™c Inbox tháº» chÆ°a giao cá»§a User `UserInboxCard`). ThÃ´ng tin bá»• trá»£ gá»“m `TodoItems` ( Checklist ), `Comment` vÃ  Ä‘Æ°á»£c gáº¯n cho Assignee vá»›i `CardMember`.
6. **Activity & Notification:** Sá»­ dá»¥ng Ä‘á»ƒ track Event, theo dÃµi quÃ¡ trÃ¬nh log lá»‹ch sá»­ hÃ nh Ä‘á»™ng há»‡ thá»‘ng tráº£ vá» thÃ´ng bÃ¡o phÃ­a Client/App.

---

## 4. CÃ¡c TÃ­nh NÄƒng (Features)

### 4.1 NgÆ°á»i dÃ¹ng & XÃ¡c Thá»±c (Auth)
- Há»‡ thá»‘ng há»— trá»£ Ä‘Äƒng nháº­p cÆ¡ báº£n vÃ  há»— trá»£ OAuth (Google Login).
- CÃ³ cÆ¡ cháº¿ xÃ¡c thá»±c Email OTP (MÃ£ pin 6 sá»‘).
- CÃ³ cÆ¡ cháº¿ Two-Factor Authentication (2FA) báº£o máº­t hai lá»›p.
- Token JWT dÃ¹ng Cookie, do frontend gá»i Auth API láº¥y token vá» vÃ  interceptor phÃ­a Client cáº¥p phÃ¡t Access Token.

### 4.2 CÃ¡c Báº£ng & KhÃ´ng Gian LÃ m Viá»‡c (Workspace & Boards)
- Chá»©c nÄƒng CRUD cÆ¡ báº£n tá»« Endpoint.
- Chá»‰ Ä‘á»‹nh vÃ  thay Ä‘á»•i cáº­p nháº­t phÃ¢n quyá»n (`BoardRole` vÃ­ dá»¥: TrÆ°á»Ÿng nhÃ³m/Viewer).
- Báº£ng cÃ³ chia quyá»n Public / Workspace / Private.

### 4.3 Tháº» (Cards)
- Thiáº¿t láº­p chi tiáº¿t vá» tiÃªu Ä‘á», Due Date (NgÃ y háº¡n), vÃ  ghi chÃº chi tiáº¿t.
- TÃ­nh nÄƒng checklist `TodoItem` tÃ­ch há»£p ngay bÃªn trong card Ä‘á»ƒ thá»±c hÃ nh cÃ¡c cÃ´ng viá»‡c theo tiáº¿n trÃ¬nh. 
- Comment/BÃ¬nh luáº­n: Cho phÃ©p Member trÃ² chuyá»‡n vá»›i nhau.

### 4.4 Flow Há»‡ Thá»‘ng Bá»• Trá»£ (Activities / Notifications)
- Má»i API táº¡o, sá»­a, Ä‘á»•i cá»§a backend Ä‘á»u log láº¡i hÃ nh Ä‘á»™ng á»Ÿ báº£ng `Activity` (Service AddActivity).
- Má»i tÆ°Æ¡ng tÃ¡c tag user, má»i hoáº·c giao nháº­n card Ä‘á»u tá»± Ä‘á»™ng táº¡o ra má»™t `Notification` hÆ°á»›ng tá»›i Client.

---

## 5. Cáº¥u TrÃºc App Mobile

ÄÆ°á»£c phÃ¢n bá»• thiáº¿t káº¿ theo chuáº©n Clean Architecture táº¡o ra cÃ¡c tÃ­nh nÄƒng.

### CÃ¡c Layer cá»§a má»™t Feature (VÃ­ dá»¥: tÃ­nh nÄƒng `board` máº«u chuáº©n á»©ng dá»¥ng)
`domain` ( Lá»›p KhÃ´ng phá»¥ thuá»™c )
-  `entities`: Object cá»§a nghiá»‡p vá»¥.
-  `repositories`: Abstract Class (interfaces).
-  `usecases`: PhÆ°Æ¡ng thá»©c gá»i chá»©c nÄƒng.

 `data` 
-  `models`: Má»Ÿ rá»™ng tá»« Entity Ä‘á»ƒ há»— trá»£ serialization (fromJson/toJson).
-  `datasources`: Implement quÃ¡ trÃ¬nh gá»i Dio Fetch dá»¯ liá»‡u theo HTTP.
-  `repositories`: CÃ¡c Repositority implement cÃ¡c phÆ°Æ¡ng thá»©c abstract khai bÃ¡o trÃªn dÃ¹ng Datasource tráº£ ngÆ°á»£c dá»¯ liá»‡u. 

`presentation` 
-  `bloc / cubit`: CÃ¡c Event , State giÃºp update thay Ä‘á»•i trÃªn giao diá»‡n ngÆ°á»i dÃ¹ng.
-  `widgets / pages`: MÃ£ nguá»“n Flutter, components. 

### CÃ¡c Trang hiá»ƒn thá»‹
1. Tab **Báº£ng** (Quáº£n lÃ½ cÃ¡c dá»± Ã¡n, má»Ÿ báº£ng ra lÃ  tháº¥y danh sÃ¡ch List vÃ  Card dáº¡ng cá»™t cá»§a Trello).
2. Tab **Há»™p thÆ° Ä‘áº¿n** (Nháº­n thÃ´ng bÃ¡o chung, Card gÃ¡n cho mÃ¬nh).
3. Tab **Káº¿ hoáº¡ch** (Xem cÃ¡c Card háº¡n má»©c).
4. Tab **Hoáº¡t Ä‘á»™ng** (Xem lá»‹ch sá»­ Event).
5. Tab **TÃ i khoáº£n** (Setting cÃ¡ nhÃ¢n).

---

## 6. Lá»™ TrÃ¬nh PhÃ¡t Triá»ƒn (Roadmap)

### Backend (C# 8.0)
- âœ… Setup dá»± Ã¡n, Database EF & Migrations.
- âœ… API XÃ¡c thá»±c (Register, Login, Google OAuth, RefreshToken, 2FA, Email OTP).
- âœ… CRUD cho Workspace, Board, List, Card, TodoItem, Comment.
- âœ… Cáº¥u hÃ¬nh Activity & Notification Event.

### Mobile App (Flutter)
- âœ… Setup UI, Framework & Base Clean Architecture.
- âœ… TÃ­ch há»£p State Management ( Bloc + GetIt locator ). 
- âœ… PhÃ¡t triá»ƒn cÃ¡c luá»“ng giao diá»‡n 5 Tab + Board List dáº¡ng Trello.
- ðŸŸ¡ Káº¿t ná»‘i vá»›i Backend thÃ´ng qua cÃ¡c luá»“ng Network ( Hiá»‡n tráº¡ng Auth API cáº§n ghÃ©p luá»“ng Domain / Data chÆ°a hoÃ n táº¥t 100% ).
- ðŸŸ¡ Triá»ƒn khai mÃ n xÃ¡c nháº­n Email trÃªn trang `VerifyPage` (Sau khi setup Login gá»i Api Verify / TÃ­ch há»£p xá»­ lÃ½ cÃ¡c Exceptions) (Xem chi tiáº¿t trÃªn file `implementation_plan.md`). 

### Web App (React) (Sáº¯p tá»›i)
- ðŸŸ¡ XÃ¢y dá»±ng cáº¥u trÃºc dá»± Ã¡n React / TypeScript.
- ðŸŸ¡ PhÃ¡t triá»ƒn UI, luá»“ng tÆ°Æ¡ng tÃ¡c React-dnd (KÃ©o tháº£ React component).
- ðŸŸ¡ Cáº¥u hÃ¬nh vÃ  tÆ°Æ¡ng tÃ¡c vá»›i cÃ¡c Endpoint API C# tÆ°Æ¡ng tá»± App. 

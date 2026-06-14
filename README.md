<a id="readme-top"></a>

# ðŸ“‹ Kabo - Trello App Clone 

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
    <img src="https://raw.githubusercontent.com/KayPham05/TrelloAppClone_V2/main/.github/logo.png" alt="Logo" width="350 px" height="120 px" onerror="this.src='https://via.placeholder.com/350x120?text=Kabo+Logo'">
  </a>

  <h2 align="center">Kabo - Task Management System</h2>

  <p align="center">
    Kabo lÃ  má»™t há»‡ thá»‘ng quáº£n lÃ½ cÃ´ng viá»‡c hoÃ n chá»‰nh, giÃºp tá»• chá»©c boards, lists, cards vÃ  tasks má»™t cÃ¡ch hiá»‡u quáº£ vÃ  dá»… dÃ ng!
    <br />
    <a href="https://github.com/KayPham05/TrelloAppClone_V2"><strong>KhÃ¡m phÃ¡ tÃ i liá»‡u Â»</strong></a>
    <br />
    <br />
    <a href="https://github.com/KayPham05/TrelloAppClone_V2">Xem Demo</a>
    &middot;
    <a href="https://github.com/KayPham05/TrelloAppClone_V2/issues/new?labels=bug&template=bug-report---.md">BÃ¡o lá»—i</a>
    &middot;
    <a href="https://github.com/KayPham05/TrelloAppClone_V2/issues/new?labels=enhancement&template=feature-request---.md">YÃªu cáº§u tÃ­nh nÄƒng</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Má»¥c lá»¥c</summary>
  <ol>
    <li>
      <a href="#about-the-project">Vá» dá»± Ã¡n</a>
      <ul>
        <li><a href="#built-with">CÃ´ng nghá»‡ sá»­ dá»¥ng</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Báº¯t Ä‘áº§u</a>
      <ul>
        <li><a href="#prerequisites">YÃªu cáº§u</a></li>
        <li><a href="#installation">CÃ i Ä‘áº·t</a></li>
      </ul>
    </li>
    <li><a href="#usage">Sá»­ dá»¥ng</a></li>
    <li><a href="#contributing">ÄÃ³ng gÃ³p</a></li>
    <li><a href="#license">Giáº¥y phÃ©p</a></li>
    <li><a href="#contact">LiÃªn há»‡</a></li>
    <li><a href="#acknowledgments">Lá»i cáº£m Æ¡n</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## ðŸŽ¯ Vá» dá»± Ã¡n

[![Product Name Screen Shot][product-screenshot]](https://github.com/KayPham05/TrelloAppClone_V2)

Kabo lÃ  má»™t ná»n táº£ng quáº£n lÃ½ cÃ´ng viá»‡c vÃ  dá»± Ã¡n, sao chÃ©p láº¡i cÃ¡c tÃ­nh nÄƒng cá»‘t lÃµi cá»§a Trello. Dá»± Ã¡n bao gá»“m **Backend Web API** linh hoáº¡t vÃ  á»©ng dá»¥ng **Mobile (Flutter)** máº¡nh máº½, há»— trá»£ quáº£n lÃ½ theo mÃ´ hÃ¬nh **Workspace â†’ Board â†’ List â†’ Card â†’ TodoItem**.

Cáº¥u trÃºc chÃ­nh cá»§a há»‡ thá»‘ng:
* **Backend:** ASP.NET Core 8 Web API chuáº©n RESTful, xÃ¡c thá»±c JWT, phÃ¢n quyá»n, vÃ  quáº£n lÃ½ cá»™ng tÃ¡c.
* **Mobile App:** PhÃ¡t triá»ƒn báº±ng Flutter theo Clean Architecture, giao diá»‡n hiá»‡n Ä‘áº¡i vÃ  mÆ°á»£t mÃ .
* **Web App:** (Äang lÃªn káº¿ hoáº¡ch) PhÃ¡t triá»ƒn báº±ng React Ä‘á»ƒ Ä‘á»“ng bá»™ tráº£i nghiá»‡m trÃªn trÃ¬nh duyá»‡t.

CÃ¡c chá»©c nÄƒng chÃ­nh:
* **XÃ¡c thá»±c:** ÄÄƒng kÃ½, Ä‘Äƒng nháº­p, Google OAuth, Email OTP (6 sá»‘), vÃ  2FA.
* **Workspace:** Quáº£n lÃ½ khÃ´ng gian lÃ m viá»‡c chung, má»i thÃ nh viÃªn vÃ  phÃ¢n quyá»n.
* **Board:** Quáº£n lÃ½ báº£ng dá»± Ã¡n (CÃ´ng khai, Workspace, hoáº·c CÃ¡ nhÃ¢n).
* **List & Card:** Tá»• chá»©c cÃ´ng viá»‡c theo cá»™t vÃ  tháº» bÃ i vá»›i kháº£ nÄƒng kÃ©o tháº£ (trÃªn App).
* **Todo & Checklist:** Quáº£n lÃ½ cÃ¡c subtasks chi tiáº¿t bÃªn trong má»—i Card.
* **TÆ°Æ¡ng tÃ¡c:** BÃ¬nh luáº­n (Comment), Gáº¯n nhÃ£n (Label), vÃ  GÃ¡n ngÆ°á»i thá»±c hiá»‡n (Assignee).
* **ThÃ´ng bÃ¡o:** Há»‡ thá»‘ng Activity Log vÃ  Notification thá»i gian thá»±c cho ngÆ°á»i dÃ¹ng.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- BUILT WITH -->
## ðŸ§± CÃ´ng nghá»‡ sá»­ dá»¥ng

Dá»± Ã¡n nÃ y Ä‘Æ°á»£c phÃ¡t triá»ƒn sá»­ dá»¥ng cÃ¡c framework, thÆ° viá»‡n vÃ  cÃ´ng nghá»‡ sau:

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
## ðŸš€ Báº¯t Ä‘áº§u

LÃ m theo cÃ¡c bÆ°á»›c sau Ä‘á»ƒ thiáº¿t láº­p dá»± Ã¡n trÃªn mÃ¡y local.

### YÃªu cáº§u

Äáº£m báº£o báº¡n Ä‘Ã£ cÃ i Ä‘áº·t cÃ¡c pháº§n má»m sau:

* **Backend:** [.NET SDK 8.0](https://dotnet.microsoft.com/en-us/download/dotnet) & [SQL Server](https://www.microsoft.com/sql-server).
* **Mobile:** [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiÃªn báº£n > 3.11.0).
* **IDE:** Visual Studio 2022 (cho C#) vÃ  VS Code hoáº·c Android Studio (cho Flutter).

### CÃ i Ä‘áº·t

#### 1. Backend (ASP.NET Core API)
1. Di chuyá»ƒn vÃ o thÆ° má»¥c backend:
   ```sh
   cd "C#/TodoAppAPI"
   ```
2. KhÃ´i phá»¥c packages:
   ```sh
   dotnet restore
   ```
3. Cáº¥u hÃ¬nh connection string trong `appsettings.json` (thay Ä‘á»•i Server name cho phÃ¹ há»£p):
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=KaboDB;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```
4. Cháº¡y migrations Ä‘á»ƒ táº¡o database:
   ```sh
   dotnet ef database update
   ```
5. Cháº¡y dá»± Ã¡n:
   ```sh
   dotnet run
   ```

#### 2. Mobile App (Flutter)
1. Di chuyá»ƒn vÃ o thÆ° má»¥c app:
   ```sh
   cd "Flutter/kabo_flutter"
   ```
2. CÃ i Ä‘áº·t cÃ¡c thÆ° viá»‡n Dart:
   ```sh
   flutter pub get
   ```
3. Cáº¥u hÃ¬nh Base URL trong `lib/core/network/dio_client.dart` (trá» vá» IP cá»§a mÃ¡y cháº¡y Backend).
4. Cháº¡y á»©ng dá»¥ng trÃªn Emulator hoáº·c thiáº¿t bá»‹ tháº­t:
   ```sh
   flutter run
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## ðŸ–¥ï¸ Sá»­ dá»¥ng

Sau khi cÃ i Ä‘áº·t, báº¡n cÃ³ thá»ƒ truy cáº­p Swagger UI Ä‘á»ƒ kiá»ƒm tra API: `https://localhost:PORT/swagger/index.html`.

**CÃ¡c Endpoint API chÃ­nh:**

| NhÃ³m | Endpoint chÃ­nh | MÃ´ táº£ |
|------|----------------|-------|
| **Auth** | `/v1/api/login/*` | ÄÄƒng kÃ½, ÄÄƒng nháº­p, OTP, 2FA |
| **Workspace** | `/v1/api/workspace/*` | CRUD Workspace, Invite members |
| **Board** | `/v1/api/boards/*` | Quáº£n lÃ½ báº£ng vÃ  thÃ nh viÃªn báº£ng |
| **Card** | `/v1/api/cards/*` | Quáº£n lÃ½ tháº», tráº¡ng thÃ¡i, vá»‹ trÃ­ |
| **Checklist** | `/v1/api/todoItem/*` | Quáº£n lÃ½ subtasks bÃªn trong Card |
| **Inbox** | `/v1/api/user-inbox/*` | Tháº» Ä‘Æ°á»£c gÃ¡n cho ngÆ°á»i dÃ¹ng |

Chi tiáº¿t hÆ¡n vá» kiáº¿n trÃºc vÃ  sÆ¡ Ä‘á»“ dá»¯ liá»‡u, vui lÃ²ng xem táº¡i [Kabo.md](Kabo.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## ðŸ¤ ÄÃ³ng gÃ³p

ÄÃ³ng gÃ³p lÃ  Ä‘iá»u lÃ m cho cá»™ng Ä‘á»“ng open source trá»Ÿ thÃ nh má»™t nÆ¡i tuyá»‡t vá»i. Má»i Ä‘Ã³ng gÃ³p Ä‘á»u Ä‘Æ°á»£c trÃ¢n trá»ng!

1. Fork dá»± Ã¡n
2. Táº¡o Branch chá»©c nÄƒng (`git checkout -b feature/AmazingFeature`)
3. Commit thay Ä‘á»•i (`git commit -m 'Add some AmazingFeature'`)
4. Push lÃªn Branch (`git push origin feature/AmazingFeature`)
5. Má»Ÿ Pull Request

### Top contributors:

<a href="https://github.com/KayPham05/TrelloAppClone_V2/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=KayPham05/TrelloAppClone_V2" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## ðŸ“œ Giáº¥y phÃ©p

ÄÆ°á»£c phÃ¢n phá»‘i theo giáº¥y phÃ©p MIT. Xem `LICENSE.txt` Ä‘á»ƒ biáº¿t thÃªm thÃ´ng tin.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## ðŸ“¬ LiÃªn há»‡

**Pháº¡m Táº¥n Kha** - [KayPham05](https://github.com/KayPham05)

Link dá»± Ã¡n: [https://github.com/KayPham05/TrelloAppClone_V2](https://github.com/KayPham05/TrelloAppClone_V2)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## ðŸ™Œ Lá»i cáº£m Æ¡n

CÃ¡c tÃ i nguyÃªn vÃ  cÃ´ng cá»¥ há»¯u Ã­ch trong quÃ¡ trÃ¬nh phÃ¡t triá»ƒn dá»± Ã¡n:

* [Microsoft Docs](https://learn.microsoft.com/)
* [Flutter Documentation](https://docs.flutter.dev/)
* [Trello](https://trello.com/) - Nguá»“n cáº£m há»©ng chÃ­nh.
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
[product-screenshot]: https://via.placeholder.com/1280x720?text=Kabo+Preview+Screenshot

<a id="readme-top"></a>

# ðŸ“‹ Kabo - Trello Clone Mobile App

<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<br />
<div align="center">
  <h2 align="center">Kabo - Workflow & Mobile Architecture</h2>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Má»¥c lá»¥c</summary>
  <ol>
    <li><a href="#architecture">Kiáº¿n trÃºc dá»± Ã¡n</a></li>
    <li><a href="#directory-structure">PhÃ¢n tÃ­ch cáº¥u trÃºc thÆ° má»¥c</a></li>
    <li><a href="#tech-stack">CÃ´ng nghá»‡ sá»­ dá»¥ng</a></li>
    <li><a href="#workflow">Luá»“ng hoáº¡t Ä‘á»™ng</a></li>
    <li><a href="#getting-started">HÆ°á»›ng dáº«n cÃ i Ä‘áº·t & Cháº¡y dá»± Ã¡n</a></li>
  </ol>
</details>

<!-- ARCHITECTURE -->

## ðŸ—ï¸ Kiáº¿n trÃºc dá»± Ã¡n (Architecture)

Dá»± Ã¡n Ã¡p dá»¥ng kiáº¿n trÃºc **Clean Architecture** káº¿t há»£p vá»›i cÃ¡ch phÃ¢n chia thÆ° má»¥c theo **Feature-first Layering**. CÃ¡ch tiáº¿p cáº­n nÃ y giÃºp mÃ£ nguá»“n dá»… báº£o trÃ¬, má»Ÿ rá»™ng vÃ  kiá»ƒm thá»­ Ä‘á»™c láº­p.

Má»—i tÃ­nh nÄƒng (Feature) Ä‘Æ°á»£c chia thÃ nh 3 lá»›p chÃ­nh:

- **Presentation**: UI (Widgets) vÃ  Quáº£n lÃ½ tráº¡ng thÃ¡i (BLoC).
- **Domain**: Chá»©a nghiá»‡p vá»¥ (Entities, UseCases, Repository Interfaces). ÄÃ¢y lÃ  trung tÃ¢m cá»§a á»©ng dá»¥ng.
- **Data**: Hiá»‡n thá»±c hÃ³a Repository, gá»i API (Data Sources) vÃ  chuyá»ƒn Ä‘á»•i dá»¯ liá»‡u (Models).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- DIRECTORY STRUCTURE -->

## ðŸ“‚ PhÃ¢n tÃ­ch cáº¥u trÃºc thÆ° má»¥c

Dá»±a trÃªn cáº¥u trÃºc thá»±c táº¿ cá»§a dá»± Ã¡n:

| ThÆ° má»¥c                      | MÃ´ táº£ Ã½ nghÄ©a                                                                                                                 |
| :--------------------------- | :---------------------------------------------------------------------------------------------------------------------------- |
| `lib/core/network`           | Cáº¥u hÃ¬nh **DioClient** (tÆ°Æ¡ng tá»± Axios). Xá»­ lÃ½ BaseUrl, Timeout vÃ  **Interceptors** Ä‘á»ƒ tá»± Ä‘á»™ng Ä‘Ã­nh kÃ¨m JWT Token vÃ o Header. |
| `lib/features/auth`          | Module xÃ¡c thá»±c: Xá»­ lÃ½ ÄÄƒng nháº­p, ÄÄƒng kÃ½ vÃ  quáº£n lÃ½ tráº¡ng thÃ¡i phiÃªn lÃ m viá»‡c cá»§a ngÆ°á»i dÃ¹ng.                                |
| `lib/features/board`         | Module quáº£n lÃ½ báº£ng: Hiá»ƒn thá»‹ danh sÃ¡ch cÃ¡c khÃ´ng gian lÃ m viá»‡c vÃ  cÃ¡c báº£ng (Boards) cá»§a ngÆ°á»i dÃ¹ng.                          |
| `lib/features/board_detail`  | **Module quan trá»ng nháº¥t**: Xá»­ lÃ½ logic kÃ©o tháº£ (Drag & Drop) Ä‘á»ƒ sáº¯p xáº¿p láº¡i cÃ¡c List vÃ  Card bÃªn trong má»™t Board.            |
| `lib/init_dependencies.dart` | NÆ¡i cáº¥u hÃ¬nh Dependency Injection (DI) toÃ n cá»¥c.                                                                              |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- TECH STACK -->

## ðŸ› ï¸ Tech Stack (CÃ´ng nghá»‡ sá»­ dá»¥ng)

Dá»± Ã¡n sá»­ dá»¥ng cÃ¡c thÆ° viá»‡n máº¡nh máº½ vÃ  phá»• biáº¿n nháº¥t trong há»‡ sinh thÃ¡i Flutter:

- ðŸŒ **[dio](https://pub.dev/packages/dio)**: Xá»­ lÃ½ cÃ¡c yÃªu cáº§u HTTP/Network (tÆ°Æ¡ng tá»± Axios trong JS).
- ðŸ§  **[flutter_bloc](https://pub.dev/packages/flutter_bloc)**: Quáº£n lÃ½ tráº¡ng thÃ¡i (State Management) theo luá»“ng sá»± kiá»‡n.
- ðŸ’‰ **[get_it](https://pub.dev/packages/get_it)**: Service Locator cho Dependency Injection.
- ðŸ” **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)**: LÆ°u trá»¯ nháº¡y cáº£m (JWT Token) an toÃ n trÃªn thiáº¿t bá»‹.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- WORKFLOW -->

## ðŸ”„ Luá»“ng hoáº¡t Ä‘á»™ng (Workflow)

Má»i yÃªu cáº§u dá»¯ liá»‡u Ä‘á»u tuÃ¢n thá»§ luá»“ng má»™t chiá»u nghiÃªm ngáº·t:

1.  **UI (Page/Widget)**: NgÆ°á»i dÃ¹ng tÆ°Æ¡ng tÃ¡c (vÃ­ dá»¥: nháº¥n nÃºt Login).
2.  **BLoC (Presentation)**: Nháº­n sá»± kiá»‡n tá»« UI, phÃ¡t ra tráº¡ng thÃ¡i `Loading`, vÃ  gá»i Ä‘áº¿n UseCase tÆ°Æ¡ng á»©ng.
3.  **UseCase (Domain)**: Thá»±c hiá»‡n logic nghiá»‡p vá»¥ cá»¥ thá»ƒ.
4.  **Repository (Data/Domain)**: Trung gian quyáº¿t Ä‘á»‹nh láº¥y dá»¯ liá»‡u tá»« Remote (API) hay Local (Cache).
5.  **Data Source (Data)**: Sá»­ dá»¥ng **Dio** Ä‘á»ƒ thá»±c hiá»‡n call API thá»±c táº¿.
6.  **Result**: Dá»¯ liá»‡u tráº£ ngÆ°á»£c láº¡i theo luá»“ng: `Data Source -> Repository -> UseCase -> BLoC -> UI` Ä‘á»ƒ cáº­p nháº­t giao diá»‡n.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## ðŸš€ HÆ°á»›ng dáº«n cÃ i Ä‘áº·t & Cháº¡y dá»± Ã¡n

Äá»ƒ báº¯t Ä‘áº§u vá»›i dá»± Ã¡n, hÃ£y Ä‘áº£m báº£o báº¡n Ä‘Ã£ cÃ i Ä‘áº·t Flutter SDK vÃ  thá»±c hiá»‡n cÃ¡c bÆ°á»›c sau:

**BÆ°á»›c 1: Táº£i cÃ¡c thÆ° viá»‡n phá»¥ thuá»™c**

```bash
flutter pub get
```

**BÆ°á»›c 2: Cháº¡y dá»± Ã¡n (Debug Mode)**

```bash
flutter run
```

**LÆ°u Ã½:** Náº¿u báº¡n thÃªm má»›i cÃ¡c Model JSON, hÃ£y cháº¡y lá»‡nh sau Ä‘á»ƒ generate code (náº¿u sá»­ dá»¥ng `json_serializable`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

âœï¸ _Dá»± Ã¡n Ä‘Æ°á»£c duy trÃ¬ vÃ  phÃ¡t triá»ƒn bá»Ÿi Ä‘á»™i ngÅ© Kabo Team._

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->

[contributors-shield]: https://img.shields.io/github/contributors/YourUsername/Kabo.svg?style=for-the-badge
[contributors-url]: https://github.com/YourUsername/Kabo/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/YourUsername/Kabo.svg?style=for-the-badge
[forks-url]: https://github.com/YourUsername/Kabo/network/members
[stars-shield]: https://img.shields.io/github/stars/YourUsername/Kabo.svg?style=for-the-badge
[stars-url]: https://github.com/YourUsername/Kabo/stargazers
[issues-shield]: https://img.shields.io/github/issues/YourUsername/Kabo.svg?style=for-the-badge
[issues-url]: https://github.com/YourUsername/Kabo/issues
[license-shield]: https://img.shields.io/github/license/YourUsername/Kabo.svg?style=for-the-badge
[license-url]: https://github.com/YourUsername/Kabo/blob/master/LICENSE

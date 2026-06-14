# TÃ i Liá»‡u PhÃ¢n TÃ­ch & Thiáº¿t Káº¿ Há»‡ Thá»‘ng Trello Clone

> **á»¨ng dá»¥ng:** Kabo â€“ Há»‡ thá»‘ng quáº£n lÃ½ cÃ´ng viá»‡c theo mÃ´ hÃ¬nh Kanban  
> **Ná»n táº£ng:** Flutter (Mobile) + ASP.NET Core 9 (Backend API) + SQL Server  
> **PhiÃªn báº£n tÃ i liá»‡u:** 1.0  

---

# PHáº¦N 1: PHÃ‚N TÃCH Há»† THá»NG

---

## 1.1 SÆ¡ Äá»“ PhÃ¢n Cáº¥p Chá»©c NÄƒng (BFD)

```
Kabo â€“ Há»‡ thá»‘ng quáº£n lÃ½ cÃ´ng viá»‡c
â”‚
â”œâ”€â”€ 1. Quáº£n lÃ½ TÃ i khoáº£n & XÃ¡c thá»±c
â”‚   â”œâ”€â”€ 1.1 ÄÄƒng kÃ½ tÃ i khoáº£n
â”‚   â”‚   â”œâ”€â”€ 1.1.1 Nháº­p thÃ´ng tin Ä‘Äƒng kÃ½ (email, máº­t kháº©u, tÃªn)
â”‚   â”‚   â””â”€â”€ 1.1.2 XÃ¡c minh email (gá»­i OTP / token)
â”‚   â”œâ”€â”€ 1.2 ÄÄƒng nháº­p
â”‚   â”‚   â”œâ”€â”€ 1.2.1 ÄÄƒng nháº­p báº±ng email + máº­t kháº©u (JWT)
â”‚   â”‚   â””â”€â”€ 1.2.2 ÄÄƒng nháº­p qua OAuth (Google, v.v.)
â”‚   â”œâ”€â”€ 1.3 XÃ¡c thá»±c hai yáº¿u tá»‘ (2FA)
â”‚   â”‚   â”œâ”€â”€ 1.3.1 Báº­t/táº¯t 2FA
â”‚   â”‚   â”œâ”€â”€ 1.3.2 XÃ¡c thá»±c TOTP code
â”‚   â”‚   â””â”€â”€ 1.3.3 DÃ¹ng backup code
â”‚   â”œâ”€â”€ 1.4 Quáº£n lÃ½ phiÃªn Ä‘Äƒng nháº­p (session / refresh token)
â”‚   â””â”€â”€ 1.5 QuÃªn & Ä‘áº·t láº¡i máº­t kháº©u
â”‚
â”œâ”€â”€ 2. Quáº£n lÃ½ Há»“ sÆ¡ NgÆ°á»i dÃ¹ng
â”‚   â”œâ”€â”€ 2.1 Xem & chá»‰nh sá»­a thÃ´ng tin cÃ¡ nhÃ¢n (tÃªn, bio)
â”‚   â”œâ”€â”€ 2.2 Thay Ä‘á»•i avatar (táº£i lÃªn Cloudinary)
â”‚   â””â”€â”€ 2.3 Xem lá»‹ch sá»­ hoáº¡t Ä‘á»™ng cÃ¡ nhÃ¢n
â”‚
â”œâ”€â”€ 3. Quáº£n lÃ½ KhÃ´ng gian LÃ m viá»‡c (Workspace)
â”‚   â”œâ”€â”€ 3.1 Táº¡o workspace má»›i
â”‚   â”œâ”€â”€ 3.2 Xem danh sÃ¡ch workspace cá»§a tÃ´i
â”‚   â”œâ”€â”€ 3.3 Chá»‰nh sá»­a thÃ´ng tin workspace
â”‚   â”œâ”€â”€ 3.4 XÃ³a workspace
â”‚   â””â”€â”€ 3.5 Quáº£n lÃ½ thÃ nh viÃªn workspace
â”‚       â”œâ”€â”€ 3.5.1 Má»i thÃ nh viÃªn vÃ o workspace
â”‚       â”œâ”€â”€ 3.5.2 Thay Ä‘á»•i vai trÃ² thÃ nh viÃªn (Admin / Member)
â”‚       â””â”€â”€ 3.5.3 XÃ³a thÃ nh viÃªn khá»i workspace
â”‚
â”œâ”€â”€ 4. Quáº£n lÃ½ Báº£ng (Board)
â”‚   â”œâ”€â”€ 4.1 Táº¡o báº£ng má»›i (cÃ¡ nhÃ¢n / trong workspace)
â”‚   â”œâ”€â”€ 4.2 Xem danh sÃ¡ch báº£ng
â”‚   â”‚   â”œâ”€â”€ 4.2.1 Báº£ng gáº§n Ä‘Ã¢y (Recent Boards)
â”‚   â”‚   â”œâ”€â”€ 4.2.2 Báº£ng cÃ¡ nhÃ¢n
â”‚   â”‚   â””â”€â”€ 4.2.3 Báº£ng trong workspace nhÃ³m
â”‚   â”œâ”€â”€ 4.3 Chá»‰nh sá»­a báº£ng
â”‚   â”‚   â”œâ”€â”€ 4.3.1 Äá»•i tÃªn báº£ng
â”‚   â”‚   â”œâ”€â”€ 4.3.2 Thay Ä‘á»•i phÃ´ng ná»n (áº£nh / mÃ u sáº¯c tá»« Cloudinary)
â”‚   â”‚   â””â”€â”€ 4.3.3 Thay Ä‘á»•i quyá»n hiá»ƒn thá»‹ (Private / Public / Workspace)
â”‚   â”œâ”€â”€ 4.4 Chuyá»ƒn báº£ng sang workspace khÃ¡c (Transfer)
â”‚   â”œâ”€â”€ 4.5 XÃ³a / LÆ°u trá»¯ báº£ng
â”‚   â””â”€â”€ 4.6 Quáº£n lÃ½ thÃ nh viÃªn báº£ng
â”‚       â”œâ”€â”€ 4.6.1 ThÃªm thÃ nh viÃªn vÃ o báº£ng
â”‚       â”œâ”€â”€ 4.6.2 Cáº­p nháº­t vai trÃ² thÃ nh viÃªn (Owner / Admin / Member / Guest)
â”‚       â””â”€â”€ 4.6.3 XÃ³a thÃ nh viÃªn khá»i báº£ng
â”‚
â”œâ”€â”€ 5. Quáº£n lÃ½ Danh sÃ¡ch (List / Column)
â”‚   â”œâ”€â”€ 5.1 Táº¡o danh sÃ¡ch má»›i trong báº£ng
â”‚   â”œâ”€â”€ 5.2 Äá»•i tÃªn danh sÃ¡ch
â”‚   â”œâ”€â”€ 5.3 XÃ³a danh sÃ¡ch
â”‚   â””â”€â”€ 5.4 Sáº¯p xáº¿p láº¡i thá»© tá»± cÃ¡c danh sÃ¡ch (kÃ©o-tháº£ / reorder)
â”‚
â”œâ”€â”€ 6. Quáº£n lÃ½ Tháº» CÃ´ng viá»‡c (Card)
â”‚   â”œâ”€â”€ 6.1 Táº¡o tháº» má»›i trong danh sÃ¡ch
â”‚   â”œâ”€â”€ 6.2 Xem chi tiáº¿t tháº»
â”‚   â”œâ”€â”€ 6.3 Chá»‰nh sá»­a tháº»
â”‚   â”‚   â”œâ”€â”€ 6.3.1 Äá»•i tiÃªu Ä‘á» / mÃ´ táº£
â”‚   â”‚   â”œâ”€â”€ 6.3.2 Äáº·t ngÃ y háº¿t háº¡n (Due date)
â”‚   â”‚   â”œâ”€â”€ 6.3.3 Thay Ä‘á»•i tráº¡ng thÃ¡i tháº» (To Do / In Progress / Completed)
â”‚   â”‚   â””â”€â”€ 6.3.4 Äáº·t phÃ´ng ná»n tháº»
â”‚   â”œâ”€â”€ 6.4 Di chuyá»ƒn tháº»
â”‚   â”‚   â”œâ”€â”€ 6.4.1 KÃ©o-tháº£ giá»¯a cÃ¡c danh sÃ¡ch trong cÃ¹ng báº£ng
â”‚   â”‚   â””â”€â”€ 6.4.2 Sáº¯p xáº¿p láº¡i vá»‹ trÃ­ trong danh sÃ¡ch
â”‚   â”œâ”€â”€ 6.5 PhÃ¢n cÃ´ng ngÆ°á»i thá»±c hiá»‡n (Card Member)
â”‚   â”‚   â”œâ”€â”€ 6.5.1 ThÃªm thÃ nh viÃªn vÃ o tháº»
â”‚   â”‚   â””â”€â”€ 6.5.2 XÃ³a thÃ nh viÃªn khá»i tháº»
â”‚   â”œâ”€â”€ 6.6 Gáº¯n nhÃ£n mÃ u (Label)
â”‚   â”‚   â”œâ”€â”€ 6.6.1 ThÃªm nhÃ£n vÃ o tháº»
â”‚   â”‚   â””â”€â”€ 6.6.2 Gá»¡ nhÃ£n khá»i tháº»
â”‚   â”œâ”€â”€ 6.7 Danh sÃ¡ch viá»‡c cáº§n lÃ m (Todo Items / Checklist)
â”‚   â”‚   â”œâ”€â”€ 6.7.1 ThÃªm todo item
â”‚   â”‚   â”œâ”€â”€ 6.7.2 ÄÃ¡nh dáº¥u hoÃ n thÃ nh
â”‚   â”‚   â””â”€â”€ 6.7.3 XÃ³a todo item
â”‚   â”œâ”€â”€ 6.8 BÃ¬nh luáº­n trÃªn tháº»
â”‚   â”‚   â”œâ”€â”€ 6.8.1 Viáº¿t bÃ¬nh luáº­n
â”‚   â”‚   â”œâ”€â”€ 6.8.2 Chá»‰nh sá»­a bÃ¬nh luáº­n
â”‚   â”‚   â””â”€â”€ 6.8.3 XÃ³a bÃ¬nh luáº­n
â”‚   â”œâ”€â”€ 6.9 ÄÃ­nh kÃ¨m tá»‡p tin (File Attachment)
â”‚   â”‚   â”œâ”€â”€ 6.9.1 Táº£i tá»‡p lÃªn (Cloudinary)
â”‚   â”‚   â””â”€â”€ 6.9.2 XÃ³a tá»‡p Ä‘Ã­nh kÃ¨m
â”‚   â””â”€â”€ 6.10 XÃ³a tháº»
â”‚
â”œâ”€â”€ 7. Há»™p thÆ° Ä‘áº¿n (Inbox / UserInboxCard)
â”‚   â”œâ”€â”€ 7.1 Xem danh sÃ¡ch tháº» Ä‘Æ°á»£c phÃ¢n cÃ´ng
â”‚   â””â”€â”€ 7.2 Äiá»u hÆ°á»›ng Ä‘áº¿n tháº» tá»« inbox
â”‚
â”œâ”€â”€ 8. ThÃ´ng bÃ¡o (Notification)
â”‚   â”œâ”€â”€ 8.1 Nháº­n thÃ´ng bÃ¡o khi cÃ³ thay Ä‘á»•i liÃªn quan
â”‚   â”œâ”€â”€ 8.2 Xem danh sÃ¡ch thÃ´ng bÃ¡o chÆ°a Ä‘á»c
â”‚   â””â”€â”€ 8.3 ÄÃ¡nh dáº¥u thÃ´ng bÃ¡o Ä‘Ã£ Ä‘á»c
â”‚
â””â”€â”€ 9. [TÆ°Æ¡ng lai] CÃ¡c tÃ­nh nÄƒng má»Ÿ rá»™ng
    â”œâ”€â”€ 9.1 Lá»‹ch (Calendar view) â€“ xem card theo due date
    â”œâ”€â”€ 9.2 TÃ­ch há»£p chatbot / AI
    â”œâ”€â”€ 9.3 BÃ¡o cÃ¡o & thá»‘ng kÃª tiáº¿n Ä‘á»™
    â”œâ”€â”€ 9.4 TÃ­ch há»£p API bÃªn thá»© ba (Zapier, Slackâ€¦)
    â””â”€â”€ 9.5 ThÃ´ng bÃ¡o nháº¯c viá»‡c (Reminder / Push Notification)
```

---

## 1.2 Báº£ng PhÃ¢n TÃ­ch: Tiáº¿n TrÃ¬nh, TÃ¡c NhÃ¢n vÃ  Há»“ SÆ¡

| STT | Tiáº¿n trÃ¬nh | TÃ¡c nhÃ¢n chÃ­nh | TÃ¡c nhÃ¢n phá»¥ | Há»“ sÆ¡ Ä‘áº§u vÃ o | Há»“ sÆ¡ Ä‘áº§u ra |
|-----|-----------|---------------|--------------|---------------|--------------|
| 1 | ÄÄƒng kÃ½ / XÃ¡c minh email | NgÆ°á»i dÃ¹ng má»›i | Há»‡ thá»‘ng email | ThÃ´ng tin Ä‘Äƒng kÃ½ | TÃ i khoáº£n + email xÃ¡c nháº­n |
| 2 | ÄÄƒng nháº­p (JWT) | NgÆ°á»i dÃ¹ng | Há»‡ thá»‘ng JWT | Email + máº­t kháº©u | Access token + Refresh token |
| 3 | XÃ¡c thá»±c 2FA | NgÆ°á»i dÃ¹ng | Há»‡ thá»‘ng TOTP | OTP code / backup code | PhiÃªn Ä‘Äƒng nháº­p há»£p lá»‡ |
| 4 | Táº¡o Workspace | Chá»§ sá»Ÿ há»¯u | â€” | TÃªn & mÃ´ táº£ workspace | Workspace má»›i |
| 5 | Má»i thÃ nh viÃªn Workspace | Chá»§ sá»Ÿ há»¯u / Admin | NgÆ°á»i Ä‘Æ°á»£c má»i | UserUId + Role | WorkspaceMember record |
| 6 | Táº¡o Board | NgÆ°á»i dÃ¹ng | â€” | TÃªn, workspace, background | Board má»›i |
| 7 | Chuyá»ƒn Board sang Workspace | Owner cá»§a Board | â€” | BoardId + WorkspaceId Ä‘Ã­ch | Board Ä‘Æ°á»£c cáº­p nháº­t workspace |
| 8 | Táº¡o List | Admin / Member Board | â€” | TÃªn danh sÃ¡ch | List má»›i trong Board |
| 9 | Táº¡o Card | ThÃ nh viÃªn Board | â€” | TiÃªu Ä‘á» + ListId | Card má»›i |
| 10 | KÃ©o-tháº£ Card | ThÃ nh viÃªn Board | â€” | CardId + ListId Ä‘Ã­ch + vá»‹ trÃ­ | Card Ä‘Æ°á»£c cáº­p nháº­t vá»‹ trÃ­ |
| 11 | KÃ©o-tháº£ List | Admin Board | â€” | ListId + vá»‹ trÃ­ má»›i | Thá»© tá»± lists Ä‘Æ°á»£c cáº­p nháº­t |
| 12 | PhÃ¢n cÃ´ng thÃ nh viÃªn Card | ThÃ nh viÃªn Board | NgÆ°á»i Ä‘Æ°á»£c phÃ¢n cÃ´ng | CardId + UserUId | CardMember record + Notification |
| 13 | BÃ¬nh luáº­n trÃªn Card | ThÃ nh viÃªn Board | â€” | CardId + Ná»™i dung | Comment record |
| 14 | ÄÃ­nh kÃ¨m tá»‡p | ThÃ nh viÃªn Board | Cloudinary | CardId + File | FileUrl record |
| 15 | HoÃ n thÃ nh Todo Item | ThÃ nh viÃªn Board | â€” | TodoItemId + tráº¡ng thÃ¡i | TodoItem cáº­p nháº­t |
| 16 | Xem Báº£ng Gáº§n ÄÃ¢y | NgÆ°á»i dÃ¹ng | â€” | UserUId | Danh sÃ¡ch 4 Board gáº§n nháº¥t |
| 17 | Nháº­n & Ä‘á»c Notification | NgÆ°á»i dÃ¹ng | â€” | UserUId | Danh sÃ¡ch thÃ´ng bÃ¡o |
| 18 | Táº£i lÃªn / thay Ä‘á»•i Avatar | NgÆ°á»i dÃ¹ng | Cloudinary | File áº£nh | AvatarUrl |
| 19 | XÃ³a Board / List / Card | Owner / Admin | â€” | Entity ID | XÃ³a khá»i DB |
| 20 | Ghi nháº­t kÃ½ hoáº¡t Ä‘á»™ng | Há»‡ thá»‘ng | â€” | HÃ nh Ä‘á»™ng + Actor | Activity record |

---

## 1.3 Biá»ƒu Äá»“ Luá»“ng Dá»¯ Liá»‡u (DFD)

### Má»©c 0 â€“ Ngá»¯ cáº£nh (Context Diagram)

```mermaid
graph LR
    U(( NgÆ°á»i dÃ¹ng))
    A(( Admin Workspace<br>/Board))
    E(( Email Server))
    C(( Cloudinary CDN))

    U -- "ÄÄƒng nháº­p/ÄÄƒng kÃ½\nQuáº£n lÃ½ tháº»/báº£ng\nBÃ¬nh luáº­n/PhÃ¢n cÃ´ng" --> SYS[ Kabo System]
    A -- "Quáº£n lÃ½ workspace\nPhÃ¢n quyá»n thÃ nh viÃªn\nChuyá»ƒn board" --> SYS
    SYS -- "JWT Token\nThÃ´ng bÃ¡o\nDá»¯ liá»‡u báº£ng/tháº»" --> U
    SYS -- "Gá»­i OTP/XÃ¡c minh\nEmail thÃ´ng bÃ¡o" --> E
    E -- "Káº¿t quáº£ xÃ¡c minh" --> SYS
    SYS -- "Upload file/áº£nh" --> C
    C -- "URL media" --> SYS
```

---

### Má»©c 1 â€“ Äá»‰nh (Level 0 DFD)

```mermaid
graph TB
    U((NgÆ°á»i dÃ¹ng))
    A((Admin))

    P1[1.0\nXÃ¡c thá»±c &\nTÃ i khoáº£n]
    P2[2.0\nQuáº£n lÃ½\nWorkspace]
    P3[3.0\nQuáº£n lÃ½\nBoard]
    P4[4.0\nQuáº£n lÃ½\nList & Card]
    P5[5.0\nThÃ´ng bÃ¡o &\nHoáº¡t Ä‘á»™ng]

    DS1[(D1: Users)]
    DS2[(D2: Workspaces\n& Members)]
    DS3[(D3: Boards\n& BoardMembers)]
    DS4[(D4: Lists\n& Cards)]
    DS5[(D5: Notifications\n& Activities)]

    U -- "ThÃ´ng tin Ä‘Äƒng nháº­p" --> P1
    P1 -- "LÆ°u/truy váº¥n user" --> DS1
    P1 -- "Token há»£p lá»‡" --> U

    A --> P2
    P2 -- "CRUD workspace/members" --> DS2
    P2 -- "Danh sÃ¡ch workspace" --> U

    U --> P3
    A --> P3
    P3 -- "CRUD board/members" --> DS3
    P3 -- "Äá»c workspace" --> DS2
    P3 -- "Danh sÃ¡ch board" --> U

    U --> P4
    P4 -- "CRUD list/card/comment/todo" --> DS4
    P4 -- "Äá»c board" --> DS3
    P4 -- "Káº¿t quáº£" --> U

    P4 -- "Ghi hoáº¡t Ä‘á»™ng" --> DS5
    P3 -- "Ghi hoáº¡t Ä‘á»™ng" --> DS5
    P5 -- "Äá»c/Ghi thÃ´ng bÃ¡o" --> DS5
    P5 -- "Push notification" --> U
```

---

### Má»©c 2 â€“ DÆ°á»›i Äá»‰nh: Tiáº¿n trÃ¬nh 1.0 â€“ Quáº£n lÃ½ NgÆ°á»i dÃ¹ng (User)

```mermaid
graph TB
    U((NgÆ°á»i dÃ¹ng))
    E((Email Server))
    C((Cloudinary))

    P11[1.1\nÄÄƒng kÃ½\n& XÃ¡c minh Email]
    P12[1.2\nÄÄƒng nháº­p\n& Cáº¥p Token]
    P13[1.3\nXÃ¡c thá»±c\n2FA]
    P14[1.4\nQuáº£n lÃ½\nHá»“ sÆ¡]
    P15[1.5\nÄáº·t láº¡i\nMáº­t kháº©u]

    DS1[(D1: Users\n& Sessions)]
    DS2[(D2: UserOtp\n& BackupCodes)]

    U -- "ThÃ´ng tin Ä‘Äƒng kÃ½" --> P11
    P11 -- "LÆ°u User (chÆ°a xÃ¡c minh)" --> DS1
    P11 -- "Gá»­i OTP xÃ¡c minh" --> E
    E -- "Token xÃ¡c minh" --> P11
    P11 -- "KÃ­ch hoáº¡t tÃ i khoáº£n" --> DS1
    P11 -- "ÄÄƒng kÃ½ thÃ nh cÃ´ng" --> U

    U -- "Email + Password" --> P12
    P12 -- "Äá»c User" --> DS1
    P12 -- "Táº¡o JWT + LÆ°u Session" --> DS1
    P12 -- "Access/Refresh Token" --> U

    U -- "OTP / Backup Code" --> P13
    P13 -- "Äá»c Secret / BackupCode" --> DS2
    P13 -- "XÃ¡c nháº­n / Huá»· BackupCode" --> DS2
    P13 -- "PhiÃªn há»£p lá»‡" --> U

    U -- "ThÃ´ng tin cáº­p nháº­t / Avatar" --> P14
    P14 -- "Upload avatar" --> C
    C -- "AvatarUrl" --> P14
    P14 -- "UPDATE User" --> DS1
    P14 -- "Há»“ sÆ¡ má»›i" --> U

    U -- "Email" --> P15
    P15 -- "Táº¡o OTP" --> DS2
    P15 -- "Gá»­i email Ä‘áº·t láº¡i" --> E
    P15 -- "Cáº­p nháº­t PasswordHash" --> DS1
    P15 -- "XÃ¡c nháº­n thÃ nh cÃ´ng" --> U
```

---

### Má»©c 2 â€“ DÆ°á»›i Äá»‰nh: Tiáº¿n trÃ¬nh 2.0 â€“ Quáº£n lÃ½ Workspace

```mermaid
graph TB
    OW((Admin\nWorkspace))
    U((ThÃ nh viÃªn))

    P21[2.1\nTáº¡o / Sá»­a / XÃ³a\nWorkspace]
    P22[2.2\nQuáº£n lÃ½\nThÃ nh viÃªn WS]
    P23[2.3\nXem danh sÃ¡ch\nWorkspace]

    DS1[(D1: Users)]
    DS2[(D2: Workspaces)]
    DS3[(D3: WorkspaceMembers)]
    DS5[(D5: Notifications)]

    OW -- "TÃªn, mÃ´ táº£" --> P21
    P21 -- "CRUD Workspace" --> DS2
    P21 -- "Káº¿t quáº£" --> OW

    OW -- "UserUId + Role" --> P22
    P22 -- "Äá»c User" --> DS1
    P22 -- "INSERT / UPDATE / DELETE WorkspaceMember" --> DS3
    P22 -- "INSERT Notification (má»i/xoÃ¡)" --> DS5
    P22 -- "Káº¿t quáº£" --> OW

    U -- "UserUId" --> P23
    P23 -- "SELECT Workspaces WHERE member" --> DS3
    P23 -- "Äá»c thÃ´ng tin WS" --> DS2
    P23 -- "Danh sÃ¡ch workspace" --> U
```

---

### Má»©c 2 â€“ DÆ°á»›i Äá»‰nh: Tiáº¿n trÃ¬nh 3.0 â€“ Quáº£n lÃ½ Board

```mermaid
graph TB
    OW((Owner\nBoard))
    MB((ThÃ nh viÃªn\nBoard))
    C((Cloudinary))

    P31[3.1\nTáº¡o / Sá»­a / XÃ³a\nBoard]
    P32[3.2\nXem danh sÃ¡ch\nBoard]
    P33[3.3\nThay Ä‘á»•i\nBackground]
    P34[3.4\nChuyá»ƒn Board\nsang Workspace]
    P35[3.5\nQuáº£n lÃ½\nThÃ nh viÃªn Board]

    DS2[(D2: Workspaces\n& WsMembers)]
    DS3[(D3: Boards)]
    DS4[(D4: BoardMembers)]
    DS6[(D6: UserRecentBoards)]
    DS5[(D5: Notifications)]

    OW -- "TÃªn, visibility, workspace" --> P31
    P31 -- "CRUD Board" --> DS3
    P31 -- "Káº¿t quáº£" --> OW

    MB -- "UserUId" --> P32
    P32 -- "SELECT cÃ¡ nhÃ¢n + workspace" --> DS3
    P32 -- "Äá»c RecentBoards" --> DS6
    P32 -- "Danh sÃ¡ch Board" --> MB

    OW -- "File / URL áº£nh" --> P33
    P33 -- "Upload" --> C
    C -- "BackgroundUrl" --> P33
    P33 -- "UPDATE Board.BackgroundUrl" --> DS3
    P33 -- "URL má»›i" --> OW

    OW -- "BoardId + WorkspaceId Ä‘Ã­ch" --> P34
    P34 -- "Kiá»ƒm tra quyá»n Owner" --> DS4
    P34 -- "UPDATE Board (WorkspaceUId / IsPersonal)" --> DS3
    P34 -- "INSERT WsMembers (thÃ nh viÃªn chÆ°a cÃ³)" --> DS2
    P34 -- "Káº¿t quáº£" --> OW

    OW -- "UserUId + Role" --> P35
    P35 -- "INSERT / UPDATE / DELETE BoardMember" --> DS4
    P35 -- "INSERT Notification" --> DS5
    P35 -- "Káº¿t quáº£" --> OW
```

---

### Má»©c 2 â€“ DÆ°á»›i Äá»‰nh: Tiáº¿n trÃ¬nh 5.0 â€“ ThÃ´ng bÃ¡o & Hoáº¡t Ä‘á»™ng

```mermaid
graph TB
    U((NgÆ°á»i dÃ¹ng))
    SYS((Há»‡ thá»‘ng\n[tiáº¿n trÃ¬nh khÃ¡c]))

    P51[5.1\nTáº¡o &\nGá»­i thÃ´ng bÃ¡o]
    P52[5.2\nXem & Äá»c\nthÃ´ng bÃ¡o]
    P53[5.3\nGhi nháº­t kÃ½\nhoáº¡t Ä‘á»™ng]

    DS5N[(D5a: Notifications)]
    DS5A[(D5b: Activities)]
    DS1[(D1: Users)]

    SYS -- "Sá»± kiá»‡n (phÃ¢n cÃ´ng, má»i, cáº­p nháº­t)" --> P51
    P51 -- "Äá»c thÃ´ng tin recipient" --> DS1
    P51 -- "INSERT Notification" --> DS5N
    P51 -- "ThÃ´ng bÃ¡o realtime" --> U

    U -- "UserUId" --> P52
    P52 -- "SELECT Notifications WHERE recipientId" --> DS5N
    P52 -- "Danh sÃ¡ch thÃ´ng bÃ¡o" --> U
    U -- "ÄÃ¡nh dáº¥u Ä‘Ã£ Ä‘á»c" --> P52
    P52 -- "UPDATE Notification.Read = true" --> DS5N

    SYS -- "HÃ nh Ä‘á»™ng + Actor" --> P53
    P53 -- "INSERT Activity" --> DS5A
    U -- "UserUId" --> P53
    P53 -- "SELECT Activities" --> DS5A
    P53 -- "Lá»‹ch sá»­ hoáº¡t Ä‘á»™ng" --> U
```

---

### Má»©c 2 â€“ DÆ°á»›i Äá»‰nh: Tiáº¿n trÃ¬nh 6.0 â€“ Há»™p thÆ° Ä‘áº¿n (Inbox)

```mermaid
graph TB
    U((NgÆ°á»i dÃ¹ng))
    SYS(Há»‡ thá»‘ng\n[CardMember])

    P61[6.1\nThÃªm Card\nvÃ o Inbox]
    P62[6.2\nXem danh sÃ¡ch\nInbox]
    P63[6.3\nÄiá»u hÆ°á»›ng\nÄ‘áº¿n Card]

    DS_IC[(D7: UserInboxCards)]
    DS_C[(D4b: Cards\n& Lists)]
    DS_B[(D3: Boards)]

    SYS -- "CardId + UserUId (Ä‘Æ°á»£c phÃ¢n cÃ´ng)" --> P61
    P61 -- "INSERT UserInboxCard (náº¿u chÆ°a tá»“n táº¡i)" --> DS_IC
    P61 -- "ThÃªm vÃ o inbox" --> U

    U -- "UserUId" --> P62
    P62 -- "SELECT InboxCards JOIN Cards JOIN Lists JOIN Boards" --> DS_IC
    P62 -- "Danh sÃ¡ch tháº» Ä‘Æ°á»£c phÃ¢n cÃ´ng" --> U

    U -- "Chá»n tháº»" --> P63
    P63 -- "Äá»c CardId + BoardId" --> DS_C
    P63 -- "Äiá»u hÆ°á»›ng Ä‘áº¿n Board + Card" --> U
```

---

### Má»©c 2 â€“ DÆ°á»›i Äá»‰nh: Tiáº¿n trÃ¬nh 4.0 â€“ Quáº£n lÃ½ List & Card


```mermaid
graph TB
    U((NgÆ°á»i dÃ¹ng))

    P41[4.1\nQuáº£n lÃ½\nDanh sÃ¡ch]
    P42[4.2\nQuáº£n lÃ½\nTháº»]
    P43[4.3\nQuáº£n lÃ½ ná»™i dung\nTháº» chi tiáº¿t]
    P44[4.4\nDi chuyá»ƒn\nTháº»/Danh sÃ¡ch]

    DS3[(D3: Boards)]
    DS4[(D4: Lists)]
    DS5[(D5: Cards)]
    DS6[(D6: Comments\nTodos\nLabels\nFiles)]

    U -- "Táº¡o/Sá»­a/XÃ³a list" --> P41
    P41 -- "CRUD List" --> DS4
    P41 -- "Äá»c Board" --> DS3

    U -- "Táº¡o/Sá»­a/XÃ³a card" --> P42
    P42 -- "CRUD Card" --> DS5
    P42 -- "Äá»c List" --> DS4

    U -- "BÃ¬nh luáº­n/Todo/Label/File" --> P43
    P43 -- "CRUD ná»™i dung" --> DS6
    P43 -- "Äá»c Card" --> DS5

    U -- "KÃ©o-tháº£" --> P44
    P44 -- "Cáº­p nháº­t position/listId" --> DS5
    P44 -- "Cáº­p nháº­t position list" --> DS4
```

---

## 1.4 Use Case Diagram

```mermaid
graph TB
    subgraph Actors
        A(( NgÆ°á»i dÃ¹ng\nmá»›i))
        B(( ThÃ nh viÃªn\nBoard))
        C(( Admin /\nOwner Board))
        D(( Admin\nWorkspace))
    end

    subgraph "XÃ¡c thá»±c & TÃ i khoáº£n"
        UC1[ÄÄƒng kÃ½ tÃ i khoáº£n]
        UC2[ÄÄƒng nháº­p]
        UC3[XÃ¡c thá»±c 2FA]
        UC4[Äáº·t láº¡i máº­t kháº©u]
        UC5[Cáº­p nháº­t há»“ sÆ¡]
    end

    subgraph "Workspace"
        UC6[Táº¡o workspace]
        UC7[Xem/Sá»­a workspace]
        UC8[Quáº£n lÃ½ thÃ nh viÃªn WS]
    end

    subgraph "Board"
        UC9[Táº¡o board]
        UC10[Xem danh sÃ¡ch board]
        UC11[Äá»•i tÃªn / Background board]
        UC12[Thay Ä‘á»•i Visibility]
        UC13[Chuyá»ƒn Board sang WS khÃ¡c]
        UC14[Quáº£n lÃ½ thÃ nh viÃªn Board]
    end

    subgraph "List & Card"
        UC15[Táº¡o / Sáº¯p xáº¿p List]
        UC16[Táº¡o / Xem Card]
        UC17[Chá»‰nh sá»­a Card]
        UC18[KÃ©o-tháº£ Card / List]
        UC19[PhÃ¢n cÃ´ng thÃ nh viÃªn Card]
        UC20[Gáº¯n nhÃ£n Label]
        UC21[ThÃªm Checklist / Todo]
        UC22[BÃ¬nh luáº­n]
        UC23[ÄÃ­nh kÃ¨m tá»‡p]
    end

    subgraph "ThÃ´ng bÃ¡o"
        UC24[Nháº­n thÃ´ng bÃ¡o]
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

### 1.4.1 Äáº·c táº£ chi tiáº¿t cÃ¡c Use Case

#### NhÃ³m 1: XÃ¡c thá»±c vÃ  TÃ i khoáº£n

```mermaid
graph TB
    subgraph "XÃ¡c thá»±c & TÃ i khoáº£n"
        UC1(UC1: ÄÄƒng kÃ½)
        UC2(UC2: ÄÄƒng nháº­p)
        UC3(UC3: XÃ¡c thá»±c 2FA)
        UC4(UC4: Äáº·t láº¡i máº­t kháº©u)
        UC5(UC5: Cáº­p nháº­t há»“ sÆ¡)
        UC1 -.->|include| UC1a(XÃ¡c minh Email)
        UC2 -.->|extend| UC3
    end
    U((NgÆ°á»i dÃ¹ng))
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

**UC1: ÄÄƒng kÃ½ tÃ i khoáº£n**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng má»›i.
- **Tiá»n Ä‘iá»u kiá»‡n:** NgÆ°á»i dÃ¹ng chÆ°a cÃ³ tÃ i khoáº£n hoáº·c email chÆ°a Ä‘Æ°á»£c Ä‘Äƒng kÃ½.
- **Háº­u Ä‘iá»u kiá»‡n:** TÃ i khoáº£n Ä‘Æ°á»£c táº¡o vÃ  á»Ÿ tráº¡ng thÃ¡i "Chá» xÃ¡c minh" hoáº·c "ÄÃ£ kÃ­ch hoáº¡t".
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng chá»n chá»©c nÄƒng ÄÄƒng kÃ½.
  2. Há»‡ thá»‘ng hiá»ƒn thá»‹ form nháº­p: TÃªn, Email, Máº­t kháº©u.
  3. NgÆ°á»i dÃ¹ng nháº­p thÃ´ng tin vÃ  nháº¥n "ÄÄƒng kÃ½".
  4. Há»‡ thá»‘ng kiá»ƒm tra há»£p lá»‡: Email Ä‘Ãºng Ä‘á»‹nh dáº¡ng, chÆ°a tá»“n táº¡i, máº­t kháº©u Ä‘á»§ Ä‘á»™ máº¡nh.
  5. Há»‡ thá»‘ng gá»­i mÃ£ OTP xÃ¡c nháº­n vá» email cá»§a ngÆ°á»i dÃ¹ng.
  6. NgÆ°á»i dÃ¹ng nháº­p mÃ£ OTP vÃ o á»©ng dá»¥ng.
  7. Há»‡ thá»‘ng xÃ¡c thá»±c mÃ£ vÃ  kÃ­ch hoáº¡t tÃ i khoáº£n.
- **Ngoáº¡i lá»‡:** Email Ä‘Ã£ tá»“n táº¡i -> Há»‡ thá»‘ng yÃªu cáº§u Ä‘Äƒng nháº­p hoáº·c dÃ¹ng email khÃ¡c.

**UC2: ÄÄƒng nháº­p**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng nháº­p Email vÃ  Máº­t kháº©u.
  2. Há»‡ thá»‘ng kiá»ƒm tra thÃ´ng tin Ä‘Äƒng nháº­p trong DB.
  3. Náº¿u chÃ­nh xÃ¡c, há»‡ thá»‘ng kiá»ƒm tra cÃ i Ä‘áº·t 2FA.
  4. Náº¿u khÃ´ng báº­t 2FA, há»‡ thá»‘ng táº¡o mÃ£ JWT (AccessToken & RefreshToken) vÃ  tráº£ vá» cho App.
  5. Náº¿u báº­t 2FA, chuyá»ƒn sang UC3.
- **Ngoáº¡i lá»‡:** Sai máº­t kháº©u quÃ¡ 5 láº§n -> KhÃ³a tÃ i khoáº£n táº¡m thá»i.

**UC3: XÃ¡c thá»±c 2FA**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. Sau khi nháº­p Ä‘Ãºng email/máº­t kháº©u, há»‡ thá»‘ng yÃªu cáº§u mÃ£ xÃ¡c thá»±c.
  2. NgÆ°á»i dÃ¹ng má»Ÿ app xÃ¡c thá»±c (Google Authenticator) hoáº·c kiá»ƒm tra email láº¥y mÃ£.
  3. NgÆ°á»i dÃ¹ng nháº­p mÃ£ vÃ o há»‡ thá»‘ng.
  4. Há»‡ thá»‘ng kiá»ƒm tra mÃ£ há»£p lá»‡ vÃ  cáº¥p quyá»n truy cáº­p.

**UC4: Äáº·t láº¡i máº­t kháº©u**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng chá»n "QuÃªn máº­t kháº©u" táº¡i mÃ n hÃ¬nh Ä‘Äƒng nháº­p.
  2. Nháº­p email Ä‘Äƒng kÃ½.
  3. Há»‡ thá»‘ng kiá»ƒm tra sá»± tá»“n táº¡i cá»§a email vÃ  gá»­i link/mÃ£ Ä‘áº·t láº¡i máº­t kháº©u.
  4. NgÆ°á»i dÃ¹ng sá»­ dá»¥ng link/mÃ£ Ä‘á»ƒ nháº­p máº­t kháº©u má»›i.
  5. Há»‡ thá»‘ng cáº­p nháº­t PasswordHash má»›i vÃ o DB.

**UC5: Cáº­p nháº­t há»“ sÆ¡**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng truy cáº­p "CÃ i Ä‘áº·t tÃ i khoáº£n".
  2. Thay Ä‘á»•i thÃ´ng tin: TÃªn hiá»ƒn thá»‹, Bio, hoáº·c táº£i lÃªn áº£nh Ä‘áº¡i diá»‡n má»›i.
  3. Há»‡ thá»‘ng táº£i áº£nh lÃªn Cloudinary (náº¿u cÃ³) vÃ  lÆ°u URL vÃ o DB.
  4. Pháº£n há»“i cáº­p nháº­t thÃ nh cÃ´ng.

#### NhÃ³m 2: Quáº£n lÃ½ KhÃ´ng gian lÃ m viá»‡c (Workspace)

```mermaid
graph TB
    subgraph "Workspace"
        UC6(UC6: Táº¡o Workspace)
        UC7(UC7: Xem/Sá»­a Workspace)
        UC8(UC8: Quáº£n lÃ½ thÃ nh viÃªn)
    end
    A((Admin WS))
    O((Owner WS))
    M((ThÃ nh viÃªn))
    
    A --> UC6
    A --> UC7
    O --> UC8
    UC8 -- "Má»i/XÃ³a" --- M
```

**UC6: Táº¡o Workspace**
- **TÃ¡c nhÃ¢n:** Admin Workspace.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng nháº¥n "Táº¡o Workspace má»›i".
  2. Nháº­p tÃªn Workspace, loáº¡i hÃ¬nh vÃ  mÃ´ táº£.
  3. Há»‡ thá»‘ng táº¡o báº£n ghi Workspace vÃ  máº·c Ä‘á»‹nh gÃ¡n ngÆ°á»i táº¡o lÃ  "Owner".
  4. Workspace hiá»ƒn thá»‹ trÃªn danh sÃ¡ch bÃªn trÃ¡i.

**UC7: Xem/Sá»­a Workspace**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn (Xem), Admin (Sá»­a).
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng chá»n má»™t Workspace tá»« danh sÃ¡ch.
  2. Há»‡ thá»‘ng hiá»ƒn thá»‹ thÃ´ng tin chung vÃ  danh sÃ¡ch cÃ¡c báº£ng bÃªn trong.
  3. Admin cÃ³ thá»ƒ sá»­a tÃªn hoáº·c xÃ³a Workspace (chá»‰ dÃ nh cho Owner).

**UC8: Quáº£n lÃ½ thÃ nh viÃªn Workspace**
- **TÃ¡c nhÃ¢n:** Admin Workspace.
- **Luá»“ng sá»± kiá»‡n:**
  1. Admin má»Ÿ tab "Members" trong Workspace.
  2. Nháº¥n "Invite" vÃ  nháº­p Email cá»§a thÃ nh viÃªn muá»‘n má»i.
  3. Há»‡ thá»‘ng kiá»ƒm tra User hiá»‡n cÃ³ vÃ  gá»­i thÃ´ng bÃ¡o má»i.
  4. Admin cÃ³ thá»ƒ thay Ä‘á»•i vai trÃ² (Admin/Member) hoáº·c xÃ³a thÃ nh viÃªn khá»i WS.

#### NhÃ³m 3: Quáº£n lÃ½ Báº£ng (Board)

```mermaid
graph TB
    subgraph "Board Management"
        UC9(UC9: Táº¡o Board)
        UC10(UC10: Danh sÃ¡ch Board)
        UC11(UC11: Chá»‰nh sá»­a Board)
        UC12(UC12: Visibility)
        UC13(UC13: Chuyá»ƒn Workspace)
        UC14(UC14: Quáº£n lÃ½ thÃ nh viÃªn)
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

**UC9: Táº¡o Board**
- **TÃ¡c nhÃ¢n:** Owner/Admin Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng nháº¥n "Create Board".
  2. Nháº­p tÃªn Board, chá»n Background (MÃ u hoáº·c áº¢nh tá»« thÆ° viá»‡n Cloudinary).
  3. Chá»n Workspace Ä‘á»ƒ chá»©a Board (hoáº·c chá»n No Workspace cho Board cÃ¡ nhÃ¢n).
  4. Chá»n quyá»n hiá»ƒn thá»‹ (Private, Workspace, Public).
  5. Há»‡ thá»‘ng khá»Ÿi táº¡o Board vÃ  3 List máº·c Ä‘á»‹nh (To Do, Doing, Done).

**UC10: Xem danh sÃ¡ch Board**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. Há»‡ thá»‘ng tá»± Ä‘á»™ng táº£i danh sÃ¡ch Board ngÆ°á»i dÃ¹ng cÃ³ quyá»n truy cáº­p.
  2. PhÃ¢n loáº¡i theo: Board gáº§n Ä‘Ã¢y, Starred Boards, vÃ  Board theo tá»«ng Workspace.

**UC11: Chá»‰nh sá»­a trang trÃ­ Board**
- **TÃ¡c nhÃ¢n:** Admin Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Truy cáº­p cÃ i Ä‘áº·t Board.
  2. Thay Ä‘á»•i tÃªn Board hoáº·c chá»n Background má»›i.
  3. Há»‡ thá»‘ng cáº­p nháº­t giao diá»‡n ngay láº­p tá»©c cho táº¥t cáº£ ngÆ°á»i dÃ¹ng Ä‘ang xem.

**UC12: Thay Ä‘á»•i Visibility**
- **TÃ¡c nhÃ¢n:** Admin Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Admin thay Ä‘á»•i tráº¡ng thÃ¡i tá»« Private sang Workspace hoáº·c Public.
  2. Há»‡ thá»‘ng cáº­p nháº­t quyá»n truy cáº­p: Public cho phÃ©p má»i ngÆ°á»i xem, Workspace cho phÃ©p thÃ nh viÃªn WS xem.

**UC13: Chuyá»ƒn Board sang Workspace khÃ¡c**
- **TÃ¡c nhÃ¢n:** Owner Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Chá»n chá»©c nÄƒng "Move Board".
  2. Chá»n Workspace Ä‘Ã­ch.
  3. Há»‡ thá»‘ng cáº­p nháº­t WorkspaceUId cá»§a Board vÃ  thÃ´ng bÃ¡o cho cÃ¡c thÃ nh viÃªn liÃªn quan.

**UC14: Quáº£n lÃ½ thÃ nh viÃªn Board**
- **TÃ¡c nhÃ¢n:** Admin Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Chá»n "Members" trong Board.
  2. TÃ¬m kiáº¿m thÃ nh viÃªn theo tÃªn hoáº·c email.
  3. ThÃªm thÃ nh viÃªn vÃ o Board vÃ  gÃ¡n vai trÃ².
  4. Há»‡ thá»‘ng táº¡o thÃ´ng bÃ¡o má»i tham gia Board.

#### NhÃ³m 4: Quáº£n lÃ½ List & Card

```mermaid
graph TB
    subgraph "List & Card"
        UC15(UC15: Quáº£n lÃ½ List)
        UC16(UC16: Táº¡o/Xem Card)
        UC17(UC17: Chá»‰nh sá»­a Card)
        UC18(UC18: Di chuyá»ƒn Card)
        UC19(UC19: PhÃ¢n cÃ´ng)
        UC20(UC20: Gáº¯n nhÃ£n)
        UC21(UC21: Checklist/Todo)
        UC22(UC22: BÃ¬nh luáº­n)
        UC23(UC23: ÄÃ­nh kÃ¨m)
    end
    M((ThÃ nh viÃªn))
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

**UC15: Táº¡o / Sáº¯p xáº¿p List**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Nháº¥n "Add List" á»Ÿ cuá»‘i danh sÃ¡ch cÃ¡c cá»™t.
  2. Nháº­p tÃªn List vÃ  Enter.
  3. NgÆ°á»i dÃ¹ng cÃ³ thá»ƒ kÃ©o tháº£ List Ä‘á»ƒ thay Ä‘á»•i thá»© tá»± Æ°u tiÃªn cÃ¡c cá»™t.

**UC16: Táº¡o / Xem Card**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Nháº¥n "Add Card" trong má»™t List cá»¥ thá»ƒ.
  2. Nháº­p tiÃªu Ä‘á» nhanh.
  3. Nháº¥n vÃ o Card Ä‘Ã£ táº¡o Ä‘á»ƒ má»Ÿ mÃ n hÃ¬nh "Card Detail" hiá»ƒn thá»‹ Ä‘áº§y Ä‘á»§ thÃ´ng tin.

**UC17: Chá»‰nh sá»­a Card**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Táº¡i mÃ n hÃ¬nh Card Detail, ngÆ°á»i dÃ¹ng sá»­a tiÃªu Ä‘á» hoáº·c thÃªm mÃ´ táº£ (Markdown support).
  2. Chá»n "Due Date" Ä‘á»ƒ Ä‘áº·t ngÃ y hoÃ n thÃ nh cÃ´ng viá»‡c.
  3. Há»‡ thá»‘ng tá»± Ä‘á»™ng lÆ°u cÃ¡c thay Ä‘á»•i nhá».

**UC18: KÃ©o-tháº£ Card (Di chuyá»ƒn)**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng kÃ©o Card tá»« List A sang List B.
  2. Hoáº·c kÃ©o Card lÃªn/xuá»‘ng trong cÃ¹ng List A Ä‘á»ƒ Ä‘á»•i vá»‹ trÃ­.
  3. Há»‡ thá»‘ng lÆ°u position má»›i vÃ  cáº­p nháº­t ListId tÆ°Æ¡ng á»©ng trong DB.

**UC19: PhÃ¢n cÃ´ng thÃ nh viÃªn Card**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Trong Card Detail, chá»n má»¥c "Members".
  2. Tick chá»n cÃ¡c thÃ nh viÃªn trong Board tham gia tháº» nÃ y.
  3. Há»‡ thá»‘ng táº¡o báº£n ghi `CardMember` vÃ  gá»­i thÃ´ng bÃ¡o cho ngÆ°á»i Ä‘Æ°á»£c phÃ¢n cÃ´ng.

**UC20: Gáº¯n nhÃ£n Label**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Chá»n "Labels".
  2. Chá»n cÃ¡c nhÃ£n mÃ u cÃ³ sáºµn hoáº·c táº¡o nhÃ£n má»›i vá»›i mÃ u sáº¯c tÃ¹y chá»‰nh.
  3. NhÃ£n hiá»ƒn thá»‹ ngay trÃªn máº·t trÆ°á»›c cá»§a Card.

**UC21: ThÃªm Checklist/Todo**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Chá»n "Checklist", nháº­p tÃªn checklist.
  2. ThÃªm cÃ¡c Ä‘áº§u viá»‡c (Todo items).
  3. Khi ngÆ°á»i dÃ¹ng tick hoÃ n thÃ nh, há»‡ thá»‘ng cáº­p nháº­t thanh tiáº¿n Ä‘á»™ (%) cá»§a Card.

**UC22: BÃ¬nh luáº­n (Comment)**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Nháº­p ná»™i dung vÃ o Ã´ Comment phÃ­a dÆ°á»›i Card Detail.
  2. Há»‡ thá»‘ng lÆ°u bÃ¬nh luáº­n kÃ¨m thá»i gian vÃ  thÃ´ng tin ngÆ°á»i viáº¿t.
  3. CÃ¡c thÃ nh viÃªn khÃ¡c theo dÃµi tháº» nÃ y sáº½ nháº­n Ä‘Æ°á»£c thÃ´ng bÃ¡o.

**UC23: ÄÃ­nh kÃ¨m tá»‡p**
- **TÃ¡c nhÃ¢n:** ThÃ nh viÃªn Board.
- **Luá»“ng sá»± kiá»‡n:**
  1. Chá»n "Attachments" -> "Computer".
  2. Chá»n tá»‡p tin.
  3. Há»‡ thá»‘ng upload lÃªn Cloudinary, lÆ°u URL vÃ  hiá»ƒn thá»‹ danh sÃ¡ch tá»‡p Ä‘Ã­nh kÃ¨m trong Card.

#### NhÃ³m 5: ThÃ´ng bÃ¡o & Há»™p thÆ°

```mermaid
graph TB
    subgraph "Notification & Inbox"
        UC24(UC24: Nháº­n thÃ´ng bÃ¡o)
        UC25(UC25: Xem Inbox Card)
    end
    U((NgÆ°á»i dÃ¹ng))
    S((Server API))
    
    S -- "Push" --> UC24
    UC24 --- U
    U --> UC25
```

**UC24: Nháº­n thÃ´ng bÃ¡o**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. Khi cÃ³ sá»± kiá»‡n: ÄÆ°á»£c má»i vÃ o Board/WS, Ä‘Æ°á»£c phÃ¢n cÃ´ng Card, hoáº·c cÃ³ comment má»›i.
  2. Há»‡ thá»‘ng táº¡o báº£n ghi Notification.
  3. NgÆ°á»i dÃ¹ng tháº¥y cháº¥m Ä‘á» táº¡i Icon thÃ´ng bÃ¡o vÃ  cÃ³ thá»ƒ xem danh sÃ¡ch.

**UC25: Xem Inbox Card**
- **TÃ¡c nhÃ¢n:** NgÆ°á»i dÃ¹ng.
- **Luá»“ng sá»± kiá»‡n:**
  1. NgÆ°á»i dÃ¹ng truy cáº­p tab "Inbox".
  2. Há»‡ thá»‘ng hiá»ƒn thá»‹ táº¥t cáº£ cÃ¡c Card mÃ  ngÆ°á»i dÃ¹ng Ä‘Æ°á»£c phÃ¢n cÃ´ng trÃªn toÃ n bá»™ há»‡ thá»‘ng.
  3. NgÆ°á»i dÃ¹ng nháº¥n vÃ o Card Ä‘á»ƒ nháº£y trá»±c tiáº¿p Ä‘áº¿n Board chá»©a Card Ä‘Ã³.

---

## 1.5 Activity Diagram â€“ Quy trÃ¬nh táº¡o vÃ  xá»­ lÃ½ tháº» cÃ´ng viá»‡c

```mermaid
flowchart TD
    Start([Báº¯t Ä‘áº§u]) --> Login[ÄÄƒng nháº­p há»‡ thá»‘ng]
    Login --> Auth{XÃ¡c thá»±c\nthÃ nh cÃ´ng?}
    Auth -- KhÃ´ng --> Login
    Auth -- CÃ³ --> ViewBoard[Má»Ÿ Board]
    ViewBoard --> SelectList[Chá»n Danh sÃ¡ch]
    SelectList --> CreateCard[Nháº¥n Táº¡o tháº» má»›i]
    CreateCard --> EnterTitle[Nháº­p tiÃªu Ä‘á» tháº»]
    EnterTitle --> SaveCard[LÆ°u tháº»]
    SaveCard --> CardDetail{Má»Ÿ Chi tiáº¿t\ntháº»?}
    CardDetail -- KhÃ´ng --> ViewBoard
    CardDetail -- CÃ³ --> AddInfo[ThÃªm thÃ´ng tin]
    AddInfo --> ParallelActions{Thao tÃ¡c}
    ParallelActions --> SetDue[Äáº·t Due Date]
    ParallelActions --> AssignMember[PhÃ¢n cÃ´ng\nthÃ nh viÃªn]
    ParallelActions --> AddLabel[Gáº¯n nhÃ£n]
    ParallelActions --> AddTodo[ThÃªm Checklist]
    ParallelActions --> WriteComment[Viáº¿t bÃ¬nh luáº­n]
    SetDue --> Notify[Há»‡ thá»‘ng gá»­i\nthÃ´ng bÃ¡o]
    AssignMember --> Notify
    Notify --> UpdateStatus{Cáº­p nháº­t\ntráº¡ng thÃ¡i?}
    AddLabel --> UpdateStatus
    AddTodo --> UpdateStatus
    WriteComment --> UpdateStatus
    UpdateStatus -- Drag & Drop --> MoveCard[Di chuyá»ƒn tháº»\ngiá»¯a cÃ¡c list]
    MoveCard --> LogActivity[Ghi nháº­t kÃ½\nhoáº¡t Ä‘á»™ng]
    UpdateStatus -- Xong --> LogActivity
    LogActivity --> End([Káº¿t thÃºc])
```

---

## 1.6 SÆ¡ Ä‘á»“ Tráº¡ng thÃ¡i (State Diagram)

### 1.6.1 Tráº¡ng thÃ¡i TÃ i khoáº£n NgÆ°á»i dÃ¹ng
MÃ´ táº£ vÃ²ng Ä‘á»i cá»§a má»™t tÃ i khoáº£n tá»« khi Ä‘Äƒng kÃ½ Ä‘áº¿n khi hoáº¡t Ä‘á»™ng hoáº·c bá»‹ khÃ³a.

```mermaid
stateDiagram-v2
    [*] --> Unverified: ÄÄƒng kÃ½ thÃ nh cÃ´ng
    Unverified --> Verified: XÃ¡c minh Email (OTP)
    Unverified --> [*]: QuÃ¡ háº¡n xÃ¡c minh
    Verified --> Active: ÄÄƒng nháº­p láº§n Ä‘áº§u
    Active --> Locked: Nháº­p sai máº­t kháº©u > 5 láº§n
    Locked --> Active: Admin má»Ÿ khÃ³a hoáº·c Reset Pass
    Active --> Deactivated: NgÆ°á»i dÃ¹ng tá»± Ä‘Ã³ng tÃ i khoáº£n
    Deactivated --> [*]
```

### 1.6.2 Tráº¡ng thÃ¡i Tháº» cÃ´ng viá»‡c (Card)
MÃ´ táº£ sá»± luÃ¢n chuyá»ƒn cá»§a má»™t tháº» cÃ´ng viá»‡c thÃ´ng qua cÃ¡c tráº¡ng thÃ¡i xá»­ lÃ½.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Created: Táº¡o tháº» má»›i
    Created --> ToDo: ThÃªm vÃ o danh sÃ¡ch chá»
    ToDo --> InProgress: Báº¯t Ä‘áº§u thá»±c hiá»‡n
    InProgress --> InReview: Gá»­i yÃªu cáº§u kiá»ƒm tra
    InReview --> Done: Admin phÃª duyá»‡t
    InReview --> ToDo: Cáº§n sá»­a Ä‘á»•i
    Done --> Archived: LÆ°u trá»¯ (sau khi hoÃ n thÃ nh)
    Archived --> ToDo: KhÃ´i phá»¥c
    Archived --> [*]: XÃ³a vÄ©nh viá»…n
```

---

## 1.7 SÆ¡ Ä‘á»“ BPMN (Business Process Model and Notation)

### 1.7.1 Quy trÃ¬nh xá»­ lÃ½ vÃ  hoÃ n thÃ nh tháº» cÃ´ng viá»‡c
DÆ°á»›i Ä‘Ã¢y lÃ  sÆ¡ Ä‘á»“ quy trÃ¬nh nghiá»‡p vá»¥ phá»‘i há»£p giá»¯a cÃ¡c vai trÃ² trong má»™t Board.

```mermaid
graph TB
    subgraph Member["ThÃ nh viÃªn thá»±c hiá»‡n (Member)"]
        direction TB
        M_Start([Báº¯t Ä‘áº§u]) --> M_Create[Nháº­n viá»‡c / Táº¡o Card]
        M_Create --> M_Work[Thá»±c hiá»‡n cÃ´ng viá»‡c]
        M_Work --> M_Update[Cáº­p nháº­t Checklist/Tá»‡p Ä‘Ã­nh kÃ¨m]
        M_Update --> M_Submit[Chuyá»ƒn tráº¡ng thÃ¡i sang Review]
    end

    subgraph Admin["Quáº£n lÃ½ / NgÆ°á»i duyá»‡t (Admin/Owner)"]
        direction TB
        M_Submit --> A_Review{Kiá»ƒm tra káº¿t quáº£}
        A_Review -- "KhÃ´ng Ä‘áº¡t" --> A_Comment[Viáº¿t bÃ¬nh luáº­n pháº£n há»“i]
        A_Comment --> M_Work
        A_Review -- "Äáº¡t" --> A_Close[Chuyá»ƒn tháº» sang Done]
    end

    subgraph System["Há»‡ thá»‘ng (Kabo)"]
        direction TB
        A_Close --> S_Noti[Gá»­i thÃ´ng bÃ¡o hoÃ n thÃ nh]
        S_Noti --> S_Log[Ghi nháº­t kÃ½ hoáº¡t Ä‘á»™ng Activity]
        S_Log --> S_End([Káº¿t thÃºc quy trÃ¬nh])
    end
```

### 1.7.2 Quy trÃ¬nh má»i vÃ  phÃ¢n quyá»n thÃ nh viÃªn
Quy trÃ¬nh nghiá»‡p vá»¥ khi má»™t Admin má»i ngÆ°á»i dÃ¹ng má»›i vÃ o há»‡ thá»‘ng lÃ m viá»‡c.

```mermaid
graph LR
    subgraph "Admin (TrÃ¬nh gá»­i)"
        Start_I([Báº¯t Ä‘áº§u]) --> Invite[Gá»­i lá»i má»i qua Email]
    end

    subgraph "System (Xá»­ lÃ½)"
        Invite --> Check_U{User Ä‘Ã£ cÃ³<br/>tÃ i khoáº£n?}
        Check_U -- "ChÆ°a" --> Send_E[Gá»­i link Ä‘Äƒng kÃ½ + má»i]
        Check_U -- "Rá»“i" --> Add_WS[GÃ¡n vÃ o danh sÃ¡ch chá»]
        Send_E --> Reg[NgÆ°á»i dÃ¹ng Ä‘Äƒng kÃ½]
        Reg --> Add_WS
    end

    subgraph "Member (TrÃ¬nh nháº­n)"
        Add_WS --> Accept[Cháº¥p nháº­n lá»i má»i]
        Accept --> Access[Truy cáº­p Workspace/Board]
        Access --> End_I([Káº¿t thÃºc])
    end
```

---

# PHáº¦N 2: THIáº¾T Káº¾ Há»† THá»NG

---

## 2.1 Class Diagram (Biá»ƒu Äá»“ Lá»›p)

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

### 2.1.1 Báº£ng MÃ´ Táº£ Thá»±c Thá»ƒ

| Thá»±c thá»ƒ | Thuá»™c tÃ­nh chÃ­nh | KhÃ³a chÃ­nh | KhÃ³a ngoáº¡i | Má»¥c Ä‘Ã­ch |
|---------|----------------|-----------|-----------|---------|
| **User** | UserName, Email, PasswordHash, AvatarUrl, IsTwoFactorEnabled | UserUId | RoleId | LÆ°u thÃ´ng tin tÃ i khoáº£n vÃ  xÃ¡c thá»±c |
| **Workspace** | Name, Description, Status | WorkspaceUId | OwnerUId (â†’User) | KhÃ´ng gian lÃ m viá»‡c nhÃ³m |
| **WorkspaceMembers** | Role, JoinedAt | WorkspaceMemberUId | WorkspaceUId, UserUId | Quáº£n lÃ½ thÃ nh viÃªn workspace vá»›i phÃ¢n quyá»n |
| **Board** | BoardName, IsPersonal, Visibility, BackgroundUrl | BoardUId | UserUId (â†’User), WorkspaceUId (â†’Workspace) | Báº£ng kanban, cá»‘t lÃµi cá»§a há»‡ thá»‘ng |
| **BoardMember** | BoardRole, JoinedAt | BoardMemberUId | BoardUId, UserUId | PhÃ¢n quyá»n thÃ nh viÃªn trong board |
| **List** | ListName, Position, Status | ListUId | BoardUId (â†’Board) | Cá»™t trong báº£ng kanban (To Do, In Progress...) |
| **Card** | Title, Description, DueDate, Position, Status | CardUId | ListUId (â†’List), UserUId | ÄÆ¡n vá»‹ cÃ´ng viá»‡c cá»¥ thá»ƒ |
| **CardMember** | AssignedAt | CardMemberUId | CardUId, UserUId | PhÃ¢n cÃ´ng ngÆ°á»i thá»±c hiá»‡n tháº» |
| **CardLabel** | LabelName, Color | CardLabelUId | CardUId (â†’Card) | NhÃ£n mÃ u phÃ¢n loáº¡i tháº» |
| **Comment** | Content, CreatedAt | CommentUId | CardUId, UserUId | Tháº£o luáº­n trÃªn tháº» |
| **TodoItem** | Content, IsCompleted | TodoItemUId | CardUId (â†’Card) | Checklist cÃ´ng viá»‡c nhá» trong tháº» |
| **FileUrl** | Url, FileName | FileId | CardUId (â†’Card) | Tá»‡p Ä‘Ã­nh kÃ¨m trÃªn tháº» (lÆ°u qua Cloudinary) |
| **Notification** | Type, Title, Message, Read | NotiId | RecipientId, ActorId (â†’User) | ThÃ´ng bÃ¡o sá»± kiá»‡n trong há»‡ thá»‘ng |
| **Activity** | Description, CreatedAt | ActivityId | UserUId (â†’User) | Nháº­t kÃ½ hoáº¡t Ä‘á»™ng ngÆ°á»i dÃ¹ng |
| **UserRecentBoard** | LastVisitedAt | UserRecentBoardUId | UserUId, BoardUId | Lá»‹ch sá»­ truy cáº­p board gáº§n Ä‘Ã¢y (tá»‘i Ä‘a 4) |
| **UserInboxCard** | â€” | InboxCardUId | UserUId, CardUId | Há»™p thÆ°: tháº» Ä‘Æ°á»£c phÃ¢n cÃ´ng cho user |

---

## 2.2 Sequence Diagram

### 2.2.1 ÄÄƒng nháº­p vÃ  láº¥y danh sÃ¡ch Board

```mermaid
sequenceDiagram
    actor U as NgÆ°á»i dÃ¹ng
    participant App as Flutter App
    participant API as ASP.NET Core API
    participant DB as SQL Server
    participant Cache as Local Storage

    U->>App: Nháº­p email + máº­t kháº©u
    App->>API: POST /v1/api/auth/login
    API->>DB: SELECT User WHERE Email = ?
    DB-->>API: User record
    API->>API: Verify PasswordHash (BCrypt)
    alt 2FA báº­t
        API-->>App: YÃªu cáº§u OTP
        App->>U: Hiá»ƒn thá»‹ mÃ n hÃ¬nh OTP
        U->>App: Nháº­p OTP
        App->>API: POST /v1/api/auth/verify-2fa
    end
    API->>API: Táº¡o JWT AccessToken
    API-->>App: { accessToken, refreshToken }
    App->>Cache: LÆ°u token + userId
    App->>API: GET /v1/api/board?userUId=...
    API->>DB: SELECT Boards (personal + workspace)
    DB-->>API: Board list + recent boards
    API-->>App: JSON Board list
    App->>U: Hiá»ƒn thá»‹ trang chá»§
```

---

### 2.2.2 KÃ©o-tháº£ tháº» giá»¯a cÃ¡c danh sÃ¡ch (Optimistic Update)

```mermaid
sequenceDiagram
    actor U as NgÆ°á»i dÃ¹ng
    participant App as Flutter App
    participant Cubit as BoardDetailCubit
    participant API as ASP.NET Core API
    participant DB as SQL Server

    U->>App: KÃ©o Card tá»« List A sang List B (vá»‹ trÃ­ X)
    App->>Cubit: moveCard(card, sourceListId, targetListId, insertIndex)
    Cubit->>Cubit: LÆ°u _previousLists (rollback snapshot)
    Cubit->>Cubit: Optimistic update: cáº­p nháº­t UI ngay láº­p tá»©c
    Cubit-->>App: emit BoardDetailLoaded (lists má»›i)
    App->>U: UI ngay láº­p tá»©c pháº£n há»“i

    Cubit->>API: PUT /v1/api/cards/{cardId}/move?newListId=...
    API->>DB: UPDATE Card SET ListUId = ?, Position = ?
    DB-->>API: Success

    alt ThÃ nh cÃ´ng
        API-->>Cubit: 200 OK
    else Tháº¥t báº¡i
        API-->>Cubit: 4xx/5xx Error
        Cubit->>Cubit: Rollback vá» _previousLists
        Cubit-->>App: emit BoardDetailLoaded (lists cÅ© + transientError)
        App->>U: Hiá»ƒn thá»‹ SnackBar lá»—i
    end
```

---

### 2.2.3 Chuyá»ƒn Board sang Workspace khÃ¡c

```mermaid
sequenceDiagram
    actor OW as Owner Board
    participant App as Flutter App
    participant Sheet as TransferWorkspaceSheet
    participant Cubit as BoardDetailCubit
    participant API as ASP.NET Core API
    participant DB as SQL Server

    OW->>App: Má»Ÿ Board Settings â†’ Chá»n "KhÃ´ng gian lÃ m viá»‡c"
    App->>Sheet: Hiá»ƒn thá»‹ TransferWorkspaceSheet
    Sheet->>API: GET /v1/api/workspace?userUId=...
    API->>DB: SELECT Workspaces WHERE UserUId = ?
    DB-->>API: Danh sÃ¡ch workspace
    API-->>Sheet: Workspace list (cÃ³ dáº¥u tÃ­ch WS hiá»‡n táº¡i)
    OW->>Sheet: Chá»n Workspace Ä‘Ã­ch / KhÃ´ng gian cÃ¡ nhÃ¢n
    Sheet->>Sheet: Hiá»ƒn thá»‹ Dialog xÃ¡c nháº­n
    OW->>Sheet: XÃ¡c nháº­n chuyá»ƒn
    Sheet->>Cubit: transferBoardWorkspace(newWorkspaceId, name)
    Cubit->>API: POST /v1/api/boardMember/{boardId}/transfer-workspace?newWorkspaceUId=...
    API->>API: Kiá»ƒm tra requester lÃ  Owner
    alt Chuyá»ƒn vá» Personal
        API->>DB: UPDATE Board SET WorkspaceUId = NULL, IsPersonal = true
    else Chuyá»ƒn sang Workspace má»›i
        API->>DB: UPDATE Board SET WorkspaceUId = ?, IsPersonal = false
        API->>DB: INSERT WorkspaceMembers (cÃ¡c thÃ nh viÃªn board chÆ°a cÃ³)
    end
    DB-->>API: Success
    API-->>Cubit: 200 OK { message }
    Cubit->>Cubit: emit state má»›i vá»›i workspaceId má»›i
    Cubit-->>App: SnackBar " ÄÃ£ chuyá»ƒn báº£ng thÃ nh cÃ´ng"
```

---

### 2.2.4 PhÃ¢n cÃ´ng thÃ nh viÃªn tháº» vÃ  gá»­i thÃ´ng bÃ¡o

```mermaid
sequenceDiagram
    actor A as ThÃ nh viÃªn Board
    participant App as Flutter App
    participant API as ASP.NET Core API
    participant DB as SQL Server

    A->>App: Má»Ÿ Card â†’ Tab ThÃ nh viÃªn
    App->>API: GET /v1/api/boardMember/{boardId}/members
    API->>DB: SELECT BoardMembers JOIN Users
    DB-->>API: Danh sÃ¡ch thÃ nh viÃªn board
    API-->>App: Member list

    A->>App: Chá»n thÃªm thÃ nh viÃªn vÃ o card
    App->>API: POST /v1/api/cardMember/{cardId}/add?userUId=...
    API->>DB: INSERT CardMember
    API->>DB: INSERT UserInboxCard (náº¿u chÆ°a cÃ³)
    API->>DB: INSERT Notification (type=CardAssigned, recipientId=userUId)
    DB-->>API: Success
    API-->>App: 200 OK
    App->>A: UI cáº­p nháº­t danh sÃ¡ch thÃ nh viÃªn card

    Note over DB,App: ThÃ nh viÃªn Ä‘Æ°á»£c phÃ¢n cÃ´ng nháº­n thÃ´ng bÃ¡o<br/>khi má»Ÿ app láº§n tiáº¿p theo
```

---

## 2.3 Activity Diagram (Má»©c Thiáº¿t Káº¿)

### 2.3.1 Thuáº­t toÃ¡n xá»­ lÃ½ ÄÄƒng nháº­p + 2FA

```mermaid
flowchart TD
    S([Start]) --> Input[Nháº­n email + password]
    Input --> FindUser{TÃ¬m User\ntrong DB?}
    FindUser -- KhÃ´ng tÃ¬m tháº¥y --> ErrUser[Tráº£ vá» 401\nUser khÃ´ng tá»“n táº¡i]
    ErrUser --> End1([End])

    FindUser -- TÃ¬m tháº¥y --> CheckPwd{BCrypt.Verify\n(password, hash)?}
    CheckPwd -- Sai --> ErrPwd[Tráº£ vá» 401\nSai máº­t kháº©u]
    ErrPwd --> End2([End])

    CheckPwd -- ÄÃºng --> CheckEmail{IsEmailVerified?}
    CheckEmail -- KhÃ´ng --> ErrEmail[Tráº£ vá» 403\nEmail chÆ°a xÃ¡c minh]
    ErrEmail --> End3([End])

    CheckEmail -- CÃ³ --> Check2FA{IsTwoFactorEnabled?}
    Check2FA -- KhÃ´ng --> GenToken[Táº¡o JWT AccessToken\n+ RefreshToken]
    Check2FA -- CÃ³ --> Return2FA[Tráº£ vá» 200\n+ flag require2FA]
    Return2FA --> Wait[Client gá»­i OTP code]
    Wait --> VerifyOTP{TOTP.Verify\n(secret, code)?}
    VerifyOTP -- Sai --> CheckBackup{Backup Code\nhá»£p lá»‡?}
    CheckBackup -- KhÃ´ng --> ErrOTP[Tráº£ vá» 401\nSai OTP]
    ErrOTP --> End4([End])
    CheckBackup -- CÃ³ --> GenToken
    VerifyOTP -- ÄÃºng --> GenToken

    GenToken --> SaveSession[LÆ°u UserSession\nvÃ o DB]
    SaveSession --> LogActivity[Ghi Activity\n'User signed in']
    LogActivity --> Response[Tráº£ vá» 200\n{ accessToken, refreshToken }]
    Response --> End5([End])
```

---

### 2.3.2 Thuáº­t toÃ¡n xá»­ lÃ½ di chuyá»ƒn tháº» (Move Card)

```mermaid
flowchart TD
    S([Start]) --> CheckAuth{User lÃ  thÃ nh viÃªn\nBoard?}
    CheckAuth -- KhÃ´ng --> Err403[Tráº£ vá» 403]
    Err403 --> End1([End])

    CheckAuth -- CÃ³ --> GetCard{TÃ¬m Card\ntrong DB?}
    GetCard -- KhÃ´ng --> Err404[Tráº£ vá» 404]
    Err404 --> End2([End])

    GetCard -- CÃ³ --> GetTargetList{TÃ¬m List Ä‘Ã­ch\ntrong cÃ¹ng Board?}
    GetTargetList -- KhÃ´ng --> Err400[Tráº£ vá» 400\nList khÃ´ng há»£p lá»‡]
    Err400 --> End3([End])

    GetTargetList -- CÃ³ --> UpdateCard[UPDATE Card:\nListUId = target\nPosition = insertIndex]
    UpdateCard --> ShiftPositions[Cáº­p nháº­t Position\ncÃ¡c card cÃ²n láº¡i trong\ncáº£ 2 list]
    ShiftPositions --> SaveDB[SaveChangesAsync]
    SaveDB --> LogActivity[Ghi Activity]
    LogActivity --> Response[Tráº£ vá» 200 OK]
    Response --> End4([End])
```

---

### 2.3.3 Thuáº­t toÃ¡n lÆ°u Board gáº§n Ä‘Ã¢y (Recent Board)

```mermaid
flowchart TD
    S([Start: User má»Ÿ Board]) --> LoadBoard[loadBoard Ä‘Æ°á»£c gá»i]
    LoadBoard --> SaveRecent[saveRecentBoardUseCase\n(userUId, boardId)]

    SaveRecent --> CheckExist{UserRecentBoard\ntá»“n táº¡i?}
    CheckExist -- CÃ³ --> UpdateTime[UPDATE LastVisitedAt = Now]
    CheckExist -- KhÃ´ng --> InsertNew[INSERT UserRecentBoard má»›i]

    UpdateTime --> CountAll[Äáº¿m tá»•ng record\ncá»§a userUId]
    InsertNew --> CountAll

    CountAll --> CheckLimit{Count > 4?}
    CheckLimit -- KhÃ´ng --> SaveDB[SaveChangesAsync]
    CheckLimit -- CÃ³ --> DeleteOld[XÃ³a cÃ¡c record cÅ©\n vÆ°á»£t quÃ¡ 4 má»¥c\norderd by LastVisitedAt DESC]
    DeleteOld --> SaveDB

    SaveDB --> End([End])
```

---

*TÃ i liá»‡u Ä‘Æ°á»£c táº¡o tá»± Ä‘á»™ng dá»±a trÃªn phÃ¢n tÃ­ch mÃ£ nguá»“n thá»±c táº¿ cá»§a dá»± Ã¡n Kabo.*
*Cáº­p nháº­t láº§n cuá»‘i: 2026-05-10*

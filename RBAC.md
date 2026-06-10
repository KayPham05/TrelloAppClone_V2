# Há»‡ thá»‘ng PhÃ¢n quyá»n (RBAC) - Kabo

Báº£ng dÆ°á»›i Ä‘Ã¢y mÃ´ táº£ chi tiáº¿t cÃ¡c quyá»n háº¡n dá»±a trÃªn vai trÃ² (Role-Based Access Control) Ä‘Æ°á»£c triá»ƒn khai trong há»‡ thá»‘ng Kabo cho cáº£ Workspace vÃ  Board.

## 1. PhÃ¢n quyá»n KhÃ´ng gian lÃ m viá»‡c (Workspace)

| TÃ­nh nÄƒng | Workspace Owner | Workspace Admin | Workspace Member | Workspace Viewer |
| :--- | :---: | :---: | :---: | :---: |
| **Quáº£n lÃ½ Workspace** (Sá»­a/XÃ³a) | âœ… | âœ… | âŒ | âŒ |
| **Quáº£n lÃ½ thÃ nh viÃªn** (Má»i/XÃ³a) | âœ… | âœ… | âŒ | âŒ |
| **Thay Ä‘á»•i vai trÃ² thÃ nh viÃªn** | âœ… | âš ï¸ (1) | âŒ | âŒ |
| **Táº¡o Báº£ng (Board) má»›i** | âœ… | âœ… | âœ… | âŒ |
| **Xem danh sÃ¡ch Board** | âœ… | âœ… | âœ… | âœ… |

*(1) Workspace Admin chá»‰ cÃ³ thá»ƒ thay Ä‘á»•i vai trÃ² lÃªn má»©c tá»‘i tá»‘i Ä‘a lÃ  Member (khÃ´ng thá»ƒ bá»• nhiá»‡m Admin/Owner).*

---

## 2. PhÃ¢n quyá»n Báº£ng (Board)

| TÃ­nh nÄƒng | Board Owner | Board Admin | Board Editor | Board Viewer |
| :--- | :---: | :---: | :---: | :---: |
| **XÃ³a Báº£ng** | âœ… | âŒ | âŒ | âŒ |
| **Quáº£n lÃ½ Báº£ng** (TÃªn, Background) | âœ… | âœ… | âŒ | âŒ |
| **Quáº£n lÃ½ thÃ nh viÃªn Board** | âœ… | âœ… | âŒ | âŒ |
| **Thao tÃ¡c Danh sÃ¡ch** (Táº¡o/Sá»­a) | âœ… | âœ… | âœ… | âŒ |
| **XÃ³a Danh sÃ¡ch** | âœ… | âœ… | âŒ | âŒ |
| **Táº¡o/Sá»­a Tháº» (Card)** | âœ… | âœ… | âœ… | âŒ |
| **XÃ³a Tháº» (Card)** | âœ… | âœ… | âŒ | âŒ |
| **BÃ¬nh luáº­n (Comment)** | âœ… | âœ… | âœ… | âŒ |
| **Di chuyá»ƒn Card** | âœ… | âœ… | âœ… | âŒ |

---

## 3. CÆ¡ cháº¿ Káº¿ thá»«a & Äáº·c biá»‡t (Inheritance)

Há»‡ thá»‘ng triá»ƒn khai cÆ¡ cháº¿ káº¿ thá»«a quyá»n háº¡n tá»« Workspace xuá»‘ng Board Ä‘á»ƒ Ä‘áº£m báº£o tÃ­nh quáº£n trá»‹:

*   **Workspace Admin/Owner**: Tá»± Ä‘á»™ng cÃ³ quyá»n **Edit/Manage** trÃªn táº¥t cáº£ cÃ¡c Board thuá»™c Workspace Ä‘Ã³, ngay cáº£ khi khÃ´ng pháº£i lÃ  thÃ nh viÃªn trá»±c tiáº¿p cá»§a Board.
*   **Workspace Owner**: LÃ  ngÆ°á»i duy nháº¥t cÃ³ quyá»n **XÃ³a** báº¥t ká»³ Board nÃ o trong Workspace cá»§a mÃ¬nh.
*   **Tháº» cÃ¡ nhÃ¢n (Inbox)**: Äá»‘i vá»›i cÃ¡c tháº» khÃ´ng náº±m trong Board (tháº» cÃ¡ nhÃ¢n), chá»‰ ngÆ°á»i sá»Ÿ há»¯u (Creator) má»›i cÃ³ quyá»n chá»‰nh sá»­a/xÃ³a.
*   **Äá»™ Æ°u tiÃªn vai trÃ² (Role Priority)**:
    *   `Owner (3)` > `Admin (2)` > `Member/Editor (1)` > `Viewer (0)`.

---
*TÃ i liá»‡u nÃ y Ä‘Æ°á»£c trÃ­ch xuáº¥t tá»« logic thá»±c táº¿ trong `AuthorizationService.cs`.*

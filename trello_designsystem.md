# Design System â€” Kabo Mobile App

> PhiÃªn báº£n á»©ng dá»¥ng: `2026.10.1` | Build: `20260513.155745`  
> NgÃ´n ngá»¯: Tiáº¿ng Viá»‡t | Platform: iOS

---

## 1. Brand & Tá»•ng quan

Kabo lÃ  á»©ng dá»¥ng quáº£n lÃ½ cÃ´ng viá»‡c theo mÃ´ hÃ¬nh Kanban board, Ä‘Æ°á»£c thiáº¿t káº¿ cho mobile-first. Giao diá»‡n sáº¡ch, rÃµ rÃ ng, táº­p trung vÃ o ná»™i dung, tá»‘i giáº£n nhÆ°ng Ä‘á»§ thÃ´ng tin.

---

## 2. MÃ u sáº¯c (Color Palette)

### Primary Colors

| TÃªn | Hex | DÃ¹ng cho |
|-----|-----|---------|
| Primary Blue | `#0052CC` | NÃºt CTA chÃ­nh, icon active, link |
| Blue Light | `#579DFF` | Badge, highlight chá»n |
| Background | `#F4F5F7` | Ná»n mÃ n hÃ¬nh |
| Surface White | `#FFFFFF` | Card, sheet, modal |

### Priority Label Colors

| Tag | Hex | MÃ´ táº£ |
|-----|-----|-------|
| P1 (Cao nháº¥t) | `#F87462` | Cam Ä‘á» â€” Æ¯u tiÃªn cao |
| P2 | `#388BFF` | Xanh dÆ°Æ¡ng â€” Æ¯u tiÃªn trung bÃ¬nh |
| P3 | `#4BCE97` | Xanh lÃ¡ â€” Æ¯u tiÃªn tháº¥p |

### Type Tag Colors

| Tag | Hex | MÃ´ táº£ |
|-----|-----|-------|
| FE (Frontend) | `#579DFF` | Xanh nháº¡t |
| Full-stack | `#F5A623` | Cam vÃ ng |

### Label / NhÃ£n Colors (6 mÃ u chuáº©n)

| TÃªn | Hex |
|-----|-----|
| Green | `#4BCE97` |
| Yellow | `#CCA300` |
| Orange | `#F5A623` |
| Red | `#F87462` |
| Purple | `#9F8FEF` |
| Blue | `#579DFF` |

### Text Colors

| TÃªn | Hex | DÃ¹ng cho |
|-----|-----|---------|
| Text Primary | `#172B4D` | TiÃªu Ä‘á», ná»™i dung chÃ­nh |
| Text Secondary | `#6B778C` | Phá»¥ Ä‘á», metadata |
| Text Placeholder | `#A5ADBA` | Input placeholder |
| Text Link / Action | `#0052CC` | Link, nÃºt vÄƒn báº£n |
| Text Destructive | `#CA3521` | NÃºt xÃ³a ngÃ y, cáº£nh bÃ¡o |
| Text Disabled | `#C1C7D0` | Tráº¡ng thÃ¡i vÃ´ hiá»‡u |

### Tráº¡ng thÃ¡i (State Colors)

| Tráº¡ng thÃ¡i | Hex |
|-----------|-----|
| Success / Done | `#22A06B` |
| Warning | `#FF8B00` |
| Error / Danger | `#DE350B` |
| Info | `#0065FF` |
| Unread Indicator | `#0052CC` (dot) |

---

## 3. Typography

### Font

- **Font chÃ­nh**: San Francisco (iOS system font) â€” `-apple-system, BlinkMacSystemFont`
- **KhÃ´ng sá»­ dá»¥ng** custom typeface; toÃ n bá»™ theo iOS system typography

### Thang cá»¡ chá»¯

| TÃªn | Size | Weight | Line Height | DÃ¹ng cho |
|-----|------|--------|-------------|---------|
| Large Title | 34pt | Bold (700) | 41pt | TiÃªu Ä‘á» mÃ n hÃ¬nh (Báº£ng, TÃ i khoáº£n) |
| Title 1 | 28pt | Bold | 34pt | TiÃªu Ä‘á» section lá»›n (thÃ¡ng 5) |
| Title 2 | 22pt | Semibold (600) | 28pt | TÃªn Board, tÃªn Card |
| Title 3 | 20pt | Semibold | 25pt | Header card detail |
| Headline | 17pt | Semibold | 22pt | TÃªn task trong card |
| Body | 17pt | Regular (400) | 22pt | Ná»™i dung mÃ´ táº£, bÃ¬nh luáº­n |
| Callout | 16pt | Regular | 21pt | Metadata phá»¥ |
| Subheadline | 15pt | Regular | 20pt | Section header (KHÃ”NG GIAN LÃ€M VIá»†C) |
| Footnote | 13pt | Regular | 18pt | Timestamp, thÃ´ng tin phá»¥ (14:52 23 thg 4) |
| Caption 1 | 12pt | Regular | 16pt | Label badge text |
| Caption 2 | 11pt | Regular | 13pt | Micro metadata |

### Äáº·c biá»‡t

- **Section header dáº¡ng ALL CAPS**: `KHÃ”NG GIAN LÃ€M VIá»†C` â€” Subheadline + Letter-spacing 0.5px + `#6B778C`
- **Badge text**: Caption 1 + Bold + White trÃªn ná»n mÃ u priority

---

## 4. Spacing & Layout

### ÄÆ¡n vá»‹ cÆ¡ sá»Ÿ

- **Base unit**: 4pt
- **Grid**: 8pt grid

### Khoáº£ng cÃ¡ch thÃ´ng dá»¥ng

| Token | Value | DÃ¹ng cho |
|-------|-------|---------|
| `space-xs` | 4pt | Khoáº£ng cÃ¡ch nhá» nháº¥t |
| `space-sm` | 8pt | Padding ná»™i bá»™ card nhá» |
| `space-md` | 12pt | Padding card thÃ´ng thÆ°á»ng |
| `space-lg` | 16pt | Padding mÃ n hÃ¬nh |
| `space-xl` | 20pt | Khoáº£ng cÃ¡ch section |
| `space-2xl` | 24pt | Header margin |
| `space-3xl` | 32pt | Khoáº£ng cÃ¡ch lá»›n |

### Screen Margins

- **Horizontal padding mÃ n hÃ¬nh**: 16pt (trÃ¡i/pháº£i)
- **Card padding ná»™i bá»™**: 12pt

---

## 5. CÃ¡c thÃ nh pháº§n UI (Components)

### 5.1 Bottom Navigation Bar

```
[Báº£ng] [Há»™p thÆ° Ä‘áº¿n] [TrÃ¬nh láº­p káº¿ hoáº¡ch] [Hoáº¡t Ä‘á»™ng ðŸ”´7] [TÃ i khoáº£n]
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Height | 83pt (bao gá»“m safe area) |
| Icon size | 24Ã—24pt |
| Label size | 10pt |
| Active color | `#0052CC` |
| Inactive color | `#6B778C` |
| Background | `#FFFFFF` |
| Border top | 0.5pt `#E3E6EA` |
| Badge (sá»‘ thÃ´ng bÃ¡o) | Äá» `#DE350B`, 18pt circle, 10pt white bold |

**Tabs:**
1. Báº£ng (Board icon)
2. Há»™p thÆ° Ä‘áº¿n (Inbox icon)
3. TrÃ¬nh láº­p káº¿ hoáº¡ch (Calendar icon)
4. Hoáº¡t Ä‘á»™ng (Bell icon + badge sá»‘)
5. TÃ i khoáº£n (Avatar circle)

---

### 5.2 Card (Tháº» Kanban)

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ [P2] [FE]                   â”‚
â”‚ â—‹  TÃªn task                 â”‚
â”‚ ðŸ‘ â‰¡ â˜‘ 0/4         [Avatar] â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Background | `#FFFFFF` |
| Border radius | 8pt |
| Shadow | `0 1pt 3pt rgba(9,30,66,0.13)` |
| Padding | 12pt |
| Margin bottom | 8pt |

**Cáº¥u trÃºc Card:**
1. **Row 1 â€” Priority + Type tags**: HÃ ng ngang, gap 4pt
2. **Row 2 â€” Checkbox + Title**: `â—‹` (16pt) + text Headline
3. **Row 3 â€” Metadata icons**: Máº¯t ðŸ‘, dÃ²ng káº» â‰¡, checkbox â˜‘ `0/4`, avatar gÃ³c pháº£i

**Card Cover Image**: áº¢nh full-width, border-radius-top 8pt, height ~160pt

---

### 5.3 Priority & Type Badges

| Badge | Ná»n | Chá»¯ | Border radius |
|-------|-----|-----|--------------|
| P1 | `#FFEBE6` | `#CA3521` | 3pt |
| P2 | `#DEEBFF` | `#0052CC` | 3pt |
| P3 | `#E3FCEF` | `#006644` | 3pt |
| FE | `#DEEBFF` | `#0052CC` | 3pt |
| Full-stack | `#FFF0B3` | `#172B4D` | 3pt |

**Size:** padding `2pt 6pt`, font Caption 1 Semibold

---

### 5.4 Kanban Column Header

```
Backlog                    Â·Â·Â·
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Font | Headline Semibold |
| Color | `#172B4D` |
| Background | `#F4F5F7` |
| Padding | 12pt 16pt |
| Menu icon (Â·Â·Â·) | 20pt, `#6B778C` |

**CÃ¡c tráº¡ng thÃ¡i cá»™t:**
- `Backlog` â€” Tá»“n Ä‘á»ng
- `In Progress` â€” Äang lÃ m
- `Done` / `Review` (suy Ä‘oÃ¡n)

---

### 5.5 Button

#### Primary Button

```
[  ÄÃ¡nh giÃ¡ chÃºng tÃ´i trÃªn App Store  ]
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Background | `#0052CC` |
| Text | White, 17pt Semibold |
| Height | 50pt |
| Border radius | 25pt (pill shape) |
| Margin horizontal | 16pt |

#### Text Button / Action Link

```
Di chuyá»ƒn
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Color | `#0052CC` |
| Font | 17pt Regular |

#### Icon Button (Circle)

```
(+)  (Q)  Â·Â·Â·
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Size | 36pt diameter |
| Background | `#FFFFFF` hoáº·c `#0052CC` |
| Icon | 20pt |
| Shadow | Subtle 1pt |

#### Destructive Text

```
XÃ³a ngÃ y
```

| Color | `#CA3521` |
|-------|-----------|
| Font | 17pt Regular |
| Alignment | Center |

---

### 5.6 Sheet / Bottom Sheet

Modal tá»« dÆ°á»›i lÃªn (Card Detail, NgÃ y háº¿t háº¡n, NhÃ£n...)

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Background | `#FFFFFF` |
| Border radius top | 12pt |
| Header title | 17pt Semibold, center |
| Close button (X) | 36pt circle, `#F4F5F7`, `#172B4D` icon |
| Save/Confirm button | Text `#0052CC`, 17pt Semibold |

---

### 5.7 List Row (Settings / Account)

```
âš™  CÃ i Ä‘áº·t á»©ng dá»¥ng                    >
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Height | 44pt min |
| Padding | 16pt horizontal |
| Icon | 22pt, `#172B4D` |
| Text | Body Regular, `#172B4D` |
| Chevron > | `#C1C7D0` |
| External link icon | `#0052CC` |
| Separator | 0.5pt `#E3E6EA`, inset 16pt |
| Group background | `#FFFFFF` |
| Section background | `#F4F5F7` |

---

### 5.8 Toggle (Switch)

| State | Track color | Thumb |
|-------|------------|-------|
| On | `#0052CC` | White |
| Off | `#E3E6EA` | White |

**Size:** 51Ã—31pt (iOS standard)

---

### 5.9 Avatar

| Size | DÃ¹ng cho |
|------|---------|
| 32pt | Card assignee |
| 40pt | Tab bar account |
| 56pt | Account page header |

**Fallback:** Chá»¯ táº¯t tÃªn (KP, DP) trÃªn ná»n mÃ u ngáº«u nhiÃªn tá»« palette (`#0052CC`, `#F5A623`, v.v.)  
**Border radius:** 50% (circle)

---

### 5.10 Date Picker

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Sheet height | ~80% screen |
| Quick picks | Pill chips: "HÃ´m nay", "NgÃ y mai", "Tuáº§n tá»›i" |
| Calendar header | `thÃ¡ng 5 nÄƒm 2026 >` â€” Title 2 Semibold |
| Today | Blue text `#0052CC` |
| Selected date | Blue circle `#0052CC`, white text |
| Navigation arrows | `#0052CC` |
| Day labels | TH 2...CN, Caption 2, `#6B778C` |
| Time section | Footnote label + pill chip value |
| Reminder | Row vá»›i picker inline |

---

### 5.11 Label Manager (NhÃ£n)

- **Header**: "NhÃ£n" â€” Title 2 Semibold | NÃºt X (Ä‘Ã³ng) + NÃºt + (thÃªm)
- **Color blindness toggle**: "Cháº¿ Ä‘á»™ mÃ¹ mÃ u" + Switch
- **Label name display toggle**: "Hiá»ƒn thá»‹ tÃªn nhÃ£n trÃªn máº·t trÆ°á»›c tháº»" + Switch (ON máº·c Ä‘á»‹nh)
- **Label row**: Full-width color bar, border-radius 6pt, height 48pt, edit icon `âœ` bÃªn pháº£i

---

### 5.12 Search Bar

```
ðŸ”  Báº£ng
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Background | `#FFFFFF` |
| Border radius | 10pt |
| Height | 36pt |
| Placeholder | `#A5ADBA`, Body Regular |
| Icon | 16pt, `#6B778C` |

---

### 5.13 Inbox Card (Há»™p thÆ° Ä‘áº¿n)

Dáº¡ng tháº» ná»•i báº­t trÃªn mÃ n hÃ¬nh Báº£ng

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Background | `#EAF2FF` (light blue tint) |
| Border | 1pt `#B3D4FF` |
| Border radius | 12pt |
| Header | "Há»™p thÆ° Ä‘áº¿n 1" â€” Headline Semibold + Badge sá»‘ |
| Edit icon | `âœ` top right |

---

### 5.14 Activity Feed Row

```
ðŸ–¥  [TÃªn] Ä‘Ã£ thÃªm báº¡n vÃ o tháº» [TÃªn tháº»] á»Ÿ báº£ng [TÃªn báº£ng]
    14:52 23 thg 4
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Icon | 24pt, xÃ¡m nháº¡t |
| TÃªn ngÆ°á»i dÃ¹ng | Bold `#172B4D` |
| Card link | Underline `#172B4D` |
| Timestamp | Footnote `#6B778C` |
| Separator | 0.5pt `#E3E6EA` |
| Unread indicator | 3pt blue bar bÃªn trÃ¡i trÃ¡i |
| Filter chips | "Táº¥t cáº£ cÃ¡c loáº¡i â–¾" + "âœ“ ChÆ°a Ä‘á»c" â€” pill shape |

---

### 5.15 Calendar / Planner View

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Header | "thÃ¡ng 5" â€” Large Title Bold |
| NgÃ y hiá»‡n táº¡i | Purple circle `#6554C0` + CN/17 |
| NgÃ y khÃ¡c | Day label + sá»‘, Regular |
| Tráº¡ng thÃ¡i trá»‘ng | "ChÆ°a lÃªn káº¿ hoáº¡ch nÃ o" â€” Body `#6B778C` |
| Separator | Full-width 1pt `#E3E6EA` |
| Time indicator line | Purple `#6554C0` full width |

---

## 6. Iconography

- **Style**: SF Symbols (iOS system icons) â€” Outlined, 22â€“24pt
- **Weight**: Regular
- **Colors**: Inherit tá»« context (active = `#0052CC`, default = `#6B778C`, destructive = `#CA3521`)

### Icon chuáº©n dÃ¹ng trong app

| Icon | DÃ¹ng cho |
|------|---------|
| `square.grid.2x2` | Tab Báº£ng |
| `tray` | Tab Há»™p thÆ° Ä‘áº¿n |
| `calendar` | Tab TrÃ¬nh láº­p káº¿ hoáº¡ch |
| `bell` | Tab Hoáº¡t Ä‘á»™ng |
| `person.crop.circle` | Tab TÃ i khoáº£n |
| `checkmark.square` | Checklist item |
| `paperclip` | ÄÃ­nh kÃ¨m |
| `eye` | Äang theo dÃµi |
| `line.3.horizontal` | MÃ´ táº£ / menu |
| `circle` | Checkbox chÆ°a hoÃ n thÃ nh |
| `checkmark.circle.fill` | Checkbox hoÃ n thÃ nh |
| `clock` | NgÃ y báº¯t Ä‘áº§u |
| `tag` | NhÃ£n |
| `photo` | áº¢nh bÃ¬a |
| `plus` | ThÃªm má»›i |
| `xmark` | ÄÃ³ng |
| `chevron.right` | Äiá»u hÆ°á»›ng sang pháº£i |
| `square.and.arrow.up` | External link |
| `gearshape` | CÃ i Ä‘áº·t |
| `arrow.triangle.2.circlepath` | Äá»“ng bá»™ |
| `wrench.and.screwdriver` | Dev tools |
| `questionmark.circle` | Trá»£ giÃºp |
| `person.badge.key` | Quáº£n lÃ½ tÃ i khoáº£n |
| `trash` | XÃ³a |
| `bolt` | Beta |
| `rectangle.portrait.and.arrow.right` | ÄÄƒng xuáº¥t |
| `magnifyingglass` | TÃ¬m kiáº¿m |
| `pencil` | Chá»‰nh sá»­a |
| `star` | Star/Unstar |
| `arrow.up.arrow.down` | Di chuyá»ƒn |

---

## 7. Motion & Animation

- **Sheet present**: Slide up tá»« dÆ°á»›i, duration 300ms, ease-out
- **Sheet dismiss**: Slide down, duration 250ms, ease-in
- **Card tap**: Scale 0.97, opacity 0.8, duration 100ms
- **Badge update**: Fade in, duration 200ms
- **Toggle**: Spring animation, iOS default
- **Scroll**: Momentum scroll (native iOS)

---

## 8. Navigation Patterns

### Kiá»ƒu mÃ n hÃ¬nh

| Pattern | DÃ¹ng khi |
|---------|---------|
| Bottom Tab | Navigation chÃ­nh (5 tabs) |
| Full-screen push | Board detail, Card detail (full mÃ n hÃ¬nh) |
| Bottom Sheet | Modal ngáº¯n (Date picker, Label, Di chuyá»ƒn) |
| Half Sheet | Modal vá»«a (Card detail) |

### Header Actions

- **Left**: X (Ä‘Ã³ng) â€” circle button 36pt
- **Right**: + (thÃªm) hoáº·c Â·Â·Â· (menu) hoáº·c LÆ°u/text action
- **Center**: TiÃªu Ä‘á» mÃ n hÃ¬nh â€” Title 2 Semibold

---

## 9. Card Detail Screen

Cáº¥u trÃºc mÃ n hÃ¬nh chi tiáº¿t tháº» (scroll view):

```
[Cover Image â€” Full width, ~200pt height]
[Photo icon] áº¢nh bÃ¬a

â—‹  TÃªn tháº» (Title 2 Bold)

[Color chip]  TÃªn list          Di chuyá»ƒn (link)

â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
â‰¡  ThÃªm mÃ´ táº£

â±  NgÃ y báº¯t Ä‘áº§u
   NgÃ y háº¿t háº¡n

ðŸ·  NhÃ£n

â˜‘  Danh sÃ¡ch cÃ´ng viá»‡c              +

ðŸ“Ž  CÃ¡c táº­p tin Ä‘Ã­nh kÃ¨m            +

:â‰¡  BÃ¬nh luáº­n
    KhÃ´ng cÃ³ nháº­n xÃ©t nÃ o vá» tháº» nÃ y

â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
[KP Avatar]  BÃ¬nh luáº­n...          ðŸ“Ž
```

---

## 10. Account Screen

```
[TÃ i khoáº£n â€” Large Title]

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  [KP]  Kha Pham                â”‚
â”‚        kha999...@gmail.com  [+]â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

KhÃ´ng gian lÃ m viá»‡c
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  KhÃ´ng gian lÃ m viá»‡c cá»§a báº¡n  >â”‚
â”‚  KhÃ´ng gian lÃ m viá»‡c cá»§a khÃ¡ch>â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

CÃ i Ä‘áº·t vÃ  cÃ´ng cá»¥
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ âš™  CÃ i Ä‘áº·t á»©ng dá»¥ng           â”‚
â”‚ â†º  HÃ ng Ä‘á»£i Ä‘á»“ng bá»™           â”‚
â”‚ ðŸ”§ CÃ´ng cá»¥ cho NhÃ  phÃ¡t triá»ƒn >â”‚
â”‚ ?  Giá»›i thiá»‡u vÃ  trá»£ giÃºp     >â”‚
â”‚ ðŸ‘¤ Quáº£n lÃ½ tÃ i khoáº£n         â†— â”‚
â”‚ ðŸ—‘ XÃ³a tÃ i khoáº£n             â†— â”‚
â”‚ âš¡ Tham gia thá»­ nghiá»‡m báº£n betaâ†—â”‚
â”‚ â†’ ÄÄƒng xuáº¥t                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

ThÃ´ng tin á»©ng dá»¥ng
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ PhiÃªn báº£n á»©ng dá»¥ng:  2026.10.1 â”‚
â”‚ Báº£n dá»±ng:    20260513.155745   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

[ÄÃ¡nh giÃ¡ chÃºng tÃ´i trÃªn App Store]
```

---

## 11. Board List Screen (MÃ n hÃ¬nh Báº£ng)

```
Báº£ng                        ðŸ”  +

[ðŸ” Báº£ng â€” Search bar]

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ ðŸ“¥ Há»™p thÆ° Ä‘áº¿n  1       âœ  â”‚
â”‚ [ThÃªm tháº»...]          ðŸ“Ž  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â± Báº£ng Gáº§n ÄÃ¢y

[img] Ä‚n
[img] My Kabo                 ðŸ”µ
[   ] Báº£ng Trello cá»§a tÃ´i
[img] Há»c

KHÃ”NG GIAN LÃ€M VIá»†C Cá»¦A Báº N
ðŸ‘¥ Trello KhÃ´ng gian lÃ m viá»‡c    Báº£ng >

[img] Ä‚n
[   ] Báº£ng Trello cá»§a tÃ´i
...
```

---

## 12. Responsive & Safe Areas

- **Status bar**: 44â€“54pt (dynamic island / notch)
- **Home indicator safe area**: 34pt bottom
- **Tab bar height**: 49pt + safe area
- **Min touch target**: 44Ã—44pt (Apple HIG)
- **Viewport**: 390pt wide (iPhone 15 base)

---

## 13. Accessibility

- Contrast ratio tá»‘i thiá»ƒu: **4.5:1** (WCAG AA)
- Cháº¿ Ä‘á»™ mÃ¹ mÃ u: CÃ³ toggle trong Label Manager
- Dynamic Type: Support scale font theo cÃ i Ä‘áº·t há»‡ thá»‘ng
- VoiceOver labels: Táº¥t cáº£ icon cáº§n accessibility label
- Minimum tap target: 44pt

---

## 14. Naming Conventions

### File / Component

```
ComponentName.swift / ComponentNameView.swift
screen_name_screen
modal_name_sheet
```

### Color tokens

```
color-primary
color-priority-p1
color-label-green
color-text-primary
color-surface-default
```

### Spacing tokens

```
space-xs / space-sm / space-md / space-lg / space-xl / space-2xl / space-3xl
```

---

## 15. Board Menu Screen (Menu báº£ng)

MÃ n hÃ¬nh menu nhanh cá»§a board, dáº¡ng **full-screen sheet** (push tá»« pháº£i hoáº·c bottom sheet lá»›n).

```
X    Menu báº£ng

[â˜† Star] [ðŸ‘¥ Members] [â¬† Share] [Â·Â·Â·More]

ðŸ‘¤  ThÃ nh viÃªn
    [Avatar1] [Avatar2] [Avatar3] ... (hÃ ng ngang, 40pt circles)

â“˜  Vá» báº£ng nÃ y                        >

ðŸ“£  Gá»­i pháº£n há»“i...

ðŸ—„  LÆ°u trá»¯ cÃ¡c tháº» Ä‘Æ°á»£c Ä‘Ã¡nh dáº¥u hoÃ n táº¥t

âš¡  Power-Ups
    BÃ¬nh chá»n, Tháº» bá»‹ "bá» quÃªn"...
    [ðŸ—“ Power-Up Lá»‹ch]                 >
    [Quáº£n lÃ½ Power-Ups]                >

:â‰¡  Hoáº¡t Ä‘á»™ng
â†’   [actor] Ä‘Ã£ di chuyá»ƒn tháº» [tÃªn tháº»]
    tá»« [list] tá»›i [list]  â€¢  1 giá» trÆ°á»›c

â†º   ÄÃ£ Ä‘á»“ng bá»™
```

### Cáº¥u trÃºc layout

| Khu vá»±c | MÃ´ táº£ |
|---------|-------|
| **Header** | X (Ä‘Ã³ng) trÃ¡i + "Menu báº£ng" Headline center |
| **Quick actions row** | 4 nÃºt icon ngang, border bottom 0.5pt `#E3E6EA` |
| **Member section** | Icon ngÆ°á»i + label "ThÃ nh viÃªn" + hÃ ng avatar |
| **Menu rows** | List row chuáº©n, icon trÃ¡i + label + chevron pháº£i |
| **Power-Ups block** | TiÃªu Ä‘á» + subtitle nhá» + sub-rows thá»¥t vÃ o |
| **Activity inline** | TiÃªu Ä‘á» section + 1 activity row preview |
| **Sync status** | Row cuá»‘i, icon sync + "ÄÃ£ Ä‘á»“ng bá»™" |

### Quick Actions Row

```
[  â˜†  ]  [  ðŸ‘¥  ]  [  â¬†  ]  [  Â·Â·Â·  ]
 Star    Members   Share    More
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Button width | 25% each (equal split) |
| Height | 52pt |
| Icon size | 22pt |
| Border | 0.5pt `#E3E6EA` ngÄƒn cÃ¡ch + bottom |
| Icon color | `#172B4D` |
| Background | `#FFFFFF` |

### Member Avatars Strip

- Hiá»ƒn thá»‹ tá»‘i Ä‘a **6â€“7 avatar** hÃ ng ngang, gap 4pt
- Avatar 40pt circle
- MÃ u ná»n avatar ngáº«u nhiÃªn (xem Section 5.9)
- CÃ³ thá»ƒ dÃ¹ng áº£nh profile tháº­t

### Power-Ups Section

```
âš¡  Power-Ups
    BÃ¬nh chá»n, Tháº» bá»‹ "bá» quÃªn"...      â† subtitle 13pt #6B778C

    [ðŸ—“]  Power-Up Lá»‹ch               >
          Quáº£n lÃ½ Power-Ups            >
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Power-Up icon | 32pt rounded square, mÃ u riÃªng (lá»‹ch = xanh dÆ°Æ¡ng) |
| Sub-row indent | 16pt so vá»›i icon chÃ­nh |
| Subtitle | Footnote `#6B778C` |

### Activity Inline Preview

```
:â‰¡  Hoáº¡t Ä‘á»™ng

â†’   phamtan606 Ä‘Ã£ di chuyá»ƒn tháº» Mark as read + Delete notification
    tá»« danh sÃ¡ch In Progress tá»›i danh sÃ¡ch Review
    1 giá» trÆ°á»›c
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Action icon | Arrow right `â†’`, 20pt, `#6B778C` |
| Actor name | Bold `#172B4D` |
| Card name | Underline + Bold `#172B4D` |
| List names | Bold `#172B4D` |
| Timestamp relative | Footnote `#6B778C` ("1 giá» trÆ°á»›c") |

### Sync Status Row

```
â†º   ÄÃ£ Ä‘á»“ng bá»™
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Icon | `arrow.clockwise`, 20pt, `#6B778C` |
| Text | Body Regular `#6B778C` |
| Position | Bottom of sheet |

---

## 16. Board Settings Screen (Thiáº¿t láº­p báº£ng)

MÃ n hÃ¬nh cÃ i Ä‘áº·t board, dáº¡ng **push navigation** tá»« Menu báº£ng.

```
<   Thiáº¿t láº­p báº£ng

[Group 1]
KhÃ´ng gian lÃ m viá»‡c    BÃ¡o cÃ¡o ðŸ’¯
PhÃ´ng ná»n              [img thumbnail] >
Hiá»ƒn thá»‹ áº£nh bÃ¬a tháº»              [Toggle ON]
Chá»‰nh sá»­a nhÃ£n                    >
Äang theo dÃµi                     [Toggle OFF]
CÃ i Ä‘áº·t thÃªm tháº» qua email

[Group 2]
LÆ°u trá»¯                            >

[Group 3]
Hiá»ƒn thá»‹                KhÃ´ng gian lÃ m viá»‡c
Quyá»n bÃ¬nh luáº­n         ThÃ nh viÃªn
BÃ¬nh chá»n               ÄÃ£ táº¯t
ThÃªm thÃ nh viÃªn         Quáº£n trá»‹ viÃªn

[Group 4]
Tá»± tham gia                        [Toggle ON]
Báº¡n pháº£i lÃ  quáº£n trá»‹ viÃªn cá»§a báº£ng Ä‘á»ƒ thay Ä‘á»•i cÃ i Ä‘áº·t nÃ y.
```

### CÃ¡c setting rows

| Row | Loáº¡i | GiÃ¡ trá»‹ máº«u |
|-----|------|------------|
| KhÃ´ng gian lÃ m viá»‡c | Label + value text | "BÃ¡o cÃ¡o ðŸ’¯" |
| PhÃ´ng ná»n | Label + thumbnail 32pt + chevron | áº¢nh nÃºi |
| Hiá»ƒn thá»‹ áº£nh bÃ¬a tháº» | Label + Toggle | ON (blue) |
| Chá»‰nh sá»­a nhÃ£n | Label + chevron | â€” |
| Äang theo dÃµi | Label + Toggle | OFF (gray) |
| CÃ i Ä‘áº·t thÃªm tháº» qua email | Label only | â€” |
| LÆ°u trá»¯ | Label + chevron | â€” (group riÃªng) |
| Hiá»ƒn thá»‹ | Label + value text | "KhÃ´ng gian lÃ m viá»‡c" |
| Quyá»n bÃ¬nh luáº­n | Label + value text | "ThÃ nh viÃªn" |
| BÃ¬nh chá»n | Label + value text | "ÄÃ£ táº¯t" |
| ThÃªm thÃ nh viÃªn | Label + value text | "Quáº£n trá»‹ viÃªn" |
| Tá»± tham gia | Label + Toggle | ON (blue) |

### Value text style

- Font: Body Regular
- Color: `#172B4D`
- Alignment: Right (trailing)

### Footnote / Helper text

```
Báº¡n pháº£i lÃ  quáº£n trá»‹ viÃªn cá»§a báº£ng Ä‘á»ƒ thay Ä‘á»•i cÃ i Ä‘áº·t nÃ y.
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Font | Footnote 13pt Regular |
| Color | `#6B778C` |
| Padding | 16pt horizontal, 8pt top |

### Background Thumbnail

- Size: 32Ã—32pt
- Border radius: 6pt
- Hiá»ƒn thá»‹ preview áº£nh phÃ´ng ná»n hiá»‡n táº¡i

---

## 17. Activity Screen â€” Filter & Variants

MÃ n hÃ¬nh Hoáº¡t Ä‘á»™ng cÃ³ 2 biáº¿n thá»ƒ header:

### Variant A â€” Tab chÃ­nh (Bottom tab "Hoáº¡t Ä‘á»™ng")

```
Hoáº¡t Ä‘á»™ng              [ðŸ“‹âœ“]  [Â·Â·Â·]

[Táº¥t cáº£ cÃ¡c loáº¡i â–¾]  [âœ“ ChÆ°a Ä‘á»c]
```

- Header: **Large Title** "Hoáº¡t Ä‘á»™ng"
- Filter chips: dáº¡ng pill, 2 chips song song

### Variant B â€” Sheet tá»« Board/Card

```
X    Hoáº¡t Ä‘á»™ng         [ðŸ“‹âœ“]  [Â·Â·Â·]

[âœ“ TÃ´i â–¾]  [âœ“ ChÆ°a Ä‘á»c]
```

- Header: dáº¡ng **sheet** vá»›i X Ä‘Ã³ng bÃªn trÃ¡i, Headline center
- Filter máº·c Ä‘á»‹nh: "TÃ´i" (lá»c theo ngÆ°á»i dÃ¹ng hiá»‡n táº¡i) + "ChÆ°a Ä‘á»c"

### Filter Chips

```
[âœ“ TÃ´i â–¾]        [âœ“ ChÆ°a Ä‘á»c]
```

| Thuá»™c tÃ­nh | GiÃ¡ trá»‹ |
|-----------|---------|
| Background | `#FFFFFF` (border `#0052CC`) |
| Text color | `#0052CC` |
| Checkmark | `âœ“` blue, 14pt |
| Dropdown arrow | `â–¾` â€” cÃ³ dropdown chá»n filter |
| Border radius | 20pt (pill) |
| Height | 32pt |
| Padding | 8pt 12pt |

**CÃ¡c loáº¡i filter:**
- **Loáº¡i**: Táº¥t cáº£ cÃ¡c loáº¡i / TÃ´i (theo ngÆ°á»i dÃ¹ng)
- **Tráº¡ng thÃ¡i Ä‘á»c**: ChÆ°a Ä‘á»c / Táº¥t cáº£

### Unread Indicator

- Thanh dá»c **3pt mÃ u `#0052CC`** sÃ¡t cáº¡nh trÃ¡i mÃ n hÃ¬nh
- KÃ©o dÃ i toÃ n chiá»u cao cá»§a activity row chÆ°a Ä‘á»c

### Activity Row â€” Anatomy

```
[3pt blue bar] [icon 24pt]  [actor bold] [verb] [card underline+bold] [board bold]
                            [timestamp footnote]
```

| Pháº§n | Style |
|------|-------|
| Icon | SF Symbol 24pt, `#8993A4` |
| Actor | Bold 17pt `#172B4D` |
| Verb | Regular 17pt `#172B4D` |
| Card name | Bold + Underline `#172B4D` (tappable) |
| Board name | Bold `#172B4D` |
| Timestamp | Footnote 13pt `#6B778C` |
| Row padding | 16pt horizontal, 12pt vertical |

---

## 18. Kanban Column â€” Confirmed States

Tá»« áº£nh Board chi tiáº¿t, xÃ¡c nháº­n cÃ¡c tráº¡ng thÃ¡i cá»™t thá»±c táº¿:

| TÃªn cá»™t | MÃ´ táº£ |
|---------|-------|
| `Backlog` | Tá»“n Ä‘á»ng â€” chÆ°a báº¯t Ä‘áº§u |
| `In Progress` | Äang thá»±c hiá»‡n |
| `Review` | Äang review / kiá»ƒm tra |
| `Done` | HoÃ n thÃ nh (suy Ä‘oÃ¡n) |

**LÆ°u Ã½**: NgÆ°á»i dÃ¹ng di chuyá»ƒn tháº» giá»¯a cÃ¡c cá»™t theo thá»© tá»± Backlog â†’ In Progress â†’ Review â†’ Done.

---

*Design System Ä‘Æ°á»£c trÃ­ch xuáº¥t tá»« áº£nh chá»¥p mÃ n hÃ¬nh á»©ng dá»¥ng Kabo â€” PhiÃªn báº£n 2026.10.1*

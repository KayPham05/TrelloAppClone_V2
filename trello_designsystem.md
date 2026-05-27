# Design System — Trellon Mobile App

> Phiên bản ứng dụng: `2026.10.1` | Build: `20260513.155745`  
> Ngôn ngữ: Tiếng Việt | Platform: iOS

---

## 1. Brand & Tổng quan

Trellon là ứng dụng quản lý công việc theo mô hình Kanban board, được thiết kế cho mobile-first. Giao diện sạch, rõ ràng, tập trung vào nội dung, tối giản nhưng đủ thông tin.

---

## 2. Màu sắc (Color Palette)

### Primary Colors

| Tên | Hex | Dùng cho |
|-----|-----|---------|
| Primary Blue | `#0052CC` | Nút CTA chính, icon active, link |
| Blue Light | `#579DFF` | Badge, highlight chọn |
| Background | `#F4F5F7` | Nền màn hình |
| Surface White | `#FFFFFF` | Card, sheet, modal |

### Priority Label Colors

| Tag | Hex | Mô tả |
|-----|-----|-------|
| P1 (Cao nhất) | `#F87462` | Cam đỏ — Ưu tiên cao |
| P2 | `#388BFF` | Xanh dương — Ưu tiên trung bình |
| P3 | `#4BCE97` | Xanh lá — Ưu tiên thấp |

### Type Tag Colors

| Tag | Hex | Mô tả |
|-----|-----|-------|
| FE (Frontend) | `#579DFF` | Xanh nhạt |
| Full-stack | `#F5A623` | Cam vàng |

### Label / Nhãn Colors (6 màu chuẩn)

| Tên | Hex |
|-----|-----|
| Green | `#4BCE97` |
| Yellow | `#CCA300` |
| Orange | `#F5A623` |
| Red | `#F87462` |
| Purple | `#9F8FEF` |
| Blue | `#579DFF` |

### Text Colors

| Tên | Hex | Dùng cho |
|-----|-----|---------|
| Text Primary | `#172B4D` | Tiêu đề, nội dung chính |
| Text Secondary | `#6B778C` | Phụ đề, metadata |
| Text Placeholder | `#A5ADBA` | Input placeholder |
| Text Link / Action | `#0052CC` | Link, nút văn bản |
| Text Destructive | `#CA3521` | Nút xóa ngày, cảnh báo |
| Text Disabled | `#C1C7D0` | Trạng thái vô hiệu |

### Trạng thái (State Colors)

| Trạng thái | Hex |
|-----------|-----|
| Success / Done | `#22A06B` |
| Warning | `#FF8B00` |
| Error / Danger | `#DE350B` |
| Info | `#0065FF` |
| Unread Indicator | `#0052CC` (dot) |

---

## 3. Typography

### Font

- **Font chính**: San Francisco (iOS system font) — `-apple-system, BlinkMacSystemFont`
- **Không sử dụng** custom typeface; toàn bộ theo iOS system typography

### Thang cỡ chữ

| Tên | Size | Weight | Line Height | Dùng cho |
|-----|------|--------|-------------|---------|
| Large Title | 34pt | Bold (700) | 41pt | Tiêu đề màn hình (Bảng, Tài khoản) |
| Title 1 | 28pt | Bold | 34pt | Tiêu đề section lớn (tháng 5) |
| Title 2 | 22pt | Semibold (600) | 28pt | Tên Board, tên Card |
| Title 3 | 20pt | Semibold | 25pt | Header card detail |
| Headline | 17pt | Semibold | 22pt | Tên task trong card |
| Body | 17pt | Regular (400) | 22pt | Nội dung mô tả, bình luận |
| Callout | 16pt | Regular | 21pt | Metadata phụ |
| Subheadline | 15pt | Regular | 20pt | Section header (KHÔNG GIAN LÀM VIỆC) |
| Footnote | 13pt | Regular | 18pt | Timestamp, thông tin phụ (14:52 23 thg 4) |
| Caption 1 | 12pt | Regular | 16pt | Label badge text |
| Caption 2 | 11pt | Regular | 13pt | Micro metadata |

### Đặc biệt

- **Section header dạng ALL CAPS**: `KHÔNG GIAN LÀM VIỆC` — Subheadline + Letter-spacing 0.5px + `#6B778C`
- **Badge text**: Caption 1 + Bold + White trên nền màu priority

---

## 4. Spacing & Layout

### Đơn vị cơ sở

- **Base unit**: 4pt
- **Grid**: 8pt grid

### Khoảng cách thông dụng

| Token | Value | Dùng cho |
|-------|-------|---------|
| `space-xs` | 4pt | Khoảng cách nhỏ nhất |
| `space-sm` | 8pt | Padding nội bộ card nhỏ |
| `space-md` | 12pt | Padding card thông thường |
| `space-lg` | 16pt | Padding màn hình |
| `space-xl` | 20pt | Khoảng cách section |
| `space-2xl` | 24pt | Header margin |
| `space-3xl` | 32pt | Khoảng cách lớn |

### Screen Margins

- **Horizontal padding màn hình**: 16pt (trái/phải)
- **Card padding nội bộ**: 12pt

---

## 5. Các thành phần UI (Components)

### 5.1 Bottom Navigation Bar

```
[Bảng] [Hộp thư đến] [Trình lập kế hoạch] [Hoạt động 🔴7] [Tài khoản]
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Height | 83pt (bao gồm safe area) |
| Icon size | 24×24pt |
| Label size | 10pt |
| Active color | `#0052CC` |
| Inactive color | `#6B778C` |
| Background | `#FFFFFF` |
| Border top | 0.5pt `#E3E6EA` |
| Badge (số thông báo) | Đỏ `#DE350B`, 18pt circle, 10pt white bold |

**Tabs:**
1. Bảng (Board icon)
2. Hộp thư đến (Inbox icon)
3. Trình lập kế hoạch (Calendar icon)
4. Hoạt động (Bell icon + badge số)
5. Tài khoản (Avatar circle)

---

### 5.2 Card (Thẻ Kanban)

```
┌─────────────────────────────┐
│ [P2] [FE]                   │
│ ○  Tên task                 │
│ 👁 ≡ ☑ 0/4         [Avatar] │
└─────────────────────────────┘
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Background | `#FFFFFF` |
| Border radius | 8pt |
| Shadow | `0 1pt 3pt rgba(9,30,66,0.13)` |
| Padding | 12pt |
| Margin bottom | 8pt |

**Cấu trúc Card:**
1. **Row 1 — Priority + Type tags**: Hàng ngang, gap 4pt
2. **Row 2 — Checkbox + Title**: `○` (16pt) + text Headline
3. **Row 3 — Metadata icons**: Mắt 👁, dòng kẻ ≡, checkbox ☑ `0/4`, avatar góc phải

**Card Cover Image**: Ảnh full-width, border-radius-top 8pt, height ~160pt

---

### 5.3 Priority & Type Badges

| Badge | Nền | Chữ | Border radius |
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
Backlog                    ···
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Font | Headline Semibold |
| Color | `#172B4D` |
| Background | `#F4F5F7` |
| Padding | 12pt 16pt |
| Menu icon (···) | 20pt, `#6B778C` |

**Các trạng thái cột:**
- `Backlog` — Tồn đọng
- `In Progress` — Đang làm
- `Done` / `Review` (suy đoán)

---

### 5.5 Button

#### Primary Button

```
[  Đánh giá chúng tôi trên App Store  ]
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Background | `#0052CC` |
| Text | White, 17pt Semibold |
| Height | 50pt |
| Border radius | 25pt (pill shape) |
| Margin horizontal | 16pt |

#### Text Button / Action Link

```
Di chuyển
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Color | `#0052CC` |
| Font | 17pt Regular |

#### Icon Button (Circle)

```
(+)  (Q)  ···
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Size | 36pt diameter |
| Background | `#FFFFFF` hoặc `#0052CC` |
| Icon | 20pt |
| Shadow | Subtle 1pt |

#### Destructive Text

```
Xóa ngày
```

| Color | `#CA3521` |
|-------|-----------|
| Font | 17pt Regular |
| Alignment | Center |

---

### 5.6 Sheet / Bottom Sheet

Modal từ dưới lên (Card Detail, Ngày hết hạn, Nhãn...)

| Thuộc tính | Giá trị |
|-----------|---------|
| Background | `#FFFFFF` |
| Border radius top | 12pt |
| Header title | 17pt Semibold, center |
| Close button (X) | 36pt circle, `#F4F5F7`, `#172B4D` icon |
| Save/Confirm button | Text `#0052CC`, 17pt Semibold |

---

### 5.7 List Row (Settings / Account)

```
⚙  Cài đặt ứng dụng                    >
```

| Thuộc tính | Giá trị |
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

**Size:** 51×31pt (iOS standard)

---

### 5.9 Avatar

| Size | Dùng cho |
|------|---------|
| 32pt | Card assignee |
| 40pt | Tab bar account |
| 56pt | Account page header |

**Fallback:** Chữ tắt tên (KP, DP) trên nền màu ngẫu nhiên từ palette (`#0052CC`, `#F5A623`, v.v.)  
**Border radius:** 50% (circle)

---

### 5.10 Date Picker

| Thuộc tính | Giá trị |
|-----------|---------|
| Sheet height | ~80% screen |
| Quick picks | Pill chips: "Hôm nay", "Ngày mai", "Tuần tới" |
| Calendar header | `tháng 5 năm 2026 >` — Title 2 Semibold |
| Today | Blue text `#0052CC` |
| Selected date | Blue circle `#0052CC`, white text |
| Navigation arrows | `#0052CC` |
| Day labels | TH 2...CN, Caption 2, `#6B778C` |
| Time section | Footnote label + pill chip value |
| Reminder | Row với picker inline |

---

### 5.11 Label Manager (Nhãn)

- **Header**: "Nhãn" — Title 2 Semibold | Nút X (đóng) + Nút + (thêm)
- **Color blindness toggle**: "Chế độ mù màu" + Switch
- **Label name display toggle**: "Hiển thị tên nhãn trên mặt trước thẻ" + Switch (ON mặc định)
- **Label row**: Full-width color bar, border-radius 6pt, height 48pt, edit icon `✏` bên phải

---

### 5.12 Search Bar

```
🔍  Bảng
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Background | `#FFFFFF` |
| Border radius | 10pt |
| Height | 36pt |
| Placeholder | `#A5ADBA`, Body Regular |
| Icon | 16pt, `#6B778C` |

---

### 5.13 Inbox Card (Hộp thư đến)

Dạng thẻ nổi bật trên màn hình Bảng

| Thuộc tính | Giá trị |
|-----------|---------|
| Background | `#EAF2FF` (light blue tint) |
| Border | 1pt `#B3D4FF` |
| Border radius | 12pt |
| Header | "Hộp thư đến 1" — Headline Semibold + Badge số |
| Edit icon | `✏` top right |

---

### 5.14 Activity Feed Row

```
🖥  [Tên] đã thêm bạn vào thẻ [Tên thẻ] ở bảng [Tên bảng]
    14:52 23 thg 4
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Icon | 24pt, xám nhạt |
| Tên người dùng | Bold `#172B4D` |
| Card link | Underline `#172B4D` |
| Timestamp | Footnote `#6B778C` |
| Separator | 0.5pt `#E3E6EA` |
| Unread indicator | 3pt blue bar bên trái trái |
| Filter chips | "Tất cả các loại ▾" + "✓ Chưa đọc" — pill shape |

---

### 5.15 Calendar / Planner View

| Thuộc tính | Giá trị |
|-----------|---------|
| Header | "tháng 5" — Large Title Bold |
| Ngày hiện tại | Purple circle `#6554C0` + CN/17 |
| Ngày khác | Day label + số, Regular |
| Trạng thái trống | "Chưa lên kế hoạch nào" — Body `#6B778C` |
| Separator | Full-width 1pt `#E3E6EA` |
| Time indicator line | Purple `#6554C0` full width |

---

## 6. Iconography

- **Style**: SF Symbols (iOS system icons) — Outlined, 22–24pt
- **Weight**: Regular
- **Colors**: Inherit từ context (active = `#0052CC`, default = `#6B778C`, destructive = `#CA3521`)

### Icon chuẩn dùng trong app

| Icon | Dùng cho |
|------|---------|
| `square.grid.2x2` | Tab Bảng |
| `tray` | Tab Hộp thư đến |
| `calendar` | Tab Trình lập kế hoạch |
| `bell` | Tab Hoạt động |
| `person.crop.circle` | Tab Tài khoản |
| `checkmark.square` | Checklist item |
| `paperclip` | Đính kèm |
| `eye` | Đang theo dõi |
| `line.3.horizontal` | Mô tả / menu |
| `circle` | Checkbox chưa hoàn thành |
| `checkmark.circle.fill` | Checkbox hoàn thành |
| `clock` | Ngày bắt đầu |
| `tag` | Nhãn |
| `photo` | Ảnh bìa |
| `plus` | Thêm mới |
| `xmark` | Đóng |
| `chevron.right` | Điều hướng sang phải |
| `square.and.arrow.up` | External link |
| `gearshape` | Cài đặt |
| `arrow.triangle.2.circlepath` | Đồng bộ |
| `wrench.and.screwdriver` | Dev tools |
| `questionmark.circle` | Trợ giúp |
| `person.badge.key` | Quản lý tài khoản |
| `trash` | Xóa |
| `bolt` | Beta |
| `rectangle.portrait.and.arrow.right` | Đăng xuất |
| `magnifyingglass` | Tìm kiếm |
| `pencil` | Chỉnh sửa |
| `star` | Star/Unstar |
| `arrow.up.arrow.down` | Di chuyển |

---

## 7. Motion & Animation

- **Sheet present**: Slide up từ dưới, duration 300ms, ease-out
- **Sheet dismiss**: Slide down, duration 250ms, ease-in
- **Card tap**: Scale 0.97, opacity 0.8, duration 100ms
- **Badge update**: Fade in, duration 200ms
- **Toggle**: Spring animation, iOS default
- **Scroll**: Momentum scroll (native iOS)

---

## 8. Navigation Patterns

### Kiểu màn hình

| Pattern | Dùng khi |
|---------|---------|
| Bottom Tab | Navigation chính (5 tabs) |
| Full-screen push | Board detail, Card detail (full màn hình) |
| Bottom Sheet | Modal ngắn (Date picker, Label, Di chuyển) |
| Half Sheet | Modal vừa (Card detail) |

### Header Actions

- **Left**: X (đóng) — circle button 36pt
- **Right**: + (thêm) hoặc ··· (menu) hoặc Lưu/text action
- **Center**: Tiêu đề màn hình — Title 2 Semibold

---

## 9. Card Detail Screen

Cấu trúc màn hình chi tiết thẻ (scroll view):

```
[Cover Image — Full width, ~200pt height]
[Photo icon] Ảnh bìa

○  Tên thẻ (Title 2 Bold)

[Color chip]  Tên list          Di chuyển (link)

─────────────────────────────────────
≡  Thêm mô tả

⏱  Ngày bắt đầu
   Ngày hết hạn

🏷  Nhãn

☑  Danh sách công việc              +

📎  Các tập tin đính kèm            +

:≡  Bình luận
    Không có nhận xét nào về thẻ này

─────────────────────────────────────
[KP Avatar]  Bình luận...          📎
```

---

## 10. Account Screen

```
[Tài khoản — Large Title]

┌────────────────────────────────┐
│  [KP]  Kha Pham                │
│        kha999...@gmail.com  [+]│
└────────────────────────────────┘

Không gian làm việc
┌────────────────────────────────┐
│  Không gian làm việc của bạn  >│
│  Không gian làm việc của khách>│
└────────────────────────────────┘

Cài đặt và công cụ
┌────────────────────────────────┐
│ ⚙  Cài đặt ứng dụng           │
│ ↺  Hàng đợi đồng bộ           │
│ 🔧 Công cụ cho Nhà phát triển >│
│ ?  Giới thiệu và trợ giúp     >│
│ 👤 Quản lý tài khoản         ↗ │
│ 🗑 Xóa tài khoản             ↗ │
│ ⚡ Tham gia thử nghiệm bản beta↗│
│ → Đăng xuất                   │
└────────────────────────────────┘

Thông tin ứng dụng
┌────────────────────────────────┐
│ Phiên bản ứng dụng:  2026.10.1 │
│ Bản dựng:    20260513.155745   │
└────────────────────────────────┘

[Đánh giá chúng tôi trên App Store]
```

---

## 11. Board List Screen (Màn hình Bảng)

```
Bảng                        🔍  +

[🔍 Bảng — Search bar]

┌─────────────────────────────┐
│ 📥 Hộp thư đến  1       ✏  │
│ [Thêm thẻ...]          📎  │
└─────────────────────────────┘

⏱ Bảng Gần Đây

[img] Ăn
[img] My Trellon                 🔵
[   ] Bảng Trello của tôi
[img] Học

KHÔNG GIAN LÀM VIỆC CỦA BẠN
👥 Trello Không gian làm việc    Bảng >

[img] Ăn
[   ] Bảng Trello của tôi
...
```

---

## 12. Responsive & Safe Areas

- **Status bar**: 44–54pt (dynamic island / notch)
- **Home indicator safe area**: 34pt bottom
- **Tab bar height**: 49pt + safe area
- **Min touch target**: 44×44pt (Apple HIG)
- **Viewport**: 390pt wide (iPhone 15 base)

---

## 13. Accessibility

- Contrast ratio tối thiểu: **4.5:1** (WCAG AA)
- Chế độ mù màu: Có toggle trong Label Manager
- Dynamic Type: Support scale font theo cài đặt hệ thống
- VoiceOver labels: Tất cả icon cần accessibility label
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

## 15. Board Menu Screen (Menu bảng)

Màn hình menu nhanh của board, dạng **full-screen sheet** (push từ phải hoặc bottom sheet lớn).

```
X    Menu bảng

[☆ Star] [👥 Members] [⬆ Share] [···More]

👤  Thành viên
    [Avatar1] [Avatar2] [Avatar3] ... (hàng ngang, 40pt circles)

ⓘ  Về bảng này                        >

📣  Gửi phản hồi...

🗄  Lưu trữ các thẻ được đánh dấu hoàn tất

⚡  Power-Ups
    Bình chọn, Thẻ bị "bỏ quên"...
    [🗓 Power-Up Lịch]                 >
    [Quản lý Power-Ups]                >

:≡  Hoạt động
→   [actor] đã di chuyển thẻ [tên thẻ]
    từ [list] tới [list]  •  1 giờ trước

↺   Đã đồng bộ
```

### Cấu trúc layout

| Khu vực | Mô tả |
|---------|-------|
| **Header** | X (đóng) trái + "Menu bảng" Headline center |
| **Quick actions row** | 4 nút icon ngang, border bottom 0.5pt `#E3E6EA` |
| **Member section** | Icon người + label "Thành viên" + hàng avatar |
| **Menu rows** | List row chuẩn, icon trái + label + chevron phải |
| **Power-Ups block** | Tiêu đề + subtitle nhỏ + sub-rows thụt vào |
| **Activity inline** | Tiêu đề section + 1 activity row preview |
| **Sync status** | Row cuối, icon sync + "Đã đồng bộ" |

### Quick Actions Row

```
[  ☆  ]  [  👥  ]  [  ⬆  ]  [  ···  ]
 Star    Members   Share    More
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Button width | 25% each (equal split) |
| Height | 52pt |
| Icon size | 22pt |
| Border | 0.5pt `#E3E6EA` ngăn cách + bottom |
| Icon color | `#172B4D` |
| Background | `#FFFFFF` |

### Member Avatars Strip

- Hiển thị tối đa **6–7 avatar** hàng ngang, gap 4pt
- Avatar 40pt circle
- Màu nền avatar ngẫu nhiên (xem Section 5.9)
- Có thể dùng ảnh profile thật

### Power-Ups Section

```
⚡  Power-Ups
    Bình chọn, Thẻ bị "bỏ quên"...      ← subtitle 13pt #6B778C

    [🗓]  Power-Up Lịch               >
          Quản lý Power-Ups            >
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Power-Up icon | 32pt rounded square, màu riêng (lịch = xanh dương) |
| Sub-row indent | 16pt so với icon chính |
| Subtitle | Footnote `#6B778C` |

### Activity Inline Preview

```
:≡  Hoạt động

→   phamtan606 đã di chuyển thẻ Mark as read + Delete notification
    từ danh sách In Progress tới danh sách Review
    1 giờ trước
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Action icon | Arrow right `→`, 20pt, `#6B778C` |
| Actor name | Bold `#172B4D` |
| Card name | Underline + Bold `#172B4D` |
| List names | Bold `#172B4D` |
| Timestamp relative | Footnote `#6B778C` ("1 giờ trước") |

### Sync Status Row

```
↺   Đã đồng bộ
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Icon | `arrow.clockwise`, 20pt, `#6B778C` |
| Text | Body Regular `#6B778C` |
| Position | Bottom of sheet |

---

## 16. Board Settings Screen (Thiết lập bảng)

Màn hình cài đặt board, dạng **push navigation** từ Menu bảng.

```
<   Thiết lập bảng

[Group 1]
Không gian làm việc    Báo cáo 💯
Phông nền              [img thumbnail] >
Hiển thị ảnh bìa thẻ              [Toggle ON]
Chỉnh sửa nhãn                    >
Đang theo dõi                     [Toggle OFF]
Cài đặt thêm thẻ qua email

[Group 2]
Lưu trữ                            >

[Group 3]
Hiển thị                Không gian làm việc
Quyền bình luận         Thành viên
Bình chọn               Đã tắt
Thêm thành viên         Quản trị viên

[Group 4]
Tự tham gia                        [Toggle ON]
Bạn phải là quản trị viên của bảng để thay đổi cài đặt này.
```

### Các setting rows

| Row | Loại | Giá trị mẫu |
|-----|------|------------|
| Không gian làm việc | Label + value text | "Báo cáo 💯" |
| Phông nền | Label + thumbnail 32pt + chevron | Ảnh núi |
| Hiển thị ảnh bìa thẻ | Label + Toggle | ON (blue) |
| Chỉnh sửa nhãn | Label + chevron | — |
| Đang theo dõi | Label + Toggle | OFF (gray) |
| Cài đặt thêm thẻ qua email | Label only | — |
| Lưu trữ | Label + chevron | — (group riêng) |
| Hiển thị | Label + value text | "Không gian làm việc" |
| Quyền bình luận | Label + value text | "Thành viên" |
| Bình chọn | Label + value text | "Đã tắt" |
| Thêm thành viên | Label + value text | "Quản trị viên" |
| Tự tham gia | Label + Toggle | ON (blue) |

### Value text style

- Font: Body Regular
- Color: `#172B4D`
- Alignment: Right (trailing)

### Footnote / Helper text

```
Bạn phải là quản trị viên của bảng để thay đổi cài đặt này.
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Font | Footnote 13pt Regular |
| Color | `#6B778C` |
| Padding | 16pt horizontal, 8pt top |

### Background Thumbnail

- Size: 32×32pt
- Border radius: 6pt
- Hiển thị preview ảnh phông nền hiện tại

---

## 17. Activity Screen — Filter & Variants

Màn hình Hoạt động có 2 biến thể header:

### Variant A — Tab chính (Bottom tab "Hoạt động")

```
Hoạt động              [📋✓]  [···]

[Tất cả các loại ▾]  [✓ Chưa đọc]
```

- Header: **Large Title** "Hoạt động"
- Filter chips: dạng pill, 2 chips song song

### Variant B — Sheet từ Board/Card

```
X    Hoạt động         [📋✓]  [···]

[✓ Tôi ▾]  [✓ Chưa đọc]
```

- Header: dạng **sheet** với X đóng bên trái, Headline center
- Filter mặc định: "Tôi" (lọc theo người dùng hiện tại) + "Chưa đọc"

### Filter Chips

```
[✓ Tôi ▾]        [✓ Chưa đọc]
```

| Thuộc tính | Giá trị |
|-----------|---------|
| Background | `#FFFFFF` (border `#0052CC`) |
| Text color | `#0052CC` |
| Checkmark | `✓` blue, 14pt |
| Dropdown arrow | `▾` — có dropdown chọn filter |
| Border radius | 20pt (pill) |
| Height | 32pt |
| Padding | 8pt 12pt |

**Các loại filter:**
- **Loại**: Tất cả các loại / Tôi (theo người dùng)
- **Trạng thái đọc**: Chưa đọc / Tất cả

### Unread Indicator

- Thanh dọc **3pt màu `#0052CC`** sát cạnh trái màn hình
- Kéo dài toàn chiều cao của activity row chưa đọc

### Activity Row — Anatomy

```
[3pt blue bar] [icon 24pt]  [actor bold] [verb] [card underline+bold] [board bold]
                            [timestamp footnote]
```

| Phần | Style |
|------|-------|
| Icon | SF Symbol 24pt, `#8993A4` |
| Actor | Bold 17pt `#172B4D` |
| Verb | Regular 17pt `#172B4D` |
| Card name | Bold + Underline `#172B4D` (tappable) |
| Board name | Bold `#172B4D` |
| Timestamp | Footnote 13pt `#6B778C` |
| Row padding | 16pt horizontal, 12pt vertical |

---

## 18. Kanban Column — Confirmed States

Từ ảnh Board chi tiết, xác nhận các trạng thái cột thực tế:

| Tên cột | Mô tả |
|---------|-------|
| `Backlog` | Tồn đọng — chưa bắt đầu |
| `In Progress` | Đang thực hiện |
| `Review` | Đang review / kiểm tra |
| `Done` | Hoàn thành (suy đoán) |

**Lưu ý**: Người dùng di chuyển thẻ giữa các cột theo thứ tự Backlog → In Progress → Review → Done.

---

*Design System được trích xuất từ ảnh chụp màn hình ứng dụng Trellon — Phiên bản 2026.10.1*

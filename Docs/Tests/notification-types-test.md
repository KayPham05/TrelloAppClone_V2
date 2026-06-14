# README Các Loại Thông Báo

## Hợp Đồng Activity

Thông báo Activity được backend lưu và trả về qua API:

```text
GET /v1/api/notifications?page=&pageSize=&tab=
```

Dạng response:

```text
items, unreadCount, hasMore
```

Các tab được hỗ trợ:

| Tab | Giá trị API | Ý nghĩa |
| --- | --- | --- |
| Tất cả | `all` | Tất cả thông báo của người dùng hiện tại. |
| Gửi tới tôi | `sentToMe` | Các thông báo trực tiếp chưa đọc. Backend lọc bằng `NotificationService.SentToMeTypes`; Flutter realtime lọc bằng `NotificationCubit._isSentToMe`. |
| Đã đọc | `read` | Chỉ các thông báo đã đọc. |

Realtime event được gửi qua `NotificationHub` tại:

```text
/hubs/notifications
```

Giao diện Activity đang nhận các event notification chung như `NotificationCreated`, `UnreadCountChanged`, `NotificationRead`, `NotificationReadAll`, và `NotificationDeleted`.

## Các Loại Thông Báo Đang Hoạt Động

Bảng dưới đây liệt kê các loại thông báo hiện được backend tạo từ các luồng nghiệp vụ và có thể hiển thị trong Activity.

| # | Backend type | Mã | Nhóm | Khi nào tạo | Ai nhận | Ví dụ nội dung |
| ---: | --- | ---: | --- | --- | --- | --- |
| 1 | `Assign` | `1` | Card | Một người dùng được phân công vào card. | Người vừa được phân công. | `Bạn đã được Nguyễn An phân công vào Important card.` |
| 2 | `CardUnassigned` | `7` | Card | Một người dùng bị xóa khỏi card. | Card member vừa bị xóa. | `Bạn đã bị Nguyễn An xóa khỏi Important card.` |
| 3 | `Move` | `2` | Card | Card được chuyển sang list khác qua `UpdateListUid` hoặc đổi list trong `UpdateCard`. | Card members, trừ người thực hiện thao tác. | `Nguyễn An đã chuyển Important card sang Done.` |
| 4 | `DueDateChanged` | `14` | Card | Hạn của card được thay đổi hoặc bị xóa. | Card members, trừ người thực hiện thao tác. | `Nguyễn An đã đổi hạn của Important card thành 2026-06-13 09:30.` |
| 5 | `DueDateReminder` | `15` | Card | Service nhắc hạn phát hiện card sắp đến hạn hoặc đã đến hạn. | Card members cần nhận nhắc hạn. | `Thẻ 'Important card' sẽ đến hạn vào 2026-06-13 09:30.` |
| 6 | `CardArchived` | `16` | Card | Card được lưu trữ. | Card members, trừ người thực hiện thao tác. | `Nguyễn An đã lưu trữ Important card` |
| 7 | `AttachmentAdded` | `17` | Card | Một tệp được thêm vào card. | Card members, trừ người thực hiện thao tác. | `Nguyễn An đã thêm một đính kèm spec.pdf vào Important card.` |
| 8 | `AttachmentRemoved` | `18` | Card | Một tệp bị xóa khỏi card. | Card members, trừ người thực hiện thao tác. | `Nguyễn An đã xóa một đính kèm delete.pdf khỏi Important card.` |
| 9 | `CardRenamed` | `19` | Card | Tên card thay đổi. | Card members, trừ người thực hiện thao tác. | `Nguyễn An đã đổi tên Important card thành Updated card.` |
| 10 | `Mention` | `4` | Comment/Card | Comment trong card mention card member bằng `@username`. | Card member được mention. | `Nguyễn An đã nhắc đến bạn trong Important card.` |
| 11 | `BoardMemberAdded` | `8` | Board | Một người dùng được thêm vào board. | Board member vừa được thêm. | `Bạn đã được Nguyễn An thêm vào Sprint Board.` |
| 12 | `BoardMemberRemoved` | `9` | Board | Một người dùng bị xóa khỏi board. | Board member vừa bị xóa. | `Bạn đã bị Nguyễn An xóa khỏi Sprint Board.` |
| 13 | `BoardRoleChanged` | `10` | Board | Vai trò board member thay đổi. | Người dùng có vai trò board bị đổi. | `Nguyễn An đã thay đổi vai trò của bạn trong Sprint Board từ Người xem -> Biên tập viên` |
| 14 | `WorkspaceMemberAdded` | `11` | Workspace | Một người dùng được thêm vào workspace. | Workspace member vừa được thêm. | `Bạn đã được Nguyễn An thêm vào Team Space.` |
| 15 | `WorkspaceMemberRemoved` | `12` | Workspace | Một người dùng bị xóa khỏi workspace. | Workspace member vừa bị xóa. | `Bạn đã bị Nguyễn An xóa khỏi Team Space.` |
| 16 | `WorkspaceRoleChanged` | `13` | Workspace | Vai trò workspace member thay đổi. | Người dùng có vai trò workspace bị đổi. | `Nguyễn An đã thay đổi vai trò của bạn từ Thành viên -> Quản trị viên` |

## Nội Dung Nhắc Hạn Card

| Mốc nhắc hạn | Tiêu đề | Mẫu nội dung |
| --- | --- | --- |
| `OneDayBefore` | `Thẻ sắp đến hạn trong 1 ngày` | `Thẻ '[CARD]' sẽ đến hạn vào yyyy-MM-dd HH:mm.` |
| `OneHourBefore` | `Thẻ sắp đến hạn trong 1 giờ` | `Thẻ '[CARD]' sẽ đến hạn lúc yyyy-MM-dd HH:mm.` |
| `DueNow` | `Thẻ đã đến hạn` | `Thẻ '[CARD]' đã đến hạn hoặc quá hạn.` |

## Enum Cũ Hoặc Đang Dự Phòng

Các enum này vẫn tồn tại trong backend và Flutter parser, nhưng hiện tại các luồng nghiệp vụ backend không tạo notification row cho chúng.

| Backend type | Mã | Trạng thái hiện tại |
| --- | ---: | --- |
| `Comment` | `0` | Giá trị dự phòng hoặc fallback khi parse. Luồng mention trong comment hiện tạo `Mention`, không tạo `Comment`. |
| `Due` | `3` | Giá trị cũ hoặc dự phòng. Các luồng hạn card hiện tạo `DueDateChanged` và `DueDateReminder`. |
| `Workspace` | `5` | Giá trị cũ hoặc dự phòng. Các luồng workspace hiện tạo các type workspace theo member cụ thể. |
| `Board` | `6` | Giá trị cũ hoặc dự phòng. Các luồng board hiện tạo các type board theo member cụ thể. |

## Các Type Trực Tiếp Trong Tab Gửi Tới Tôi

Tab `sentToMe` cần bao gồm các thông báo chưa đọc thuộc các type sau:

| Backend type | Flutter enum |
| --- | --- |
| `Assign` | `NotificationTypeEnum.assign` |
| `CardUnassigned` | `NotificationTypeEnum.cardUnassigned` |
| `Mention` | `NotificationTypeEnum.mention` |
| `BoardMemberAdded` | `NotificationTypeEnum.boardMemberAdded` |
| `BoardMemberRemoved` | `NotificationTypeEnum.boardMemberRemoved` |
| `BoardRoleChanged` | `NotificationTypeEnum.boardRoleChanged` |
| `WorkspaceMemberAdded` | `NotificationTypeEnum.workspaceMemberAdded` |
| `WorkspaceMemberRemoved` | `NotificationTypeEnum.workspaceMemberRemoved` |
| `WorkspaceRoleChanged` | `NotificationTypeEnum.workspaceRoleChanged` |
| `Move` | `NotificationTypeEnum.move` |
| `DueDateChanged` | `NotificationTypeEnum.dueDateChanged` |
| `DueDateReminder` | `NotificationTypeEnum.dueDateReminder` |
| `CardArchived` | `NotificationTypeEnum.cardArchived` |
| `AttachmentAdded` | `NotificationTypeEnum.attachmentAdded` |
| `AttachmentRemoved` | `NotificationTypeEnum.attachmentRemoved` |
| `CardRenamed` | `NotificationTypeEnum.cardRenamed` |

## Nhãn Vai Trò

Backend map role gốc sang nhãn tiếng Việt khi tạo message thông báo:

| Role gốc | Nhãn tiếng Việt |
| --- | --- |
| `Owner` | `Chủ sở hữu` |
| `Admin` | `Quản trị viên` |
| `Member` | `Thành viên` |
| `Viewer` | `Người xem` |
| `Editor` | `Biên tập viên` |
| `Assignee` | `Người thực hiện` |
| `Observer` | `Người theo dõi` |

## Bản Đồ Triển Khai

| Khu vực | File chính |
| --- | --- |
| Backend enum | `C#/TodoAppAPI/Models/NotificationType.cs` |
| Backend lọc Activity | `C#/TodoAppAPI/Service/NotificationService.cs` |
| Card notifications | `C#/TodoAppAPI/Service/CardMemberService.cs`, `C#/TodoAppAPI/Service/CardsService.cs`, `C#/TodoAppAPI/Service/CardDueDateReminderService.cs`, `C#/TodoAppAPI/Service/CommentService.cs` |
| Board notifications | `C#/TodoAppAPI/Service/BoardMemberService.cs` |
| Workspace notifications | `C#/TodoAppAPI/Service/WorkspaceService.cs` |
| Flutter enum parsing | `Flutter/trellon_flutter/lib/features/activity/domain/entities/notification_entity.dart` |
| Flutter lọc realtime cho tab Gửi tới tôi | `Flutter/trellon_flutter/lib/features/activity/presentation/cubit/notification_cubit.dart` |
| Flutter Activity icons/UI | `Flutter/trellon_flutter/lib/features/activity/presentation/pages/activity_page.dart` |
| Backend tests | `C#/TodoAppAPI.Tests/NotificationCoverageTests.cs`, `C#/TodoAppAPI.Tests/CardDueDateReminderServiceTests.cs`, `C#/TodoAppAPI.Tests/NotificationBroadcastIsolationTests.cs` |
| Flutter tests | `Flutter/trellon_flutter/test/features/activity/data/models/notification_model_test.dart`, `Flutter/trellon_flutter/test/features/activity/presentation/cubit/notification_cubit_test.dart` |

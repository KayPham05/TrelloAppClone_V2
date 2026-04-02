import '../domain/entities/board_entity.dart';
import '../domain/entities/workspace_entity.dart';
import '../domain/entities/list_entity.dart';
import '../../card/domain/entities/card_entity.dart';

class BoardMockData {
  // ── Mock Boards ──────────────────────────────────────────────────────────
  static final List<BoardEntity> personalBoards = [
    const BoardEntity(
      id: 'board-1',
      name: 'Bảng Trello của tôi',
      visibility: 'Private',
      isPersonal: true,
      workspaceName: 'Cá nhân',
      coverColor: '#9C93F6',
    ),
    const BoardEntity(
      id: 'board-2',
      name: 'AirlineReservation - Winform',
      visibility: 'Private',
      isPersonal: true,
      workspaceName: 'Cá nhân',
      coverColor: '#D29034',
    ),
    const BoardEntity(
      id: 'board-3',
      name: 'TestTrello',
      visibility: 'Private',
      isPersonal: true,
      workspaceName: 'Cá nhân',
      coverColor: '#0079BF',
    ),
    const BoardEntity(
      id: 'board-4',
      name: 'Test',
      visibility: 'Private',
      isPersonal: true,
      workspaceName: 'Cá nhân',
      coverColor: '#838C91',
    ),
  ];

  static final List<WorkspaceEntity> workspaces = [
    WorkspaceEntity(
      id: 'ws-1',
      name: 'Time & Project Management',
      description: 'Quản lý thời gian và dự án nhóm',
      boards: [
        const BoardEntity(
          id: 'board-ws1-1',
          name: 'Sprint Planning Q1',
          visibility: 'Public',
          isPersonal: false,
          workspaceId: 'ws-1',
          workspaceName: 'Time & Project Management',
          coverColor: '#519839',
        ),
        const BoardEntity(
          id: 'board-ws1-2',
          name: 'Design System',
          visibility: 'Private',
          isPersonal: false,
          workspaceId: 'ws-1',
          workspaceName: 'Time & Project Management',
          coverColor: '#CD5A91',
        ),
        const BoardEntity(
          id: 'board-ws1-3',
          name: 'Bug Tracker',
          visibility: 'Private',
          isPersonal: false,
          workspaceId: 'ws-1',
          workspaceName: 'Time & Project Management',
          coverColor: '#B04632',
        ),
      ],
    ),
    WorkspaceEntity(
      id: 'ws-2',
      name: 'Trello Không gian làm việc',
      description: 'Workspace mặc định',
      boards: [
        const BoardEntity(
          id: 'board-ws2-1',
          name: 'Bảng Trello của tôi',
          visibility: 'Private',
          isPersonal: false,
          workspaceId: 'ws-2',
          workspaceName: 'Trello Không gian làm việc',
          coverColor: '#9C93F6',
        ),
        const BoardEntity(
          id: 'board-ws2-2',
          name: 'Test',
          visibility: 'Private',
          isPersonal: false,
          workspaceId: 'ws-2',
          workspaceName: 'Trello Không gian làm việc',
          coverColor: '#D29034',
        ),
      ],
    ),
  ];

  // ── Mock Lists & Cards for Board Detail ──────────────────────────────────
  static final Map<String, List<ListEntity>> boardLists = {
    'board-1': [
      ListEntity(
        id: 'list-1',
        name: 'Cần làm',
        position: 0,
        boardId: 'board-1',
        cards: [
          const CardEntity(id: 'card-1', title: 'Thiết kế UI màn hình Login', position: 0, status: 'To Do', listId: 'list-1'),
          const CardEntity(id: 'card-2', title: 'Setup project Flutter', position: 1, status: 'To Do', listId: 'list-1'),
          const CardEntity(id: 'card-3', title: 'Tích hợp API auth', position: 2, description: 'Kết nối với backend C#', listId: 'list-1'),
        ],
      ),
      ListEntity(
        id: 'list-2',
        name: 'Đang làm',
        position: 1,
        boardId: 'board-1',
        cards: [
          const CardEntity(id: 'card-4', title: 'Implement Board screen', position: 0, status: 'In Progress', listId: 'list-2'),
          const CardEntity(id: 'card-5', title: 'Viết clean architecture', position: 1, status: 'In Progress', listId: 'list-2'),
        ],
      ),
      ListEntity(
        id: 'list-3',
        name: 'Hoàn thành',
        position: 2,
        boardId: 'board-1',
        cards: [
          const CardEntity(id: 'card-6', title: 'Setup project structure', position: 0, status: 'Done', listId: 'list-3'),
          const CardEntity(id: 'card-7', title: 'Cài đặt dependencies', position: 1, status: 'Done', listId: 'list-3'),
          const CardEntity(id: 'card-8', title: 'Phân tích yêu cầu', position: 2, status: 'Done', listId: 'list-3'),
        ],
      ),
      ListEntity(
        id: 'list-4',
        name: 'Review',
        position: 3,
        boardId: 'board-1',
        cards: [
          const CardEntity(id: 'card-9', title: 'Code review PR #12', position: 0, status: 'Review', listId: 'list-4'),
        ],
      ),
    ],
  };

  static List<ListEntity> getListsForBoard(String boardId) {
    return boardLists[boardId] ?? _generateDefaultLists(boardId);
  }

  static List<ListEntity> _generateDefaultLists(String boardId) {
    return [
      ListEntity(
        id: 'list-default-1-$boardId',
        name: 'Cần làm',
        position: 0,
        boardId: boardId,
        cards: [
          CardEntity(id: 'card-d1-$boardId', title: 'Task 1', position: 0, listId: 'list-default-1-$boardId'),
          CardEntity(id: 'card-d2-$boardId', title: 'Task 2', position: 1, listId: 'list-default-1-$boardId'),
        ],
      ),
      ListEntity(
        id: 'list-default-2-$boardId',
        name: 'Đang làm',
        position: 1,
        boardId: boardId,
        cards: [],
      ),
      ListEntity(
        id: 'list-default-3-$boardId',
        name: 'Hoàn thành',
        position: 2,
        boardId: boardId,
        cards: [],
      ),
    ];
  }
}

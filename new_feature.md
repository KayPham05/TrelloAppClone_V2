# TrellOn Workflow Intelligence System
## idea.plan

---

# 1. Project Vision

## Current System

TrellOn hiện tại là:
- Kanban board management system
- Workspace → Board → List → Card
- task collaboration platform

Kiến trúc hiện tại phù hợp với:
- Agile
- Scrum
- Kanban
- basic task tracking

---

# 2. New Product Direction

## Goal

Mở rộng TrellOn thành:

Visual Workflow Intelligence Platform

Không chỉ quản lý task,
mà còn:
- quản lý quy trình
- workflow dependency
- process orchestration
- workflow visualization
- workflow interaction
- workflow intelligence

---

# 3. Core Idea

## Workflow Graph System

Cho phép tạo:
- dependency giữa các board
- dependency giữa workflow
- trực quan hóa process bằng graph

Ví dụ:

[Design]
    ↓
[Frontend]
    ↓
[Testing]

hoặc:

[A] ──► [C]
[B] ──► [C]
[C] ──► [D]

---

# 4. Main Concept

## Board = Node

Mỗi board sẽ được render thành:
- visual node
- interactive component

---

## Workflow Link = Edge

Mỗi dependency sẽ là:
- edge
- connection
- process relation

---

# 5. Workflow Philosophy

## IMPORTANT

Workflow KHÔNG bắt buộc.

Boards trong workspace:
- không cần liên kết với nhau
- chỉ liên kết khi user muốn

Điều này đảm bảo:
- giữ được tính đơn giản của Trello
- workflow là optional layer
- tránh UX phức tạp

---

# 6. Workflow Modes

## Normal Mode

Trello-like:
- boards độc lập
- quản lý task truyền thống

---

## Workflow Mode

Cho phép:
- graph view
- dependency management
- workflow orchestration

---

# 7. Workflow Designer

## Dedicated Workflow Design Interface

Workspace sẽ có thêm:

- Boards
- Calendar
- Analytics
- Workflow Designer

---

# 8. Workflow Designer UI

## Main Layout

┌────────────────────────────────────┐
│ Toolbar                            │
├─────────────┬──────────────────────┤
│ Left Panel  │                      │
│             │                      │
│ Components  │      Canvas          │
│             │                      │
│             │                      │
├─────────────┴──────────────────────┤
│ Bottom Info / Status               │
└────────────────────────────────────┘

---

# 9. Toolbar Components

## Workflow Elements

Toolbar sẽ chứa:

- Board Node
- List Node
- Card Node
- Dependency Edge
- Approval Node
- Condition Node
- Note Node

---

# 10. Node Creation Flow

## Visual-first creation

Ví dụ:
- kéo Board Node ra canvas
- popup config xuất hiện
- nhập:
  - board name
  - description
  - members
  - labels
  - status
- click Create

=> board thật được tạo ngay lập tức

---

# 11. Workflow Canvas

## Main Features

Canvas hỗ trợ:
- drag node
- connect edge
- delete edge
- zoom
- pan
- minimap
- context menu
- node interaction

---

# 12. Chosen Frontend Graph Library

## React Flow

Official:
https://reactflow.dev

---

## Reason for choosing

React Flow hỗ trợ:
- node editor
- edge system
- drag/drop
- zoom/pan
- minimap
- custom node
- custom edge
- event system
- high scalability
- React integration

---

# 13. Frontend Stack

## Core Stack

- React
- TypeScript
- Vite

---

## Graph System

- React Flow

---

## Styling

- TailwindCSS

---

## State Management

Recommended:
- Zustand

Alternative:
- Redux Toolkit

---

## Realtime

- SignalR

---

# 14. Backend Stack

## Core

- ASP.NET Core Web API
- Entity Framework Core
- SQL Server

---

## Realtime

- SignalR

---

# 15. Backend Responsibilities

Backend xử lý:
- workflow validation
- dependency management
- unlock conditions
- synchronization
- graph persistence
- workflow state
- permission validation

---

# 16. Database Architecture

# 16.1 Existing Core

Workspace
 └── Boards
      └── Lists
           └── Cards

---

# 16.2 New Workflow Layer

WorkflowDesign
 ├── WorkflowNodes
 ├── WorkflowEdges
 └── WorkflowStates

---

# 17. Database Design

## WorkflowDesigns

```sql
CREATE TABLE WorkflowDesigns (
    WorkflowDesignUId NVARCHAR(128) PRIMARY KEY,

    WorkspaceUId NVARCHAR(128) NOT NULL,

    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000),

    CreatedByUserUId NVARCHAR(128),

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);
## WorkflowNodes

CREATE TABLE WorkflowNodes (
    WorkflowNodeUId NVARCHAR(128) PRIMARY KEY,

    WorkflowDesignUId NVARCHAR(128) NOT NULL,

    NodeType NVARCHAR(50) NOT NULL,

    ReferenceId NVARCHAR(128),

    PositionX FLOAT NOT NULL,
    PositionY FLOAT NOT NULL,

    Width FLOAT,
    Height FLOAT,

    MetadataJson NVARCHAR(MAX),

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_WorkflowNodes_Design
        FOREIGN KEY (WorkflowDesignUId)
        REFERENCES WorkflowDesigns(WorkflowDesignUId)
);

## WorkflowEdges
CREATE TABLE WorkflowEdges (
    WorkflowEdgeUId NVARCHAR(128) PRIMARY KEY,

    SourceNodeUId NVARCHAR(128) NOT NULL,
    TargetNodeUId NVARCHAR(128) NOT NULL,

    EdgeType NVARCHAR(50) NOT NULL,
    ConditionType NVARCHAR(50),

    IsBlocking BIT NOT NULL DEFAULT 0,
    IsEnabled BIT NOT NULL DEFAULT 1,

    MetadataJson NVARCHAR(MAX),

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);

## Board Workflow Status

ALTER TABLE Boards
ADD WorkflowStatus NVARCHAR(50)
DEFAULT 'READY';

# 18. Workflow States

## Board States

LOCKED
READY
IN_PROGRESS
WAITING_REVIEW
BLOCKED
DONE
ARCHIVED

20. Unlock Conditions
Supported Conditions
ALL_DONE
ANY_DONE
MANUAL_APPROVAL
DATE_TRIGGER
CUSTOM_RULE
21. Optional Workflow Locking
IMPORTANT FEATURE

Workflow locking có thể:

bật
tắt
If disabled

Dependency chỉ dùng cho:

visualization
tracking
reference
If enabled

Workflow được enforce:

board bị lock
workflow state bị kiểm soát
dependency được validate
22. Frontend Workflow Mapping
React Flow Node

Board → Node

Ví dụ:

{
  "id": "boardA",
  "position": {
    "x": 100,
    "y": 200
  },
  "data": {
    "title": "Frontend",
    "status": "IN_PROGRESS"
  }
}
React Flow Edge

WorkflowEdge → Edge

{
  "id": "edge_A_B",
  "source": "A",
  "target": "B",
  "type": "finish_to_start"
}
23. Suggested APIs
Workflow APIs

GET /api/workflow/{workspaceId}

POST /api/workflow/node

POST /api/workflow/edge

DELETE /api/workflow/node/{id}

DELETE /api/workflow/edge/{id}

PATCH /api/workflow/node-position

PATCH /api/workflow/status

24. Case Studies & Problem Solving
24.1 Circular Dependency
Problem

A → B → C → A

gây loop workflow.

Solution

Backend validation:

detect cycle
reject invalid edge

Workflow graph phải là:
Directed Acyclic Graph (DAG)

24.2 Massive Graph
Problem

Workflow quá lớn:

lag
khó nhìn
UX rối
Solution
minimap
zoom level
grouping
collapsible nodes
lazy rendering
graph virtualization
24.3 Concurrent Editing
Problem

Nhiều user chỉnh workflow cùng lúc.

Solution
SignalR realtime sync
optimistic update
conflict resolution
version tracking
24.4 Deleted Board
Problem

Board bị xóa nhưng workflow edge vẫn tồn tại.

Solution
cascade cleanup
hoặc:
soft delete
orphan validation
24.5 Invalid Dependency
Problem

User tạo dependency vô nghĩa.

Ví dụ:

self reference
duplicate edge
Solution

Backend validation:

no self-loop
no duplicate edge
validate workflow rules
24.6 Workflow Complexity Explosion
Problem

Quá nhiều node type khiến UX phức tạp.

Solution
Phase strategy

Phase 1:

Board node
Dependency edge

Phase 2:

workflow logic

Phase 3:

advanced node system
24.7 Mobile UX
Problem

Graph editor khó dùng trên mobile.

Solution

Desktop/Web:

full workflow editor

Mobile:

workflow viewer
lightweight interaction
25. Recommended Development Phases
Phase 1 — Workflow Visualization

Features:

graph rendering
board node
edge rendering
zoom/pan
minimap
Phase 2 — Interactive Workflow Editing

Features:

connect node
delete edge
node dragging
save position
context menu
Phase 3 — Workflow Logic

Features:

workflow states
unlock conditions
dependency validation
blocking system
Phase 4 — Workflow Automation

Features:

auto unlock
auto notification
automation trigger
workflow rules
Phase 5 — Advanced Workflow Intelligence

Features:

analytics
bottleneck detection
AI assistant
workflow simulation
26. Product Identity

TrellOn sẽ không còn là:
“Trello Clone”

Mà trở thành:

Visual Workflow Orchestration Platform

kết hợp:

Kanban
Workflow Graph
Dependency Management
Visual Process Design
Workflow Intelligence
Automation
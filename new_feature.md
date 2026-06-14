# Kabo Workflow Intelligence System
## idea.plan

---

# 1. Project Vision

## Current System

Kabo hiá»‡n táº¡i lÃ :
- Kanban board management system
- Workspace â†’ Board â†’ List â†’ Card
- task collaboration platform

Kiáº¿n trÃºc hiá»‡n táº¡i phÃ¹ há»£p vá»›i:
- Agile
- Scrum
- Kanban
- basic task tracking

---

# 2. New Product Direction

## Goal

Má»Ÿ rá»™ng Kabo thÃ nh:

Visual Workflow Intelligence Platform

KhÃ´ng chá»‰ quáº£n lÃ½ task,
mÃ  cÃ²n:
- quáº£n lÃ½ quy trÃ¬nh
- workflow dependency
- process orchestration
- workflow visualization
- workflow interaction
- workflow intelligence

---

# 3. Core Idea

## Workflow Graph System

Cho phÃ©p táº¡o:
- dependency giá»¯a cÃ¡c board
- dependency giá»¯a workflow
- trá»±c quan hÃ³a process báº±ng graph

VÃ­ dá»¥:

[Design]
    â†“
[Frontend]
    â†“
[Testing]

hoáº·c:

[A] â”€â”€â–º [C]
[B] â”€â”€â–º [C]
[C] â”€â”€â–º [D]

---

# 4. Main Concept

## Board = Node

Má»—i board sáº½ Ä‘Æ°á»£c render thÃ nh:
- visual node
- interactive component

---

## Workflow Link = Edge

Má»—i dependency sáº½ lÃ :
- edge
- connection
- process relation

---

# 5. Workflow Philosophy

## IMPORTANT

Workflow KHÃ”NG báº¯t buá»™c.

Boards trong workspace:
- khÃ´ng cáº§n liÃªn káº¿t vá»›i nhau
- chá»‰ liÃªn káº¿t khi user muá»‘n

Äiá»u nÃ y Ä‘áº£m báº£o:
- giá»¯ Ä‘Æ°á»£c tÃ­nh Ä‘Æ¡n giáº£n cá»§a Trello
- workflow lÃ  optional layer
- trÃ¡nh UX phá»©c táº¡p

---

# 6. Workflow Modes

## Normal Mode

Trello-like:
- boards Ä‘á»™c láº­p
- quáº£n lÃ½ task truyá»n thá»‘ng

---

## Workflow Mode

Cho phÃ©p:
- graph view
- dependency management
- workflow orchestration

---

# 7. Workflow Designer

## Dedicated Workflow Design Interface

Workspace sáº½ cÃ³ thÃªm:

- Boards
- Calendar
- Analytics
- Workflow Designer

---

# 8. Workflow Designer UI

## Main Layout

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Toolbar                            â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Left Panel  â”‚                      â”‚
â”‚             â”‚                      â”‚
â”‚ Components  â”‚      Canvas          â”‚
â”‚             â”‚                      â”‚
â”‚             â”‚                      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Bottom Info / Status               â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

---

# 9. Toolbar Components

## Workflow Elements

Toolbar sáº½ chá»©a:

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

VÃ­ dá»¥:
- kÃ©o Board Node ra canvas
- popup config xuáº¥t hiá»‡n
- nháº­p:
  - board name
  - description
  - members
  - labels
  - status
- click Create

=> board tháº­t Ä‘Æ°á»£c táº¡o ngay láº­p tá»©c

---

# 11. Workflow Canvas

## Main Features

Canvas há»— trá»£:
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

React Flow há»— trá»£:
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

Backend xá»­ lÃ½:
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
 â””â”€â”€ Boards
      â””â”€â”€ Lists
           â””â”€â”€ Cards

---

# 16.2 New Workflow Layer

WorkflowDesign
 â”œâ”€â”€ WorkflowNodes
 â”œâ”€â”€ WorkflowEdges
 â””â”€â”€ WorkflowStates

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

Workflow locking cÃ³ thá»ƒ:

báº­t
táº¯t
If disabled

Dependency chá»‰ dÃ¹ng cho:

visualization
tracking
reference
If enabled

Workflow Ä‘Æ°á»£c enforce:

board bá»‹ lock
workflow state bá»‹ kiá»ƒm soÃ¡t
dependency Ä‘Æ°á»£c validate
22. Frontend Workflow Mapping
React Flow Node

Board â†’ Node

VÃ­ dá»¥:

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

WorkflowEdge â†’ Edge

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

A â†’ B â†’ C â†’ A

gÃ¢y loop workflow.

Solution

Backend validation:

detect cycle
reject invalid edge

Workflow graph pháº£i lÃ :
Directed Acyclic Graph (DAG)

24.2 Massive Graph
Problem

Workflow quÃ¡ lá»›n:

lag
khÃ³ nhÃ¬n
UX rá»‘i
Solution
minimap
zoom level
grouping
collapsible nodes
lazy rendering
graph virtualization
24.3 Concurrent Editing
Problem

Nhiá»u user chá»‰nh workflow cÃ¹ng lÃºc.

Solution
SignalR realtime sync
optimistic update
conflict resolution
version tracking
24.4 Deleted Board
Problem

Board bá»‹ xÃ³a nhÆ°ng workflow edge váº«n tá»“n táº¡i.

Solution
cascade cleanup
hoáº·c:
soft delete
orphan validation
24.5 Invalid Dependency
Problem

User táº¡o dependency vÃ´ nghÄ©a.

VÃ­ dá»¥:

self reference
duplicate edge
Solution

Backend validation:

no self-loop
no duplicate edge
validate workflow rules
24.6 Workflow Complexity Explosion
Problem

QuÃ¡ nhiá»u node type khiáº¿n UX phá»©c táº¡p.

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

Graph editor khÃ³ dÃ¹ng trÃªn mobile.

Solution

Desktop/Web:

full workflow editor

Mobile:

workflow viewer
lightweight interaction
25. Recommended Development Phases
Phase 1 â€” Workflow Visualization

Features:

graph rendering
board node
edge rendering
zoom/pan
minimap
Phase 2 â€” Interactive Workflow Editing

Features:

connect node
delete edge
node dragging
save position
context menu
Phase 3 â€” Workflow Logic

Features:

workflow states
unlock conditions
dependency validation
blocking system
Phase 4 â€” Workflow Automation

Features:

auto unlock
auto notification
automation trigger
workflow rules
Phase 5 â€” Advanced Workflow Intelligence

Features:

analytics
bottleneck detection
AI assistant
workflow simulation
26. Product Identity

Kabo sáº½ khÃ´ng cÃ²n lÃ :
â€œTrello Cloneâ€

MÃ  trá»Ÿ thÃ nh:

Visual Workflow Orchestration Platform

káº¿t há»£p:

Kanban
Workflow Graph
Dependency Management
Visual Process Design
Workflow Intelligence
Automation
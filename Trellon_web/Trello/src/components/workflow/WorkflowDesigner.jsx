import React, { useCallback, useEffect, useMemo, useState } from "react";
import ReactFlow, {
  addEdge,
  Background,
  Controls,
  MiniMap,
  ReactFlowProvider,
  useEdgesState,
  useNodesState,
} from "reactflow";
import "reactflow/dist/style.css";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import { GitFork, RefreshCw, Plus, LayoutGrid } from "lucide-react";

import BoardNode from "./BoardNode";
import CustomEdge from "./CustomEdge";
import AddNodePanel from "./AddNodePanel";
import BoardSettingsPanel from "./BoardSettingsPanel";
import {
  addWorkflowEdgeAPI,
  addWorkflowNodeAPI,
  createWorkflowAPI,
  deleteWorkflowEdgeAPI,
  deleteWorkflowNodeAPI,
  getWorkflowAPI,
  updateNodePositionAPI,
  updateWorkflowEdgeAPI,
} from "../../services/WorkflowAPI";
import { getWorkspaceBoardsAPI, getWorkspaceMembersAPI } from "../../services/WorkspaceAPI";
import { createBoardAPI, deleteBoardAPI, getBoardByIdAPI } from "../../services/BoardAPI";

const NODE_TYPES = { boardNode: BoardNode };
const EDGE_TYPES = { custom: CustomEdge };

// ─── Inner component ─────────────────────────────────────────────────────────
function WorkflowCanvas({ workspaceId, user }) {
  const navigate = useNavigate();
  const [nodes, setNodes, onNodesChange] = useNodesState([]);
  const [edges, setEdges, onEdgesChange] = useEdgesState([]);
  const [designId, setDesignId] = useState(null);
  const [boards, setBoards] = useState([]);
  const [workspaceMembers, setWorkspaceMembers] = useState([]);
  const [loadingBoards, setLoadingBoards] = useState(false);
  const [saving, setSaving] = useState(false);

  // Create-board modal
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newBoardName, setNewBoardName] = useState("");
  const [creatingBoard, setCreatingBoard] = useState(false);

  // Board settings panel (from node gear icon)
  const [settingsBoard, setSettingsBoard] = useState(null);

  // ── Load workspace members ────────────────────────────────────────────────
  const loadWorkspaceMembers = useCallback(async () => {
    try {
      const data = await getWorkspaceMembersAPI(workspaceId);
      setWorkspaceMembers(Array.isArray(data) ? data : []);
    } catch { /* non-critical */ }
  }, [workspaceId]);

  // ── Load boards ───────────────────────────────────────────────────────────
  const loadBoards = useCallback(async () => {
    setLoadingBoards(true);
    try {
      const data = await getWorkspaceBoardsAPI(workspaceId, user?.userUId);
      setBoards(Array.isArray(data) ? data : []);
    } catch { toast.error("Không tải được danh sách board."); }
    finally { setLoadingBoards(false); }
  }, [workspaceId, user?.userUId]);

  // ── Load workflow ─────────────────────────────────────────────────────────
  const loadWorkflow = useCallback(async () => {
    try {
      const data = await getWorkflowAPI(workspaceId);
      setDesignId(data.workflowDesignUId || null);

      setNodes(
        (data.nodes ?? []).map((n) => ({
          id: n.workflowNodeUId,
          type: "boardNode",
          position: { x: n.positionX, y: n.positionY },
          data: makeNodeData(n.workflowNodeUId, n.boardName ?? n.referenceId, n.boardStatus ?? "Active", n.referenceId),
        }))
      );

      setEdges(
        (data.edges ?? []).map((e) =>
          makeEdgeObj(e.workflowEdgeUId, e.sourceNodeUId, e.targetNodeUId, {
            label: e.label, isReversed: e.isReversed ?? false, animated: true,
          })
        )
      );
    } catch { toast.error("Không tải được workflow."); }
  }, [workspaceId]); // eslint-disable-line

  useEffect(() => {
    loadWorkflow();
    loadBoards();
    loadWorkspaceMembers();
  }, [loadWorkflow, loadBoards, loadWorkspaceMembers]);

  // ── Ensure design exists ──────────────────────────────────────────────────
  const ensureDesign = useCallback(async () => {
    if (designId) return designId;
    const data = await createWorkflowAPI({ workspaceUId: workspaceId, name: "Workflow", createdByUserUId: user?.userUId });
    const id = data?.workflowDesignUId;
    setDesignId(id);
    return id;
  }, [designId, workspaceId, user?.userUId]);

  // ── Open board in /dashboard ─────────────────────────────────────────────
  const handleOpenBoard = useCallback(async (boardId) => {
    try {
      // Fetch fresh board data then store and navigate
      const boardData = await getBoardByIdAPI(boardId);
      const board = boardData?.board ?? boardData;
      if (board) {
        localStorage.setItem("selectedBoard", JSON.stringify(board));
      }
    } catch { /* ignore, navigate anyway */ }
    navigate("/dashboard");
  }, [navigate]);

  // ── Open board settings panel ────────────────────────────────────────────
  const handleEditBoard = useCallback(async (boardId) => {
    try {
      const data = await getBoardByIdAPI(boardId);
      const board = data?.board ?? data;
      setSettingsBoard({ ...board, workspaceUId: workspaceId });
    } catch { toast.error("Không tải được board."); }
  }, [workspaceId]);

  // ── Build node data with all callbacks ───────────────────────────────────
  // eslint-disable-next-line react-hooks/exhaustive-deps
  const makeNodeData = useCallback(
    (nodeId, boardName, boardStatus, referenceId, visibility = "Public") => ({
      boardName, boardStatus, referenceId, visibility,
      onOpenBoard: handleOpenBoard,
      onEditBoard: handleEditBoard,
      onRemoveFromCanvas: removeFromCanvas,
      onDeleteFromWorkspace: deleteFromWorkspace,
    }),
    [] // callbacks are stable
  );

  // ── Build edge object ─────────────────────────────────────────────────────
  const makeEdgeObj = (edgeId, source, target, opts = {}) => ({
    id: edgeId, source, target, type: "custom",
    animated: opts.animated ?? true,
    data: {
      label: opts.label ?? "",
      isReversed: opts.isReversed ?? false,
      animated: opts.animated ?? true,
      onUpdate: handleEdgeUpdate,
      onDelete: handleEdgeDeleteById,
    },
  });

  // ── Edge handlers ─────────────────────────────────────────────────────────
  const handleEdgeUpdate = useCallback(async (edgeId, patch) => {
    setEdges((eds) =>
      eds.map((e) => e.id === edgeId
        ? { ...e, animated: patch.animated ?? e.animated, data: { ...e.data, ...patch } }
        : e)
    );
    try {
      const current = edges.find((e) => e.id === edgeId);
      if (current) {
        await updateWorkflowEdgeAPI(edgeId, {
          label: patch.label ?? current.data.label ?? "",
          isReversed: patch.isReversed ?? current.data.isReversed ?? false,
          edgeType: current.data.edgeType ?? "dependency",
        });
      }
    } catch { /* cosmetic; silent */ }
  }, [edges]);

  const handleEdgeDeleteById = useCallback(async (edgeId) => {
    try {
      await deleteWorkflowEdgeAPI(edgeId);
      setEdges((eds) => eds.filter((e) => e.id !== edgeId));
    } catch { toast.error("Xóa kết nối thất bại."); }
  }, []);

  // ── Node handlers ─────────────────────────────────────────────────────────
  const removeFromCanvas = useCallback(async (nodeId) => {
    try {
      await deleteWorkflowNodeAPI(nodeId);
      setNodes((ns) => ns.filter((n) => n.id !== nodeId));
      setEdges((es) => es.filter((e) => e.source !== nodeId && e.target !== nodeId));
      toast.success("Đã xóa khỏi canvas.");
    } catch { toast.error("Xóa thất bại."); }
  }, []);

  const deleteFromWorkspace = useCallback(async (nodeId, boardId, boardName) => {
    if (!window.confirm(`Xóa board "${boardName}" khỏi workspace? Không thể hoàn tác.`)) return;
    try {
      await deleteBoardAPI(boardId, user?.userUId);
      await deleteWorkflowNodeAPI(nodeId);
      setNodes((ns) => ns.filter((n) => n.id !== nodeId));
      setEdges((es) => es.filter((e) => e.source !== nodeId && e.target !== nodeId));
      setBoards((bs) => bs.filter((b) => (b.boardUId ?? b.BoardUId) !== boardId));
      toast.success(`Board "${boardName}" đã bị xóa.`);
    } catch { toast.error("Xóa board thất bại."); }
  }, [user?.userUId]);

  // ── Add board from panel ──────────────────────────────────────────────────
  const handleAddBoard = useCallback(async (board) => {
    const boardId   = board.boardUId ?? board.BoardUId;
    const boardName = board.boardName ?? board.BoardName;
    const boardStat = board.status ?? board.Status ?? "Active";
    const vis       = board.visibility ?? board.Visibility ?? "Public";

    if (nodes.some((n) => n.data.referenceId === boardId)) {
      toast.info(`"${boardName}" đã có trên canvas.`); return;
    }
    setSaving(true);
    try {
      const dId = await ensureDesign();
      const position = { x: 100 + nodes.length * 240, y: 120 };
      const res = await addWorkflowNodeAPI(dId, {
        workflowDesignUId: dId, nodeType: "Board", referenceId: boardId,
        positionX: position.x, positionY: position.y,
      });
      const nodeId = res?.workflowNodeUId;
      setNodes((prev) => [...prev, {
        id: nodeId, type: "boardNode", position,
        data: makeNodeData(nodeId, boardName, boardStat, boardId, vis),
      }]);
    } catch { toast.error("Thêm node thất bại."); }
    finally { setSaving(false); }
  }, [nodes, ensureDesign, makeNodeData]);

  // ── Create board from toolbar ─────────────────────────────────────────────
  const handleCreateBoard = useCallback(async () => {
    if (!newBoardName.trim()) return;
    setCreatingBoard(true);
    try {
      const created = await createBoardAPI({
        boardName: newBoardName.trim(),
        workspaceUId: workspaceId,
        userUId: user?.userUId,
        visibility: "Public",
        isPersonal: false,
      });
      const newBoard = {
        boardUId: created?.boardUId ?? created?.BoardUId,
        boardName: newBoardName.trim(),
        status: "Active", visibility: "Public",
      };
      setBoards((prev) => [...prev, newBoard]);
      setNewBoardName(""); setShowCreateModal(false);
      toast.success(`Board "${newBoard.boardName}" đã được tạo.`);
      await handleAddBoard(newBoard);
    } catch { toast.error("Tạo board thất bại."); }
    finally { setCreatingBoard(false); }
  }, [newBoardName, workspaceId, user?.userUId, handleAddBoard]);

  // ── Drag-end ──────────────────────────────────────────────────────────────
  const handleNodeDragStop = useCallback(async (_evt, node) => {
    try { await updateNodePositionAPI(node.id, node.position.x, node.position.y); } catch {}
  }, []);

  // ── Connect ───────────────────────────────────────────────────────────────
  const handleConnect = useCallback(async (params) => {
    const dId = designId ?? await ensureDesign();
    try {
      const res = await addWorkflowEdgeAPI({
        workflowDesignUId: dId,
        sourceNodeUId: params.source,
        targetNodeUId: params.target,
        edgeType: "dependency",
      });
      setEdges((prev) =>
        addEdge(makeEdgeObj(res?.workflowEdgeUId, params.source, params.target, { animated: true }), prev)
      );
    } catch (err) {
      toast.error(err?.response?.data?.message ?? "Không thể tạo kết nối.");
    }
  }, [designId, ensureDesign]);

  // ── Keyboard delete ───────────────────────────────────────────────────────
  const handleEdgesDelete = useCallback(async (deleted) => {
    for (const e of deleted) { try { await deleteWorkflowEdgeAPI(e.id); } catch { toast.error("Xóa cạnh thất bại."); } }
  }, []);
  const handleNodesDelete = useCallback(async (deleted) => {
    for (const n of deleted) { try { await deleteWorkflowNodeAPI(n.id); } catch { toast.error("Xóa node thất bại."); } }
  }, []);

  return (
    <div className="fixed top-[64px] left-0 right-0 bottom-0 flex bg-gray-50 dark:bg-[#1E1F22]">

      {/* Left panel */}
      <AddNodePanel
        boards={boards}
        onAddBoard={handleAddBoard}
        loading={loadingBoards}
        workspaceMembers={workspaceMembers}
      />

      {/* Canvas area */}
      <div className="flex-1 flex flex-col relative">

        {/* Toolbar */}
        <div className="flex items-center gap-2 px-4 py-2
          bg-white dark:bg-[#2B2D31] border-b border-gray-200 dark:border-[#3F4147]">
          <GitFork size={17} className="text-indigo-500 flex-shrink-0" />
          <span className="text-sm font-bold text-gray-700 dark:text-[#E8EAED]">Workflow Designer</span>
          <span className="text-xs text-gray-400 dark:text-[#9AA0A6] hidden md:inline">
            — Kết nối các board để trực quan hoá quy trình
          </span>
          <div className="ml-auto flex items-center gap-2">
            {saving && (
              <span className="flex items-center gap-1 text-xs text-gray-400">
                <RefreshCw size={11} className="animate-spin" /> Đang lưu…
              </span>
            )}
            <button onClick={() => setShowCreateModal(true)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold
                bg-indigo-600 hover:bg-indigo-700 text-white shadow-sm transition-colors">
              <Plus size={13} /> Tạo Board
            </button>
            <button onClick={() => { loadWorkflow(); loadBoards(); }} title="Refresh"
              className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 dark:hover:bg-[#3A3C42] transition">
              <RefreshCw size={13} />
            </button>
            <span className="hidden sm:flex items-center gap-1 text-xs text-gray-400">
              <kbd className="px-1.5 py-0.5 rounded bg-gray-100 dark:bg-[#3A3C42]">Del</kbd> xóa node/edge đã chọn
            </span>
          </div>
        </div>

        {/* Canvas */}
        <div className="flex-1">
          <ReactFlow
            nodes={nodes} edges={edges}
            nodeTypes={NODE_TYPES} edgeTypes={EDGE_TYPES}
            onNodesChange={onNodesChange} onEdgesChange={onEdgesChange}
            onConnect={handleConnect} onNodeDragStop={handleNodeDragStop}
            onNodesDelete={handleNodesDelete} onEdgesDelete={handleEdgesDelete}
            fitView deleteKeyCode="Delete"
            proOptions={{ hideAttribution: true }}
          >
            <Background color="#a5b4fc" gap={24} size={1} className="opacity-30 dark:opacity-10" />
            <Controls className="dark:bg-[#2B2D31] dark:border-[#3F4147]" />
            <MiniMap nodeColor={() => "#6366f1"} maskColor="rgba(0,0,0,0.07)"
              className="dark:bg-[#2B2D31] dark:border-[#3F4147] rounded-lg" />
          </ReactFlow>
        </div>
      </div>

      {/* Create Board modal */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm"
          onClick={() => setShowCreateModal(false)}>
          <div className="bg-white dark:bg-[#2B2D31] rounded-2xl shadow-2xl border border-gray-200 dark:border-[#3F4147] w-80 p-5"
            onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center gap-2 mb-4">
              <LayoutGrid size={15} className="text-indigo-500" />
              <span className="font-bold text-gray-800 dark:text-[#E8EAED]">Tạo Board mới</span>
            </div>
            <input autoFocus value={newBoardName} onChange={(e) => setNewBoardName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleCreateBoard()}
              placeholder="Tên board…"
              className="w-full px-3 py-2 rounded-lg text-sm border border-gray-200 dark:border-[#3F4147]
                bg-gray-50 dark:bg-[#1E1F22] dark:text-white outline-none focus:ring-2 focus:ring-indigo-500/40 mb-3" />
            <div className="flex justify-end gap-2">
              <button onClick={() => setShowCreateModal(false)}
                className="px-3 py-1.5 text-sm rounded-lg text-gray-500 hover:bg-gray-100 dark:hover:bg-[#3A3C42]">
                Huỷ
              </button>
              <button onClick={handleCreateBoard} disabled={!newBoardName.trim() || creatingBoard}
                className="flex items-center gap-1.5 px-4 py-1.5 text-sm rounded-lg font-semibold
                  bg-indigo-600 hover:bg-indigo-700 text-white disabled:opacity-50 transition">
                {creatingBoard ? <RefreshCw size={12} className="animate-spin" /> : <Plus size={12} />} Tạo
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Board settings panel (from node ⚙ menu) */}
      {settingsBoard && (
        <BoardSettingsPanel
          board={settingsBoard}
          workspaceMembers={workspaceMembers}
          onClose={() => setSettingsBoard(null)}
          onSaved={(updated) => {
            setSettingsBoard(null);
            // Patch the node's display name in real time
            setNodes((ns) => ns.map((n) =>
              n.data.referenceId === updated.boardUId
                ? { ...n, data: { ...n.data, boardName: updated.boardName, visibility: updated.visibility } }
                : n
            ));
            setBoards((bs) => bs.map((b) =>
              (b.boardUId ?? b.BoardUId) === updated.boardUId ? { ...b, ...updated } : b
            ));
          }}
        />
      )}
    </div>
  );
}

export default function WorkflowDesigner() {
  const { workspaceId } = useParams();
  const user = useMemo(() => JSON.parse(localStorage.getItem("user") ?? "{}"), []);
  return (
    <ReactFlowProvider>
      <WorkflowCanvas workspaceId={workspaceId} user={user} />
    </ReactFlowProvider>
  );
}

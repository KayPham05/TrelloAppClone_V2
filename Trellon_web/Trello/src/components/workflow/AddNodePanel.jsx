import React, { useState } from "react";
import { LayoutGrid, Plus, RefreshCw, Settings } from "lucide-react";
import BoardSettingsPanel from "./BoardSettingsPanel";

export default function AddNodePanel({ boards = [], onAddBoard, loading = false, workspaceMembers = [] }) {
  const [editingBoard, setEditingBoard] = useState(null);

  const handleSaved = (updated) => {
    // Propagate name/visibility change up if needed (boards are managed in parent)
    setEditingBoard(null);
  };

  return (
    <>
      <aside className="
        w-60 h-full flex flex-col
        bg-white dark:bg-[#2B2D31]
        border-r border-gray-200 dark:border-[#3F4147]
        overflow-hidden
      ">
        {/* Header */}
        <div className="px-4 py-3 border-b border-gray-200 dark:border-[#3F4147]">
          <div className="flex items-center gap-2">
            <LayoutGrid size={16} className="text-indigo-500" />
            <span className="text-sm font-bold text-gray-700 dark:text-[#E8EAED]">Boards</span>
          </div>
          <p className="text-xs text-gray-400 dark:text-[#9AA0A6] mt-0.5">
            Click để thêm vào canvas
          </p>
        </div>

        {/* Board list */}
        <div className="flex-1 overflow-y-auto p-3 space-y-1">
          {loading && (
            <div className="flex items-center justify-center py-8">
              <RefreshCw size={18} className="animate-spin text-gray-400" />
            </div>
          )}

          {!loading && boards.length === 0 && (
            <p className="text-xs text-gray-400 dark:text-[#9AA0A6] text-center py-8">
              Không có board nào
            </p>
          )}

          {!loading && boards.map((board) => {
            const id    = board.boardUId   ?? board.BoardUId;
            const name  = board.boardName  ?? board.BoardName ?? "Board";
            const init  = name.charAt(0).toUpperCase();

            return (
              <div key={id} className="group flex items-center gap-2 rounded-lg
                hover:bg-indigo-50 dark:hover:bg-[#3A3C42]
                border border-transparent hover:border-indigo-200 dark:hover:border-[#4F5158]
                transition-all duration-100 pr-1">
                {/* Click area → add to canvas */}
                <button
                  className="flex items-center gap-2.5 px-3 py-2 flex-1 min-w-0 text-left"
                  onClick={() => onAddBoard(board)}
                >
                  <div className="w-6 h-6 rounded-md bg-gradient-to-br from-indigo-400 to-purple-500
                    flex items-center justify-center flex-shrink-0 shadow-sm">
                    <span className="text-xs font-bold text-white">{init}</span>
                  </div>
                  <span className="text-sm text-gray-700 dark:text-[#B5BAC1] truncate flex-1
                    group-hover:text-indigo-600 dark:group-hover:text-[#8AB4F8]">
                    {name}
                  </span>
                  <Plus size={13} className="flex-shrink-0 text-gray-400 group-hover:text-indigo-500 opacity-0 group-hover:opacity-100 transition-opacity" />
                </button>

                {/* Settings gear per board */}
                <button
                  title="Cài đặt board"
                  onClick={(e) => { e.stopPropagation(); setEditingBoard(board); }}
                  className="flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center
                    text-gray-300 hover:text-indigo-500 hover:bg-indigo-100 dark:hover:bg-indigo-900/40
                    opacity-0 group-hover:opacity-100 transition-all"
                >
                  <Settings size={12} />
                </button>
              </div>
            );
          })}
        </div>
      </aside>

      {/* Board settings modal */}
      {editingBoard && (
        <BoardSettingsPanel
          board={editingBoard}
          workspaceMembers={workspaceMembers}
          onClose={() => setEditingBoard(null)}
          onSaved={handleSaved}
        />
      )}
    </>
  );
}

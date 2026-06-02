import React, { useState, useEffect} from "react";
import {
  Users,
  Plus,
  Settings,
  ChevronDown,
  ChevronRight,
  UserPlus,
  Briefcase
} from "lucide-react";
import EditBoardModal from "./EditBoardModal";

export default function WorkspaceSection({
  workspaces = [],
  loading = false,
  onCreateWorkspace,
  onCreateBoard,
  onSelectBoard,
  onInviteUser,
  onOpenSetting,
  boardMembers,
  workspaceMembersMap = {}
}) {
  const [expandedWorkspaces, setExpandedWorkspaces] = useState({});
  const [editingBoard, setEditingBoard] = useState(null);
  const [wsLocal, setWsLocal] = useState(workspaces);

  const [editingWorkspaceMembers, setEditingWorkspaceMembers] = useState([]);

  React.useEffect(() => setWsLocal(workspaces), [workspaces]);

  const handleBoardSaved = (payload) => {
    if (!payload) return;

    // Delete case
    if (payload.type === "delete" && payload.boardUId) {
      const deletedId = payload.boardUId;
      setWsLocal((prev) =>
        prev.map((ws) => {
          if (!ws.boards || ws.boards.length === 0) return ws;
          return {
            ...ws,
            boards: ws.boards.filter((b) => b.boardUId !== deletedId),
          };
        })
      );
      return;
    }

    // Update board
    const updatedBoard = payload.board || payload;

    if (!updatedBoard.boardUId) return;

    setWsLocal((prev) =>
      prev.map((ws) => {
        if (!ws.boards || ws.boards.length === 0) return ws;

        return {
          ...ws,
          boards: ws.boards.map((b) =>
            b.boardUId === updatedBoard.boardUId ? { ...b, ...updatedBoard } : b
          ),
        };
      })
    );
  };
  
  const toggleWorkspace = (workspaceUId) => {
    setExpandedWorkspaces((prev) => ({
      ...prev,
      [workspaceUId]: !prev[workspaceUId],
    }));
  };

  const getBoardGradient = (index) => {
    const gradients = [
      "from-indigo-500 to-purple-600",
      "from-cyan-500 to-blue-600",
      "from-rose-500 to-pink-600",
      "from-amber-500 to-orange-600",
      "from-emerald-500 to-green-600",
      "from-violet-500 to-fuchsia-600",
    ];
    return gradients[index % gradients.length];
  };

  return (
    <section>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Briefcase size={22} className="text-gray-700 dark:text-gray-300" />
          <h2 className="text-xl font-bold text-gray-800 dark:text-[#E8EAED]">
            Your workspaces
          </h2>
        </div>
        <button
          onClick={onCreateWorkspace}
          className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold rounded-lg shadow-md hover:shadow-lg transition"
        >
          <Plus size={18} />
          Create workspace
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="text-center">
            <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600 mx-auto mb-3"></div>
            <p className="text-gray-500 text-sm">Loading workspaces...</p>
          </div>
        </div>
      ) : workspaces.length === 0 ? (
        <div className="bg-white rounded-xl border-2 border-dashed border-gray-300 p-16 text-center">
          <Users className="mx-auto text-gray-300 mb-4" size={64} />
          <h3 className="text-gray-700 font-bold mb-2 text-xl">
            No workspaces yet
          </h3>
          <p className="text-gray-500 text-sm mb-6 max-w-md mx-auto">
            Create a workspace to organize team projects and collaborate efficiently with colleagues.
          </p>
          <button
            onClick={onCreateWorkspace}
            className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg shadow-md hover:shadow-lg transition"
          >
            Create first workspace
          </button>
        </div>
      ) : (
        <div className="space-y-3">
          {wsLocal.map((workspace) => {
            const isExpanded = expandedWorkspaces[workspace.workspaceUId];
            const wsMembers =
              workspaceMembersMap[workspace.workspaceUId] || [];

            return (
              <div
                key={workspace.workspaceUId}
                className="dark:bg-neutral dark:border-neutral bg-white rounded-xl shadow-sm border border-gray-200 hover:shadow-md transition overflow-hidden"
              >
                {/* Workspace Header */}
                <div className="dark:from-neutral-900 dark:to-neutral-900 flex items-center justify-between p-4 bg-gradient-to-r from-gray-50 to-white">
                  <div className="flex items-center gap-3 flex-1 min-w-0">
                    <button
                      onClick={() => toggleWorkspace(workspace.workspaceUId)}
                      className="p-1.5 hover:bg-gray-200 rounded-lg transition flex-shrink-0"
                    >
                      {isExpanded ? (
                        <ChevronDown size={20} className="text-gray-600 dark:!text-gray-300" />
                      ) : (
                        <ChevronRight size={20} className="text-gray-600 dark:!text-gray-300" />
                      )}
                    </button>

                    <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-teal-600 rounded-xl flex items-center justify-center text-white font-bold text-lg shadow-md flex-shrink-0">
                      {workspace.name?.charAt(0)?.toUpperCase() || "W"}
                    </div>

                    <div className="flex-1 min-w-0">
                      <h3 className="dark:!text-gray-300 text-gray-800 font-bold text-base truncate">
                        {workspace.name}
                      </h3>
                      <div className="flex items-center gap-2 mt-0.5">
                        <span className="dark:!text-gray-300 text-xs text-gray-500">
                          {workspace.boards?.length || 0} boards
                        </span>
                        {workspace.description && (
                          <>
                            <span className="text-gray-300">•</span>
                            <p className="text-xs text-gray-500 truncate">
                              {workspace.description}
                            </p>
                          </>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 flex-shrink-0">
                    {/* Invite */}
                    <button
                      onClick={() => onInviteUser(workspace)}
                      className="flex items-center gap-1.5 px-3 py-1.5 bg-green-50 hover:bg-green-100 text-green-700 rounded-lg transition text-sm"
                    >
                      <UserPlus size={16} />
                      <span className="font-medium">Invite</span>
                    </button>

                    <button
                      onClick={() => onOpenSetting && onOpenSetting(workspace)}
                      className="p-2 hover:bg-gray-100 rounded-lg transition dark:hover:bg-white/20"
                      title="Workspace settings"
                    >
                      <Settings size={18} className="text-gray-600 dark:!text-gray-300" />
                    </button>
                  </div>
                </div>

                {/* Workspace Boards */}
                {isExpanded && (
                  <div className="p-6 pt-4 border-t border-gray-100 dark:bg-neutral-800 dark:border-neutral-800">
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                      {workspace.boards && workspace.boards.length > 0
                        ? workspace.boards.map((board, index) => (
                            <div
                              key={board.boardUId}
                              onClick={() =>
                                onSelectBoard && onSelectBoard(board)
                              }
                              className={`h-32 rounded-xl overflow-hidden shadow-md cursor-pointer relative group bg-gradient-to-br ${getBoardGradient(
                                index
                              )} hover:shadow-xl hover:scale-[1.03] transition-all duration-200
                                  dark:ring-1 dark:ring-inset dark:ring-white/10`}
                            >
                              {/* Board Settings */}
                              <button
                                title="Board settings"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setEditingBoard({
                                    ...board,
                                    workspaceUId: workspace.workspaceUId,
                                  });
                                  setEditingWorkspaceMembers(wsMembers);
                                }}
                                className="absolute top-2 right-2 z-20 p-2 hover:rounded-full hover:bg-white/30 backdrop-blur-sm text-white dark:hover:bg-white/20"
                              >
                                <Settings size={16} />
                              </button>

                              {/* Avatars */}
                              {boardMembers[board.boardUId] &&
                                boardMembers[board.boardUId].length > 0 && (
                                  <div className="absolute top-2 left-2 flex -space-x-2 z-20">
                                    {boardMembers[board.boardUId]
                                      .filter((m) =>
                                        ["Owner", "Admin", "Member"].includes(
                                          m.role
                                        )
                                      )
                                      .slice(0, 4)
                                      .map((member, index) => {
                                        const avatarColors = [
                                          "bg-blue-700",
                                          "bg-yellow-600",
                                          "bg-orange-600",
                                          "bg-emerald-600",
                                          "bg-green-600",
                                          "bg-violet-600",
                                          "bg-rose-600",
                                          "bg-teal-600",
                                          "bg-indigo-600",
                                        ];
                                        const colorClass =
                                          avatarColors[index % avatarColors.length];

                                        return (
                                          <div
                                            key={member.userUId}
                                            title={`${member.userName} (${member.role})`}
                                            className={`w-7 h-7 ${colorClass} text-white text-sm flex items-center justify-center font-semibold rounded-full shadow-md hover:scale-110 transition-transform`}
                                          >
                                            {member.userName
                                              ?.split(" ")
                                              .map((n) => n[0])
                                              .join("")
                                              .toUpperCase()
                                              .slice(0, 2)}
                                          </div>
                                        );
                                      })}

                                    {/* +N */}
                                    {boardMembers[board.boardUId].filter((m) =>
                                      ["Owner", "Admin", "Member"].includes(
                                        m.role
                                      )
                                    ).length > 4 && (
                                      <div className="dark:bg-neutral-700 dark:text-neutral-100 dark:border-neutral-800 w-10 h-10 bg-gray-200 text-gray-700 text-sm flex items-center justify-center font-semibold border-2 border-white rounded-full shadow-sm">
                                        +
                                        {boardMembers[board.boardUId].filter(
                                          (m) =>
                                            ["Owner", "Admin", "Member"].includes(m.role)
                                        ).length - 4}
                                      </div>
                                    )}
                                  </div>
                                )}

                              {/* Overlay */}
                              <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition dark:bg-black/30 dark:group-hover:bg-black/20"></div>

                              {/* Content */}
                              <div className="absolute bottom-4 left-4 right-4 z-10">
                                <h4 className="text-white font-bold text-base truncate mb-1 dark:!text-white">
                                  {board.boardName}
                                </h4>
                                <p className="text-white/90 text-xs font-medium bg-white/20 px-2 py-0.5 rounded-full backdrop-blur-sm w-fit dark:!text-neutral-100 dark:bg-white/15">
                                  {board.visibility || "Private"}
                                </p>
                              </div>
                            </div>
                          ))
                        : null}

                      {/* Create board */}
                      <button
                        onClick={() =>
                          onCreateBoard && onCreateBoard(workspace.workspaceUId)
                        }
                        className="h-32 rounded-xl border-2 border-dashed border-gray-300 flex flex-col items-center justify-center hover:bg-gray-50 hover:border-blue-400 text-gray-600 transition group dark:border-gray-600 dark:hover:border-blue-500 dark:hover:bg-neutral-900 dark:!text-neutral-200"
                      >
                        <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center mb-2 group-hover:bg-blue-200 transition dark:bg-blue-900/30 dark:group-hover:bg-blue-900/40">
                          <Plus
                            size={28}
                            className="text-blue-600 group-hover:text-blue-700 transition dark:!text-blue-300 dark:group-hover:!text-blue-200"
                          />
                        </div>
                        <span className="text-sm font-semibold group-hover:text-blue-600 transition dark:!text-neutral-100 dark:group-hover:!text-blue-300">
                          Create New Board
                        </span>
                      </button>
                    </div>

                    {/* Empty workspace boards */}
                    {(!workspace.boards || workspace.boards.length === 0) && (
                      <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-200 dark:bg-neutral-900/40 dark:border-neutral-700">
                        <p className="text-gray-500 text-sm mb-3 dark:!text-neutral-300">
                          Workspace has no board yet
                        </p>
                        <button
                          onClick={() =>
                            onCreateBoard &&
                            onCreateBoard(workspace.workspaceUId)
                          }
                          className="text-blue-600 hover:text-blue-700 text-sm font-semibold hover:underline inline-flex items-center gap-2 dark:!text-blue-300 dark:hover:!text-blue-200"
                        >
                          <Plus size={16} />
                          Create first board
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
      
      <EditBoardModal
        open={!!editingBoard}
        onClose={() => {
          setEditingBoard(null);
          setEditingWorkspaceMembers([]);
        }}
        board={editingBoard}
        onSaved={handleBoardSaved}
        workspaceMembers={editingWorkspaceMembers}
      />
    </section>
  );
}

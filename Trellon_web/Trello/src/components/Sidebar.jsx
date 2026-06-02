import React, { useState } from "react";
import { Home, ChevronDown, ChevronRight, Plus, Menu, GitFork } from "lucide-react";
import { useNavigate } from "react-router-dom";

export default function Sidebar({
    workspaces = [],
    onCreateWorkspace,
    onCreateBoard,
    onSelectBoard,
    className = "",
}) {
    const [expandedWorkspaces, setExpandedWorkspaces] = useState({});
    const [isCollapsed, setIsCollapsed] = useState(false);
    const navigate = useNavigate();

    const toggleWorkspace = (workspaceId) => {
        setExpandedWorkspaces((prev) => ({
            ...prev,
            [workspaceId]: !prev[workspaceId],
        }));
    };

    const toggleSidebar = () => {
        setIsCollapsed(!isCollapsed);
        // Đóng tất cả workspace khi thu gọn
        if (!isCollapsed) {
            setExpandedWorkspaces({});
        }
    };

    return (
    <aside
        className={`${isCollapsed ? 'w-20' : 'w-72'} 
            bg-white dark:bg-[#2B2D31] 
            border-r dark:border-[#3F4147] 
            flex flex-col transition-all duration-300 ease-in-out ${className}`}
    >
        {/* Header */}
        <div className="p-4 border-b dark:bg-[#1E1F23] dark:border-[#3F4147]">
            <div className={`flex items-center ${isCollapsed ? 'justify-center' : 'gap-3'}`}>
                <button
                    onClick={toggleSidebar}
                    className="p-2 hover:bg-gray-100 dark:hover:bg-[#3A3C42] 
                               rounded-lg transition flex-shrink-0"
                    title={isCollapsed ? "Mở rộng sidebar" : "Thu gọn sidebar"}
                >
                    <Menu size={20} className="text-gray-600 dark:text-[#E8EAED]" />
                </button>

                {!isCollapsed && (
                    <button className="flex items-center gap-3 px-4 py-2.5 
                        bg-blue-50 dark:bg-[#1E1F22] 
                        text-blue-700 dark:text-[#8AB4F8] 
                        rounded-lg flex-1 
                        hover:bg-blue-100 dark:hover:bg-[#3A3C42] transition">
                        <Home size={20} />
                        <span className="text-sm font-semibold">Home</span>
                    </button>
                )}

                {isCollapsed && (
                    <button
                        className="p-2 bg-blue-50 dark:bg-[#1E1F22] 
                                   text-blue-700 dark:text-[#8AB4F8] 
                                   rounded-lg hover:bg-blue-100 dark:hover:bg-[#3A3C42] 
                                   transition absolute left-1/2 -translate-x-1/2 mt-12"
                        title="Trang chủ"
                    >
                    </button>
                )}
            </div>
        </div>

        {/* Workspaces */}
        <div className="flex-1 overflow-y-auto">
            <div className="p-4">
                <div className={`flex items-center ${isCollapsed ? 'justify-center' : 'justify-between'} mb-3`}>
                    {!isCollapsed && (
                        <h3 className="text-xs font-bold text-gray-500 dark:text-[#9AA0A6] uppercase tracking-wider">
                            Workspace
                        </h3>
                    )}

                    <button
                        onClick={onCreateWorkspace}
                        className="p-1.5 hover:bg-gray-100 dark:hover:bg-[#3A3C42] rounded-lg transition"
                        title="Tạo workspace mới"
                    >
                        <Plus size={16} className="text-gray-600 dark:text-[#E8EAED]" />
                    </button>
                </div>

                <div className="space-y-1">
                    {workspaces.length === 0 ? (
                        !isCollapsed && (
                            <div className="px-4 py-8 text-center">
                                <p className="text-sm text-gray-500 dark:text-[#9AA0A6] mb-3">
                                    There is no workspace yet
                                </p>
                                <button
                                    onClick={onCreateWorkspace}
                                    className="text-sm text-blue-600 dark:text-[#8AB4F8] 
                                               hover:underline dark:hover:text-[#A8C7FA] font-medium"
                                >
                                    Create First Workspace
                                </button>
                            </div>
                        )
                    ) : (
                        workspaces.map((workspace) => (
                            <div key={workspace.workspaceUId}>
                                <button
                                    onClick={() => !isCollapsed && toggleWorkspace(workspace.workspaceUId)}
                                    className={`flex items-center justify-between w-full px-3 py-2.5 
                                        hover:bg-gray-100 dark:hover:bg-[#3A3C42] 
                                        rounded-lg transition group ${isCollapsed ? 'justify-center' : ''}`}
                                    title={isCollapsed ? workspace.name : (workspace.description || "Không có mô tả")}
                                >
                                    <div className={`flex items-center ${isCollapsed ? '' : 'gap-3 flex-1 min-w-0'}`}>
                                        <div className="w-8 h-8 bg-gradient-to-br from-purple-500 to-pink-600 
                                            rounded-lg flex items-center justify-center text-white 
                                            text-sm font-bold flex-shrink-0 shadow-md">
                                            {workspace.name?.charAt(0)?.toUpperCase() || "W"}
                                        </div>

                                        {!isCollapsed && (
                                            <div className="flex flex-col items-start flex-1 min-w-0">
                                                <span className="text-sm font-semibold text-gray-800 dark:text-[#E8EAED] truncate">
                                                    {workspace.name}
                                                </span>
                                                <span className="text-xs text-gray-500 dark:text-[#9AA0A6]">
                                                    {workspace.boards?.length || 0} bảng
                                                </span>
                                            </div>
                                        )}
                                    </div>

                                    {!isCollapsed && (
                                        expandedWorkspaces[workspace.workspaceUId] ? (
                                            <ChevronDown
                                                size={18}
                                                className="text-gray-500 dark:text-[#9AA0A6] flex-shrink-0"
                                            />
                                        ) : (
                                            <ChevronRight
                                                size={18}
                                                className="text-gray-500 dark:text-[#9AA0A6] flex-shrink-0"
                                            />
                                        )
                                    )}
                                </button>

                                {/* Workspace Boards */}
                                {!isCollapsed && expandedWorkspaces[workspace.workspaceUId] && (
                                    <div className="ml-11 mt-1 space-y-1 mb-2">
                                        {(workspace.boards || []).map((board) => (
                                            <button
                                                key={board.boardUId}
                                                onClick={() => onSelectBoard && onSelectBoard(board)}
                                                className="w-full text-left px-3 py-2 text-sm 
                                                    text-gray-700 dark:text-[#B5BAC1] 
                                                    hover:bg-gray-100 dark:hover:bg-[#3A3C42] 
                                                    rounded-lg transition flex items-center gap-2 group"
                                            >
                                                <div className="w-1 h-1 rounded-full bg-gray-400 dark:bg-[#9AA0A6] 
                                                    group-hover:bg-blue-600 dark:group-hover:bg-[#8AB4F8]"></div>

                                                <span className="truncate group-hover:text-blue-600 dark:group-hover:text-[#8AB4F8]">
                                                    {board.boardName}
                                                </span>
                                            </button>
                                        ))}

                                        <button
                                            onClick={() => onCreateBoard && onCreateBoard(workspace.workspaceUId)}
                                            className="w-full text-left px-3 py-2 text-sm 
                                                text-blue-600 dark:text-[#8AB4F8] 
                                                hover:bg-blue-50 dark:hover:bg-[#3A3C42] 
                                                rounded-lg transition flex items-center gap-2 font-medium"
                                        >
                                            <Plus size={14} />
                                            Add new board
                                        </button>

                                        {/* Workflow Designer link */}
                                        <button
                                            onClick={() => navigate(`/workflow/${workspace.workspaceUId}`)}
                                            className="w-full text-left px-3 py-2 text-sm 
                                                text-indigo-600 dark:text-indigo-400 
                                                hover:bg-indigo-50 dark:hover:bg-[#3A3C42] 
                                                rounded-lg transition flex items-center gap-2 font-medium"
                                        >
                                            <GitFork size={14} />
                                            Workflow Designer
                                        </button>
                                    </div>
                                )}
                            </div>
                        ))
                    )}
                </div>
            </div>
        </div>

        {/* Footer Tips */}
        {!isCollapsed && (
            <div className="p-4 border-t dark:border-[#3F4147] bg-gray-50 dark:bg-[#1E1F22]">
                <div className="text-xs text-gray-600 dark:text-[#B5BAC1] space-y-1">
                    <p className="font-semibold text-gray-700 dark:text-[#E8EAED]">💡 Tips</p>
                    <p>• Click into workspace to view your boards </p>
                    <p>• Create workspace for teamwork</p>
                </div>
            </div>
        )}
    </aside>
);







}
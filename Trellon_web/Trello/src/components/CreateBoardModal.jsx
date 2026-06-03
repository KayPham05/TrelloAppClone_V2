import React, { useState, useEffect } from "react";
import { X, Globe, Lock } from "lucide-react";
import { toast } from "react-toastify";
import { createBoardAPI } from "../services/BoardAPI";
import { addNotificationAPI } from "../services/NotificationAPI";

export default function CreateBoardModal({
  currentUser,
  workspaces = [],
  defaultWorkspaceId = null,
  onClose,
  onSuccess,
}) {
  const [boardName, setBoardName] = useState("");
  const [workspaceId, setWorkspaceId] = useState(defaultWorkspaceId);
  const [visibility, setVisibility] = useState("Private");
  const [isLoading, setIsLoading] = useState(false);

  const [members, setMembers] = useState([]);
  const [selectedMembers, setSelectedMembers] = useState([]);

  useEffect(() => {
    if (!workspaceId) {
      setMembers([]);
      setSelectedMembers([]);
      return;
    }

    const selectedWs = workspaces.find((ws) => ws.workspaceUId === workspaceId);
    if (selectedWs && Array.isArray(selectedWs.members)) {
      setMembers(selectedWs.members);

      // TỰ ĐỘNG THÊM OWNER VÀO selectedMembers
      const ownerMember = selectedWs.members.find(
        m => m.userUId === currentUser?.userUId && m.role === "Owner"
      );

      if (ownerMember) {
        setSelectedMembers([{
          userUId: ownerMember.userUId,
          BoardRole: "Owner" // ← Đổi từ role thành BoardRole
        }]);
      }
    } else {
      setMembers([]);
      setSelectedMembers([]);
    }
  }, [workspaceId, workspaces, currentUser]);

  const handleMemberChange = (userUId, role) => {
    setSelectedMembers((prev) => {
      const exists = prev.find((m) => m.userUId === userUId);
      if (exists) {
        // Nếu chọn "Không tham gia" thì xóa khỏi danh sách
        if (!role || role === "") {
          return prev.filter(m => m.userUId !== userUId);
        }
        // Cập nhật role
        return prev.map((m) =>
          m.userUId === userUId ? { ...m, BoardRole: role } : m // ← Đổi role thành BoardRole
        );
      } else {
        // Thêm mới nếu có chọn role
        if (role && role !== "") {
          return [...prev, { userUId, BoardRole: role }]; // ← Đổi role thành BoardRole
        }
        return prev;
      }
    });
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    if (!boardName.trim() || !currentUser) {
      toast.error("Please enter board's name");
      return;
    }

    const newBoard = {
      boardName: boardName.trim(),
      userUId: currentUser.userUId,
      workspaceUId: workspaceId || null,
      visibility,
      isPersonal: !workspaceId,
      members: selectedMembers, // ← Giờ đã có BoardRole
      createdAt: new Date().toISOString(),
    };

    console.log(" Sending board data:", newBoard);

    try {
      setIsLoading(true);
      const createdBoard = await createBoardAPI(newBoard);

      // Tạo thông báo cho tất cả thành viên được thêm vào board (trừ chủ board)
      const notificationPromises = selectedMembers
        .filter(member => member.userUId !== currentUser.userUId) // Loại trừ chủ board
        .map(member => {
          const notificationPayload = {
            recipientId: member.userUId,
            actorId: currentUser.userUId,
            type: 6, //  Invitation
            title: "Board Invitation",
            message: `${currentUser.userName} invited you to join board '${boardName}' as ${member.BoardRole}.`,
            link: `/boards/${createdBoard?.board?.boardUId}`,
            workspaceId: workspaceId || null,
            boardId: createdBoard?.board?.boardUId
          };

          console.log("Sending notification with payload:", notificationPayload);
          return addNotificationAPI(notificationPayload);
        });

      // Chờ tất cả notification gửi xong
      await Promise.all(notificationPromises);

      if (createdBoard?.board?.boardUId) {
        toast.success("Create board succesfully!");
        onSuccess?.();
        onClose?.();
      } else {
        toast.error("Can't create board!");
      }
    } catch (err) {
      console.error("Lỗi tạo board:", err);
      toast.error("Error occurs when creating board");
    } finally {
      setIsLoading(false);
    }
  };

  return (
  <div
    className="
      fixed inset-0 bg-black/60 
      flex items-center justify-center 
      z-50 p-4
    "
    onClick={(e) => {
      if (e.target === e.currentTarget) onClose();
    }}
  >
    <div
      className="
        bg-white dark:bg-[#1E1F22] 
        text-gray-800 dark:text-gray-200
        rounded-2xl shadow-2xl 
        border border-gray-200 dark:border-[#3F4147]
        w-full max-w-md relative p-6
      "
    >
      {/* Close button */}
      <button
        onClick={onClose}
        className="
          absolute top-4 right-4 p-2 rounded-full 
          hover:bg-gray-100 dark:hover:bg-white/10 
          transition text-gray-700 dark:text-gray-300
        "
      >
        <X size={20} />
      </button>

      <h2 className="text-xl font-bold mb-6 text-gray-800 dark:text-gray-100">
        Create new board
      </h2>

      <form onSubmit={handleCreate} className="space-y-5">

        {/* Board name */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Board name <span className="text-red-500">*</span>
          </label>

          <input
            type="text"
            value={boardName}
            onChange={(e) => setBoardName(e.target.value)}
            placeholder="Ex: Website Project, Marketing Plan"
            className="
              w-full px-4 py-2.5 rounded-lg
              border border-gray-300 dark:border-[#4A4D52]
              bg-white dark:bg-[#2B2D31]
              text-gray-800 dark:text-gray-100
              placeholder:text-gray-400 dark:placeholder:text-gray-500
              focus:ring-2 focus:ring-blue-500 outline-none
              transition
            "
            required
            autoFocus
          />
        </div>

        {/* Workspace */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            From workspace
          </label>

          <select
            value={workspaceId || ""}
            onChange={(e) => setWorkspaceId(e.target.value || null)}
            className="
              w-full px-3 py-2.5 rounded-lg
              border border-gray-300 dark:border-[#4A4D52]
              bg-white dark:bg-[#2B2D31]
              text-gray-800 dark:text-gray-100
              focus:ring-2 focus:ring-blue-500 outline-none
            "
          >
            <option value="">(None – Personal board)</option>

            {workspaces.map((ws) => (
              <option key={ws.workspaceUId} value={ws.workspaceUId}>
                {ws.name}
              </option>
            ))}
          </select>
        </div>

        {/* Members (only when Private) */}
        {workspaceId && visibility === "Private" && (
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Board members
            </label>

            <div className="
              max-h-40 overflow-y-auto rounded-lg p-2 space-y-2
              border border-gray-300 dark:border-[#4A4D52]
              bg-gray-50 dark:bg-[#2B2D31]
            ">
              {members.length > 0 ? (
                members.map((m) => {
                  const isOwner =
                    m.userUId === currentUser?.userUId && m.role === "Owner";

                  const currentSelection = selectedMembers.find(
                    (sm) => sm.userUId === m.userUId
                  );

                  const currentRole = currentSelection?.BoardRole || "";

                  return (
                    <div
                      key={m.userUId}
                      className="
                        flex justify-between items-center
                        bg-gray-50 dark:bg-[#1E1F22]
                        border border-gray-200 dark:border-[#3F4147]
                        rounded-lg px-3 py-2
                      "
                    >
                      <span className="text-sm font-medium text-gray-800 dark:text-gray-200">
                        {m.userName || m.email}
                        {isOwner && (
                          <span className="ml-2 text-xs text-blue-600 dark:text-blue-400 font-medium">
                            (Owner)
                          </span>
                        )}
                      </span>

                      {isOwner ? (
                        <select
                          disabled
                          value="Owner"
                          className="
                            rounded-md px-2 py-1 text-sm cursor-not-allowed
                            bg-gray-100 dark:bg-[#3A3B3F]
                            border border-gray-200 dark:border-[#4A4D52]
                            text-gray-500 dark:text-gray-400
                          "
                        >
                          <option>Owner</option>
                        </select>
                      ) : (
                        <select
                          value={currentRole}
                          onChange={(e) =>
                            handleMemberChange(m.userUId, e.target.value)
                          }
                          className="
                            rounded-md px-2 py-1 text-sm cursor-pointer
                            bg-white dark:bg-[#2B2D31]
                            border border-gray-300 dark:border-[#4A4D52]
                            text-gray-800 dark:text-gray-200
                          "
                        >
                          <option value="">Not participating</option>
                          <option value="Admin">Admin</option>
                          <option value="Member">Member</option>
                          <option value="Viewer">Viewer</option>
                        </select>
                      )}
                    </div>
                  );
                })
              ) : (
                <p className="text-sm text-gray-500 dark:text-gray-400 text-center">
                  No member in this workspace.
                </p>
              )}
            </div>
          </div>
        )}

        {/* Permissions */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Permissions
          </label>

          <div className="flex gap-3">
            {/* Public */}
            <button
              type="button"
              onClick={() => setVisibility("Public")}
              className={`
                flex items-center gap-2 px-4 py-2.5 rounded-lg border transition
                ${visibility === "Public"
                  ? "bg-blue-100 dark:bg-blue-900/40 border-blue-500 dark:border-blue-400 text-blue-700 dark:text-blue-300"
                  : "border-gray-300 dark:border-[#4A4D52] text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-white/5"
                }
              `}
            >
              <Globe size={16} />
              Public
            </button>

            {/* Private */}
            <button
              type="button"
              onClick={() => setVisibility("Private")}
              className={`
                flex items-center gap-2 px-4 py-2.5 rounded-lg border transition
                ${visibility === "Private"
                  ? "bg-blue-100 dark:bg-blue-900/40 border-blue-500 dark:border-blue-400 text-blue-700 dark:text-blue-300"
                  : "border-gray-300 dark:border-[#4A4D52] text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-white/5"
                }
              `}
            >
              <Lock size={16} />
              Private
            </button>
          </div>

          <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
            {visibility === "Public"
              ? "All workspace members can view this board"
              : "Only invited users can access this board"}
          </p>
        </div>

        {/* Buttons */}
        <div className="flex justify-end gap-3 pt-4 border-t border-gray-200 dark:border-[#3F4147]">
          <button
            type="button"
            onClick={onClose}
            className="
              px-4 py-2.5 rounded-lg
              border border-gray-300 dark:border-[#4A4D52]
              text-gray-700 dark:text-gray-200
              hover:bg-gray-50 dark:hover:bg-white/5
              transition
            "
          >
            Cancel
          </button>

          <button
            type="submit"
            disabled={isLoading}
            className={`
              px-4 py-2.5 rounded-lg font-medium shadow-sm transition text-white
              ${isLoading
                ? "bg-gray-400 cursor-not-allowed"
                : "bg-blue-600 hover:bg-blue-700"
              }
            `}
          >
            {isLoading ? "Creating..." : "Create Board"}
          </button>
        </div>

      </form>
    </div>
  </div>
);

}
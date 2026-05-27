import React, { useEffect, useState } from "react";
import {
  X, Globe, Lock, Trash2, Save, RefreshCw, Users, Settings,
} from "lucide-react";
import { toast } from "react-toastify";
import AxiosClient from "../../services/axios/axiosApi";
import {
  getBoardMembersAPI,
  addBoardMemberAPI,
  updateBoardMemberRoleAPI,
  removeBoardMemberAPI,
} from "../../services/BoardMemberAPI";

export default function BoardSettingsPanel({ board, workspaceMembers = [], onClose, onSaved }) {
  const [name, setName] = useState("");
  const [visibility, setVisibility] = useState("Public");
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const user = JSON.parse(localStorage.getItem("user") ?? "{}");

  // Normalize board — handle both camelCase and PascalCase API responses
  const boardId    = board?.boardUId    ?? board?.BoardUId    ?? "";
  const boardName  = board?.boardName   ?? board?.BoardName   ?? "";
  const boardVis   = board?.visibility  ?? board?.Visibility  ?? "Public";
  const boardUser  = board?.userUId     ?? board?.UserUId     ?? user?.userUId ?? "";
  const boardBg    = board?.backgroundUrl ?? board?.BackgroundUrl ?? "";
  const boardStat  = board?.status      ?? board?.Status      ?? "Active";
  const boardAt    = board?.createdAt   ?? board?.CreatedAt   ?? new Date().toISOString();
  const boardPersonal = board?.isPersonal ?? board?.IsPersonal ?? false;
  const workspaceUId  = board?.workspaceUId ?? board?.WorkspaceUId ?? "";

  useEffect(() => {
    setName(boardName);
    setVisibility(boardVis);
    setMembers([]);
    if (boardId) {
      setLoading(true);
      getBoardMembersAPI(boardId)
        .then((res) => setMembers(Array.isArray(res) ? res : res?.members ?? []))
        .catch(() => setMembers([]))
        .finally(() => setLoading(false));
    }
  }, [boardId]);

  const handleSave = async () => {
    if (!name.trim()) { toast.error("Tên board không được trống"); return; }
    setSaving(true);
    try {
      // Backend expects: [FromBody] Board (PascalCase) + [FromQuery] userUId
      await AxiosClient.put(`boards/${boardId}?userUId=${boardUser}`, {
        BoardUId:      boardId,
        BoardName:     name.trim(),
        Visibility:    visibility,
        BackgroundUrl: boardBg,
        IsPersonal:    boardPersonal,
        UserUId:       boardUser,
        Status:        boardStat,
        CreatedAt:     boardAt,
        WorkspaceUId:  workspaceUId,
      });
      toast.success("Đã lưu");
      onSaved?.({ boardUId: boardId, boardName: name.trim(), visibility });
      onClose?.();
    } catch (err) {
      console.error("Board update error:", err?.response?.data);
      toast.error("Lưu thất bại — " + (err?.response?.data?.message ?? err?.message ?? "unknown"));
    } finally { setSaving(false); }
  };

  const handleChangeRole = async (memberUId, newRole) => {
    if (!newRole) {
      if (!window.confirm("Xóa thành viên này khỏi board?")) return;
      try {
        await removeBoardMemberAPI(boardId, memberUId, user?.userUId);
        setMembers((m) => m.filter((x) => (x.userUId ?? x.UserUId) !== memberUId));
        toast.success("Đã xóa");
      } catch { toast.error("Thất bại"); }
      return;
    }
    try {
      await updateBoardMemberRoleAPI(boardId, memberUId, newRole, user?.userUId);
      setMembers((m) => m.map((x) =>
        (x.userUId ?? x.UserUId) === memberUId ? { ...x, role: newRole, boardRole: newRole } : x
      ));
      toast.success("Đã cập nhật");
    } catch { toast.error("Thất bại"); }
  };

  const handleAddMember = async (memberUId, role) => {
    if (!role) return;
    try {
      await addBoardMemberAPI(boardId, memberUId, user?.userUId, role);
      toast.success("Đã thêm thành viên");
      getBoardMembersAPI(boardId)
        .then((r) => setMembers(Array.isArray(r) ? r : r?.members ?? []));
    } catch { toast.error("Thất bại"); }
  };

  const available = workspaceMembers.filter((wm) =>
    !members.some((bm) => (bm.userUId ?? bm.UserUId) === (wm.userUId ?? wm.UserUId))
  );

  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/40 backdrop-blur-sm"
      onClick={onClose}>
      <div className="
          bg-white dark:bg-[#2B2D31] rounded-2xl shadow-2xl
          border border-gray-200 dark:border-[#3F4147]
          w-[440px] max-h-[88vh] overflow-y-auto
        "
        onClick={(e) => e.stopPropagation()}>

        {/* Header */}
        <div className="flex items-center justify-between px-5 pt-5 pb-3 border-b border-gray-100 dark:border-[#3F4147]">
          <div className="flex items-center gap-2">
            <Settings size={16} className="text-indigo-500" />
            <span className="font-bold text-gray-800 dark:text-[#E8EAED]">Board Settings</span>
            <span className="text-xs text-gray-400 dark:text-[#9AA0A6] ml-1 truncate max-w-[160px]">{boardName}</span>
          </div>
          <button onClick={onClose}
            className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 dark:hover:bg-[#3A3C42]">
            <X size={16} />
          </button>
        </div>

        <div className="px-5 py-4 space-y-4">
          {/* Name */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 dark:text-[#9AA0A6] mb-1 uppercase tracking-wide">
              Tên board
            </label>
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleSave()}
              className="w-full px-3 py-2 text-sm rounded-lg border border-gray-200 dark:border-[#3F4147]
                bg-gray-50 dark:bg-[#1E1F22] dark:text-white outline-none
                focus:ring-2 focus:ring-indigo-500/40"
            />
          </div>

          {/* Visibility */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 dark:text-[#9AA0A6] mb-2 uppercase tracking-wide">
              Visibility
            </label>
            <div className="flex gap-2">
              {["Public", "Private"].map((v) => (
                <button key={v} type="button" onClick={() => setVisibility(v)}
                  className={`flex items-center gap-1.5 px-3 py-1.5 text-sm rounded-lg border transition
                    ${visibility === v
                      ? "border-indigo-500 bg-indigo-50 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300"
                      : "border-gray-200 dark:border-[#3F4147] text-gray-600 dark:text-[#B5BAC1] hover:bg-gray-50 dark:hover:bg-[#3A3C42]"}`}>
                  {v === "Public" ? <Globe size={13} /> : <Lock size={13} />}
                  {v}
                </button>
              ))}
            </div>
            <p className="text-xs text-gray-400 dark:text-[#9AA0A6] mt-1">
              {visibility === "Public" ? "Mọi thành viên workspace đều xem được." : "Chỉ thành viên được mời mới truy cập được."}
            </p>
          </div>

          {/* Members */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 dark:text-[#9AA0A6] mb-2 uppercase tracking-wide flex items-center gap-1">
              <Users size={11} /> Thành viên board
            </label>
            {loading ? (
              <p className="text-xs text-gray-400 flex items-center gap-1"><RefreshCw size={11} className="animate-spin" /> Đang tải…</p>
            ) : members.length === 0 ? (
              <p className="text-xs text-gray-400">Chưa có thành viên</p>
            ) : (
              <div className="space-y-1.5 max-h-44 overflow-y-auto pr-1">
                {members.map((m) => {
                  const uid  = m.userUId  ?? m.UserUId  ?? "";
                  const name = m.userName ?? m.UserName ?? m.email ?? m.Email ?? uid;
                  const role = m.role ?? m.boardRole ?? m.Role ?? "";
                  return (
                    <div key={uid} className="flex items-center justify-between bg-gray-50 dark:bg-[#1E1F22] rounded-lg px-3 py-1.5">
                      <div className="flex items-center gap-2">
                        <div className="w-6 h-6 rounded-full bg-indigo-100 dark:bg-indigo-900/40 text-indigo-600 dark:text-indigo-400 text-xs font-bold flex items-center justify-center">
                          {name.charAt(0).toUpperCase()}
                        </div>
                        <span className="text-xs text-gray-700 dark:text-[#E8EAED]">{name}</span>
                      </div>
                      {role === "Owner" ? (
                        <span className="text-xs text-indigo-500 font-medium px-2">Owner</span>
                      ) : (
                        <select value={role} onChange={(e) => handleChangeRole(uid, e.target.value)}
                          className="text-xs border border-gray-200 dark:border-[#3F4147] rounded-md px-1.5 py-1
                            bg-white dark:bg-[#2B2D31] dark:text-[#B5BAC1] cursor-pointer">
                          <option value="">Xóa</option>
                          <option value="Admin">Admin</option>
                          <option value="Member">Member</option>
                          <option value="Viewer">Viewer</option>
                        </select>
                      )}
                    </div>
                  );
                })}
              </div>
            )}

            {/* Add from workspace */}
            {available.length > 0 && (
              <div className="mt-3 pt-3 border-t border-gray-100 dark:border-[#3F4147]">
                <label className="block text-xs text-gray-400 mb-1.5">Thêm từ workspace</label>
                <div className="space-y-1.5 max-h-36 overflow-y-auto pr-1">
                  {available.map((m) => {
                    const uid  = m.userUId  ?? m.UserUId  ?? "";
                    const name = m.userName ?? m.UserName ?? m.email ?? m.Email ?? uid;
                    return (
                      <div key={uid} className="flex items-center justify-between bg-gray-50 dark:bg-[#1E1F22] rounded-lg px-3 py-1.5">
                        <span className="text-xs text-gray-700 dark:text-[#E8EAED]">{name}</span>
                        <select defaultValue="" onChange={(e) => handleAddMember(uid, e.target.value)}
                          className="text-xs border border-gray-200 dark:border-[#3F4147] rounded-md px-1.5 py-1
                            bg-white dark:bg-[#2B2D31] dark:text-[#B5BAC1] cursor-pointer">
                          <option value="">-- Vai trò --</option>
                          <option value="Admin">Admin</option>
                          <option value="Member">Member</option>
                          <option value="Viewer">Viewer</option>
                        </select>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Footer */}
        <div className="flex justify-end gap-2 px-5 py-3 border-t border-gray-100 dark:border-[#3F4147]">
          <button onClick={onClose}
            className="px-3 py-1.5 text-sm rounded-lg text-gray-500 hover:bg-gray-100 dark:hover:bg-[#3A3C42] transition">
            Huỷ
          </button>
          <button onClick={handleSave} disabled={saving}
            className="flex items-center gap-1.5 px-4 py-1.5 text-sm rounded-lg font-semibold
              bg-indigo-600 hover:bg-indigo-700 text-white disabled:opacity-50 transition">
            {saving ? <RefreshCw size={12} className="animate-spin" /> : <Save size={12} />}
            Lưu
          </button>
        </div>
      </div>
    </div>
  );
}

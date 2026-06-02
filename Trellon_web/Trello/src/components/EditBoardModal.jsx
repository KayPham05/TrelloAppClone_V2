// src/components/EditBoardModal.jsx
import React, { useState, useEffect, useRef } from "react";
import { X, Trash2, Globe, Lock, Image, Upload, Palette, ArrowLeftRight } from "lucide-react";
import { toast } from "react-toastify";
import { updateBoardAPI, deleteBoardAPI } from "../services/BoardAPI";
import {
  getBoardMembersAPI,
  updateBoardMemberRoleAPI,
  removeBoardMemberAPI,
  addBoardMemberAPI,
} from "../services/BoardMemberAPI";
import AxiosClient from "../services/axios/axiosApi";
import { getAllWorkspacesAPI } from "../services/WorkspaceAPI";

const PRESET_BACKGROUNDS = [
  { type: "gradient", value: "linear-gradient(135deg,#6366f1,#8b5cf6)", label: "Indigo" },
  { type: "gradient", value: "linear-gradient(135deg,#0ea5e9,#6366f1)", label: "Ocean" },
  { type: "gradient", value: "linear-gradient(135deg,#f43f5e,#ec4899)", label: "Rose" },
  { type: "gradient", value: "linear-gradient(135deg,#f59e0b,#ef4444)", label: "Sunset" },
  { type: "gradient", value: "linear-gradient(135deg,#10b981,#0ea5e9)", label: "Teal" },
  { type: "gradient", value: "linear-gradient(135deg,#8b5cf6,#ec4899)", label: "Purple" },
  { type: "color", value: "#1E3A5F", label: "Navy" },
  { type: "color", value: "#1A2B1A", label: "Forest" },
  { type: "color", value: "#2D1B33", label: "Plum" },
  { type: "color", value: "#1C1C1C", label: "Mono" },
];

// Tabs
const TABS = ["General", "Background", "Move Board"];

export default function EditBoardModal({
  open,
  onClose,
  board,
  onSaved,
  workspaceMembers = [],
  allWorkspaces = null,
}) {
  const [activeTab, setActiveTab] = useState("General");
  const [name, setName] = useState(board?.boardName || "");
  const [visibility, setVisibility] = useState(board?.visibility || "Private");
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);

  const [members, setMembers] = useState([]);
  const [loadingMembers, setLoadingMembers] = useState(false);
  const [currentUserUId, setCurrentUserUId] = useState(null);

  // Background state
  const [bgPreview, setBgPreview] = useState(board?.backgroundUrl || "");
  const [uploadingBg, setUploadingBg] = useState(false);
  const fileRef = useRef(null);

  // Move Board state
  const [workspaces, setWorkspaces] = useState([]);
  const [targetWorkspaceId, setTargetWorkspaceId] = useState("");
  const [moving, setMoving] = useState(false);

  useEffect(() => {
    const stored = localStorage.getItem("user");
    if (stored) {
      try { setCurrentUserUId(JSON.parse(stored).userUId); }
      catch { /* ignore */ }
    }
  }, []);

  useEffect(() => {
    if (!open || !board) return;
    setName(board?.boardName || "");
    setVisibility(board?.visibility || "Private");
    setBgPreview(board?.backgroundUrl || "");
    setMembers([]);
    setActiveTab("General");
    if (board.workspaceUId) loadMembers();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, board]);

  // Load workspaces for Move Board tab
  useEffect(() => {
    if (activeTab !== "Move Board" || workspaces.length > 0) return;
    const uid = currentUserUId || JSON.parse(localStorage.getItem("user") || "{}").userUId;
    if (!uid) return;
    getAllWorkspacesAPI(uid)
      .then((data) => setWorkspaces(Array.isArray(data) ? data : []))
      .catch(() => {});
  }, [activeTab, currentUserUId]);

  if (!open || !board) return null;

  const loadMembers = async () => {
    setLoadingMembers(true);
    try {
      const res = await getBoardMembersAPI(board.boardUId);
      setMembers(Array.isArray(res) ? res : Array.isArray(res?.members) ? res.members : []);
    } catch {
      setMembers([]);
    } finally {
      setLoadingMembers(false);
    }
  };

  // ====== Save name + visibility ======
  const handleSave = async (e) => {
    e?.preventDefault?.();
    if (!name.trim()) { toast.error("Board name is required"); return; }
    try {
      setSaving(true);
      const payload = {
        boardUId: board.boardUId,
        boardName: name.trim(),
        visibility,
        backgroundUrl: bgPreview || board.backgroundUrl,
        isPersonal: board.isPersonal ?? true,
        userUId: board.userUId,
        status: board.status || "Active",
        createdAt: board.createdAt || new Date().toISOString(),
      };
      await updateBoardAPI(board.boardUId, payload);
      toast.success("Saved");
      onSaved?.({ ...board, boardName: payload.boardName, visibility, backgroundUrl: payload.backgroundUrl });
      onClose?.();
    } catch { toast.error("Save failed"); }
    finally { setSaving(false); }
  };

  // ====== Delete board ======
  const handleDelete = async () => {
    if (!confirm("Delete this board? This cannot be undone.")) return;
    try {
      setDeleting(true);
      await deleteBoardAPI(board.boardUId, currentUserUId);
      toast.success("Board deleted");
      onSaved?.({ type: "delete", boardUId: board.boardUId });
      onClose?.();
    } catch { toast.error("Delete failed"); }
    finally { setDeleting(false); }
  };

  // ====== Remove member ======
  const handleRemoveMember = async (userUId) => {
    if (!currentUserUId) return toast.error("Missing requester");
    try {
      await removeBoardMemberAPI(board.boardUId, userUId, currentUserUId);
      toast.success("Member removed");
      loadMembers();
    } catch { toast.error("Remove failed"); }
  };

  const handleChangeRole = async (userUId, newRole) => {
    if (!currentUserUId) { toast.error("Missing requester!"); return; }
    if (!newRole) {
      if (!window.confirm("Remove this member from the board?")) return;
      return handleRemoveMember(userUId);
    }
    try {
      await updateBoardMemberRoleAPI(board.boardUId, userUId, newRole, currentUserUId);
      toast.success("Updated role");
      loadMembers();
    } catch { toast.error("Failed to update role"); }
  };

  const handleAddMember = async (userUId, role) => {
    if (!role || !currentUserUId) return;
    try {
      await addBoardMemberAPI(board.boardUId, userUId, currentUserUId, role);
      toast.success("Member added to board");
      loadMembers();
    } catch { toast.error("Failed to add member"); }
  };

  const getUserLabel = (userUId, fallback) => {
    const wm = Array.isArray(workspaceMembers)
      ? workspaceMembers.find((w) => w.userUId === userUId)
      : null;
    return wm?.userName || wm?.email || fallback?.email || fallback?.userName || userUId;
  };

  const availableWorkspaceMembers = Array.isArray(workspaceMembers)
    ? workspaceMembers.filter((wm) => !members.some((bm) => bm.userUId === wm.userUId))
    : [];

  // ====== Background: upload file ======
  const handleFileUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (!file.type.startsWith("image/")) { toast.error("Please choose an image file"); return; }
    try {
      setUploadingBg(true);
      const formData = new FormData();
      formData.append("file", file);
      const res = await AxiosClient.post(
        `boards/${board.boardUId}/upload-background?userUId=${currentUserUId}`,
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      const url = res?.url || res?.data?.url || "";
      if (url) {
        setBgPreview(url);
        toast.success("Background uploaded");
      }
    } catch { toast.error("Upload failed"); }
    finally { setUploadingBg(false); }
  };

  // ====== Background: pick preset ======
  const applyPreset = async (preset) => {
    const value = preset.value;
    setBgPreview(value);
    // Persist immediately
    try {
      await updateBoardAPI(board.boardUId, {
        boardUId: board.boardUId,
        boardName: board.boardName,
        backgroundUrl: value,
        userUId: currentUserUId,
        visibility: board.visibility,
        status: board.status || "Active",
        createdAt: board.createdAt || new Date().toISOString(),
      });
      toast.success("Background updated");
      onSaved?.({ ...board, backgroundUrl: value });
    } catch { toast.error("Failed to apply background"); }
  };

  const clearBackground = async () => {
    setBgPreview("");
    try {
      await updateBoardAPI(board.boardUId, {
        boardUId: board.boardUId,
        boardName: board.boardName,
        backgroundUrl: "",
        userUId: currentUserUId,
        visibility: board.visibility,
        status: board.status || "Active",
        createdAt: board.createdAt || new Date().toISOString(),
      });
      toast.success("Background removed");
      onSaved?.({ ...board, backgroundUrl: "" });
    } catch { toast.error("Failed to remove background"); }
  };

  // ====== Move Board ======
  const handleMoveBoard = async () => {
    if (!targetWorkspaceId) { toast.error("Please choose a destination workspace"); return; }
    try {
      setMoving(true);
      const res = await AxiosClient.post(
        `boardMember/${board.boardUId}/transfer-workspace`,
        null,
        { params: { newWorkspaceUId: targetWorkspaceId, requesterUId: currentUserUId } }
      );
      toast.success("Board moved successfully");
      onSaved?.({ ...board, workspaceUId: targetWorkspaceId });
      onClose?.();
    } catch {
      toast.error("Failed to move board");
    } finally {
      setMoving(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      onClick={(e) => { if (e.target === e.currentTarget) onClose?.(); }}
    >
      <div className="absolute inset-0 bg-black/60" />
      <div className="dark:bg-zinc-900 dark:border dark:border-zinc-700 relative w-full max-w-lg bg-white rounded-2xl shadow-2xl overflow-hidden">
        {/* Background preview strip */}
        {bgPreview && (
          <div
            className="h-12 w-full"
            style={
              bgPreview.startsWith("linear-gradient") || bgPreview.startsWith("#")
                ? { background: bgPreview }
                : { backgroundImage: `url(${bgPreview})`, backgroundSize: "cover", backgroundPosition: "center" }
            }
          />
        )}

        <div className="p-6">
          <button
            onClick={onClose}
            className="dark:hover:bg-zinc-800 absolute right-4 top-4 p-2 rounded-full hover:bg-gray-100"
            aria-label="Close"
          >
            <X className="text-gray-700 dark:!text-gray-200" size={18} />
          </button>

          <h3 className="dark:!text-gray-100 text-xl font-bold mb-4">Board settings</h3>

          {/* Tab Bar */}
          <div className="flex gap-1 mb-5 border-b dark:border-zinc-700">
            {TABS.map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={[
                  "px-3 py-2 text-sm font-medium rounded-t-lg transition",
                  activeTab === tab
                    ? "border-b-2 border-blue-500 text-blue-600 dark:text-blue-400"
                    : "text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200",
                ].join(" ")}
              >
                {tab === "General" && <Settings2Inline />}
                {tab === "Background" && <Image size={14} className="inline mr-1" />}
                {tab === "Move Board" && <ArrowLeftRight size={14} className="inline mr-1" />}
                {tab}
              </button>
            ))}
          </div>

          {/* ── TAB: General ── */}
          {activeTab === "General" && (
            <form onSubmit={handleSave} className="space-y-4">
              {/* Name */}
              <div>
                <label className="dark:!text-gray-200 block text-sm font-medium text-gray-700 mb-1">
                  Board name
                </label>
                <input
                  className="dark:bg-zinc-800 dark:border-zinc-700 dark:!text-gray-100 w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Board name..."
                />
              </div>

              {/* Visibility */}
              <div>
                <label className="dark:!text-gray-200 block text-sm font-medium text-gray-700 mb-2">
                  Visibility
                </label>
                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={() => setVisibility("Public")}
                    className={`flex items-center gap-2 px-3 py-2 rounded-lg border text-sm transition ${
                      visibility === "Public"
                        ? "dark:bg-blue-900/30 dark:border-blue-400 dark:!text-blue-200 bg-blue-100 border-blue-500 text-blue-700"
                        : "dark:border-zinc-700 dark:hover:bg-zinc-800 dark:!text-gray-200 border-gray-300 hover:bg-gray-50"
                    }`}
                  >
                    <Globe size={16} /> Public
                  </button>
                  <button
                    type="button"
                    onClick={() => setVisibility("Private")}
                    className={`flex items-center gap-2 px-3 py-2 rounded-lg border text-sm transition ${
                      visibility === "Private"
                        ? "dark:bg-blue-900/30 dark:border-blue-400 dark:!text-blue-200 bg-blue-100 border-blue-500 text-blue-700"
                        : "dark:border-zinc-700 dark:hover:bg-zinc-800 dark:!text-gray-200 border-gray-300 hover:bg-gray-50"
                    }`}
                  >
                    <Lock size={16} /> Private
                  </button>
                </div>
                <p className="text-xs text-gray-500 mt-1 dark:!text-gray-300">
                  {visibility === "Public"
                    ? "All workspace members can view this board."
                    : "Only invited members can access this board."}
                </p>
              </div>

              {/* Board members */}
              {board.workspaceUId && visibility === "Private" && (
                <>
                  <div className="mt-4 pt-4 border-t dark:border-zinc-700">
                    <label className="dark:!text-gray-200 block text-sm font-medium text-gray-700 mb-2">
                      Board members
                    </label>
                    {loadingMembers ? (
                      <p className="text-sm text-gray-500 dark:!text-gray-300">Loading...</p>
                    ) : members.length === 0 ? (
                      <p className="text-sm text-gray-500 dark:!text-gray-300">No members in this board.</p>
                    ) : (
                      <div className="space-y-3 max-h-48 overflow-y-auto pr-2">
                        {members.map((m) => {
                          const isOwner = m.role === "Owner";
                          return (
                            <div key={m.userUId} className="flex justify-between items-center bg-gray-50 dark:bg-zinc-800 rounded-lg px-3 py-2">
                              <span className="text-sm font-medium text-gray-700 dark:!text-gray-100">
                                {getUserLabel(m.userUId, m)}
                                {isOwner && <span className="ml-2 text-xs text-blue-600 dark:!text-blue-300">(Owner)</span>}
                              </span>
                              {isOwner ? (
                                <select disabled value="Owner" className="border border-gray-200 bg-gray-100 rounded-md text-sm px-2 py-1 text-gray-500 cursor-not-allowed dark:bg-zinc-700 dark:border-zinc-600 dark:!text-gray-300">
                                  <option value="Owner">Owner</option>
                                </select>
                              ) : (
                                <select value={m.role || ""} onChange={(e) => handleChangeRole(m.userUId, e.target.value)} className="border border-gray-300 rounded-md text-sm px-2 py-1 text-gray-700 cursor-pointer dark:bg-zinc-700 dark:border-zinc-600 dark:!text-gray-200">
                                  <option value="">Not participating</option>
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
                  </div>

                  {availableWorkspaceMembers.length > 0 && (
                    <div className="mt-4 pt-4 border-t dark:border-zinc-700">
                      <label className="dark:!text-gray-200 block text-sm font-medium text-gray-700 mb-1">
                        Add from workspace
                      </label>
                      <div className="space-y-3 max-h-40 overflow-y-auto pr-2">
                        {availableWorkspaceMembers.map((m) => (
                          <div key={m.userUId} className="flex justify-between items-center bg-gray-50 dark:bg-zinc-800 rounded-lg px-3 py-2">
                            <span className="text-sm font-medium text-gray-700 dark:!text-gray-100">{getUserLabel(m.userUId, m)}</span>
                            <select defaultValue="" onChange={(e) => handleAddMember(m.userUId, e.target.value)} className="border border-gray-300 rounded-md text-sm px-2 py-1 text-gray-700 cursor-pointer dark:bg-zinc-700 dark:border-zinc-600 dark:!text-gray-200">
                              <option value="">Not participating</option>
                              <option value="Admin">Admin</option>
                              <option value="Member">Member</option>
                              <option value="Viewer">Viewer</option>
                            </select>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </>
              )}

              {/* Footer */}
              <div className="dark:border-zinc-700 flex justify-between items-center pt-4 border-t">
                <button type="button" onClick={handleDelete} disabled={deleting}
                  className="dark:border-red-400/40 dark:!text-red-300 dark:hover:bg-red-900/20 inline-flex items-center gap-2 px-4 py-2 rounded-lg border border-red-300 text-red-600 hover:bg-red-50">
                  <Trash2 size={16} /> {deleting ? "Deleting..." : "Delete board"}
                </button>
                <div className="flex gap-2">
                  <button type="button" onClick={onClose}
                    className="px-4 py-2 rounded-lg border hover:bg-gray-50 border-gray-300 text-gray-700 dark:border-zinc-700 dark:hover:bg-zinc-800 dark:!text-gray-200">
                    Cancel
                  </button>
                  <button type="submit" disabled={saving}
                    className={`px-4 py-2 rounded-lg text-white ${saving ? "bg-gray-400" : "bg-blue-600 hover:bg-blue-700"}`}>
                    {saving ? "Saving..." : "Save changes"}
                  </button>
                </div>
              </div>
            </form>
          )}

          {/* ── TAB: Background ── */}
          {activeTab === "Background" && (
            <div className="space-y-5">
              {/* Current preview */}
              {bgPreview && (
                <div className="relative h-24 rounded-xl overflow-hidden">
                  <div
                    className="absolute inset-0"
                    style={
                      bgPreview.startsWith("linear-gradient") || bgPreview.startsWith("#")
                        ? { background: bgPreview }
                        : { backgroundImage: `url(${bgPreview})`, backgroundSize: "cover", backgroundPosition: "center" }
                    }
                  />
                  <button
                    onClick={clearBackground}
                    className="absolute top-2 right-2 bg-black/50 hover:bg-black/70 text-white rounded-full p-1 transition"
                    title="Remove background"
                  >
                    <X size={14} />
                  </button>
                  <p className="absolute bottom-2 left-3 text-white text-xs font-medium drop-shadow">Current background</p>
                </div>
              )}

              {/* Upload photo */}
              <div>
                <p className="text-sm font-semibold text-gray-700 dark:!text-gray-200 mb-2 flex items-center gap-1">
                  <Upload size={14} /> Upload photo
                </p>
                <button
                  type="button"
                  onClick={() => fileRef.current?.click()}
                  disabled={uploadingBg}
                  className="w-full border-2 border-dashed border-gray-300 dark:border-zinc-600 rounded-xl py-4 text-sm text-gray-500 dark:!text-gray-300 hover:border-blue-400 hover:bg-blue-50/50 dark:hover:bg-blue-900/10 transition"
                >
                  {uploadingBg ? "Uploading..." : "Click to choose a photo"}
                </button>
                <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handleFileUpload} />
              </div>

              {/* Preset backgrounds */}
              <div>
                <p className="text-sm font-semibold text-gray-700 dark:!text-gray-200 mb-2 flex items-center gap-1">
                  <Palette size={14} /> Presets
                </p>
                <div className="grid grid-cols-5 gap-2">
                  {PRESET_BACKGROUNDS.map((preset) => (
                    <button
                      key={preset.value}
                      title={preset.label}
                      onClick={() => applyPreset(preset)}
                      className={[
                        "h-10 rounded-lg transition hover:scale-105 hover:shadow-md",
                        bgPreview === preset.value ? "ring-2 ring-blue-500 ring-offset-1" : "",
                      ].join(" ")}
                      style={{
                        background: preset.value,
                      }}
                    />
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* ── TAB: Move Board ── */}
          {activeTab === "Move Board" && (
            <div className="space-y-4">
              <p className="text-sm text-gray-600 dark:!text-gray-300">
                Move this board to a different workspace. You must be an Admin or Owner of the destination workspace.
              </p>
              <div>
                <label className="dark:!text-gray-200 block text-sm font-medium text-gray-700 mb-1">
                  Destination workspace
                </label>
                <select
                  value={targetWorkspaceId}
                  onChange={(e) => setTargetWorkspaceId(e.target.value)}
                  className="w-full border border-gray-300 dark:border-zinc-600 rounded-lg px-3 py-2 text-sm dark:bg-zinc-800 dark:!text-gray-100 outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">— Choose workspace —</option>
                  {workspaces
                    .filter((ws) => ws.workspaceUId !== board.workspaceUId)
                    .map((ws) => (
                      <option key={ws.workspaceUId} value={ws.workspaceUId}>
                        {ws.name}
                      </option>
                    ))}
                </select>
              </div>
              <div className="flex justify-end gap-2 pt-2 border-t dark:border-zinc-700">
                <button type="button" onClick={onClose}
                  className="px-4 py-2 rounded-lg border hover:bg-gray-50 border-gray-300 text-gray-700 dark:border-zinc-700 dark:hover:bg-zinc-800 dark:!text-gray-200">
                  Cancel
                </button>
                <button
                  onClick={handleMoveBoard}
                  disabled={moving || !targetWorkspaceId}
                  className={`px-4 py-2 rounded-lg text-white font-medium flex items-center gap-2 ${
                    moving || !targetWorkspaceId ? "bg-gray-400 cursor-not-allowed" : "bg-blue-600 hover:bg-blue-700"
                  }`}
                >
                  <ArrowLeftRight size={16} />
                  {moving ? "Moving..." : "Move board"}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// Tiny inline icon helper
function Settings2Inline() {
  return null; // no icon for General tab, keep it clean
}

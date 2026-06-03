import React, { useEffect, useRef, useState } from "react";
import { Handle, Position } from "reactflow";
import {
  Layers, CheckCircle, Clock, AlertCircle, Archive,
  Settings, Trash2, Link2, ExternalLink, X,
  Globe, Lock, Users, Eye, EyeOff,
} from "lucide-react";
import { getBoardMembersAPI } from "../../services/BoardMemberAPI";

const STATUS_CONFIG = {
  Active:   { label: "Active",   color: "bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300",  icon: CheckCircle },
  "To Do":  { label: "To Do",   color: "bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300",      icon: Clock },
  Blocked:  { label: "Blocked", color: "bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-300",          icon: AlertCircle },
  Archived: { label: "Archived",color: "bg-gray-100 text-gray-500 dark:bg-gray-800 dark:text-gray-400",         icon: Archive },
};

const HANDLE_STYLE = "!w-2.5 !h-2.5 !border-2 !border-white dark:!border-[#2B2D31]";

export default function BoardNode({ id, data }) {
  const [menuOpen, setMenuOpen] = useState(false);

  // ── Display toggles (default all visible) ─────────────────────────────────
  const [showStatus,     setShowStatus]     = useState(true);
  const [showVisibility, setShowVisibility] = useState(true);
  const [showMembers,    setShowMembers]    = useState(false);

  // Members (lazy loaded when showMembers toggled on)
  const [members, setMembers]           = useState([]);
  const [loadingMembers, setLoading]    = useState(false);
  const menuRef = useRef(null);

  const status     = STATUS_CONFIG[data.boardStatus] ?? STATUS_CONFIG["Active"];
  const StatusIcon = status.icon;
  const visibility = data.visibility ?? "Public";

  // Close menu on outside click
  useEffect(() => {
    const handler = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) setMenuOpen(false);
    };
    if (menuOpen) document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [menuOpen]);

  // Lazy-load members when section shown
  useEffect(() => {
    if (!showMembers || members.length > 0 || !data.referenceId) return;
    setLoading(true);
    getBoardMembersAPI(data.referenceId)
      .then((res) => setMembers(Array.isArray(res) ? res : res?.members ?? []))
      .catch(() => setMembers([]))
      .finally(() => setLoading(false));
  }, [showMembers, data.referenceId]);

  return (
    <div className="
      w-60 rounded-xl shadow-lg border border-gray-200 dark:border-[#3F4147]
      bg-white dark:bg-[#2B2D31]
      hover:shadow-xl transition-shadow duration-150 relative select-none
    ">
      {/* ── 4 Handles ── */}
      <Handle type="target" position={Position.Top}    id="t-top"    className={`${HANDLE_STYLE} !bg-blue-500`}   style={{ left: "50%" }} />
      <Handle type="source" position={Position.Bottom} id="s-bottom" className={`${HANDLE_STYLE} !bg-purple-500`} style={{ left: "50%" }} />
      <Handle type="target" position={Position.Left}   id="t-left"   className={`${HANDLE_STYLE} !bg-blue-400`}   style={{ top: "50%" }} />
      <Handle type="source" position={Position.Right}  id="s-right"  className={`${HANDLE_STYLE} !bg-purple-400`} style={{ top: "50%" }} />

      {/* ── Header ── */}
      <div className="flex items-center gap-2 px-3 pt-3 pb-2 border-b border-gray-100 dark:border-[#3F4147]">
        <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-indigo-500 to-purple-600
          flex items-center justify-center flex-shrink-0 shadow-sm">
          <Layers size={14} className="text-white" />
        </div>
        <span className="text-sm font-semibold text-gray-800 dark:text-[#E8EAED] truncate flex-1" title={data.boardName}>
          {data.boardName ?? "Board"}
        </span>
        <button
          onClick={(e) => { e.stopPropagation(); setMenuOpen((v) => !v); }}
          className={`flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center transition-colors
            ${menuOpen
              ? "bg-indigo-100 dark:bg-indigo-900/50 text-indigo-600 dark:text-indigo-400"
              : "text-gray-400 hover:text-gray-600 hover:bg-gray-100 dark:hover:bg-[#3A3C42]"}`}
          title="Settings"
        >
          <Settings size={13} />
        </button>
      </div>

      {/* ── Body ── */}
      <div className="px-3 py-2 space-y-1.5">
        {/* Status */}
        {showStatus && (
          <div className="flex items-center gap-1.5">
            <StatusIcon size={11} className="text-gray-400 flex-shrink-0" />
            <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${status.color}`}>
              {status.label}
            </span>
          </div>
        )}

        {/* Visibility */}
        {showVisibility && (
          <div className="flex items-center gap-1.5">
            {visibility === "Public"
              ? <Globe size={11} className="text-gray-400 flex-shrink-0" />
              : <Lock size={11} className="text-gray-400 flex-shrink-0" />}
            <span className="text-[11px] text-gray-500 dark:text-[#9AA0A6]">{visibility}</span>
          </div>
        )}

        {/* Members */}
        {showMembers && (
          <div>
            {loadingMembers && <p className="text-[10px] text-gray-400">Đang tải…</p>}
            {!loadingMembers && members.length === 0 && (
              <p className="text-[10px] text-gray-400 flex items-center gap-1"><Users size={9} />Chưa có thành viên</p>
            )}
            {!loadingMembers && members.slice(0, 4).map((m, i) => {
              const name = m.userName ?? m.UserName ?? m.email ?? m.userUId ?? "?";
              return (
                <div key={m.userUId ?? i} className="flex items-center gap-1.5 mt-0.5">
                  <div className="w-4 h-4 rounded-full bg-indigo-100 dark:bg-indigo-900/40 text-indigo-600
                    text-[8px] font-bold flex items-center justify-center flex-shrink-0">
                    {name.charAt(0).toUpperCase()}
                  </div>
                  <span className="text-[10px] text-gray-500 dark:text-[#9AA0A6] truncate">{name}</span>
                  <span className="ml-auto text-[9px] text-gray-400 flex-shrink-0">{m.role ?? m.boardRole}</span>
                </div>
              );
            })}
            {members.length > 4 && (
              <p className="text-[10px] text-gray-400 mt-0.5">+{members.length - 4} người khác</p>
            )}
          </div>
        )}
      </div>

      {/* ── Settings dropdown ── */}
      {menuOpen && (
        <div
          ref={menuRef}
          className="
            absolute top-1 right-[-176px] z-[9999]
            w-44 rounded-xl shadow-2xl
            bg-white dark:bg-[#2B2D31]
            border border-gray-200 dark:border-[#3F4147]
            p-1.5 flex flex-col gap-0.5
          "
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex items-center justify-between px-2 py-1 mb-0.5">
            <span className="text-[10px] font-bold uppercase tracking-wide text-gray-400">Board</span>
            <button onClick={() => setMenuOpen(false)} className="text-gray-400 hover:text-gray-600"><X size={12} /></button>
          </div>

          {/* Actions */}
          <NodeMenu icon={<ExternalLink size={12} />} label="Mở board"
            onClick={() => { setMenuOpen(false); if (data.onOpenBoard) data.onOpenBoard(data.referenceId); }} />
          <NodeMenu icon={<Settings size={12} />} label="Cài đặt board"
            onClick={() => { setMenuOpen(false); if (data.onEditBoard) data.onEditBoard(data.referenceId); }} />
          <NodeMenu icon={<Link2 size={12} />} label="Thêm liên kết"
            onClick={() => { setMenuOpen(false); if (data.onLinkToBoard) data.onLinkToBoard(id); }} />

          <hr className="border-gray-100 dark:border-[#3F4147] my-1" />

          {/* Display toggles */}
          <p className="px-2 text-[9px] font-bold uppercase tracking-wider text-gray-400 mb-0.5">Hiển thị</p>

          <ToggleItem label="Trạng thái" enabled={showStatus}
            onToggle={() => setShowStatus((v) => !v)} />
          <ToggleItem label="Visibility" enabled={showVisibility}
            onToggle={() => setShowVisibility((v) => !v)} />
          <ToggleItem label="Thành viên" enabled={showMembers}
            onToggle={() => setShowMembers((v) => !v)} />

          <hr className="border-gray-100 dark:border-[#3F4147] my-1" />

          <NodeMenu icon={<Trash2 size={12} />} label="Xóa khỏi canvas" danger
            onClick={() => { setMenuOpen(false); if (data.onRemoveFromCanvas) data.onRemoveFromCanvas(id); }} />
          <NodeMenu icon={<Trash2 size={12} />} label="Xóa khỏi workspace" danger
            onClick={() => { setMenuOpen(false); if (data.onDeleteFromWorkspace) data.onDeleteFromWorkspace(id, data.referenceId, data.boardName); }} />
        </div>
      )}
    </div>
  );
}

function NodeMenu({ icon, label, onClick, danger = false }) {
  return (
    <button onClick={onClick}
      className={`flex items-center gap-2 px-2 py-1.5 rounded-lg w-full text-left text-xs transition-colors
        ${danger ? "text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20"
          : "text-gray-600 dark:text-[#B5BAC1] hover:bg-gray-50 dark:hover:bg-[#3A3C42]"}`}>
      {icon}<span>{label}</span>
    </button>
  );
}

function ToggleItem({ label, enabled, onToggle }) {
  return (
    <button onClick={onToggle}
      className="flex items-center justify-between px-2 py-1.5 rounded-lg w-full text-xs transition-colors
        text-gray-600 dark:text-[#B5BAC1] hover:bg-gray-50 dark:hover:bg-[#3A3C42]">
      <span>{label}</span>
      <div className={`w-7 h-4 rounded-full transition-colors flex-shrink-0 flex items-center px-0.5
        ${enabled ? "bg-indigo-500" : "bg-gray-200 dark:bg-[#3A3C42]"}`}>
        <div className={`w-3 h-3 rounded-full bg-white shadow transition-transform
          ${enabled ? "translate-x-3" : "translate-x-0"}`} />
      </div>
    </button>
  );
}

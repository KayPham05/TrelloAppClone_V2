/* LabelPickerPopup.jsx
 * Popup quản lý nhãn của card – giống screenshot Flutter
 *
 * Logic:
 *   - Tất cả nhãn đang có trên card = đã tick (checked)
 *   - Click vào checkbox của nhãn → DELETE khỏi card
 *   - Click "Tạo nhãn mới" → view Create
 *   - Click biểu tượng bút → view Edit (cập nhật title/color hoặc xóa)
 *   - Nếu > 7 nhãn → nút "Hiển thị thêm nhãn"
 *
 * Dedup khi tạo/sửa:
 *   - Cùng title (không rỗng) → không cho phép
 *   - Cả hai rỗng title + cùng màu → không cho phép
 */
import React, { useState, useRef } from "react";
import { X, ChevronLeft, Edit2 } from "lucide-react";
import {
  addCardLabelAPI,
  updateCardLabelAPI,
  deleteCardLabelAPI,
} from "../services/LabelAPI";

/* ─── Bảng màu (30 màu, 6 hàng × 5 cột) ──────────────────────── */
const PALETTE = [
  // hàng 1 – nhạt
  "#B7F5D2", "#FFF0B3", "#FFE0C4", "#FFD2CC", "#EDD8F0",
  // hàng 2 – vừa nhạt
  "#4BBF6B", "#DBB124", "#FF9F1A", "#EB5A46", "#C377E0",
  // hàng 3 – vừa đậm
  "#1E7F51", "#8B791B", "#B15F1C", "#B92C23", "#7E3DCC",
  // hàng 4 – xanh dương nhạt
  "#DEEBFF", "#E6FCFF", "#E3FCEF", "#FFECD2", "#F0F0F0",
  // hàng 5 – xanh dương vừa
  "#4DA0FF", "#00C7D1", "#94C748", "#FF78CB", "#A5ADBA",
  // hàng 6 – đậm
  "#0052CC", "#008B94", "#519839", "#893F62", "#42526E",
];

const SHOW_LIMIT = 7;

export default function LabelPickerPopup({ card, initialLabels, onClose, onLabelsChange }) {
  const [labels, setLabels] = useState(initialLabels || []);
  const [view, setView]   = useState("list"); // "list" | "create" | "edit"
  const [editing, setEditing] = useState(null);
  const [search, setSearch]   = useState("");
  const [showAll, setShowAll] = useState(false);
  const [busy, setBusy] = useState(false);

  /* Sync to parent */
  const syncParent = (next) => {
    setLabels(next);
    onLabelsChange?.(next);
  };

  /* ── Dedup check ─────────────────────────────────────────────── */
  const isDuplicate = (title, colorCode, excludeUId = null) => {
    const t = (title || "").trim().toLowerCase();
    return labels.some((l) => {
      if (excludeUId && l.cardLabelUId === excludeUId) return false;
      const lt = (l.title || "").trim().toLowerCase();
      if (t !== "" && lt === t) return true;                    // cùng title
      if (t === "" && lt === "" && l.colorCode === colorCode) return true; // rỗng + cùng màu
      return false;
    });
  };

  /* ── Toggle (check → uncheck = DELETE) ──────────────────────── */
  const handleToggle = async (label) => {
    if (busy) return;
    try {
      setBusy(true);
      await deleteCardLabelAPI(card.cardUId, label.cardLabelUId);
      syncParent(labels.filter((l) => l.cardLabelUId !== label.cardLabelUId));
    } catch {} finally { setBusy(false); }
  };

  /* ── Tạo nhãn mới ────────────────────────────────────────────── */
  const handleCreate = async (title, colorCode) => {
    if (!colorCode || isDuplicate(title, colorCode)) return;
    try {
      setBusy(true);
      const raw = await addCardLabelAPI(card.cardUId, (title || "").trim(), colorCode);
      const newLabel = raw?.data ?? raw;
      if (newLabel?.cardLabelUId) syncParent([...labels, newLabel]);
      setView("list");
    } catch {} finally { setBusy(false); }
  };

  /* ── Cập nhật nhãn ───────────────────────────────────────────── */
  const handleUpdate = async (labelId, title, colorCode) => {
    if (!colorCode || isDuplicate(title, colorCode, labelId)) return;
    try {
      setBusy(true);
      await updateCardLabelAPI(card.cardUId, labelId, (title || "").trim(), colorCode);
      syncParent(labels.map((l) =>
        l.cardLabelUId === labelId ? { ...l, title: (title || "").trim(), colorCode } : l
      ));
      setView("list");
      setEditing(null);
    } catch {} finally { setBusy(false); }
  };

  /* ── Xóa nhãn ────────────────────────────────────────────────── */
  const handleDelete = async (labelId) => {
    try {
      setBusy(true);
      await deleteCardLabelAPI(card.cardUId, labelId);
      syncParent(labels.filter((l) => l.cardLabelUId !== labelId));
      setView("list");
      setEditing(null);
    } catch {} finally { setBusy(false); }
  };

  /* Filter + paginate */
  const filtered = labels.filter((l) => {
    const q = search.toLowerCase();
    return (l.title || "").toLowerCase().includes(q) || (l.colorCode || "").toLowerCase().includes(q);
  });
  const visible   = showAll ? filtered : filtered.slice(0, SHOW_LIMIT);
  const hasMore   = !showAll && filtered.length > SHOW_LIMIT;

  return (
    /* Backdrop */
    <div className="fixed inset-0 z-[9999] flex items-center justify-center" onClick={onClose}>
      <div
        className="relative bg-white dark:bg-[#2A2D31] rounded-2xl shadow-2xl border border-gray-200 dark:border-zinc-700 w-[340px] max-h-[90vh] flex flex-col overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {view === "list" && (
          <ListView
            visible={visible}
            hasMore={hasMore}
            search={search}
            setSearch={setSearch}
            setShowAll={setShowAll}
            onClose={onClose}
            onToggle={handleToggle}
            onEdit={(lbl) => { setEditing(lbl); setView("edit"); }}
            onCreate={() => { setEditing(null); setView("create"); }}
          />
        )}

        {view === "create" && (
          <EditView
            key="create"
            mode="create"
            initial={{ title: "", colorCode: "" }}
            busy={busy}
            onBack={() => setView("list")}
            onClose={onClose}
            onSave={handleCreate}
            onDelete={null}
          />
        )}

        {view === "edit" && editing && (
          <EditView
            key={editing.cardLabelUId}
            mode="edit"
            initial={{ title: editing.title || "", colorCode: editing.colorCode }}
            busy={busy}
            onBack={() => { setEditing(null); setView("list"); }}
            onClose={onClose}
            onSave={(t, c) => handleUpdate(editing.cardLabelUId, t, c)}
            onDelete={() => handleDelete(editing.cardLabelUId)}
          />
        )}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════
   LIST VIEW
   ═══════════════════════════════════════════════════ */
function ListView({ visible, hasMore, search, setSearch, setShowAll, onClose, onToggle, onEdit, onCreate }) {
  return (
    <>
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-4 pb-2 shrink-0">
        <span className="text-sm font-semibold text-gray-800 dark:text-gray-100">Nhãn</span>
        <button onClick={onClose} className="p-1.5 rounded-full hover:bg-gray-100 dark:hover:bg-zinc-700 text-gray-400">
          <X size={16} />
        </button>
      </div>

      {/* Search */}
      <div className="px-3 pb-2 shrink-0">
        <input
          type="text"
          placeholder="Tìm nhãn..."
          value={search}
          autoFocus
          onChange={(e) => setSearch(e.target.value)}
          className="w-full px-3 py-2 text-sm border-2 border-blue-400 rounded-lg outline-none bg-white dark:bg-zinc-700 dark:text-gray-100"
        />
      </div>

      <p className="px-4 pb-1 text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400 shrink-0">
        Nhãn
      </p>

      {/* Rows */}
      <div className="flex flex-col gap-1.5 px-3 pb-2 overflow-y-auto">
        {visible.length === 0 && (
          <p className="text-xs text-gray-400 italic py-2">Không có nhãn nào.</p>
        )}
        {visible.map((lbl) => (
          <div key={lbl.cardLabelUId} className="flex items-center gap-2">
            {/* Checkbox – tất cả nhãn trên card đều là checked */}
            <button
              onClick={() => onToggle(lbl)}
              className="w-5 h-5 rounded border-2 border-blue-600 bg-blue-600 flex items-center justify-center shrink-0 hover:bg-blue-700 transition"
              title="Bỏ nhãn"
            >
              <svg viewBox="0 0 12 10" className="w-3 h-3 fill-white">
                <path d="M1 5l3.5 3.5L11 1" stroke="white" strokeWidth="1.8" fill="none" strokeLinecap="round"/>
              </svg>
            </button>

            {/* Color pill */}
            <div
              className="flex-1 h-9 rounded-md px-3 flex items-center cursor-default"
              style={{ backgroundColor: lbl.colorCode || "#ccc" }}
            >
              <span className="text-white text-sm font-semibold truncate drop-shadow-sm">{lbl.title}</span>
            </div>

            {/* Edit button */}
            <button
              onClick={() => onEdit(lbl)}
              className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-zinc-700 text-gray-500 dark:text-gray-400 shrink-0"
            >
              <Edit2 size={15} />
            </button>
          </div>
        ))}
      </div>

      {/* Show more */}
      {hasMore && (
        <button
          onClick={() => setShowAll(true)}
          className="mx-3 mb-1 py-2 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-zinc-700 hover:bg-gray-200 dark:hover:bg-zinc-600 transition"
        >
          Hiển thị thêm nhãn
        </button>
      )}

      {/* Footer */}
      <div className="px-3 pb-3 pt-2 flex flex-col gap-2 border-t border-gray-100 dark:border-zinc-700 shrink-0">
        <button
          onClick={onCreate}
          className="py-2 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-zinc-700 hover:bg-gray-200 dark:hover:bg-zinc-600 transition"
        >
          Tạo nhãn mới
        </button>
        <button
          className="py-2 rounded-lg text-sm font-medium text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-zinc-800 hover:bg-gray-100 dark:hover:bg-zinc-700 transition"
          onClick={() => {}}
        >
          Bật chế độ thân thiện với người mù màu
        </button>
      </div>
    </>
  );
}

/* ═══════════════════════════════════════════════════
   EDIT / CREATE VIEW
   ═══════════════════════════════════════════════════ */
function EditView({ mode, initial, busy, onBack, onClose, onSave, onDelete }) {
  const [title, setTitle] = useState(initial.title);
  const [colorCode, setColorCode] = useState(initial.colorCode);

  return (
    <>
      {/* Header */}
      <div className="relative flex items-center justify-between px-3 pt-4 pb-3 shrink-0">
        <button onClick={onBack} className="p-1.5 rounded-full hover:bg-gray-100 dark:hover:bg-zinc-700 text-gray-500">
          <ChevronLeft size={18} />
        </button>
        <span className="absolute left-1/2 -translate-x-1/2 text-sm font-semibold text-gray-800 dark:text-gray-100 whitespace-nowrap">
          {mode === "create" ? "Tạo nhãn mới" : "Chỉnh sửa nhãn"}
        </span>
        <button onClick={onClose} className="p-1.5 rounded-full hover:bg-gray-100 dark:hover:bg-zinc-700 text-gray-500">
          <X size={16} />
        </button>
      </div>

      <div className="overflow-y-auto flex flex-col gap-4 px-4 pb-4">
        {/* Preview */}
        <div
          className="w-full h-12 rounded-lg flex items-center px-4 transition-colors"
          style={{ backgroundColor: colorCode || "#e2e8f0" }}
        >
          <span className="text-white font-semibold text-sm drop-shadow-sm">{title}</span>
        </div>

        {/* Title */}
        <div>
          <label className="block text-xs font-semibold text-gray-600 dark:text-gray-300 mb-1">Tiêu đề</label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Tên nhãn..."
            className="w-full px-3 py-2 border border-gray-300 dark:border-zinc-600 rounded-lg text-sm bg-white dark:bg-zinc-700 dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>

        {/* Color grid */}
        <div>
          <label className="block text-xs font-semibold text-gray-600 dark:text-gray-300 mb-2">Chọn một màu</label>
          <div className="grid grid-cols-5 gap-1.5">
            {PALETTE.map((hex) => (
              <button
                key={hex}
                onClick={() => setColorCode(hex)}
                className="h-8 rounded-md relative transition hover:scale-105 hover:shadow-md"
                style={{ backgroundColor: hex }}
                title={hex}
              >
                {colorCode === hex && (
                  <span className="absolute inset-0 flex items-center justify-center">
                    <svg viewBox="0 0 12 10" className="w-3.5 h-3.5" stroke="white" strokeWidth="2" fill="none" strokeLinecap="round">
                      <path d="M1 5l3.5 3.5L11 1"/>
                    </svg>
                  </span>
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Remove color */}
        <button
          onClick={() => setColorCode("")}
          className="flex items-center justify-center gap-2 py-2 rounded-lg text-sm text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-zinc-700 hover:bg-gray-200 dark:hover:bg-zinc-600 transition"
        >
          <X size={14} /> Gỡ bỏ màu
        </button>
      </div>

      {/* Footer – Lưu + Xoá */}
      <div className="flex gap-2 px-4 pb-4 shrink-0">
        <button
          onClick={() => onSave(title, colorCode)}
          disabled={!colorCode || busy}
          className={`flex-1 py-2 rounded-lg text-white text-sm font-semibold transition ${
            colorCode && !busy ? "bg-blue-600 hover:bg-blue-700" : "bg-gray-300 cursor-not-allowed"
          }`}
        >
          {busy ? "Đang lưu..." : "Lưu"}
        </button>
        {mode === "edit" && onDelete && (
          <button
            onClick={onDelete}
            disabled={busy}
            className="flex-1 py-2 rounded-lg text-white text-sm font-semibold bg-red-500 hover:bg-red-600 transition disabled:opacity-50"
          >
            Xoá
          </button>
        )}
      </div>
    </>
  );
}

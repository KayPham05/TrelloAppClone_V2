import React, { useEffect, useState } from "react";
import {
  CreditCard,
  Edit3,
  Archive,
  Trash2,
  Copy,
  ArrowRight,
  Users,
  ChevronRight,
  X,
} from "lucide-react";
import "./css/CardMenu.css";

export default function CardMenu({
  position,
  onEdit,
  onDelete,
  onOpenCard,
  onClose,
  onManageMembers,
  onMoveCard,  // NEW: callback (lists, boards) => void to open the move picker
  listUId,
  lists = [],   // lists in the current board for fast move
}) {
  const [showMovePicker, setShowMovePicker] = useState(false);

  useEffect(() => {
    const handleClick = (e) => {
      if (
        !e.target.closest(".card-menu-floating") &&
        !e.target.closest(".card-member-popup")
      ) {
        onClose();
      }
    };
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [onClose]);

  return (
    <div
      className="card-menu-floating"
      style={{ position: "fixed", top: position.top, left: position.left }}
    >
      <div className="card-menu-header">
        <span>Card actions</span>
        <button className="menu-close-btn" onClick={onClose}>×</button>
      </div>

      <div className="card-menu-section">
        <button className="card-menu-item" onClick={onOpenCard}>
          <CreditCard size={16} />
          <span>Open card</span>
        </button>

        <button className="card-menu-item" onClick={onEdit}>
          <Edit3 size={16} />
          <span>Edit</span>
        </button>

        {listUId && (
          <button
            className="card-menu-item"
            onClick={(e) => {
              const rect = e.currentTarget.getBoundingClientRect();
              onManageMembers({
                top: rect.top + window.scrollY,
                left: rect.right + 8 + window.scrollX,
              });
            }}
          >
            <Users size={16} />
            <span>Change member</span>
          </button>
        )}

        <button className="card-menu-item">
          <Copy size={16} />
          <span>Duplicate card</span>
        </button>

        {/* ── MOVE ── */}
        <div className="relative">
          <button
            className="card-menu-item"
            onClick={() => setShowMovePicker((v) => !v)}
          >
            <ArrowRight size={16} />
            <span>Move</span>
            <ChevronRight size={14} className="ml-auto opacity-50" />
          </button>

          {showMovePicker && (
            <div
              className="card-move-picker"
              onClick={(e) => e.stopPropagation()}
            >
              <p className="card-move-picker-title">Move to list</p>
              {lists.length === 0 && (
                <p className="card-move-picker-empty">No other lists</p>
              )}
              {lists
                .filter((l) => l.listUId !== listUId)
                .map((l) => (
                  <button
                    key={l.listUId}
                    className="card-move-picker-item"
                    onClick={() => {
                      onMoveCard?.(l.listUId);
                      onClose();
                    }}
                  >
                    {l.listName}
                  </button>
                ))}
              {/* Option to open full move dialog in CardModal */}
              <button
                className="card-move-picker-item card-move-picker-advanced"
                onClick={() => {
                  onOpenCard?.();
                  onClose();
                }}
              >
                More options (open card)…
              </button>
            </div>
          )}
        </div>
      </div>

      <div className="card-menu-divider" />

      <div className="card-menu-section">
        <button className="card-menu-item">
          <Archive size={16} />
          <span>Archive</span>
        </button>

        <button className="card-menu-item danger" onClick={onDelete}>
          <Trash2 size={16} />
          <span>Delete card</span>
        </button>
      </div>
    </div>
  );
}

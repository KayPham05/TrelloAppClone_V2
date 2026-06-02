import React, { useEffect, useLayoutEffect, useRef, useState } from "react";
import {
  BaseEdge,
  EdgeLabelRenderer,
  getBezierPath,
} from "reactflow";
import { ArrowLeftRight, RotateCcw, Type, Trash2, X, Check } from "lucide-react";

export default function CustomEdge({
  id,
  sourceX, sourceY, targetX, targetY,
  sourcePosition, targetPosition,
  data = {},
  style = {},
}) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [editingLabel, setEditingLabel] = useState(false);
  const [labelText, setLabelText] = useState(data.label ?? "");
  // "up" | "down" | "left" | "right" — determined after render
  const [menuDir, setMenuDir] = useState("up");
  const menuRef = useRef(null);
  const pillRef = useRef(null);

  const isReversed = data.isReversed ?? false;
  const isAnimated = data.animated !== false;

  const [sx, sy, tx, ty, sp, tp] = isReversed
    ? [targetX, targetY, sourceX, sourceY, targetPosition, sourcePosition]
    : [sourceX, sourceY, targetX, targetY, sourcePosition, targetPosition];

  const [edgePath, labelX, labelY] = getBezierPath({
    sourceX: sx, sourceY: sy, sourcePosition: sp,
    targetX: tx, targetY: ty, targetPosition: tp,
  });

  const edgeColor = isReversed ? "#f59e0b" : "#6366f1";

  // ── Smart positioning: after menu renders, pick the direction with most space ──
  useLayoutEffect(() => {
    if (!menuOpen || !menuRef.current || !pillRef.current) return;
    const pill = pillRef.current.getBoundingClientRect();
    const menuH = menuRef.current.offsetHeight || 220;
    const menuW = menuRef.current.offsetWidth || 200;
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    const spaceUp    = pill.top - 64;            // subtract header height
    const spaceDown  = vh - pill.bottom;
    const spaceLeft  = pill.left;
    const spaceRight = vw - pill.right;

    // Prefer vertical
    if (spaceUp >= menuH + 12) { setMenuDir("up"); return; }
    if (spaceDown >= menuH + 12) { setMenuDir("down"); return; }
    if (spaceRight >= menuW + 12) { setMenuDir("right"); return; }
    if (spaceLeft >= menuW + 12) { setMenuDir("left"); return; }
    // Fallback to wherever is most room
    setMenuDir(spaceUp >= spaceDown ? "up" : "down");
  }, [menuOpen]);

  // Close on outside click
  useEffect(() => {
    const handler = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target) &&
          pillRef.current && !pillRef.current.contains(e.target)) {
        setMenuOpen(false);
        setEditingLabel(false);
      }
    };
    if (menuOpen) document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [menuOpen]);

  const dispatch = (patch) => { if (data.onUpdate) data.onUpdate(id, patch); };
  const handleLabelSave = () => { dispatch({ label: labelText }); setEditingLabel(false); };

  // Menu positioning style
  const menuPositionStyle = () => {
    const base = { position: "absolute", zIndex: 99999 };
    switch (menuDir) {
      case "down":  return { ...base, top:   "calc(100% + 8px)", left: "50%", transform: "translateX(-50%)" };
      case "right": return { ...base, left:  "calc(100% + 8px)", top:  "50%", transform: "translateY(-50%)" };
      case "left":  return { ...base, right: "calc(100% + 8px)", top:  "50%", transform: "translateY(-50%)" };
      default:      return { ...base, bottom:"calc(100% + 8px)", left: "50%", transform: "translateX(-50%)" };
    }
  };

  return (
    <>
      {/* Arrowhead markers */}
      <svg style={{ position: "absolute", width: 0, height: 0, overflow: "hidden" }}>
        <defs>
          <marker id="arrow-indigo" markerWidth="10" markerHeight="10" refX="8" refY="3"
            orient="auto" markerUnits="strokeWidth">
            <path d="M0,0 L0,6 L9,3 z" fill="#6366f1" />
          </marker>
          <marker id="arrow-amber" markerWidth="10" markerHeight="10" refX="8" refY="3"
            orient="auto" markerUnits="strokeWidth">
            <path d="M0,0 L0,6 L9,3 z" fill="#f59e0b" />
          </marker>
        </defs>
      </svg>

      <BaseEdge
        path={edgePath}
        markerEnd={`url(#${isReversed ? "arrow-amber" : "arrow-indigo"})`}
        style={{
          stroke: edgeColor,
          strokeWidth: 2,
          strokeDasharray: isAnimated ? "6 3" : undefined,
          ...style,
        }}
        className={isAnimated ? "animated" : ""}
      />

      <EdgeLabelRenderer>
        <div
          style={{
            position: "absolute",
            transform: `translate(-50%, -50%) translate(${labelX}px, ${labelY}px)`,
            pointerEvents: "all",
            zIndex: 10,
          }}
          className="nodrag nopan"
        >
          {/* Pill trigger */}
          <button
            ref={pillRef}
            onClick={() => setMenuOpen((v) => !v)}
            className={`
              flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium
              shadow border transition-all
              ${menuOpen
                ? "bg-indigo-100 dark:bg-indigo-900/60 border-indigo-300 text-indigo-700 dark:text-indigo-300"
                : "bg-white dark:bg-[#2B2D31] border-gray-200 dark:border-[#3F4147] text-gray-400 hover:border-indigo-300"
              }
            `}
          >
            {data.label
              ? <span className="max-w-[90px] truncate text-gray-600 dark:text-[#B5BAC1]">{data.label}</span>
              : <span className="opacity-50 tracking-widest">···</span>}
          </button>

          {/* Context menu — rendered relative to pill, z-index very high */}
          {menuOpen && (
            <div
              ref={menuRef}
              style={menuPositionStyle()}
              className="
                bg-white dark:bg-[#2B2D31] rounded-xl shadow-2xl
                border border-gray-200 dark:border-[#3F4147]
                p-2 min-w-[190px] flex flex-col gap-1 pointer-events-auto
              "
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between px-2 py-1 mb-0.5">
                <span className="text-[10px] font-bold uppercase tracking-wide text-gray-400 dark:text-[#9AA0A6]">Edge</span>
                <button onClick={() => { setMenuOpen(false); setEditingLabel(false); }}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-white">
                  <X size={12} />
                </button>
              </div>

              {/* Label */}
              {editingLabel ? (
                <div className="flex gap-1 px-1">
                  <input autoFocus value={labelText} onChange={(e) => setLabelText(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleLabelSave()}
                    placeholder="Điều kiện…"
                    className="flex-1 text-xs px-2 py-1 rounded-lg border border-indigo-300 dark:border-[#5865F2]
                      dark:bg-[#1E1F22] dark:text-white outline-none" />
                  <button onClick={handleLabelSave}
                    className="p-1 rounded-lg bg-indigo-500 text-white hover:bg-indigo-600">
                    <Check size={12} />
                  </button>
                </div>
              ) : (
                <EdgeMenuBtn icon={<Type size={12} />}
                  label={data.label ? `Label: "${data.label}"` : "Thêm điều kiện…"}
                  onClick={() => setEditingLabel(true)} />
              )}

              <EdgeMenuBtn icon={<ArrowLeftRight size={12} />}
                label={isReversed ? "Chiều: ← Ngược" : "Chiều: → Xuôi"}
                onClick={() => dispatch({ isReversed: !isReversed })}
                active={isReversed} />

              <EdgeMenuBtn icon={<RotateCcw size={12} />}
                label={isAnimated ? "Animation: Bật" : "Animation: Tắt"}
                onClick={() => dispatch({ animated: !isAnimated })}
                active={isAnimated} />

              <hr className="border-gray-100 dark:border-[#3F4147] my-1" />

              <EdgeMenuBtn icon={<Trash2 size={12} />} label="Xóa kết nối"
                onClick={() => { setMenuOpen(false); if (data.onDelete) data.onDelete(id); }}
                danger />
            </div>
          )}
        </div>
      </EdgeLabelRenderer>
    </>
  );
}

function EdgeMenuBtn({ icon, label, onClick, active = false, danger = false }) {
  return (
    <button onClick={onClick}
      className={`flex items-center gap-2 px-2 py-1.5 rounded-lg w-full text-left text-xs transition-colors
        ${danger ? "text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20"
          : active ? "text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/20"
          : "text-gray-600 dark:text-[#B5BAC1] hover:bg-gray-50 dark:hover:bg-[#3A3C42]"}`}>
      {icon}<span>{label}</span>
    </button>
  );
}

import React, { useState } from "react";
import {
  ChevronDown,
  Users,
  Share2,
  Star,
  Filter,
  Settings,
  X,
  Search,
} from "lucide-react";
import EditBoardModal from "./EditBoardModal";
import "./css/BoardHeaderStyle.css";


const LABEL_COLORS = [
  { color: "#61BD4F", name: "Green" },
  { color: "#F2D600", name: "Yellow" },
  { color: "#FF9F1A", name: "Orange" },
  { color: "#EB5A46", name: "Red" },
  { color: "#C377E0", name: "Purple" },
  { color: "#0079BF", name: "Blue" },
  { color: "#00C2E0", name: "Sky" },
  { color: "#51E898", name: "Lime" },
  { color: "#FF78CB", name: "Pink" },
  { color: "#344563", name: "Black" },
];

export default function BoardHeader({ board, boardMembers, onBoardUpdated, onFilterChange }) {
  const [editing, setEditing] = useState(false);
  const [showFilter, setShowFilter] = useState(false);
  const [filterText, setFilterText] = useState("");
  const [selectedLabels, setSelectedLabels] = useState([]);
  const [selectedMemberUId, setSelectedMemberUId] = useState("");
  const [dueDateFilter, setDueDateFilter] = useState(""); // "overdue"|"today"|"week"|""

  const handleSaved = (nextBoard) => {
    if (nextBoard && onBoardUpdated) onBoardUpdated(nextBoard);
    setEditing(false);
  };

  const toggleLabel = (color) => {
    setSelectedLabels((prev) =>
      prev.includes(color) ? prev.filter((c) => c !== color) : [...prev, color]
    );
  };

  const clearFilter = () => {
    setFilterText("");
    setSelectedLabels([]);
    setSelectedMemberUId("");
    setDueDateFilter("");
    onFilterChange?.({ text: "", labels: [], memberUId: "", dueDate: "" });
  };

  // Propagate filter up whenever any value changes
  const applyFilter = (overrides = {}) => {
    const next = {
      text: filterText,
      labels: selectedLabels,
      memberUId: selectedMemberUId,
      dueDate: dueDateFilter,
      ...overrides,
    };
    onFilterChange?.(next);
  };

  const activeFiltersCount =
    (filterText ? 1 : 0) +
    selectedLabels.length +
    (selectedMemberUId ? 1 : 0) +
    (dueDateFilter ? 1 : 0);

  const activeMembers = (boardMembers || []).filter((m) =>
    ["Owner", "Admin", "Member"].includes(m.role)
  );

  return (
    <div className="relative">
      <div
        className={[
          "w-full flex items-center justify-between px-6 py-3 border-b",
          "bg-white text-gray-800 border-gray-200",
          "dark:bg-[#2B2D31] dark:text-[#E8EAED] dark:border-[#3F4147]",
        ].join(" ")}
      >
        {/* LEFT: Board name */}
        <div className="flex items-center gap-2">
          <h2 className="text-lg font-bold truncate dark:text-[#E8EAED]">
            {board?.boardName || "Bảng Trello của tôi"}
          </h2>
          <ChevronDown
            size={18}
            className="text-gray-600 dark:text-[#E8EAED] cursor-pointer"
          />
        </div>

        {/* RIGHT: Actions */}
        <div className="flex items-center gap-3">
          {/* Members */}
          {(boardMembers?.length ?? 0) > 0 && (
            <div className="flex -space-x-2">
              {activeMembers.slice(0, 4).map((member, index) => {
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
                const colorClass = avatarColors[index % avatarColors.length];
                return (
                  <div
                    key={member.userUId}
                    title={`${member.userName} (${member.role})`}
                    className={[
                      "w-8 h-8 rounded-full flex items-center justify-center shadow-md",
                      "text-white text-sm font-semibold",
                      colorClass,
                      "hover:scale-110 transition-transform",
                    ].join(" ")}
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
              {activeMembers.length > 4 && (
                <div className="w-8 h-8 bg-gray-700 text-white text-xs flex items-center justify-center font-semibold border-2 border-white rounded-full shadow-sm">
                  +{activeMembers.length - 4}
                </div>
              )}
            </div>
          )}

          {/* Filter button */}
          <button
            onClick={() => setShowFilter((v) => !v)}
            title="Filter cards"
            className={[
              "relative p-2 rounded-lg transition shadow-sm",
              showFilter || activeFiltersCount > 0
                ? "bg-blue-600 text-white"
                : "bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-[#3A3C42] dark:hover:bg-[#4A4C52] dark:text-[#E8EAED]",
            ].join(" ")}
          >
            <Filter size={18} />
            {activeFiltersCount > 0 && (
              <span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 text-white text-[10px] rounded-full flex items-center justify-center font-bold">
                {activeFiltersCount}
              </span>
            )}
          </button>

          <BoardHeaderBtn>
            <Star size={18} />
          </BoardHeaderBtn>

          <BoardHeaderBtn>
            <Users size={18} />
          </BoardHeaderBtn>

          <BoardHeaderBtn onClick={() => setEditing(true)} title="Board settings">
            <Settings size={18} />
          </BoardHeaderBtn>

          <button
            className={[
              "flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold",
              "bg-blue-600 text-white hover:bg-blue-700 shadow-md",
              "dark:bg-blue-500 dark:hover:bg-blue-600",
            ].join(" ")}
          >
            <Share2 size={16} />
            Share
          </button>
        </div>

        {editing && (
          <EditBoardModal
            open={editing}
            board={board}
            onClose={() => setEditing(false)}
            onSaved={handleSaved}
          />
        )}
      </div>

      {/* ── FILTER PANEL (slide down below header) ── */}
      {showFilter && (
        <div
          className={[
            "absolute top-full left-0 right-0 z-40",
            "bg-white dark:bg-[#2B2D31]",
            "border-b border-gray-200 dark:border-[#3F4147]",
            "px-6 py-4 shadow-lg",
            "animate-filterSlideDown",
          ].join(" ")}
        >
          <div className="flex flex-wrap gap-6 items-start">
            {/* Search by keyword */}
            <div className="flex-1 min-w-[200px]">
              <label className="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1 uppercase tracking-wide">
                Keyword
              </label>
              <div className="relative">
                <Search
                  size={14}
                  className="absolute left-2.5 top-1/2 -translate-y-1/2 text-gray-400"
                />
                <input
                  type="text"
                  value={filterText}
                  onChange={(e) => {
                    setFilterText(e.target.value);
                    applyFilter({ text: e.target.value });
                  }}
                  placeholder="Filter by card title..."
                  className="w-full pl-8 pr-3 py-1.5 border border-gray-300 dark:border-[#3F4147] rounded-lg text-sm bg-white dark:bg-[#1E1F22] dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            {/* Filter by member */}
            {activeMembers.length > 0 && (
              <div className="min-w-[160px]">
                <label className="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1 uppercase tracking-wide">
                  Member
                </label>
                <select
                  value={selectedMemberUId}
                  onChange={(e) => {
                    setSelectedMemberUId(e.target.value);
                    applyFilter({ memberUId: e.target.value });
                  }}
                  className="w-full px-2 py-1.5 border border-gray-300 dark:border-[#3F4147] rounded-lg text-sm bg-white dark:bg-[#1E1F22] dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">All members</option>
                  {activeMembers.map((m) => (
                    <option key={m.userUId} value={m.userUId}>
                      {m.userName}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Filter by due date */}
            <div className="min-w-[160px]">
              <label className="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1 uppercase tracking-wide">
                Due date
              </label>
              <select
                value={dueDateFilter}
                onChange={(e) => {
                  setDueDateFilter(e.target.value);
                  applyFilter({ dueDate: e.target.value });
                }}
                className="w-full px-2 py-1.5 border border-gray-300 dark:border-[#3F4147] rounded-lg text-sm bg-white dark:bg-[#1E1F22] dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Any time</option>
                <option value="overdue">Overdue</option>
                <option value="today">Due today</option>
                <option value="week">Due this week</option>
              </select>
            </div>

            {/* Filter by label color */}
            <div>
              <label className="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1 uppercase tracking-wide">
                Labels
              </label>
              <div className="flex flex-wrap gap-1.5">
                {LABEL_COLORS.map(({ color, name }) => (
                  <button
                    key={color}
                    title={name}
                    onClick={() => {
                      toggleLabel(color);
                      applyFilter({
                        labels: selectedLabels.includes(color)
                          ? selectedLabels.filter((c) => c !== color)
                          : [...selectedLabels, color],
                      });
                    }}
                    style={{ backgroundColor: color }}
                    className={[
                      "w-7 h-5 rounded-sm transition-all",
                      selectedLabels.includes(color)
                        ? "ring-2 ring-white ring-offset-1 scale-110"
                        : "opacity-80 hover:opacity-100 hover:scale-105",
                    ].join(" ")}
                  />
                ))}
              </div>
            </div>

            {/* Clear / Close */}
            <div className="flex items-end gap-2 ml-auto">
              {activeFiltersCount > 0 && (
                <button
                  onClick={clearFilter}
                  className="text-xs text-red-500 hover:text-red-700 font-medium flex items-center gap-1"
                >
                  <X size={12} /> Clear
                </button>
              )}
              <button
                onClick={() => setShowFilter(false)}
                className="text-xs text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

/* Small reusable button */
function BoardHeaderBtn({ children, onClick, title }) {
  return (
    <button
      onClick={onClick}
      title={title}
      className={[
        "p-2 rounded-lg transition shadow-sm",
        "bg-gray-100 hover:bg-gray-200 text-gray-700",
        "dark:bg-[#3A3C42] dark:hover:bg-[#4A4C52] dark:text-[#E8EAED]",
      ].join(" ")}
    >
      {children}
    </button>
  );
}

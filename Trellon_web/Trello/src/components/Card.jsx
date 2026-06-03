import React, { useState, useEffect } from "react";
import { createPortal } from "react-dom";
import "bootstrap-icons/font/bootstrap-icons.css";
import CardMenu from "./CardMenu";
import CardModal from "./CardModal";
import {
  deleteCardAPI,
  updateCardAPI,
  updateCardStatus,
} from "../services/todoApi";
import CardMemberPopup from "./CardMemberPopup";
import { getCardMembersAPI } from "../services/CardMemberAPI";
import "./css/Card.css";

export default function Card({
  card,
  boardMembers,
  board,
  provided,
  list,
  lists = [],
  snapshot,
  onRefresh,
}) {
  const [menuState, setMenuState] = useState({
    open: false,
    position: { top: 0, left: 0 },
  });
  const [showModal, setShowModal] = useState(false);
  const [memberPopup, setMemberPopup] = useState({
    open: false,
    position: { top: 0, left: 0 },
  });

  const [isCompleted, setIsCompleted] = useState(
    card.status?.toLowerCase() === "completed"
  );
  const [statusError, setStatusError] = useState(false);
  const [cardMembers, setCardMembers] = useState([]);
  const [isLoadingMembers, setIsLoadingMembers] = useState(false);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (
        !e.target.closest(".card-menu-floating") &&
        !e.target.closest(".card-member-popup")
      ) {
        setMenuState({ open: false, position: { top: 0, left: 0 } });
        setMemberPopup({ open: false, position: { top: 0, left: 0 } });
      }
    };

    document.addEventListener("click", handleClickOutside);
    return () => document.removeEventListener("click", handleClickOutside);
  }, []);
  // Load card members khi card thay đổi hoặc sau khi refresh
  useEffect(() => {
    const fetchCardMembers = async () => {
      setIsLoadingMembers(true);
      try {
        const res = await getCardMembersAPI(card.cardUId);
        setCardMembers(Array.isArray(res) ? res : []);
      } catch (err) {
        console.error("Không thể tải card members:", err);
        setCardMembers([]);
      } finally {
        setIsLoadingMembers(false);
      }
    };

    fetchCardMembers();
  }, [card.cardUId, card]); // Thêm card để reload khi có thay đổi

  // Cập nhật trạng thái completed khi card thay đổi
  useEffect(() => {
    setIsCompleted(card.status?.toLowerCase() === "completed");
    setStatusError(false);
  }, [card.status]);

  const handleCardMembersChange = async (members) => {
    console.log("Thành viên thẻ nhận từ popup:", members);
    setCardMembers(members);
    // Reload lại members sau khi thay đổi
    try {
      const res = await getCardMembersAPI(card.cardUId);
      setCardMembers(Array.isArray(res) ? res : []);
    } catch (err) {
      console.error("Không thể tải lại card members:", err);
    }
  };

  // Toggle trạng thái hoàn thành
  const handleToggleComplete = async () => {
    const next = !isCompleted;
    setIsCompleted(next); // optimistic update
    try {
      // API nhận giá trị: "todo" hoặc "completed" (lowercase)
      const newStatus = next ? "completed" : "todo";
      await updateCardStatus(card.cardUId, newStatus);
      onRefresh();
    } catch (err) {
      console.error("Lỗi khi cập nhật trạng thái card:", err);
      setIsCompleted(!next); // rollback on error
    }
  };

  // Xóa card
  const handleDelete = async () => {
    await deleteCardAPI(card.cardUId);
    onRefresh();
  };

  const handleManageMembers = (pos) => {
    if (!card.listUId) return;
    setMemberPopup({ open: true, position: pos });
  };

  // Mở menu
  const handleOpenMenu = (e) => {
    e.stopPropagation();
    const rect = e.currentTarget.getBoundingClientRect();
    setMenuState({
      open: true,
      position: {
        top: rect.bottom + window.scrollY,
        left: rect.left + window.scrollX,
      },
    });
  };

  const handleCloseMenu = () => {
    setMenuState({ open: false, position: { top: 0, left: 0 } });
    setMemberPopup({ open: false, position: { top: 0, left: 0 } });
  };

  const handleMoveCard = async (targetListUId) => {
    const user = JSON.parse(localStorage.getItem("user"));
    try {
      const { updateCardListAPI } = await import("../services/todoApi");
      await updateCardListAPI(card.cardUId, targetListUId, user?.userUId);
      onRefresh();
    } catch (err) {
      console.error("Move card error:", err);
    }
  };

  // Mở modal chi tiết
  const handleOpenCard = () => {
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
  };

  // Lưu chỉnh sửa trong modal
  const handleSaveModal = async (updatedCard) => {
    try {
      await updateCardAPI(updatedCard);
      setShowModal(false);
      onRefresh();
    } catch (err) {
      console.error("Lỗi khi cập nhật card:", err);
    }
  };

  // Tính trạng thái ngày hết hạn
  const getDueStatus = () => {
    if (!card.dueDate) return null;
    const now = new Date();
    const target = new Date(card.dueDate);
    if (target < now) return "overdue";
    const diff = target - now;
    if (diff < 1000 * 60 * 60 * 24) return "soon";
    return "normal";
  };
  const dueStatus = getDueStatus();

  // Màu theo trạng thái ngày đến hạn
  const dueColor =
    dueStatus === "overdue"
      ? "#F87171" // đỏ
      : dueStatus === "soon"
      ? "#FACC15" // vàng
      : "#86EFAC"; // xanh

  return (
  <>
    <div
      ref={provided.innerRef}
      {...provided.draggableProps}
      {...provided.dragHandleProps}
      className={`
        card-item transition-all duration-300 rounded-lg
        border border-gray-200 bg-white
        dark:bg-[#1E1F22] dark:border-[#2C2D30]
        px-3 py-2 shadow-sm
        hover:shadow-md cursor-pointer
        ${snapshot.isDragging ? "rotate-2 scale-[1.02] shadow-lg" : ""}
        ${isCompleted ? "opacity-80" : ""}
      `}
    >
      {/* ROW */}
      <div className="flex items-start gap-2">
        {/* COMPLETE BUTTON */}
        <button
          className="mt-0.5"
          onClick={handleToggleComplete}
        >
          {isCompleted ? (
            <i className="bi bi-check-circle-fill text-green-500 text-lg"></i>
          ) : (
            <i className="bi bi-circle text-gray-400 text-lg"></i>
          )}
        </button>

        {/* TITLE */}
        <div
          className={`
            flex-1 text-sm leading-snug
            ${isCompleted ? "line-through text-gray-500 dark:text-gray-400" : "text-gray-800 dark:text-gray-200"}
          `}
          onClick={handleOpenCard}
        >
          {card.title}
        </div>

        {/* EDIT BUTTON */}
        <button
          onClick={handleOpenMenu}
          className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
        >
          <i className="bi bi-pencil-square"></i>
        </button>

        {/* MENU */}
        {menuState.open &&
          createPortal(
            <>
              <div
                className="menu-overlay fixed inset-0"
                onClick={handleCloseMenu}
              ></div>
              <CardMenu
                position={menuState.position}
                onOpenCard={() => {
                  handleOpenCard();
                  handleCloseMenu();
                }}
                onEdit={() => {
                  handleOpenCard();
                  handleCloseMenu();
                }}
                onDelete={handleDelete}
                onManageMembers={handleManageMembers}
                onMoveCard={handleMoveCard}
                onClose={handleCloseMenu}
                listUId={card.listUId}
                lists={lists}
              />
            </>,
            document.body
          )}
      </div>

      {/* MEMBERS */}
      {!isLoadingMembers && cardMembers.length > 0 && (
        <div className="flex items-center gap-1 mt-2">
          {cardMembers.slice(0, 3).map((member, index) => {
            const colors = [
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
            const color = colors[index % colors.length];
            // Handle both flat { userName } and nested { user: { userName } } shapes
            const displayName = member.user?.userName || member.userName || "";
            const initials = displayName
              .split(" ")
              .map((n) => n[0])
              .join("")
              .toUpperCase()
              .slice(0, 2);

            return (
              <div
                key={member.userUId}
                className={`w-6 h-6 ${color} text-white text-[10px] flex items-center justify-center rounded-full font-bold`}
                title={displayName}
              >
                {initials || "?"}
              </div>
            );
          })}

          {cardMembers.length > 3 && (
            <div className="w-6 h-6 bg-gray-400 dark:bg-gray-600 text-white text-xs flex items-center justify-center rounded-full">
              +{cardMembers.length - 3}
            </div>
          )}
        </div>
      )}

      {/* DUE DATE */}
      {card.dueDate && (
        <div
          className={`
            flex items-center gap-1 mt-2 text-xs font-medium w-fit px-2 py-0.5 rounded-full
            ${isCompleted ? "bg-green-500 text-white" : ""}
          `}
          style={
            !isCompleted
              ? {
                  backgroundColor: dueColor,
                  color: "#1E293B",
                }
              : {}
          }
        >
          <i className="bi bi-clock me-1"></i>
          {new Date(card.dueDate).toLocaleDateString("vi-VN", {
            day: "numeric",
            month: "short",
          })}
        </div>
      )}
    </div>

    {/* MODAL */}
    {showModal &&
      createPortal(
        <CardModal
          card={card}
          cardMembers={cardMembers}
          onClose={handleCloseModal}
          onSave={handleSaveModal}
        />,
        document.body
      )}

    {/* MEMBERS POPUP */}
    {memberPopup.open &&
      createPortal(
        <CardMemberPopup
          card={card}
          requester={JSON.parse(localStorage.getItem("user"))}
          onClose={() =>
            setMemberPopup({ open: false, position: { top: 0, left: 0 } })
          }
          position={memberPopup.position}
          boardMembers={boardMembers}
          board={board}
          list={list}
          onChangeCard={handleCardMembersChange}
        />,
        document.body
      )}
  </>
);

}

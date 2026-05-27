import React, { useEffect, useState } from "react";
import { X } from "lucide-react";
import {
  getCardMembersAPI,
  removeCardMemberAPI,
  addCardMemberAPI,
} from "../services/CardMemberAPI";
import { addNotificationAPI } from "../services/NotificationAPI";

import { toast } from "react-toastify";

export default function CardMemberPopup({
  card,
  requester,
  onClose,
  // onChange,
  position, // vị trí popup (truyền từ Card.jsx)
  boardMembers,
  board,
  list,
  onChangeCard,
}) {
  const [cardMembers, setCardMembers] = useState([]);
  const [search, setSearch] = useState("");

  //  Load danh sách thành viên của thẻ và của bảng
  useEffect(() => {
    if (!card?.cardUId) return;

    const fetchCardMembers = async () => {
      try {
        const cardRes = await getCardMembersAPI(card.cardUId);
        setCardMembers(Array.isArray(cardRes) ? cardRes : []);
      } catch (err) {
        console.log(err);
        toast.error("Cannot load card members");
      }
    };

    fetchCardMembers();
  }, [card?.cardUId]);

  // Theo dõi khi boardMembers cập nhật
  useEffect(() => {
    if (boardMembers.length > 0)
      console.log("BoardMembers cập nhật:", boardMembers);
  }, [boardMembers]);

  // Thêm thành viên vào card
  const handleAddMember = async (userUId) => {
    console.log("addCard")
    try {
      await addCardMemberAPI(
        userUId,
        requester.userUId,
        board.boardUId,
        card.cardUId
      );
      toast.success("Member added to card!");
      const res = await getCardMembersAPI(card.cardUId);
      setCardMembers(Array.isArray(res) ? res : []);
      onChangeCard && onChangeCard(Array.isArray(res) ? res : []);
      // onChange && onChange();

      // Tạo notification cho thành viên được thêm vào card
      const notificationPayload = {
        recipientId: userUId,
        actorId: requester.userUId,
        type: 1, // Assignment
        title: "Card Assignment",
        message: `${requester.userName} assigned you to card '${card.title}' in board '${board.boardName}'.`,
        link: `/boards/${board.boardUId}`,
        workspaceId: board.workspaceUId || null,
        boardId: board.boardUId,
        listId: list?.listUId || null,
        cardId: card.cardUId,
      };

      console.log("Sending card assignment notification:", notificationPayload);
      await addNotificationAPI(notificationPayload);
    } catch (err) {
      toast.error("Can't add member :(");
      console.error(err);
    }
  };

  //  Xóa thành viên khỏi card
  const handleRemoveMember = async (userUId) => {
    try {
      await removeCardMemberAPI(
        userUId,
        requester.userUId,
        board.boardUId,
        card.cardUId
      );
      toast.info("Member removed from card.");
      const res = await getCardMembersAPI(card.cardUId);
      setCardMembers(Array.isArray(res) ? res : []);
      onChangeCard && onChangeCard(Array.isArray(res) ? res : []);
      // onChange && onChange();
    } catch (err) {
      toast.error("Can't remove member");
      console.error(err);
    }
  };

  //  Lọc thành viên trong bảng (chưa có trong card)
  const filteredBoardMembers = boardMembers.filter((bm) => {
    const name = bm.userName || bm.user?.userName || "";
    return (
      !cardMembers.some((cm) => cm.userUId === bm.userUId) &&
      name.toLowerCase().includes(search.toLowerCase())
    );
  });

  console.log("cardMembers", cardMembers);

  return (
    <div
      className="
        absolute z-[9999] bg-white rounded-lg shadow-xl border border-gray-200 w-72 card-member-popup
        dark:bg-[#2A2D31] dark:border-[#3A3D41]
      "
      style={{ top: position?.top, left: position?.left }}
      onClick={(e) => e.stopPropagation()}
    >
      {/* Header */}
      <div className="
        flex justify-between items-center border-b border-gray-100 px-3 py-2
        dark:border-[#2A2D31]
      ">
        <h2 className="text-sm font-semibold text-gray-800 dark:text-[#E8EAED]">
          CHANGE CARD MEMBERS
        </h2>
        <button
          onClick={onClose}
          className="p-2 hover:bg-gray-100 rounded-2 transition dark:hover:bg-[#2A2D31]"
        >
          <X size={16} className="dark:text-white dark:hover:bg-[#3A3D41]" />
        </button>
      </div>

      {/* Search */}
      <div className="p-3 border-b border-gray-100 dark:border-[#2A2D31]">
        <input
          type="text"
          placeholder="Member searching"
          className="
            w-full border border-gray-300 rounded-md px-2 py-1 text-sm 
            focus:ring-1 focus:ring-blue-500 outline-none
            dark:bg-[#2A2D31] dark:border-[#3A3D41] dark:text-[#E8EAED]
            dark:placeholder:text-white/40
          "
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
      </div>

      {/* Thành viên của thẻ */}
      <div className="p-3 border-b border-gray-100 dark:border-[#2A2D31]">
        <h3 className="text-xs font-semibold text-gray-600 mb-2 dark:text-gray-300">
          Card's members
        </h3>
        <div className="space-y-1 max-h-36 overflow-y-auto">
          {cardMembers.length > 0 ? (
            cardMembers.map((m) => {
              const name = m.user?.userName || m.userName || "";
              const initials = name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
              return (
              <div
                key={m.userUId}
                className="
                  flex items-center justify-between p-1.5 rounded-md 
                  hover:bg-gray-50 dark:hover:bg-[#2A2D31]
                "
              >
                <div className="flex items-center gap-2">
                  <div className="w-7 h-7 rounded-full bg-blue-600 text-white text-xs flex items-center justify-center font-semibold">
                    {initials || "?"}
                  </div>
                  <span className="text-gray-800 text-sm dark:text-[#E8EAED]">
                    {name}
                  </span>
                </div>
                <button
                  onClick={() => handleRemoveMember(m.userUId)}
                  className="text-red-500 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 text-xs font-medium"
                >
                  ✕
                </button>
              </div>
              );
            })
          ) : (
            <p className="text-gray-500 text-xs italic dark:text-gray-400">
              This card has no member
            </p>
          )}
        </div>
      </div>

      {/* Thành viên của bảng */}
      <div className="p-3">
        <h3 className="text-xs font-semibold text-gray-600 mb-2 dark:text-gray-300">
          Board's members
        </h3>
        <div className="space-y-1 max-h-40 overflow-y-auto">
          {filteredBoardMembers.length > 0 ? (
            filteredBoardMembers.map((m) => (
              <div
                key={m.userUId}
                className="
                  flex items-center justify-between p-1.5 rounded-md 
                  hover:bg-blue-50 cursor-pointer
                  dark:hover:bg-[#2A2D31]
                "
                onClick={(e) => {
                  e.stopPropagation();
                  handleAddMember(m.userUId);
                }}
              >
                <div className="flex items-center gap-2">
                  <div className="w-7 h-7 rounded-full bg-gray-300 text-gray-700 dark:bg-[#3A3D41] dark:text-gray-200 text-xs flex items-center justify-center font-semibold">
                    {(m.userName || m.user?.userName)
                      ?.split(" ")
                      .map((n) => n[0])
                      .join("")
                      .toUpperCase()
                      .slice(0, 2)}
                  </div>
                  <span className="text-gray-800 text-sm dark:text-[#E8EAED]">
                    {m.userName || m.user?.userName}
                  </span>
                </div>
                <span className="text-blue-600 text-xs font-medium dark:text-blue-400">
                  Add
                </span>
              </div>
            ))
          ) : (
            <p className="text-gray-500 text-xs italic dark:text-gray-400">
              No member found
            </p>
          )}
        </div>
      </div>
    </div>
);

}

import React, { useState } from "react";
import Split from "react-split";
import { DragDropContext } from "@hello-pangea/dnd";
import Inbox from "./inbox-component";
import Board from "./Board";
import {
  Inbox as InboxIcon,
  LayoutGrid,
  Info,
  ChevronUp,
  ChevronDown,
} from "lucide-react";
import "./css/layout.css";
import { updateCardListAPI } from "../services/todoApi";
import { reorderListsAPI } from "../services/ListAPI";

export default function Layout() {
  const [showInbox, setShowInbox] = useState(true);
  const [isAnimating, setIsAnimating] = useState(false);
  const [activeTab, setActiveTab] = useState("inbox");
  const [refresh, setRefresh] = useState(false);
  const [lists, setLists] = useState([]);
  
  const user = JSON.parse(localStorage.getItem("user"));
  
  const handleDragEnd = async (result) => {
    const { source, destination, draggableId, type } = result;
    if (!destination) return;

    if (
      source.droppableId === destination.droppableId &&
      source.index === destination.index
    )
      return;

    //  XỬ LÝ KÉO THẢ LIST
    if (type === "LIST") {
      const reorderedLists = Array.from(lists);
      const [movedList] = reorderedLists.splice(source.index, 1);
      reorderedLists.splice(destination.index, 0, movedList);

      const updatedLists = reorderedLists.map((list, index) => ({
        ...list,
        Position: index,
      }));

      // Cập nhật UI ngay lập tức
      setLists(updatedLists);

      // Gọi API để lưu thứ tự mới
      try {
        const board = JSON.parse(localStorage.getItem("currentBoard"));
        if (!board) return;

        await reorderListsAPI(
          board.boardUId,
          updatedLists.map((list) => ({
            ListUId: list.listUId,
            Position: list.Position,
          }))
        );
        console.log(" Lists reordered successfully");
      } catch (err) {
        console.error(" Error reordering lists:", err);
        // Nếu lỗi, reload lại data
        setRefresh((r) => !r);
      }
      return;
    }

    //  XỬ LÝ KÉO THẢ CARD
    try {
      let newListUId = null;

      if (
        source.droppableId === "inbox" &&
        destination.droppableId.startsWith("list-")
      ) {
        newListUId = destination.droppableId.replace("list-", "");
      } else if (
        source.droppableId.startsWith("list-") &&
        destination.droppableId.startsWith("list-")
      ) {
        newListUId = destination.droppableId.replace("list-", "");
      } else if (
        source.droppableId.startsWith("list-") &&
        destination.droppableId === "inbox"
      ) {
        newListUId = null; // Trả về inbox
      }
      
      console.log("Update card:", draggableId, "→ List:", newListUId);
      await updateCardListAPI(draggableId, newListUId, user.userUId);
      setRefresh((r) => !r);
    } catch (err) {
      console.error("Lỗi khi cập nhật list cho card:", err);
    }
  };

  // 🔹 Toggle Inbox hiển thị
  const toggleInbox = () => {
    if (showInbox) {
      setIsAnimating(true);
      setTimeout(() => {
        setShowInbox(false);
        setIsAnimating(false);
      }, 350);
    } else {
      setShowInbox(true);
      setIsAnimating(true);
      setTimeout(() => setIsAnimating(false), 350);
    }
  };

  return (
  <DragDropContext onDragEnd={handleDragEnd}>
    <div className="fixed top-[64px] left-0 right-0 bottom-0 w-full overflow-hidden bg-gray-50 dark:bg-[#1E1F22]">

      <div className="h-full w-full">
        {showInbox ? (
          <Split
            className="flex h-full"
            sizes={[25, 75]}
            minSize={[0, 380]}
            gutterSize={8}
            onDragEnd={(newSizes) => {
              if (newSizes[0] <= 10) {
                setIsAnimating(true);
                setTimeout(() => {
                  setShowInbox(false);
                  setIsAnimating(false);
                }, 400);
              }
            }}
          >
            {/* INBOX PANEL */}
            <div
              className={`
                h-full overflow-y-auto rounded-tr-xl 
                bg-white dark:bg-[#1E1F22] 
                border-r border-gray-200 dark:border-[#2C2D30]
                transition-all 
                ${isAnimating ? "animate-slideOutLeft" : "animate-slideInLeft"}
              `}
            >
              <Inbox refresh={refresh} setRefresh={setRefresh} />
            </div>

            {/* BOARD PANEL */}
            <div
              className="
                flex-1 overflow-y-auto rounded-tl-xl 
                bg-gray-100 dark:bg-[#1E1F22]
              "
            >
              <Board
                refresh={refresh}
                setRefresh={setRefresh}
                lists={lists}
                setLists={setLists}
              />
            </div>
          </Split>
        ) : (
          /* KHI ẨN INBOX: BOARD FULL */
          <div className="h-full w-full overflow-y-auto rounded-tl-xl bg-gray-100 dark:bg-[#1E1F22]">
            <Board
              refresh={refresh}
              setRefresh={setRefresh}
              lists={lists}
              setLists={setLists}
            />
          </div>
        )}

        {/* === BOTTOM TOOLBAR (giống Notification UI) === */}
        <div
          className="
            absolute bottom-0 left-0 w-full border-t
            bg-white/80 dark:bg-[#1E1F22]/80 
            backdrop-blur-lg
            border-gray-200 dark:border-[#2C2D30]
            flex items-center justify-center
          "
        >
          <div className="flex items-center gap-3 px-4 py-2 text-sm">

            {/* TAB: Inbox */}
            <button
              onClick={() => {
                toggleInbox();
                setActiveTab("inbox");
              }}
              className={`
                flex items-center gap-1 px-3 py-2 rounded-lg transition
                ${
                  activeTab === "inbox"
                    ? "bg-blue-600 text-white shadow-sm"
                    : "text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-[#2A2B2E]"
                }
              `}
            >
              <InboxIcon size={16} />
              <span>Inbox</span>
              {showInbox ? (
                <ChevronDown size={14} className="ml-1" />
              ) : (
                <ChevronUp size={14} className="ml-1" />
              )}
            </button>

            {/* TAB: Planner */}
            <button
              onClick={() => setActiveTab("plan")}
              className={`
                flex items-center gap-1 px-3 py-2 rounded-lg transition
                ${
                  activeTab === "plan"
                    ? "bg-blue-600 text-white shadow-sm"
                    : "text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-[#2A2B2E]"
                }
              `}
            >
              <LayoutGrid size={16} />
              <span>Project Planner</span>
            </button>

            {/* TAB: Info */}
            <button
              onClick={() => setActiveTab("info")}
              className={`
                flex items-center gap-1 px-3 py-2 rounded-lg transition
                ${
                  activeTab === "info"
                    ? "bg-blue-600 text-white shadow-sm"
                    : "text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-[#2A2B2E]"
                }
              `}
            >
              <Info size={16} />
              <span>Information Board</span>
            </button>

          </div>
        </div>
      </div>
    </div>
  </DragDropContext>
);

}
import React, { useEffect, useState } from "react";
import { Droppable, Draggable } from "@hello-pangea/dnd";
import { Plus, Trash2, GripVertical } from "lucide-react";
import "bootstrap-icons/font/bootstrap-icons.css";
import PortalAwareDraggable from "./PortalAwareDraggable";
import Card from "./Card";
import BoardHeader from "./BoardHeader";
import { useNavigate } from "react-router-dom";
import {
  getListsByBoardIdAPI,
  createListAPI,
  updateListStatusAPI,
} from "../services/ListAPI";
import { getCardsAPI } from "../services/todoApi";
import { getBoardMembersAPI } from "../services/BoardMemberAPI";
import { addCardAPI } from "../services/todoApi";

import "./css/Board.css";

export default function Board({ refresh, setRefresh, lists, setLists }) {
  const [cards, setCards] = useState([]);
  const [board, setBoard] = useState(null);
  const [newListName, setNewListName] = useState("");
  const [loading, setLoading] = useState(false);
  const [boardMembers, setBoardMembers] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const stored = localStorage.getItem("currentBoard");
    if (stored) {
      const b = JSON.parse(stored);
      setBoard(b);
      loadData(b.boardUId);
    }
  }, [refresh]);

  const loadData = async (boardId) => {
    setLoading(true);
    try {
      const [listsData, cardsData, membersData] = await Promise.all([
        getListsByBoardIdAPI(boardId),
        getCardsAPI(boardId),
        getBoardMembersAPI(boardId),
      ]);

      setLists(Array.isArray(listsData) ? listsData : []);
      setCards(Array.isArray(cardsData) ? cardsData : []);
      setBoardMembers(Array.isArray(membersData) ? membersData : []);

      console.log(" Data loaded:", {
        lists: listsData?.length || 0,
        cards: cardsData?.length || 0,
        members: membersData?.length || 0,
      });
    } catch (err) {
      console.error("❌ Error loading data:", err);
      setLists([]);
      setCards([]);
      setBoardMembers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleBoardUpdated = (nextBoard) => {
    if (nextBoard?.type === "delete") {
      try {
        localStorage.removeItem("currentBoard");
      } catch (err) {
        console.log(err);
      }
      navigate(`/home/${userUId}`);
      return;
    }
    if (nextBoard) {
      setBoard(nextBoard);
      try {
        localStorage.setItem("currentBoard", JSON.stringify(nextBoard));
      } catch (err) {
        console.log(err);
      }
      setRefresh && setRefresh((r) => !r);
    }
  };

  const handleAddList = async () => {
    if (!newListName.trim()) return;
    try {
      const newList = await createListAPI({
        ListName: newListName,
        BoardUId: board.boardUId,
        Status: "Active",
        Position: lists.length,
      });

      if (newList) {
        setLists([...lists, newList]);
        setNewListName("");
      }
    } catch (err) {
      console.error("Error adding list:", err);
    }
  };

  const handleDeleteList = async (id) => {
    try {
      await updateListStatusAPI(id, "Storage");
      if (board) {
        loadData(board.boardUId);
      }
    } catch (err) {
      console.error("Error deleting list:", err);
    }
  };

  const handleAddCard = async (listId, cardTitle) => {
    if (!cardTitle.trim()) return;
    const user = JSON.parse(localStorage.getItem("user"));
    try {
      const newCard = await addCardAPI({
        title: cardTitle,
        listUId: listId,
        status: "todo",
        position: 0,
        userUId: user?.userUId || "",
      });
      if (newCard) setCards((prev) => [...prev, newCard]);
    } catch (err) {
      console.error("Error adding card:", err);
    }
  };

  return (
  <div
    className="flex flex-col h-full dark:bg-gradient-to-br dark:from-[#1E1F22] dark:to-[#2A2B2E]"
    style={board?.backgroundUrl
      ? board.backgroundUrl.startsWith("linear-gradient") || board.backgroundUrl.startsWith("#")
        ? { background: board.backgroundUrl }
        : { backgroundImage: `url(${board.backgroundUrl})`, backgroundSize: "cover", backgroundPosition: "center" }
      : { background: "linear-gradient(135deg,#46237A,#7A1E6E)" }
    }
  >
    <BoardHeader
      board={board}
      boardMembers={boardMembers}
      onBoardUpdated={handleBoardUpdated}
      onFilterChange={(f) => {
        // future: apply filter to cards
      }}
    />

    <Droppable droppableId="all-lists" direction="horizontal" type="LIST">
      {(provided) => (
        <div
          ref={provided.innerRef}
          {...provided.droppableProps}
          className="flex gap-4 p-4 flex-1 overflow-x-auto"
        >
          {Array.isArray(lists) &&
            lists.map((list, index) => (
              <Draggable
                key={list.listUId}
                draggableId={list.listUId}
                index={index}
              >
                {(listProvided, listSnapshot) => (
                  <div
                    ref={listProvided.innerRef}
                    {...listProvided.draggableProps}
                    className={`${
                      listSnapshot.isDragging ? "opacity-50 rotate-2" : ""
                    }`}
                  >
                    <Droppable droppableId={`list-${list.listUId}`} type="CARD">
                      {(cardProvided, cardSnapshot) => (
                        <div
                          ref={cardProvided.innerRef}
                          {...cardProvided.droppableProps}
                          className={`
                            board-list
                            ${cardSnapshot.isDraggingOver ? "dragging-over" : ""}
                            dark:bg-[#2B2D31]
                            dark:border dark:border-[#3A3C40]
                            dark:shadow-[0_0_8px_rgba(0,0,0,0.25)]
                            dark:text-gray-200
                          `}
                        >
                          {/* LIST HEADER */}
                          <div
                            className="
                              list-header
                              dark:bg-[#2B2D31]
                              dark:text-gray-200
                            "
                          >
                            <div className="flex items-center gap-2 flex-1">
                              <div
                                {...listProvided.dragHandleProps}
                                className="
                                  cursor-grab active:cursor-grabbing p-1 
                                  hover:bg-white/10 
                                  dark:hover:bg-[#3A3C40]
                                  rounded transition-colors
                                "
                              >
                                <GripVertical
                                  size={18}
                                  className="
                                    text-white/70 hover:text-white
                                    dark:text-gray-300 dark:hover:text-white
                                  "
                                />
                              </div>
                              <h4 className="list-title dark:text-gray-200">
                                {list.listName}
                              </h4>
                            </div>

                            <button
                              className="
                                list-delete-btn
                                dark:text-gray-300 
                                dark:hover:text-red-400
                              "
                              onClick={() => handleDeleteList(list.listUId)}
                            >
                              <Trash2 size={16} />
                            </button>
                          </div>

                          {/* LIST CARDS */}
                          <div className="list-cards">
                            {loading ? (
                              <div className="text-white/50 text-sm p-2 dark:text-gray-400">
                                Loading...
                              </div>
                            ) : (
                              cards
                                .filter((c) => c.listUId === list.listUId)
                                .map((card, cardIndex) => (
                                  <PortalAwareDraggable
                                    key={card.cardUId}
                                    draggableId={card.cardUId}
                                    index={cardIndex}
                                  >
                                    {(cardDragProvided, cardDragSnapshot) => (
                                      <Card
                                        card={card}
                                        boardMembers={boardMembers}
                                        board={board}
                                        list={list}
                                        lists={lists}
                                        provided={cardDragProvided}
                                        snapshot={cardDragSnapshot}
                                        onRefresh={() =>
                                          setRefresh((r) => !r)
                                        }
                                      />
                                    )}
                                  </PortalAwareDraggable>
                                ))
                            )}
                            {cardProvided.placeholder}
                          </div>

                          {/* ADD CARD SECTION */}
                          <AddCardSection
                            listId={list.listUId}
                            onAdd={handleAddCard}
                          />
                        </div>
                      )}
                    </Droppable>
                  </div>
                )}
              </Draggable>
            ))}

          {provided.placeholder}

          {/* ADD LIST BOX */}
          <div
            className="
              add-list-box
              dark:bg-[#26272A]
              dark:border dark:border-[#26272A]
            "
          >
            <input
              type="text"
              value={newListName}
              onChange={(e) => setNewListName(e.target.value)}
              placeholder="List name..."
              className="
                add-list-input
                dark:bg-[#3A3C40]
                dark:text-gray-200
                dark:border dark:border-[#4A4B4F]
                dark:placeholder:text-gray-400
              "
              onKeyDown={(e) => {
                if (e.key === "Enter") handleAddList();
              }}
            />
            <button
              onClick={handleAddList}
              className="
                add-list-btn
                dark:bg-blue-500 dark:hover:bg-blue-600 
                dark:text-white
              "
            >
              <Plus size={18} /> Add list
            </button>
          </div>
        </div>
      )}
    </Droppable>
  </div>
);


}

function AddCardSection({ listId, onAdd }) {
  const [adding, setAdding] = useState(false);
  const [title, setTitle] = useState("");

  const handleSubmit = () => {
    if (!title.trim()) return;
    onAdd(listId, title);
    setTitle("");
    setAdding(false);
  };

  return (
    <div className="px-2 pb-3 mt-2">
      {!adding ? (
        <button
          className="
            flex items-center gap-2 
            text-white/80 hover:text-white 
            text-sm px-2 py-1 rounded-md 
            hover:bg-white/10 transition
          "
          onClick={() => setAdding(true)}
        >
          <Plus size={15} /> Add a card
        </button>
      ) : (
        <div className="p-2 rounded-md bg-white/10 backdrop-blur-sm">
          <textarea
            className="
              w-full rounded-md px-2 py-1 text-sm 
              text-white
              bg-white/10 border border-white/20
              placeholder:text-white/60
              focus:outline-none focus:ring-2 focus:ring-white/40
            "
            rows={2}
            placeholder="Enter card title…"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSubmit()}
          />

          <div className="flex gap-2 mt-2">
            <button
              onClick={handleSubmit}
              className="
                px-3 py-1 rounded-md text-sm
                bg-blue-600 hover:bg-blue-700 text-white
              "
            >
              Add card
            </button>

            <button
              onClick={() => {
                setAdding(false);
                setTitle("");
              }}
              className="text-white/70 hover:text-white text-sm"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
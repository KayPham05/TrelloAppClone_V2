import React, { useState, useEffect, useRef } from "react";
import {
  X, CreditCard, AlignLeft, User, CheckSquare,
  Clock, Tag, ArrowRight, Paperclip, Upload, Trash2, ExternalLink,
} from "lucide-react";
import { getCommentsAPI, addCommentAPI, deleteCommentAPI } from "../services/CommentAPI";
import { getTodoItemsAPI, addTodoItemAPI, deleteTodoItemAPI, updateStatusTodoItemAPI } from "../services/AddTodoItem";
import { updateCardAPI, updateCardListAPI } from "../services/todoApi";
import { getCardMembersAPI } from "../services/CardMemberAPI";
import { getAllWorkspacesAPI, getWorkspaceBoardsAPI } from "../services/WorkspaceAPI";
import { getListsByBoardIdAPI } from "../services/ListAPI";
import { getAttachmentsAPI, uploadAttachmentAPI, deleteAttachmentAPI } from "../services/AttachmentAPI";
import LabelPickerPopup from "./LabelPickerPopup";
import "./css/CardModal.css";
import "./css/CardModalDark.css";

/** Chuẩn hóa mảng nhãn từ API về dạng object { cardLabelUId, title, colorCode } */
function normalizeLabels(raw) {
  if (!Array.isArray(raw)) return [];
  return raw.map((l) => {
    if (typeof l === "string") return { cardLabelUId: l, title: "", colorCode: l };
    return {
      cardLabelUId: l.cardLabelUId || l.id || "",
      title: l.title ?? l.name ?? "",
      colorCode: l.colorCode ?? l.color ?? l.hex ?? "",
    };
  });
}

function getInitials(name) {
  if (!name) return "?";
  return name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
}

const AVATAR_COLORS = [
  "bg-blue-700","bg-yellow-600","bg-orange-600","bg-emerald-600",
  "bg-green-600","bg-violet-600","bg-rose-600","bg-teal-600","bg-indigo-600",
];

export default function CardModal({ card, onClose, onSave }) {
  const [title, setTitle] = useState(card.title || "");
  const [description, setDescription] = useState(card.description || "");
  const [dueDate, setDueDate] = useState(card.dueDate || "");
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState("");
  const [isEditingDesc, setIsEditingDesc] = useState(false);
  const [todoItems, setTodoItems] = useState([]);
  const [newTodo, setNewTodo] = useState("");
  const [cardMembers, setCardMembers] = useState([]);
  const [isLoadingMembers, setIsLoadingMembers] = useState(false);

  // Labels – mảng { cardLabelUId, title, colorCode }
  const [labels, setLabels] = useState(() =>
    normalizeLabels(card.labels ?? card.cardLabels ?? [])
  );
  const [showLabelPicker, setShowLabelPicker] = useState(false);

  // Attachments
  const [attachments, setAttachments] = useState([]);
  const [uploading, setUploading] = useState(false);
  const attachInputRef = useRef(null);

  // Move card
  const [showMovePicker, setShowMovePicker] = useState(false);
  const [workspaces, setWorkspaces] = useState([]);
  const [moveBoards, setMoveBoards] = useState([]);
  const [moveLists, setMoveLists] = useState([]);
  const [selWsId, setSelWsId] = useState("");
  const [selBoardId, setSelBoardId] = useState("");
  const [selListId, setSelListId] = useState("");
  const [moving, setMoving] = useState(false);

  const storedUser = JSON.parse(localStorage.getItem("user"));

  useEffect(() => {
    if (card?.cardUId) {
      fetchComments(card.cardUId);
      fetchTodos(card.cardUId);
      fetchCardMembers(card.cardUId);
      fetchAttachments(card.cardUId);
    }
  }, [card]);

  useEffect(() => {
    if (!showMovePicker || workspaces.length > 0) return;
    getAllWorkspacesAPI(storedUser?.userUId)
      .then((d) => setWorkspaces(Array.isArray(d) ? d : []))
      .catch(() => {});
  }, [showMovePicker]);

  useEffect(() => {
    if (!selWsId) { setMoveBoards([]); setMoveLists([]); return; }
    getWorkspaceBoardsAPI(selWsId, storedUser?.userUId)
      .then((d) => setMoveBoards(Array.isArray(d) ? d : []))
      .catch(() => setMoveBoards([]));
  }, [selWsId]);

  useEffect(() => {
    if (!selBoardId) { setMoveLists([]); return; }
    getListsByBoardIdAPI(selBoardId)
      .then((d) => setMoveLists(Array.isArray(d) ? d : []))
      .catch(() => setMoveLists([]));
  }, [selBoardId]);

  const fetchCardMembers = async (id) => {
    setIsLoadingMembers(true);
    try { setCardMembers(Array.isArray(await getCardMembersAPI(id)) ? await getCardMembersAPI(id) : []); }
    catch { setCardMembers([]); }
    finally { setIsLoadingMembers(false); }
  };

  const fetchComments = async (id) => {
    try { const d = await getCommentsAPI(id); setComments(Array.isArray(d) ? d : []); } catch {}
  };

  const fetchAttachments = async (id) => {
    try { const d = await getAttachmentsAPI(id); setAttachments(Array.isArray(d) ? d : []); } catch {}
  };

  const handleAddComment = async () => {
    if (!newComment.trim()) return;
    try {
      const added = await addCommentAPI({ content: newComment, cardUId: card.cardUId, userUId: storedUser.userUId });
      setComments((p) => [added, ...p]);
      setNewComment("");
    } catch {}
  };

  const handleDeleteComment = async (id) => {
    try { await deleteCommentAPI(id); setComments((p) => p.filter((c) => c.commentUId !== id)); } catch {}
  };

  const fetchTodos = async (id) => {
    try { const d = await getTodoItemsAPI(id); setTodoItems(Array.isArray(d) ? d : []); } catch {}
  };

  const handleAddTodo = async () => {
    if (!newTodo.trim()) return;
    try { await addTodoItemAPI(card.cardUId, newTodo); setNewTodo(""); fetchTodos(card.cardUId); } catch {}
  };

  const handleToggleTodo = async (item) => {
    try {
      await updateStatusTodoItemAPI(item.todoItemUId, item.isCompleted ? "incomplete" : "completed");
      fetchTodos(card.cardUId);
    } catch {}
  };

  const handleDeleteTodo = async (id) => {
    try { await deleteTodoItemAPI(id); fetchTodos(card.cardUId); } catch {}
  };

  const handleAttachFile = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    try {
      setUploading(true);
      await uploadAttachmentAPI(card.cardUId, storedUser?.userUId, file);
      fetchAttachments(card.cardUId);
    } catch {}
    finally { setUploading(false); e.target.value = ""; }
  };

  const handleDeleteAttachment = async (uid) => {
    try {
      await deleteAttachmentAPI(uid, storedUser?.userUId);
      setAttachments((p) => p.filter((a) => a.attachmentUId !== uid));
    } catch {}
  };

  const getDueStatus = () => {
    if (!dueDate) return null;
    const diff = new Date(dueDate) - new Date();
    if (diff < 0) return "overdue";
    if (diff < 86400000) return "soon";
    return "normal";
  };
  const dueStatus = getDueStatus();

  const handleSave = async () => {
    try {
      const updated = { ...card, title, description, dueDate };
      await updateCardAPI(updated);
      onSave({ ...updated, labels, cardLabels: labels });
    } catch {}
  };

  const handleMoveCard = async () => {
    if (!selListId) return;
    try {
      setMoving(true);
      await updateCardListAPI(card.cardUId, selListId, storedUser?.userUId);
      onSave({ ...card, listUId: selListId });
      onClose();
    } catch { setMoving(false); }
  };

  return (
    <div className="modal-overlay-new" onClick={onClose}>
      <div className="cardmodal-wrapper" onClick={(e) => e.stopPropagation()}>

        {/* HEADER */}
        <div className="cardmodal-header">
          <div className="header-left">
            <CreditCard size={24} className="header-icon" />
            <div style={{ flex: 1 }}>
              <textarea className="header-title" value={title} onChange={(e) => setTitle(e.target.value)} rows={1} />
              <p className="header-subtitle">In list <span>{card.listName || "Inbox"}</span></p>
            </div>
          </div>
          <button className="close-btn" onClick={onClose}><X size={20} /></button>
        </div>

        {/* LABELS ROW */}
        <div className="px-4 pb-2 flex flex-wrap items-center gap-2">
          {labels.map(({ cardLabelUId, title: lt, colorCode }) => (
            <span
              key={cardLabelUId}
              className="inline-flex items-center h-6 px-3 rounded-full text-white text-xs font-semibold cursor-pointer hover:opacity-80 transition"
              style={{ backgroundColor: colorCode || "#888" }}
              onClick={() => setShowLabelPicker(true)}
              title={lt}
            >
              {lt}
            </span>
          ))}
          <button
            onClick={() => setShowLabelPicker(true)}
            className="flex items-center gap-1 text-xs text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 border border-gray-300 dark:border-zinc-600 px-2 py-0.5 rounded-full transition"
          >
            <Tag size={12} />
            {labels.length > 0 ? "Sửa nhãn" : "Thêm nhãn"}
          </button>
        </div>

        {/* LABEL PICKER POPUP */}
        {showLabelPicker && (
          <LabelPickerPopup
            card={card}
            initialLabels={labels}
            onClose={() => setShowLabelPicker(false)}
            onLabelsChange={(updated) => setLabels(updated)}
          />
        )}

        {/* CARD MEMBERS */}
        {!isLoadingMembers && cardMembers.length > 0 && (
          <div className="flex items-center gap-2 px-4 py-2">
            <User size={16} className="text-gray-500" />
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300">Thành viên:</span>
            {cardMembers.map((m, i) => {
              const name = m.user?.userName || m.userName || "";
              return (
                <div
                  key={m.userUId}
                  className={`w-8 h-8 ${AVATAR_COLORS[i % AVATAR_COLORS.length]} text-white text-xs flex items-center justify-center rounded-full font-semibold cursor-pointer hover:scale-110 transition-transform`}
                  title={name}
                >
                  {getInitials(name)}
                </div>
              );
            })}
          </div>
        )}

        {/* DUE DATE */}
        <div className="due-section">
          <div className="due-label"><Clock size={16} /><span>Ngày hết hạn:</span></div>
          <div className="due-content">
            <input
              type="datetime-local"
              value={dueDate ? new Date(dueDate).toISOString().slice(0, 16) : ""}
              onChange={(e) => setDueDate(e.target.value)}
              className="due-input"
            />
            {dueDate && (
              <span className={`due-status ${dueStatus}`}>
                {dueStatus === "overdue" ? "Quá hạn" : dueStatus === "soon" ? "Sắp hết hạn" : "Đúng hạn"}
              </span>
            )}
          </div>
        </div>

        {/* BODY */}
        <div className="cardmodal-body">
          <div className="cardmodal-left">

            {/* DESCRIPTION */}
            <div className="modal-section">
              <div className="section-header"><AlignLeft size={20} /><h3>Mô tả</h3></div>
              {!isEditingDesc ? (
                <div className="description-display" onClick={() => setIsEditingDesc(true)}>
                  {description || "Thêm mô tả chi tiết hơn..."}
                </div>
              ) : (
                <div className="description-edit">
                  <textarea className="description-textarea" value={description} onChange={(e) => setDescription(e.target.value)} autoFocus />
                  <div className="description-actions">
                    <button className="btn-primary" onClick={() => setIsEditingDesc(false)}>Lưu</button>
                    <button
                      className="btn-secondary text-gray-700 bg-gray-200 hover:bg-gray-300 dark:text-gray-300 dark:bg-[#2B2D31] dark:hover:bg-[#3A3C40] px-3 py-1.5 rounded-lg transition"
                      onClick={() => { setIsEditingDesc(false); setDescription(card.description || ""); }}
                    >Huỷ</button>
                  </div>
                </div>
              )}
            </div>

            {/* CHECKLIST */}
            <div className="modal-section">
              <div className="section-header">
                <CheckSquare size={20} /><h3>Việc cần làm</h3>
                {todoItems.length > 0 && (
                  <div className="section-actions">
                    <button className="btn-secondary btn-sm" onClick={() => setTodoItems(todoItems.filter((t) => !t.isCompleted))}>Ẩn đã xong</button>
                    <button className="btn-secondary btn-sm" onClick={() => { if (window.confirm("Xóa tất cả?")) todoItems.forEach((t) => handleDeleteTodo(t.todoItemUId)); }}>Xóa tất cả</button>
                  </div>
                )}
              </div>
              {todoItems.length > 0 && (
                <div className="progress-wrapper">
                  <span className="progress-text">{Math.round((todoItems.filter((t) => t.isCompleted).length / todoItems.length) * 100)}%</span>
                  <div className="progress-bar"><div className="progress-fill" style={{ width: `${(todoItems.filter((t) => t.isCompleted).length / todoItems.length) * 100}%` }} /></div>
                </div>
              )}
              <div className="todo-add">
                <input className="todo-input" placeholder="Thêm việc cần làm..." value={newTodo} onChange={(e) => setNewTodo(e.target.value)} onKeyDown={(e) => e.key === "Enter" && handleAddTodo()} />
                <button className="btn-primary btn-sm" onClick={handleAddTodo}>Thêm</button>
              </div>
              <ul className="todo-list">
                {todoItems.map((t) => (
                  <li key={t.todoItemUId} className="todo-item">
                    <label className="todo-label">
                      <input type="checkbox" checked={t.isCompleted} onChange={() => handleToggleTodo(t)} />
                      <span className={`todo-text ${t.isCompleted ? "line-through text-gray-500" : ""}`}>{t.content}</span>
                    </label>
                    <button className="todo-delete" onClick={() => handleDeleteTodo(t.todoItemUId)}>🗑️</button>
                  </li>
                ))}
              </ul>
            </div>

            {/* ATTACHMENTS */}
            <div className="modal-section">
              <div className="section-header">
                <Paperclip size={20} /><h3>Tệp đính kèm</h3>
                <button
                  className="btn-secondary btn-sm ml-auto flex items-center gap-1"
                  onClick={() => attachInputRef.current?.click()}
                  disabled={uploading}
                >
                  <Upload size={13} /> {uploading ? "Đang tải..." : "Đính kèm"}
                </button>
                <input ref={attachInputRef} type="file" className="hidden" onChange={handleAttachFile} />
              </div>
              {attachments.length === 0 && (
                <p className="text-sm text-gray-400 dark:text-gray-500 italic">Chưa có tệp đính kèm.</p>
              )}
              <ul className="space-y-2 mt-1">
                {attachments.map((a) => {
                  const isImg = /\.(png|jpg|jpeg|gif|webp|svg)$/i.test(a.fileUrl || "");
                  return (
                    <li key={a.attachmentUId} className="flex items-center gap-3 p-2 bg-gray-50 dark:bg-zinc-800 rounded-lg border border-gray-100 dark:border-zinc-700">
                      {isImg
                        ? <img src={a.fileUrl} alt={a.fileName} className="w-12 h-10 object-cover rounded" />
                        : <div className="w-12 h-10 flex items-center justify-center bg-gray-200 dark:bg-zinc-700 rounded text-gray-500"><Paperclip size={18} /></div>}
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-gray-700 dark:text-gray-200 truncate">{a.fileName || "Tệp"}</p>
                        <p className="text-xs text-gray-400">{a.uploadedAt ? new Date(a.uploadedAt).toLocaleDateString("vi-VN") : ""}</p>
                      </div>
                      <div className="flex gap-1 shrink-0">
                        {a.fileUrl && (
                          <a href={a.fileUrl} target="_blank" rel="noreferrer" className="p-1.5 text-blue-500 hover:text-blue-700 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded">
                            <ExternalLink size={14} />
                          </a>
                        )}
                        <button onClick={() => handleDeleteAttachment(a.attachmentUId)} className="p-1.5 text-red-400 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded">
                          <Trash2 size={14} />
                        </button>
                      </div>
                    </li>
                  );
                })}
              </ul>
            </div>

            {/* MOVE CARD */}
            <div className="modal-section">
              <div className="section-header">
                <ArrowRight size={20} /><h3>Di chuyển thẻ</h3>
                <button className="btn-secondary btn-sm ml-auto" onClick={() => setShowMovePicker((v) => !v)}>
                  {showMovePicker ? "Huỷ" : "Di chuyển..."}
                </button>
              </div>
              {showMovePicker && (
                <div className="space-y-2 mt-2">
                  <select value={selWsId} onChange={(e) => { setSelWsId(e.target.value); setSelBoardId(""); setSelListId(""); }}
                    className="w-full border border-gray-300 dark:border-zinc-600 rounded-lg px-2 py-1.5 text-sm dark:bg-zinc-800 dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">— Không gian làm việc —</option>
                    {workspaces.map((ws) => <option key={ws.workspaceUId} value={ws.workspaceUId}>{ws.name}</option>)}
                  </select>
                  {selWsId && (
                    <select value={selBoardId} onChange={(e) => { setSelBoardId(e.target.value); setSelListId(""); }}
                      className="w-full border border-gray-300 dark:border-zinc-600 rounded-lg px-2 py-1.5 text-sm dark:bg-zinc-800 dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-500">
                      <option value="">— Bảng —</option>
                      {moveBoards.map((b) => <option key={b.boardUId} value={b.boardUId}>{b.boardName}</option>)}
                    </select>
                  )}
                  {selBoardId && (
                    <select value={selListId} onChange={(e) => setSelListId(e.target.value)}
                      className="w-full border border-gray-300 dark:border-zinc-600 rounded-lg px-2 py-1.5 text-sm dark:bg-zinc-800 dark:text-gray-100 outline-none focus:ring-2 focus:ring-blue-500">
                      <option value="">— Danh sách —</option>
                      {moveLists.map((l) => <option key={l.listUId} value={l.listUId}>{l.listName}</option>)}
                    </select>
                  )}
                  {selListId && (
                    <button onClick={handleMoveCard} disabled={moving}
                      className={`w-full py-2 rounded-lg text-white text-sm font-medium flex items-center justify-center gap-2 ${moving ? "bg-gray-400" : "bg-blue-600 hover:bg-blue-700"}`}>
                      <ArrowRight size={16} /> {moving ? "Đang di chuyển..." : "Di chuyển thẻ"}
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* RIGHT - COMMENTS */}
          <div className="cardmodal-right">
            <div className="sidebar-section">
              <h4>Hoạt động &amp; Bình luận</h4>
              <div className="comment-input">
                <div className="comment-avatar">{storedUser?.userName?.[0]?.toUpperCase() || "U"}</div>
                <div className="comment-box">
                  <textarea className="comment-textarea" placeholder="Viết bình luận..." value={newComment} onChange={(e) => setNewComment(e.target.value)} />
                  {newComment && <button className="btn-primary btn-sm" onClick={handleAddComment}>Gửi</button>}
                </div>
              </div>
              <div className="comment-list">
                {comments.map((c) => (
                  <div key={c.commentUId} className="comment-item">
                    <div className="comment-avatar">{c.user?.userName?.[0]?.toUpperCase() || "U"}</div>
                    <div className="comment-content">
                      <div className="comment-header">
                        <strong>{c.user?.userName || "Ẩn danh"}</strong>
                        <span className="comment-time">{new Date(c.createdAt).toLocaleString("vi-VN", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" })}</span>
                      </div>
                      <p className="comment-text">{c.content}</p>
                      <button className="comment-delete" onClick={() => handleDeleteComment(c.commentUId)}>Xóa</button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <button className="btn-save" onClick={handleSave}>💾 Lưu thay đổi</button>
          </div>
        </div>
      </div>
    </div>
  );
}

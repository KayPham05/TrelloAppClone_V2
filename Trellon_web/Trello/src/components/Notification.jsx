import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import { Bell, MessageSquareText, UserPlus, ArrowLeftRight, CalendarCheck2, AtSign, KanbanSquare, Trash2, X } from "lucide-react";
import { getNotificationsAPI, markAsReadAPI, markAllAsReadAPI, deleteNotificationAPI } from "../services/NotificationAPI";
import { saveRecentBoardAPI } from "../services/RecentBoardAPI";

// === utilities ===
const timeAgo = (iso) => {
    const s = Math.max(1, Math.floor((Date.now() - new Date(iso)) / 1000));
    if (s < 60) return `${s}s ago`;
    const m = Math.floor(s / 60);
    if (m < 60) return `${m}m ago`;
    const h = Math.floor(m / 60);
    if (h < 24) return `${h}h ago`;
    const d = Math.floor(h / 24);
    return `${d}d ago`;
};

const TypeIcon = ({ type }) => {
    const map = {
        comment: MessageSquareText,
        assign: UserPlus,
        move: ArrowLeftRight,
        due: CalendarCheck2,
        mention: AtSign,
        board: KanbanSquare
    };
    const Icon = map[type] || MessageSquareText;
    return (
        <div className="p-2 bg-blue-50 rounded-lg">
            <Icon size={16} strokeWidth={2.5} className="text-blue-600" />
        </div>
    );
};

// === component ===
export default function Notification() {
    const [open, setOpen] = useState(false);
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(false);
    const [page, setPage] = useState(1);
    const [hasMore, setHasMore] = useState(true);
    const ref = useRef(null);
    const navigate = useNavigate();

    const unread = items.reduce((n, i) => n + (i.read ? 0 : 1), 0);
    const user = JSON.parse(localStorage.getItem("user"));

    // Lấy danh sách thông báo
    const fetchPage = async (p = 1) => {
        if (!user?.userUId) return;
        setLoading(true);
        try {
            const data = await getNotificationsAPI(user.userUId, p, 10);
            const list = Array.isArray(data) ? data : data.items || [];
            setItems((prev) => (p === 1 ? list : [...prev, ...list]));
            setHasMore(list.length === 10);
            setPage(p);
            console.log("Fetched notifications:", list);
        } catch (error) {
            console.error("Failed to fetch notifications:", error);
        } finally {
            setLoading(false);
        }
    };
    useEffect(() => { fetchPage(1); }, [user?.userUId]);

    // Đóng popup khi click ra ngoài
    useEffect(() => {
        const onClick = (e) => ref.current && !ref.current.contains(e.target) && setOpen(false);
        document.addEventListener("mousedown", onClick);
        return () => document.removeEventListener("mousedown", onClick);
    }, []);

    // Đánh dấu đã đọc và chuyển hướng
    const onItemClick = async (n) => {
        // Đánh dấu đã đọc
        if (!n.read) {
            try {
                await markAsReadAPI(n.notiId);
                setItems((prev) => prev.map((i) => (i.notiId === n.notiId ? { ...i, read: true } : i)));
            } catch (err) {
                console.error("Mark as read error:", err);
            }
        }

        // Nếu notification chứa board hoặc boardId thì mở dashboard
        if (n.board || n.boardId) {
            const board = n.board || { boardUId: n.boardId, boardName: n.title || "" };
            localStorage.setItem("currentBoard", JSON.stringify(board));
            try {
                await saveRecentBoardAPI(user.userUId, board.boardUId);
            } catch (err) {
                console.error("Recent board saving error:", err);
            }
            navigate("/dashboard");
            setOpen(false);
            return;
        }

        setOpen(false);
    };

    // Đánh dấu tất cả đã đọc
    const onMarkAll = async () => {
        try {
            await markAllAsReadAPI(user.userUId);
            setItems((prev) => prev.map((i) => ({ ...i, read: true })));
        } catch (err) {
            console.error("Mark all as read error:", err);
        }
    };

    // Xóa một thông báo
    const onDelete = async (e, notiId) => {
        e.stopPropagation(); // Ngăn click vào nút xóa không trigger onItemClick
        if (!window.confirm("Are you sure you want to delete this notification?")) {
            return;
        }
        try {
            await deleteNotificationAPI(notiId);
            setItems((prev) => prev.filter((i) => i.notiId !== notiId));
        } catch (err) {
            console.error("Delete notification error:", err);
        }
    };

    return (
    <div className="relative" ref={ref}>
        {/* Bell Button */}
        <button
            onClick={() => setOpen((v) => !v)}
            className="relative p-2.5 hover:bg-gray-200 rounded-xl transition-all duration-200
                       dark:bg-[#1E1F22] dark:hover:bg-[#3A3C42]"
            aria-label="Notifications"
        >
            <Bell className="text-gray-700 dark:text-[#F2F3F5]" size={22} strokeWidth={2.5} />
            {unread > 0 && (
                <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] font-bold min-w-[18px] h-[18px] px-1 rounded-full flex items-center justify-center shadow">
                    {unread > 9 ? "9+" : unread}
                </span>
            )}
        </button>

        {/* Popup */}
        {open && (
            <div className="absolute right-0 mt-3 w-[420px] bg-white border border-gray-200 shadow-2xl rounded-2xl overflow-hidden z-50 animate-in fade-in slide-in-from-top-2 duration-200
                            dark:bg-[#2B2D31] dark:border-[#3F4147]">
                
                {/* Header */}
                <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100 bg-white
                                dark:bg-[#2B2D31] dark:border-[#3F4147]">
                    <div className="flex items-center gap-2">
                        <Bell size={18} className="text-blue-600 dark:text-[#F2F3F5]" strokeWidth={2.5} />
                        
                        {/* Title */}
                        <h3 className="text-base font-bold 	dark:text-[#32BEFF]">Notifications</h3>

                        {unread > 0 && (
                            <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs font-semibold rounded-full bg-red-500 text-white ">
                                {unread}
                            </span>
                        )}
                    </div>

                    <div className="flex items-center gap-2">
                        {unread > 0 && (
                            <button
                                onClick={onMarkAll}
                                className="text-xs font-medium text-blue-600 hover:text-blue-700 hover:underline transition
                                           dark:text-[#8AB4F8] dark:hover:text-[#A8C7FA]"
                            >
                                Mark all read
                            </button>
                        )}
                        <button
                            onClick={() => setOpen(false)}
                            className="p-1 hover:bg-gray-100 rounded-lg transition dark:hover:bg-[#3A3C42]"
                        >
                            <X size={16} className="text-gray-500 dark:text-[#F2F3F5]" />
                        </button>
                    </div>
                </div>

                {/* Content */}
                <div className="max-h-[480px] overflow-y-auto dark:text-[#F2F3F5]">
                    
                    {/* Empty */}
                    {!loading && items.length === 0 && (
                        <div className="flex flex-col items-center justify-center py-12 px-4">
                            <div className="w-16 h-16 bg-gray-100 dark:bg-[#3A3C42] rounded-full flex items-center justify-center mb-3">
                                <Bell size={28} className="text-gray-400 dark:text-[#F2F3F5]" strokeWidth={1.5} />
                            </div>

                            {/* Empty Title */}
                            <p className="text-sm font-medium text-gray-600 dark:text-[#E8EAED]">No notifications yet</p>

                            {/* Empty Subtitle */}
                            <p className="text-xs text-gray-400 dark:text-[#9AA0A6] mt-1">
                                We'll notify you when something arrives
                            </p>
                        </div>
                    )}

                    {/* Items */}
                    {items.map((n) => (
                        <div
                            key={n.notiId}
                            className={`group relative border-b border-gray-100 last:border-b-0 transition-all duration-200 dark:border-[#3F4147]
                                ${
                                    !n.read
                                        ? "bg-blue-50/50 hover:bg-blue-100/80 dark:bg-[#1E1F22] dark:hover:bg-[#3A3C42]"
                                        : "bg-white hover:bg-gray-200 dark:bg-[#2B2D31] dark:hover:bg-[#3A3C42]"
                                }`}
                        >
                            <div className="flex gap-3 p-4 cursor-pointer" onClick={() => onItemClick(n)}>
                                <div className="flex-shrink-0 mt-0.5">
                                    <TypeIcon type={n.type} dark />
                                </div>

                                <div className="flex-1 min-w-0">
                                    <div className="flex items-start justify-between gap-2 mb-1">
                                        <h4 className="text-sm font-bold text-gray-900 dark:text-[#F2F3F5] line-clamp-1">
                                            {n.title}
                                        </h4>

                                        {!n.read && <span className="flex-shrink-0 w-2 h-2 bg-blue-500 rounded-full mt-1.5"></span>}
                                    </div>

                                    <p className="text-xs text-gray-600 dark:text-[#B5BAC1] line-clamp-2 mb-2 leading-relaxed">
                                        {n.message}
                                    </p>

                                    <div className="flex items-center justify-between">
                                        <span className="text-[11px] font-medium text-gray-400 dark:text-[#B5BAC1]">
                                            {timeAgo(n.createdAt)}
                                        </span>
                                    </div>
                                </div>

                                <button
                                    onClick={(e) => onDelete(e, n.notiId)}
                                    className="absolute top-3 right-3 p-1.5 bg-white hover:bg-red-50 border border-gray-200 rounded-lg opacity-0 group-hover:opacity-100 transition-all duration-200 shadow-sm hover:shadow hover:border-red-200 dark:bg-[#3A3C42] dark:border-[#4A4D54] dark:hover:bg-[#4F525A]"
                                    aria-label="Delete notification"
                                >
                                    <Trash2 size={13} className="text-red-500 dark:text-[#F23F43]" strokeWidth={2.5} />
                                </button>
                            </div>
                        </div>
                    ))}

                    {/* Load More */}
                    {hasMore && !loading && items.length > 0 && (
                        <button
                            onClick={() => fetchPage(page + 1)}
                            className="w-full py-3 text-sm font-medium text-blue-600 hover:bg-blue-50
                                       dark:text-[#8AB4F8] dark:hover:text-[#A8C7FA] dark:hover:bg-[#3A3C42]"
                        >
                            Load more notifications
                        </button>
                    )}

                    {/* Loading */}
                    {loading && (
                        <div className="flex items-center justify-center py-8">
                            <div className="w-6 h-6 border-2 border-blue-600 dark:border-[#F2F3F5] border-t-transparent rounded-full animate-spin"></div>
                        </div>
                    )}
                </div>
            </div>
        )}
    </div>
);




}
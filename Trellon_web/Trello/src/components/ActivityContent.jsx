// src/components/settings/ActivityContent.jsx
import React, { useEffect, useState, useRef, useCallback } from "react";
import { Loader2 } from "lucide-react";
import { getActivitiesAPI } from './../services/ActivityAPI';

export default function ActivityContent({ currentUser }) {
  const [items, setItems] = useState([]);
  const [offset, setOffset] = useState(0);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const containerRef = useRef(null);
  const LIMIT = 20;

  // format thời gian
  const formatTime = (isoString) => {
    const d = new Date(isoString);
    return d.toLocaleString("vi-VN", { hour12: false });
  };

  // gọi API
  const fetchActivities = useCallback(async () => {
    if (!currentUser?.userUId || loading || !hasMore) return;

    setLoading(true);
    try {
      const res = await getActivitiesAPI(currentUser.userUId, LIMIT, offset);
      const data = Array.isArray(res.data?.data) ? res.data.data : res.data;

      setItems((prev) => [...prev, ...data]);
      if (data.length < LIMIT) setHasMore(false);
      else setOffset((prev) => prev + LIMIT);
    } catch (err) {
      console.error("Lỗi lấy activity:", err);
    }
    setLoading(false);
  }, [currentUser, offset, loading, hasMore]);

  // load lần đầu
  useEffect(() => {
    setItems([]);
    setOffset(0);
    setHasMore(true);
  }, [currentUser]);

  useEffect(() => {
    fetchActivities();
  }, [fetchActivities]);

  // scroll để load thêm
  const handleScroll = () => {
    const el = containerRef.current;
    if (!el) return;

    if (el.scrollTop + el.clientHeight + 100 >= el.scrollHeight) {
      fetchActivities();
    }
  };

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      className="h-full overflow-y-auto px-6 py-6"
    >
      <h2 className="text-xl font-bold mb-4">Activities</h2>

      {items.length === 0 && !loading && (
        <p className="text-gray-500">No acitivity yet.</p>
      )}

      <ul className="space-y-5">
        {items.map((act) => (
          <li
            key={act.activityUId}
            className="flex items-start gap-3 border-b border-gray-200 dark:border-neutral-800 pb-4"
          >
            {/* Avatar tròn giống Trello */}
            <div className="w-9 h-9 rounded-full bg-blue-600 flex items-center justify-center text-white font-semibold">
              {act.userName?.charAt(0) || "U"}
            </div>

            <div>
              <p className="text-sm">
                <span className="font-semibold">{act.userName}</span>{" "}
                <span dangerouslySetInnerHTML={{ __html: act.action }}></span>
              </p>

              <p className="text-xs text-gray-500 mt-1">
                {formatTime(act.createdAt)}
              </p>
            </div>
          </li>
        ))}
      </ul>

      {loading && (
        <div className="flex justify-center py-4">
          <Loader2 className="animate-spin text-gray-500" />
        </div>
      )}

      {!hasMore && (
        <p className="text-center text-gray-400 text-sm py-3">
          — No activity yet —
        </p>
      )}
    </div>
  );
}

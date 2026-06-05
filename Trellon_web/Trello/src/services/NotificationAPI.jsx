import axiosClient from "./axios/axiosApi";

const END_POINT = {
  NOTIFICATIONS: "notifications",
};

// Lấy danh sách thông báo (Backend tự lấy userId từ Token)
export const getNotificationsAPI = (page = 1, pageSize = 20, tab = "all") => {
  return axiosClient.get(`${END_POINT.NOTIFICATIONS}`, {
    params: { page, pageSize, tab },
  });
};

// Lấy số lượng thông báo chưa đọc
export const getUnreadCountAPI = () => {
  return axiosClient.get(`${END_POINT.NOTIFICATIONS}/unread-count`);
};

// Đánh dấu đã đọc 1 thông báo
export const markAsReadAPI = (notiId) => {
  return axiosClient.patch(`${END_POINT.NOTIFICATIONS}/${notiId}/read`);
};

// Đánh dấu tất cả đã đọc
export const markAllAsReadAPI = () => {
  return axiosClient.patch(`${END_POINT.NOTIFICATIONS}/read-all`);
};

// === Dành cho trường hợp muốn tạo notification thủ công ===
export const addNotificationAPI = (payload) => {
  // payload gồm: recipientId, actorId, type, title, message, link, boardId?, workspaceId?, ...
  return axiosClient.post(`${END_POINT.NOTIFICATIONS}`, payload);
};

// === 🗑️ Xóa một thông báo theo ID ===
export const deleteNotificationAPI = (notiId) => {
  return axiosClient.delete(`${END_POINT.NOTIFICATIONS}/${notiId}`);
};




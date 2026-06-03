import AxiosClient from "./axios/axiosApi";

const EP = (cardId) => `cards/${cardId}/labels`;

/** Tạo nhãn mới cho card */
export const addCardLabelAPI = (cardId, title, colorCode) =>
  AxiosClient.post(EP(cardId), { title, colorCode });

/** Cập nhật nhãn (title + colorCode) */
export const updateCardLabelAPI = (cardId, labelId, title, colorCode) =>
  AxiosClient.put(`${EP(cardId)}/${labelId}`, { title, colorCode });

/** Xóa nhãn */
export const deleteCardLabelAPI = (cardId, labelId) =>
  AxiosClient.delete(`${EP(cardId)}/${labelId}`);

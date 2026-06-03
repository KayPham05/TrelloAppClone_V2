import AxiosClient from "./axios/axiosApi";
const END_POINT = { LISTS: "lists" };

const getUserUId = () => {
    try { return JSON.parse(localStorage.getItem("user"))?.userUId; }
    catch { return undefined; }
};

export const getListsByBoardIdAPI = (boardUId) =>
    AxiosClient.get(`${END_POINT.LISTS}/?boardUId=${boardUId}`);

export const createListAPI = (list, userUId = getUserUId()) =>
    AxiosClient.post(`${END_POINT.LISTS}?userUId=${userUId}`, list);

export const updateListStatusAPI = (listUId, newStatus, userUId = getUserUId()) =>
    AxiosClient.put(`${END_POINT.LISTS}/${listUId}?newStatus=${newStatus}&userUId=${userUId}`);

export const reorderListsAPI = (boardUId, order, userUId = getUserUId()) =>
  AxiosClient.put(`${END_POINT.LISTS}/reorder`, {
    boardUId,
    order,
    userUId,
  });
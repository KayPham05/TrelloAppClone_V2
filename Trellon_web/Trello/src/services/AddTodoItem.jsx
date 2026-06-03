import axiosClient from "./axios/axiosApi";
const END_POINT = {
    CARD_ITEM: "todoItem"
}

export const getTodoItemsAPI = (cardUId) => {
  return axiosClient.get(`${END_POINT.CARD_ITEM}/${cardUId}`);
};

export const addTodoItemAPI = (cardUId, content) => {
  return axiosClient.post(`${END_POINT.CARD_ITEM}/add`, { cardUId, content });
};

export const updateStatusTodoItemAPI = (todoItemUId, status) => {
  return axiosClient.put(
    `${END_POINT.CARD_ITEM}/${todoItemUId}/update-status?status=${status}`
  );
};

export const deleteTodoItemAPI = (todoItemUId) => {
  return axiosClient.delete(`${END_POINT.CARD_ITEM}/${todoItemUId}`);
};
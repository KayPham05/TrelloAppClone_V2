import axiosClient from "./axios/axiosApi";
const END_POINT = {
    TODOS: 'cards'
}

export const  getCardsAPI = (boardUId) => {
    return axiosClient.get(`${END_POINT.TODOS}/by-board/${boardUId}`);
}

export const deleteCardAPI = (id) => {
    return axiosClient.delete(`${END_POINT.TODOS}/${id}`);
}

export const addCardAPI = (card) => {
    return axiosClient.post(`${END_POINT.TODOS}`, card);
}

export const getCardDescriptionAPI = (id) => {
    return axiosClient.get(`${END_POINT.TODOS}/${id}/description`);
}

export const updateCardAPI = (card) => {
  if (!card?.cardUId) {
    console.error(" Không có cardUId để cập nhật!");
    return;
  }
  return axiosClient.put(`${END_POINT.TODOS}/${card.cardUId}`, card);
};

export const updateCardListAPI =(cardUId, listUId, userUId) => {
    return axiosClient.put(`${END_POINT.TODOS}/${cardUId}/update-list`, {
         listUId, userUId
    });
}

export const updateCardStatus =(cardUId, newStatus) => {
    return axiosClient.put(`${END_POINT.TODOS}/${cardUId}/update-status?newStatus=${newStatus}`);
}


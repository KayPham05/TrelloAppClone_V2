import axiosClient from "./axios/axiosApi";
const END_POINT = {
  CARDS: "cards",
  COMMENTS: "comments",
};


export const getCommentsAPI = (cardUId) => {
  return axiosClient.get(`${END_POINT.COMMENTS}/card/${cardUId}`);
};

export const addCommentAPI = (comment) => {
  return axiosClient.post(`${END_POINT.COMMENTS}`, comment);
};

export const updateCommentAPI = (id, comment) => {
  return axiosClient.put(`${END_POINT.COMMENTS}/${id}`, comment);
};

export const deleteCommentAPI = (id) => {
  return axiosClient.delete(`${END_POINT.COMMENTS}/${id}`);
};

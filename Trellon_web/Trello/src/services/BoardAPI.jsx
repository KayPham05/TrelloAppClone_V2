import AxiosClient from "../services/axios/axiosApi";
const END_POINT = {
  BOARDS: "boards",
};

export const getBoardsAPI = (userUId) => {
  return AxiosClient.get(`${END_POINT.BOARDS}/?userUId=${userUId}`);
};

export const getBoardByIdAPI = (id) => {
  return AxiosClient.get(`${END_POINT.BOARDS}/${id}`);
};
export const createBoardAPI = (board) => {
  return AxiosClient.post(`${END_POINT.BOARDS}`, board);
}

export const updateBoardAPI = (id, board) => {
  return AxiosClient.put(`${END_POINT.BOARDS}/${id}`, board);
}

export const deleteBoardAPI = (id, userUId) => {
  return AxiosClient.delete(`${END_POINT.BOARDS}/${id}`, { params: { userUId } });
}

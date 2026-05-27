import AxiosClient from "./axios/axiosApi";
const END_POINT = {
  CARD_MEMBER: "CardMember",
};

export const getCardMembersAPI = (cardUId) => {
  return AxiosClient.get(`${END_POINT.CARD_MEMBER}/${cardUId}`);
};

export const addCardMemberAPI = (userUId, requesterUId, boardUId, cardUId) => {
  return AxiosClient.post(`${END_POINT.CARD_MEMBER}/add`, null, {
    params: { userUId, requesterUId, boardUId, cardUId },
  });
};

export const removeCardMemberAPI = (
  userUId,
  requesterUId,
  boardUId,
  cardUId
) => {
  return AxiosClient.delete(`${END_POINT.CARD_MEMBER}/remove`, {
    params: { userUId, requesterUId, boardUId, cardUId },
  });
};

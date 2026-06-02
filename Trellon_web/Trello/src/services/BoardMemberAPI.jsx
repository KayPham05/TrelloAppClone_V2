import axiosClient from "./axios/axiosApi";

const END_POINT = {
  BOARD_MEMBER: "boardMember",
};

export const getBoardMembersAPI = (boardUId) => {
  return axiosClient.get(`${END_POINT.BOARD_MEMBER}/${boardUId}/members`);
};


export const addBoardMemberAPI = (boardUId, userUId, requesterUId, role) => {
  return axiosClient.post(
    `${END_POINT.BOARD_MEMBER}/${boardUId}/add`,
    null,
    { params: { userUId, requesterUId, role } }
  );
};


export const updateBoardMemberRoleAPI = (boardUId, userUId, newRole, requesterUId) => {
  return axiosClient.put(
    `${END_POINT.BOARD_MEMBER}/${boardUId}/update-role`,
    null,
    { params: { userUId, newRole, requesterUId } }
  );
};


export const removeBoardMemberAPI = (boardUId, userUId, requesterUId) => {
  return axiosClient.delete(
    `${END_POINT.BOARD_MEMBER}/${boardUId}/remove/${userUId}`,
    { params: { requesterUId } }
  );
};


export const getUserRoleInBoardAPI = (boardUId, userUId) => {
  return axiosClient.get(`${END_POINT.BOARD_MEMBER}/${boardUId}/role`, {
    params: { userUId },
  });
};

export const checkBoardPermissionAPI = (boardUId, userUId, requiredRole) => {
  return axiosClient.get(`${END_POINT.BOARD_MEMBER}/${boardUId}/has-permission`, {
    params: { userUId, requiredRole },
  });
};
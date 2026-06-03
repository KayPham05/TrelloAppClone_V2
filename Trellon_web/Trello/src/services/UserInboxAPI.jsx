import axiosClient from "./axios/axiosApi";
const END_POINT = {
    USER_INBOX: 'user-inbox'
};

export const getUserInboxAPI = (userUId) => {
    return axiosClient.get(`${END_POINT.USER_INBOX}/${userUId}`);
}
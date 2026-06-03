import AxiosClient from "./axios/axiosApi";

const END_POINT = {
    USER_INBOX: 'add-inbox-card'
};

export const addCardToInboxAPI = (inboxCard) => {
    return AxiosClient.post(`${END_POINT.USER_INBOX}`, inboxCard);
}
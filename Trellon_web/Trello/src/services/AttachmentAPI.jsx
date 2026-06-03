import AxiosClient from "./axios/axiosApi";

const EP = "CardAttachment";

export const getAttachmentsAPI = (cardUId) =>
  AxiosClient.get(`${EP}/${cardUId}`);

export const uploadAttachmentAPI = (cardUId, userUId, file) => {
  const form = new FormData();
  form.append("file", file);
  return AxiosClient.post(`${EP}/upload?cardUId=${cardUId}&userUId=${userUId}`, form, {
    headers: { "Content-Type": "multipart/form-data" },
  });
};

export const deleteAttachmentAPI = (attachmentUId, userUId) =>
  AxiosClient.delete(`${EP}/${attachmentUId}?userUId=${userUId}`);

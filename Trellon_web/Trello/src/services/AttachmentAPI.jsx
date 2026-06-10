import AxiosClient from "./axios/axiosApi";

// Endpoints: v1/api/cards/{cardUId}/attachments  (khớp với Flutter & Backend)
export const getAttachmentsAPI = (cardUId) =>
  AxiosClient.get(`cards/${cardUId}/attachments`);

export const uploadAttachmentAPI = (cardUId, userUId, file) => {
  const form = new FormData();
  form.append("file", file);
  return AxiosClient.post(`cards/${cardUId}/attachments?userUId=${userUId}`, form, {
    headers: { "Content-Type": "multipart/form-data" },
  });
};

// fileUId = attachmentUId returned by server
export const deleteAttachmentAPI = (cardUId, fileUId, userUId) =>
  AxiosClient.delete(`cards/${cardUId}/attachments/${fileUId}?userUId=${userUId}`);

export const updateAttachmentDescriptionAPI = (cardUId, fileUId, userUId, description) => {
  const desc = description ? `&description=${encodeURIComponent(description)}` : "";
  return AxiosClient.put(`cards/${cardUId}/attachments/${fileUId}/description?userUId=${userUId}${desc}`);
};

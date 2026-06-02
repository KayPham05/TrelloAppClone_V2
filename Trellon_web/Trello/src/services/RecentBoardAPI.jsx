import axiosClient from "./axios/axiosApi";

const END_POINT = {
    RECENT: "RecentBoard"
}

export const getRecentBoardsAPI = (userUId) =>{
   return axiosClient.get(`${END_POINT.RECENT}`, {
    params:{userUId: userUId}
   });
}

export const saveRecentBoardAPI = (userUId, boardUId) => {
    return axiosClient.post(`${END_POINT.RECENT}/${userUId}`, null, {
        params:{boardUId: boardUId}
    })
}
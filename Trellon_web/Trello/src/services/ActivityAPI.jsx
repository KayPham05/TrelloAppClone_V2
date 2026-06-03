import AxiosClient from "../services/axios/axiosApi";

const END_POINT = {
    ACTIVITY: "Activity",
};

export const getActivitiesAPI = (userUId,limit = 10, offset = 0) => {
    return AxiosClient.get(`${END_POINT.ACTIVITY}/?userUId=${userUId}`, {
        params: { limit, offset }
    });
};

//export const getActivitiesByUserAPI = (userUId, limit = 50) => {
//    return AxiosClient.get(`v1/api/${END_POINT.ACTIVITY}/user/${userUId}`, {
//        params: { limit }
//    });
//};


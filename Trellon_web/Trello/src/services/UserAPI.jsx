import axiosClient from "./axios/axiosApi";
const END_POINT = {
    USER: "users"
}

export const getUserByEmailAPI = (email) => {
    return axiosClient.get(`${END_POINT.USER}/get-by-email`, {
        params: { email }
    } );
}

export const getBioByUserUIdAPI = (userUId) =>{
    return axiosClient.get(`${END_POINT.USER}/GetBio`,{
        params:{userUId}
    });
}
export const getUsernameByUserUIdAPI = (userUId)=>{
    return axiosClient.get(`${END_POINT.USER}/GetUsername`,{
        params:{userUId}
    });
}

export const addBioByUserUIdAPI = (userUId, bio) =>{
    return axiosClient.post(`${END_POINT.USER}/AddBio`,null
    ,{
	    params:{userUId, bio}
    });
}

export const addUsernameByUserUIdAPI = (userUId, username)=>{
    return axiosClient.post(`${END_POINT.USER}/AddUsername`, null
    ,{
        params: {userUId, username}
    });
}
export const verificodeAPI = (email, code) => {
    return axiosClient.post(`${END_POINT.USER}/verify-code`, {
         email, code
    })
}

export const resendCodeAPI = (email) => {
    return axiosClient.post(`${END_POINT.USER}/resend-code`, null, {
        params:{email}
    })
}

const normalizeUser = (raw) => ({
  userName: raw?.userName ?? raw?.username ?? "",
  bio: raw?.bio ?? ""
});

export const getVerificationStatusAPI = (email) => {
  return axiosClient.get("users/get-verification-status", { params: { email } });
};

// Toggle 2FA
export const toggleTwoFactorAPI = (userUId, enabled) => {
  return axiosClient.post(`${END_POINT.USER}/toggle-2fa`, null, {
    params: { userUId, enabled },
  });
};


export { normalizeUser };
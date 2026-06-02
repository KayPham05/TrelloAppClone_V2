import axiosClient from "./axios/axiosApi";

const END_POINT = {
  AUTH: "auth",
};

export const registerAPI = (user) => {
  console.log(`${END_POINT.AUTH}/register`);
  return axiosClient.post(`${END_POINT.AUTH}/register`, user);
};

export const loginAPI = (user) => {
  return axiosClient.post(`${END_POINT.AUTH}/login`, user);
};

export const LoginGoogleAPI = (accessToken) => {
  return axiosClient.post(`${END_POINT.AUTH}/Google-login`, accessToken);
};

export const logoutAPI = (userUId) => {
  return axiosClient.post(
    `${END_POINT.AUTH}/logout`,
    {},
    {
      params: { userUId },
      withCredentials: true, // cookie gửi đi cùng request
    }
  );
};

export const send2FAOtpAPI = (email) => {
  return axiosClient.post(`${END_POINT.AUTH}/send-2fa-otp`, null, {
    params: { email },
  });
};

//  Verify OTP khi ĐĂNG NHẬP (login flow)
export const verifyOtpAPI = (email, otp) => {
  return axiosClient.post(`${END_POINT.AUTH}/verify-otp`, { email, otp });
};

//  Verify OTP khi BẬT 2FA lần đầu (setup) - Dùng query params
export const verify2FASetupAPI = (email, otp) => {
  return axiosClient.post(`${END_POINT.AUTH}/verify-2fa-setup`, null, {
    params: { email, otp }
  });
};
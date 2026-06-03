import axios from "axios";
import { toast } from "react-toastify";
// import { logoutAPI } from "../LoginAPI"

const instance = axios.create({
  baseURL: import.meta.env.VITE_URL_API,
  headers: { "Content-Type": "application/json" },
  timeout: 30000,
  withCredentials: true,
});

instance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  },
  (error) => Promise.reject(error)
);

let isRefreshing = false;
let subscribers = [];

function subscribeTokenRefresh(cb) {
  subscribers.push(cb);
}

function onRefreshed(token) {
  subscribers.forEach((cb) => cb(token));
  subscribers = [];
}

instance.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    const originalRequest = error.config;

    // Chỉ xử lý 401 cho requests KHÔNG PHẢI /refresh-token hoặc /logout
    if (
      error.response?.status === 401 && 
      !originalRequest._retry &&
      !originalRequest.url?.includes('/refresh-token') &&
      !originalRequest.url?.includes('/logout')
    ) {
      
      if (isRefreshing) {
        return new Promise((resolve) => {
          subscribeTokenRefresh((token) => {
            originalRequest.headers.Authorization = `Bearer ${token}`;
            resolve(instance(originalRequest));
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        console.log(" Attempting to refresh access token...");
        
        const res = await axios.post(
            `${import.meta.env.VITE_URL_API}/login/refresh-token`,
          {},
          { withCredentials: true }
        );

        const newAccessToken = res.data.accessToken;
        localStorage.setItem("token", newAccessToken);
        instance.defaults.headers.Authorization = `Bearer ${newAccessToken}`;
        
        console.log("Access token refreshed successfully");
        
        onRefreshed(newAccessToken);
        isRefreshing = false;

        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return instance(originalRequest);
        
      } catch (refreshErr) {
        console.error(" Refresh token failed:", refreshErr);
        isRefreshing = false;
        
        // KHÔNG GỌI logoutAPI() nữa - tránh vòng lặp
        // Chỉ xóa localStorage và redirect
        console.log("🚪 Clearing session and redirecting to login...");
        
        toast.error("Your session has expired. Please log in again!");
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        
        // Delay nhỏ để toast hiển thị
        setTimeout(() => {
          window.location.href = "/";
        }, 500);
        
        return Promise.reject(refreshErr);
      }
    }

    // Lỗi 403
    if (error.response?.status === 403) {
      toast.error("Bạn không có quyền truy cập!");
    }

    return Promise.reject(error);
  }
);

export default instance;
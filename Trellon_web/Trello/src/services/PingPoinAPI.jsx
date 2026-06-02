import axiosClient from "./axios/axiosApi";

const END_POINT = {
  PING: "ping",
};

export const Ping = () =>{
    return axiosClient.get("/ping");
}
import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { GoogleOAuthProvider } from "@react-oauth/google";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
// import { jwtDecode } from "jwt-decode";
import VerifyCode from "./components/VerifyCode.jsx";
import AppLayout from "./components/AppLayout.jsx";
import Login from "./components/Login.jsx";
import Register from "./components/Register.jsx";
import Home from "./components/Home.jsx";
import Layout from "./components/layout.jsx";
import Activity from "./components/ActivityList.jsx";
import Verify2FALogin from "./components/Verify2FALogin";
import WorkflowDesigner from "./components/workflow/WorkflowDesigner";
import "./index.css";


const CLIENT_ID =
  "687329356395-b7o51dhg1e35906kvmdivu0hf9ure9q9.apps.googleusercontent.com";

createRoot(document.getElementById("root")).render(
  <GoogleOAuthProvider clientId={CLIENT_ID}>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/VerifyCode" element={<VerifyCode />} />
        <Route path="/verify-2fa" element={<Verify2FALogin />} />
        <Route element={<AppLayout />}>
          <Route path="/home/:userUId" element={<Home />} />
          <Route path="/dashboard" element={<Layout />} />
          <Route path="/workflow/:workspaceId" element={<WorkflowDesigner />} />
        </Route>
        <Route path="/activity" element={<Activity />} />
      </Routes>
      <ToastContainer
        position="top-right"
        autoClose={2500}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        pauseOnHover
        draggable
        theme="colored"
      />
    </BrowserRouter>
  </GoogleOAuthProvider>
);

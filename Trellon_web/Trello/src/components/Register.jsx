import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { registerAPI } from "../services/LoginAPI";
import { toast } from "react-toastify";

import "../components/css/register.css";
import icon from "../assets/trello-icon.png";


export default function Register() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

const handleSubmit = async (e) => {
  e.preventDefault();
  if (!username || !email || !password) {
    toast.warning("Please fill in form");
    return;
  }

  try {
    setLoading(true);
    const res = await registerAPI({ userName: username, email, password });

    //  Nếu backend trả message thành công
    if (res?.message?.toLowerCase().includes("đăng ký thành công")) {
      toast.success(
        "Register successfully! Please check your email to verify your account."
      );
      // Không cho đăng nhập ngay, chỉ chuyển đến trang hướng dẫn
      setTimeout(() => {
        navigate("/VerifyCode", { state: { email } });
      }, 800);
    } else {
      toast.error(res?.message || "Register fail!");
    }
  } catch (err) {
    console.error(err);
    toast.error(err?.response?.data?.message || "Register fail!");
  } finally {
    setLoading(false);
  }
};


  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-md main-form">
        <div className="bg-white rounded-lg p-10 form-container">
          {/* Logo */}
          <div className="flex items-center justify-center mb-8">
            <div className="flex items-center gap-2">
              <div className="rounded px-2 py-1">
                <i>
                  <img src={icon} alt="icon" width="30" height="30" />
                </i>
              </div>
              <span className="text-2xl font-bold text-gray-800 logo-text">
                Kabo
              </span>
            </div>
          </div>

          <h2 className="text-center text-gray-700 font-bold mb-8 title-text">
            Sign up for your account
          </h2>

          <form id="signupForm" className="space-y-4" onSubmit={handleSubmit}>
            <div>
              <label
                htmlFor="username"
                className="block text-gray-700 mb-2 subtitle-text"
              >
                Username <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="username"
                placeholder="Enter your username"
                className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
            </div>

            <div>
              <label
                htmlFor="email"
                className="block text-gray-700 mb-2 subtitle-text"
              >
                Email <span className="text-red-500">*</span>
              </label>
              <input
                type="email"
                id="email"
                placeholder="Enter your email"
                className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>

            <div>
              <label
                htmlFor="password"
                className="block text-gray-700 mb-2 subtitle-text"
              >
                Password <span className="text-red-500">*</span>
              </label>
              <input
                type="password"
                id="password"
                placeholder="Enter your password"
                className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 text-white py-2.5 rounded hover:bg-blue-700 transition-colors btn-primary mt-6 disabled:opacity-60 disabled:cursor-not-allowed signin-btn"
            >
              {loading ? "Processing..." : "Sign up"}
            </button>
          </form>

          {/* Divider */}
          <div className="flex items-center my-6">
            <div className="flex-1 border-t border-gray-300" />
            <span className="px-4 text-gray-500 order-text">Or continue with</span>
            <div className="flex-1 border-t border-gray-300" />
          </div>

          {/* Social */}
          <div className="space-y-3">
            <button
              type="button"
              className="w-full flex items-center justify-center gap-2 px-4 py-2.5 border border-gray-300 rounded hover:bg-gray-50 transition-colors social-btn"
            >
              <svg
                width="18"
                height="18"
                viewBox="0 0 18 18"
                xmlns="http://www.w3.org/2000/svg"
                aria-hidden="true"
              >
                <path
                  d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.874 2.684-6.615z"
                  fill="#4285F4"
                />
                <path
                  d="M9.003 18c2.43 0 4.467-.806 5.956-2.18L12.05 13.56c-.806.54-1.836.86-3.047.86-2.344 0-4.328-1.584-5.036-3.711H.96v2.332C2.44 15.983 5.485 18 9.003 18z"
                  fill="#34A853"
                />
                <path
                  d="M3.964 10.712c-.18-.54-.282-1.117-.282-1.71 0-.593.102-1.17.282-1.71V4.96H.957C.347 6.175 0 7.55 0 9.002c0 1.452.348 2.827.957 4.042l3.007-2.332z"
                  fill="#FBBC05"
                />
                <path
                  d="M9.003 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.464.891 11.428 0 9.003 0 5.485 0 2.44 2.017.96 4.958L3.967 7.29c.708-2.127 2.692-3.71 5.036-3.71z"
                  fill="#EA4335"
                />
              </svg>
              <span className="text-gray-700">Google</span>
            </button>
          </div>

          {/* Footer */}
          <div className="mt-6 text-center text-sm">
            <span className="text-gray-600 order-text">Already have an account? </span>
            <a href="/" className="text-blue-600 hover:underline font-medium">
              Sign in
            </a>
          </div>

          <div className="mt-8 pt-6 border-t border-gray-200">
            <div className="flex items-center justify-center gap-1 mb-2">
              {/* Nếu dùng Bootstrap Icons, nhớ import CSS của bootstrap-icons */}
              <i
                className="bi bi-triangle-fill text-gray-400"
                style={{ fontSize: "0.5rem" }}
              />
              <span className="text-gray-700 font-bold tracking-wide footer-text">
                DISTINGUISHED
              </span>
            </div>
            <p className="footer-text text-gray-500 text-center mb-2">
              One account for Kabo, Jira, Confluence and{" "}
              <a href="#" className="text-blue-600 hover:underline">
                more
              </a>
              .
            </p>
            <div className="flex items-center justify-center gap-3 footer-text text-gray-500">
              <a href="#" className="hover:underline">
                Privacy Policy
              </a>
              <span>•</span>
              <a href="#" className="hover:underline">
                User Notice
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
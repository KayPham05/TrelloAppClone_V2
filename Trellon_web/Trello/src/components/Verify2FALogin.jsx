import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { verifyOtpAPI, send2FAOtpAPI } from "../services/LoginAPI";
import { toast } from "react-toastify";
import { ArrowLeft, ShieldCheck, Mail, RefreshCw } from "lucide-react";

export default function Verify2FALogin() {
  const navigate = useNavigate();
  const location = useLocation();

  const email = location.state?.email;
  
  useEffect(() => {
    if (!email) {
      toast.error("Không tìm thấy email đăng nhập!");
      navigate("/");
    }
  }, [email, navigate]);

  const [otp, setOtp] = useState("");
  const [timer, setTimer] = useState(120);
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);

  useEffect(() => {
    let interval;
    if (timer > 0) {
      interval = setInterval(() => setTimer((t) => t - 1), 1000);
    }
    return () => clearInterval(interval);
  }, [timer]);

  const formatTime = (sec) =>
    `${Math.floor(sec / 60)}:${String(sec % 60).padStart(2, "0")}`;

  const handleVerify = async (e) => {
    e.preventDefault();
    
    if (otp.length !== 6) {
      toast.error("OTP must be a 6 digit code");
      return;
    }

    try {
      setLoading(true);
      const res = await verifyOtpAPI(email, otp);
      
      if (res.token) {
        localStorage.setItem("token", res.token);
        localStorage.setItem("user", JSON.stringify(res));
        toast.success("Login successfully!");
        navigate(`/home/${res.userUId}`);
      } else {
        toast.error(res.message || "invalid OTP!");
      }
    } catch (error) {
      console.error("Verify OTP error:", error);
      toast.error("Wrong or Expired OTP!");
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    try {
      setResending(true);
      await send2FAOtpAPI(email);
      toast.success("OTP code is resent!");
      setTimer(120);
      setOtp(""); // Clear OTP input
    } catch (error) {
      toast.error("Can't send OTP!");
    } finally {
      setResending(false);
    }
  };

  const handleBackToLogin = () => {
    navigate("/");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 dark:from-neutral-950 dark:via-neutral-900 dark:to-neutral-950 flex items-center justify-center p-4">
      
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-blue-400/10 dark:bg-blue-600/5 rounded-full blur-3xl"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-purple-400/10 dark:bg-purple-600/5 rounded-full blur-3xl"></div>
      </div>

      {/* Main Card */}
      <div className="relative w-full max-w-md">
        
        {/* Back to Login Button */}
        <button
          onClick={handleBackToLogin}
          className="mb-6 flex items-center gap-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 transition-colors group"
        >
          <ArrowLeft size={18} className="group-hover:-translate-x-1 transition-transform" />
          <span className="text-sm font-medium">Sign in</span>
        </button>

        <div className="bg-white dark:bg-neutral-900 rounded-2xl shadow-xl border border-gray-200 dark:border-neutral-800 overflow-hidden">
          
          {/* Header with gradient */}
          <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-8 text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-white/20 backdrop-blur-sm rounded-full mb-4">
              <ShieldCheck size={32} className="text-white" />
            </div>
            <h1 className="text-2xl font-bold text-white mb-2">
              Security Verification 
            </h1>
            <p className="text-blue-100 text-sm">
              Two-Factor Authentication
            </p>
          </div>

          {/* Content */}
          <div className="p-8">
            
            {/* Email display */}
            <div className="flex items-center gap-3 p-4 bg-gray-50 dark:bg-neutral-800/50 rounded-lg mb-6">
              <div className="flex-shrink-0">
                <Mail size={20} className="text-gray-400 dark:text-gray-500" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">
                  OTP is sent to 
                </p>
                <p className="text-sm font-semibold text-gray-900 dark:text-gray-100 truncate">
                  {email}
                </p>
              </div>
            </div>

            {/* Form */}
            <form onSubmit={handleVerify} className="space-y-6">
              
              {/* OTP Input */}
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Enter verification code
                </label>
                <input
                  type="text"
                  maxLength={6}
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
                  className="w-full text-center tracking-[0.5em] text-2xl font-mono px-4 py-4 rounded-xl border-2 border-gray-300 dark:border-neutral-700 bg-white dark:bg-neutral-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all placeholder:tracking-normal"
                  placeholder="000000"
                  autoFocus
                  disabled={loading}
                />
              </div>

              {/* Timer */}
              <div className="flex items-center justify-center gap-2 text-sm">
                {timer > 0 ? (
                  <>
                    <span className="text-gray-600 dark:text-gray-400">
                      The code is valid for
                    </span>
                    <span className="font-mono font-bold text-blue-600 dark:text-blue-400">
                      {formatTime(timer)}
                    </span>
                  </>
                ) : (
                  <span className="text-red-500 font-medium">
                    ⚠️ Expired code
                  </span>
                )}
              </div>

              {/* Verify Button */}
              <button
                type="submit"
                disabled={loading || otp.length !== 6}
                className={`
                  w-full py-4 rounded-xl font-semibold text-white
                  transition-all duration-200 transform
                  ${
                    loading || otp.length !== 6
                      ? "bg-gray-400 dark:bg-gray-700 cursor-not-allowed"
                      : "bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98]"
                  }
                `}
              >
                {loading ? (
                  <span className="flex items-center justify-center gap-2">
                    <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                    Verifying...
                  </span>
                ) : (
                  "Verification and Sign-in"
                )}
              </button>

            </form>

            {/* Divider */}
            <div className="relative my-6">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-200 dark:border-neutral-700"></div>
              </div>
              <div className="relative flex justify-center">
                <span className="px-4 text-xs text-gray-500 dark:text-gray-400 bg-white dark:bg-neutral-900">
                  Haven't had code yet?
                </span>
              </div>
            </div>

            {/* Resend Button */}
            <button
              type="button"
              disabled={timer > 0 || resending}
              onClick={handleResend}
              className={`
                w-full py-3 rounded-xl font-medium
                border-2 transition-all duration-200
                flex items-center justify-center gap-2
                ${
                  timer > 0 || resending
                    ? "border-gray-300 dark:border-neutral-700 text-gray-400 dark:text-gray-600 cursor-not-allowed"
                    : "border-blue-600 dark:border-blue-500 text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-950/30"
                }
              `}
            >
              <RefreshCw size={16} className={resending ? "animate-spin" : ""} />
              {resending ? "Sending..." : "Resend"}
            </button>

            {/* Help text */}
            <p className="text-center text-xs text-gray-500 dark:text-gray-400 mt-6">
              OTP code is valid for 2 minutes
            </p>

          </div>
        </div>

        {/* Security Badge */}
        <div className="mt-6 text-center">
          <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center justify-center gap-2">
            <ShieldCheck size={14} />
            The connection is secured by end-to-end encryption.
          </p>
        </div>

      </div>
    </div>
  );
}
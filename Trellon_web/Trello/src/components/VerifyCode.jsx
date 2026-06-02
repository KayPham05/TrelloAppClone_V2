//Không thay đổi dòng, code, chỉ thay đổi nội dung của toast, UI từ tiếng Việt sang tiếng Anh
import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import {
  verificodeAPI,
  resendCodeAPI,
  getVerificationStatusAPI,
} from "../services/UserAPI";
import { Mail, Clock, ArrowLeft, Shield } from "lucide-react";

export default function VerifyCode() {
  const location = useLocation();
  const navigate = useNavigate();
  const email = location.state?.email;

  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);
  const [timeLeft, setTimeLeft] = useState(300);
  const [canResend, setCanResend] = useState(false);

  useEffect(() => {
    if (!email) navigate("/register");
  }, [email, navigate]);

  useEffect(() => {
    let timerId;

    const syncTimer = async () => {
      try {
        const res = await getVerificationStatusAPI(email);
        const { verified, remainingSeconds } = res;

        if (verified) {
          toast.success("Your account has been verified!");
          navigate("/");
          return;
        }

        const initialTime = Math.max(0, remainingSeconds || 0);
        setTimeLeft(initialTime);

        if (initialTime <= 0) {
          setCanResend(true);
          return;
        }

        timerId = setInterval(() => {
          setTimeLeft((prev) => {
            if (prev <= 1) {
              clearInterval(timerId);
              setCanResend(true);
              return 0;
            }
            return prev - 1;
          });
        }, 1000);
      } catch (err) {
        console.error("Sync verify timer error:", err);
      }
    };

    syncTimer();
    return () => clearInterval(timerId);
  }, [email, navigate]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs
      .toString()
      .padStart(2, "0")}`;
  };

  const handleVerify = async () => {
    if (!code.trim()) {
      toast.error("Please enter the verification code!");
      return;
    }

    try {
      setLoading(true);
      const res = await verificodeAPI(email, code);
      toast.success(res.data || "Verification successful!");
      navigate("/");
    } catch (err) {
      console.error("Verify error:", err);
      toast.error(
        err.response?.data || "Invalid or expired verification code!"
      );
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (!canResend && timeLeft > 0) {
      toast.warning(`Please wait ${formatTime(timeLeft)} before resending!`);
      return;
    }

    try {
      setResending(true);
      const res = await resendCodeAPI(email);
      toast.success(res.data || "A new verification code has been sent!");
      setTimeLeft(300);
      setCanResend(false);

      const newTimer = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            clearInterval(newTimer);
            setCanResend(true);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } catch (err) {
      console.error("Resend error:", err);
      toast.error(err.response?.data || "Unable to resend the code!");
    } finally {
      setResending(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        <button
          onClick={() => navigate("/")}
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6 transition-colors group"
        >
          <ArrowLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
          <span>Back to Home</span>
        </button>

        <div className="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
          <div className="flex flex-col items-center mb-6">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mb-4">
              <Shield className="w-8 h-8 text-blue-600" />
            </div>
            <h2 className="text-3xl font-bold text-gray-900 mb-2">
              Verify Your Account
            </h2>
            <p className="text-gray-500 text-center">
              Enter the 6-digit code sent to your email
            </p>
          </div>

          <div className="bg-blue-50 rounded-lg p-4 mb-6 flex items-center gap-3">
            <Mail className="w-5 h-5 text-blue-600 flex-shrink-0" />
            <div className="flex-1 min-w-0">
              <p className="text-sm text-gray-600 mb-1">Code sent to:</p>
              <p className="text-blue-700 font-semibold truncate">{email}</p>
            </div>
          </div>

          <div className="mb-6">
            <input
              type="text"
              inputMode="numeric"
              placeholder="000000"
              value={code}
              onChange={(e) =>
                setCode(e.target.value.replace(/\D/g, "").slice(0, 6))
              }
              onKeyPress={(e) =>
                e.key === "Enter" && code.length === 6 && handleVerify()
              }
              maxLength={6}
              className="w-full px-4 py-4 border-2 border-gray-200 rounded-xl text-center text-2xl font-bold tracking-[0.5em] focus:border-blue-500 focus:outline-none transition-colors"
            />
            <p className="text-xs text-gray-500 text-center mt-2">
              {code.length}/6 digits
            </p>
          </div>

          <div className="bg-gradient-to-r from-orange-50 to-red-50 rounded-lg p-4 mb-6 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Clock className="w-5 h-5 text-orange-600" />
              <span className="text-sm text-gray-700">Code expires in:</span>
            </div>
            <div
              className={`font-mono text-xl font-bold ${
                timeLeft <= 60 ? "text-red-600" : "text-orange-600"
              }`}
            >
              {formatTime(timeLeft)}
            </div>
          </div>

          <button
            onClick={handleVerify}
            disabled={loading || code.length !== 6}
            className={`w-full py-4 rounded-xl text-white font-semibold text-lg transition-all transform ${
              loading || code.length !== 6
                ? "bg-gray-300 cursor-not-allowed"
                : "bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 hover:shadow-lg active:scale-95"
            }`}
          >
            {loading ? (
              <span className="flex items-center justify-center gap-2">
                <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                Verifying...
              </span>
            ) : (
              "Verify Now"
            )}
          </button>

          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-4 bg-white text-gray-500">
                Didn’t receive the code?
              </span>
            </div>
          </div>

          <button
            onClick={handleResend}
            disabled={resending || (!canResend && timeLeft > 0)}
            className={`w-full py-3 rounded-xl font-medium transition-all ${
              resending || (!canResend && timeLeft > 0)
                ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                : "bg-gray-50 hover:bg-gray-100 text-blue-600 hover:text-blue-700 border-2 border-gray-200 hover:border-blue-300"
            }`}
          >
            {resending ? (
              <span className="flex items-center justify-center gap-2">
                <span className="w-4 h-4 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></span>
                Sending...
              </span>
            ) : canResend || timeLeft <= 0 ? (
              "Resend Verification Code"
            ) : (
              `Resend in ${formatTime(timeLeft)}`
            )}
          </button>

          <p className="text-xs text-gray-500 text-center mt-6">
            If you don’t see the email, please check your spam or junk folder.
          </p>
        </div>
      </div>
    </div>
  );
}

import React, { useState, useEffect } from "react";
import { toggleTwoFactorAPI } from "../services/UserAPI";
import { send2FAOtpAPI, verify2FASetupAPI } from "../services/LoginAPI";
import { toast } from "react-toastify";

export default function TwoFactorSection({ currentUser }) {
  const [enabled, setEnabled] = useState(currentUser?.isTwoFactorEnabled);
  const [otp, setOtp] = useState("");
  const [showOtp, setShowOtp] = useState(false);
  const [timer, setTimer] = useState(0);
  const [loading, setLoading] = useState(false);
  const [pendingEnable, setPendingEnable] = useState(false);

  useEffect(() => {
    let interval;
    if (timer > 0) {
      interval = setInterval(() => setTimer((t) => t - 1), 1000);
    }
    return () => clearInterval(interval);
  }, [timer]);

  const formatTime = (sec) => `${Math.floor(sec / 60)}:${String(sec % 60).padStart(2, "0")}`;

  const handleToggle = async () => {
    setLoading(true);
    try {
      const newState = !enabled;

      if (newState) {
        toast.info("Sending OTP...");
        await send2FAOtpAPI(currentUser.email);
        
        setPendingEnable(true);
        setTimer(120);
        setShowOtp(true);
        toast.success("OTP code is sent to your email!");
      } else {
        await toggleTwoFactorAPI(currentUser.userUId, false);
        setEnabled(false);
        toast.info("2FA is turned off");
        
        const user = JSON.parse(localStorage.getItem("user") || "{}");
        user.isTwoFactorEnabled = false;
        localStorage.setItem("user", JSON.stringify(user));
      }
    } catch (error) {
      console.error("Toggle 2FA error:", error);
      toast.error("ERROR!");
    } finally {
      setLoading(false);
    }
  };

  const resendOtp = async () => {
    try {
      await send2FAOtpAPI(currentUser.email);
      toast.success("OPT Code is resent!");
      setTimer(120);
    } catch (error) {
      toast.error("Can't send OTP code!");
    }
  };

  const handleVerify = async () => {
    if (!otp || otp.length !== 6) {
      toast.error("Please enter a 6 digit code!");
      return;
    }

    try {
      setLoading(true);
      
      console.log("Verifying 2FA setup for email:", currentUser.email);
      const res = await verify2FASetupAPI(currentUser.email, otp);

      console.log("Verify response:", res);

      if (res?.isTwoFactorEnabled || res?.message?.includes("thành công")) {
        await toggleTwoFactorAPI(currentUser.userUId, true);
        
        setEnabled(true);
        setPendingEnable(false);
        setShowOtp(false);
        setOtp("");
        
        toast.success("Verify successful — 2FA is activated!");

        const user = JSON.parse(localStorage.getItem("user") || "{}");
        user.isTwoFactorEnabled = true;
        localStorage.setItem("user", JSON.stringify(user));

        window.dispatchEvent(new CustomEvent("user:updated", { 
          detail: { ...user, isTwoFactorEnabled: true } 
        }));
      } else {
        toast.error("Wrong or expired OTP code!");
      }
    } catch (error) {
      console.error("Verify OTP error:", error);
      toast.error(error.response?.data?.message || "Wrong or expired OTP code!");
    } finally {
      setLoading(false);
    }
  };

  const handleCancelOtp = () => {
    setShowOtp(false);
    setPendingEnable(false);
    setOtp("");
    setTimer(0);
    toast.info("2FA Verification is deactivated");
  };

  return (
    <div className="h-full flex flex-col dark:text-[#E8EAED] px-8 pt-8 space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold">Two-Factor Authentication</h1>
        <p className="text-sm text-gray-600 dark:text-[#9AA0A6] mt-1">
          Protect your account by OTP code every you log-in !
        </p>
      </div>

      <div className="flex items-center gap-4">
        <button
          onClick={handleToggle}
          disabled={loading || pendingEnable}
          className={[
            "px-4 py-2 rounded-lg text-white transition w-fit",
            enabled ? "bg-red-600 hover:bg-red-700" : "bg-blue-600 hover:bg-blue-700",
            (loading || pendingEnable) ? "opacity-50 cursor-not-allowed" : ""
          ].join(" ")}
        >
          {enabled ? "Disable 2FA" : "Enable 2FA"}
        </button>

        {pendingEnable && (
          <span className="text-sm text-yellow-600 dark:text-yellow-400">
            ⏳ Verifying OTP code...
          </span>
        )}
      </div>

      {showOtp && (
        <div className="mt-4 p-5 border rounded-xl bg-white dark:bg-[#2B2D31] dark:border-[#3F4147] shadow-sm max-w-md">
          <h3 className="text-lg font-semibold mb-3">Enter OTP code to verify 2FA</h3>

          <input
            type="text"
            maxLength={6}
            value={otp}
            onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
            className="border rounded-lg px-3 py-2 w-40 tracking-widest font-mono text-xl
                       dark:bg-[#1E1F22] dark:border-[#3F4147] dark:text-[#E8EAED]"
            placeholder="••••••"
            disabled={loading}
          />

          <div className="mt-3 text-sm text-gray-600 dark:text-[#9AA0A6]">
            {timer > 0 ? (
              <>Expired after: <b>{formatTime(timer)}</b></>
            ) : (
              <span className="text-red-500">OTP code is expired!</span>
            )}
          </div>

          <div className="mt-4 flex gap-3">
            <button
              onClick={handleVerify}
              disabled={loading || !otp || otp.length !== 6}
              className={[
                "px-4 py-2 rounded-lg text-white transition",
                (!loading && otp.length === 6) 
                  ? "bg-blue-600 hover:bg-blue-700" 
                  : "bg-gray-400 cursor-not-allowed"
              ].join(" ")}
            >
              {loading ? "Verifying..." : "Verified"}
            </button>

            <button
              disabled={timer > 0 || loading}
              onClick={resendOtp}
              className={[
                "px-4 py-2 rounded-lg border",
                (timer > 0 || loading)
                  ? "border-gray-400 text-gray-400 cursor-not-allowed"
                  : "border-blue-600 text-blue-600 hover:bg-blue-50 dark:hover:bg-[#3A3C42]"
              ].join(" ")}
            >
              Resend code
            </button>

            <button
              onClick={handleCancelOtp}
              disabled={loading}
              className="px-4 py-2 rounded-lg border border-gray-400 text-gray-600 hover:bg-gray-50 dark:hover:bg-[#3A3C42]"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
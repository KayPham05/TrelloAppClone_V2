import React from "react";
import { useNavigate } from "react-router-dom";
import { Bell, Search, UserCircle, Grid3x3, Plus } from "lucide-react";
import Profile from "./AccountMenu";
import PersonalSettings from "./PersonalSetting";
import Notification from "../components/Notification.jsx";

export default function Header({ className = "" }) {
  const [isProfileOpen, setIsProfileOpen] = React.useState(false);
  const [settingsOpen, setSettingsOpen] = React.useState(false);
  const profileWrapRef = React.useRef(null);
  const navigate = useNavigate();

  React.useEffect(() => {
    const onDocPointer = (e) => {
      // 1) Náº¿u click náº±m trong báº¥t ká»³ node cÃ³ data-profile-keepopen thÃ¬ bá» qua
      const path = (e.composedPath && e.composedPath()) || [];
      if (
        path.some(
          (el) => el && el.dataset && el.dataset.profileKeepopen !== undefined
        )
      ) {
        return;
      }

      // 2) Náº¿u click khÃ´ng náº±m trong wrap cá»§a profile thÃ¬ má»›i Ä‘Ã³ng
      if (!profileWrapRef.current) return;
      if (!profileWrapRef.current.contains(e.target)) {
        setIsProfileOpen(false);
      }
    };

    const onKey = (e) => {
      if (e.key === "Escape") setIsProfileOpen(false);
    };

    // dÃ¹ng pointerdown á»•n hÆ¡n mousedown/click cho case menu
    document.addEventListener("pointerdown", onDocPointer);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("pointerdown", onDocPointer);
      document.removeEventListener("keydown", onKey);
    };
  }, []);

  const user = React.useMemo(() => {
    try {
      return JSON.parse(localStorage.getItem("user") || "null");
    } catch {
      return null;
    }
  }, []);

  return (
    <>
      <header
        className={`flex items-center justify-between px-6 h-16 border-b shadow-sm
        bg-white text-gray-800
        dark:bg-[#1E1F22] dark:border-[#2B2C2F] dark:text-gray-200
        backdrop-blur-sm ${className}`}
      >
        {/* LEFT: LOGO */}
        <div
          onClick={() => navigate(`/home/${user?.userUId}`)}
          className="flex items-center gap-3 cursor-pointer select-none group"
        >
          <div
            className="
            w-9 h-9 rounded-xl flex items-center justify-center
            bg-gradient-to-br from-indigo-500 to-purple-600
            shadow-[0_2px_8px_rgba(0,0,0,0.25)]
            dark:shadow-[0_2px_8px_rgba(0,0,0,0.45)]
            group-hover:scale-110 transition-transform
          "
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
              <rect x="3" y="3" width="8" height="18" rx="2" opacity="0.9" />
              <rect x="13" y="3" width="8" height="10" rx="2" opacity="0.9" />
            </svg>
          </div>

          <span
            className="
            text-2xl font-extrabold tracking-wide
            bg-gradient-to-r from-blue-400 via-blue-400 to-red-400
            bg-clip-text text-transparent
            group-hover:tracking-wider transition-all select-none
          "
          >
            Kabo
          </span>
        </div>

        {/* RIGHT SIDE */}
        <div className="flex items-center gap-4">
          {/* SEARCH BAR */}
          <div
            className="
            flex items-center rounded-lg px-4 py-2 w-96
            bg-gray-100 text-[#1E1F22] hover:bg-gray-200 transition
            dark:bg-[#2A2B2E] dark:hover:bg-[#333437]
          "
          >
            <Search className="text-[#1E1F22] dark:text-gray-300" size={18} />
            <input
              type="text"
              placeholder="Search Boards, Members..."
              className="
              bg-transparent border-none outline-none text-sm w-full px-3
              text-[#1E1F22] dark:text-gray-200
              placeholder:text-[#1E1F22] dark:placeholder:text-white
            "
            />
          </div>

          {/* CREATE BUTTON */}
          <button
            className="
            flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium
            bg-blue-600 hover:bg-blue-700 text-white
            shadow-sm dark:shadow-[0_1px_4px_rgba(0,0,0,0.45)]
            transition
          "
          >
            <Plus size={16} />
            Create New
          </button>

          {/* PROFILE AREA */}
          <div className="flex items-center gap-3" ref={profileWrapRef}>
            {/* Notification */}
            <Notification />

            {/* Avatar */}
            <button
              aria-haspopup="menu"
              aria-expanded={isProfileOpen}
              onClick={() => setIsProfileOpen((v) => !v)}
              className="
              p-2 rounded-lg transition
              hover:bg-gray-100 dark:hover:bg-[#333437]
            "
            >
              <UserCircle
                className="text-gray-600 dark:text-gray-300"
                size={28}
              />
            </button>

            {/* Dropdown Profile */}
            <Profile
              open={isProfileOpen}
              onClose={() => setIsProfileOpen(false)}
              onOpenSettings={() => {
                setSettingsOpen(true);
                setIsProfileOpen(false);
              }}
            />
          </div>
        </div>
      </header>

      <PersonalSettings
        open={settingsOpen}
        initialTab="profile"
        onClose={() => setSettingsOpen(false)}
        currentUser={{
          userName: user?.userName ?? "",
          email: user?.email ?? "",
          bio: user?.bio ?? "",
        }}
        onSaveProfile={async (payload) => {
          console.log("SAVE PROFILE", payload);
        }}
      />
    </>
  );
}

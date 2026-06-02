import React, { useState, useEffect, useRef, useLayoutEffect } from "react";
import { ChevronRight, ExternalLink} from "lucide-react";
import { createPortal } from "react-dom";
import { applyTheme, getInitialTheme } from "../components/Theme.ts";
import {
  getUsernameByUserUIdAPI,
  getBioByUserUIdAPI,
} from "../services/UserAPI.jsx";
import { logoutAPI } from "../services/LoginAPI.jsx";

export default function AccountMenu({ open, onClose, onOpenSettings }) {
  if (!open) return null;

  const [user, setUser] = useState(null);
  const [themeOpen, setThemeOpen] = useState(false);
  const themeRef = useRef(null);

  useEffect(() => {
    if (!open) return;
    let cancel = false;

    (async () => {
      const auth = JSON.parse(localStorage.getItem("user") || "{}");
      if (!auth?.userUId) {
        setUser(null);
        return;
      }
      const [uRes, bRes] = await Promise.all([
        getUsernameByUserUIdAPI(auth.userUId),
        getBioByUserUIdAPI(auth.userUId),
      ]);

      const userName =
        typeof uRes === "string"
          ? uRes
          : uRes?.userName ?? uRes?.username ?? "";

      const bio = typeof bRes === "string" ? bRes : bRes?.bio ?? "";

      const next = {
        userUId: auth.userUId,
        email: auth.email || "",
        userName,
        bio,
      };

      if (!cancel) setUser(next);
    })();

    const h = (e) => setUser(e.detail);
    window.addEventListener("user:updated", h);

    return () => {
      cancel = true;
      window.removeEventListener("user:updated", h);
    };
  }, [open]);

  const initials = user?.userName
    ?.split(" ")
    ?.map((n) => n[0])
    ?.join("")
    ?.toUpperCase();

  const handleLogout = async () => {
    try {
      await logoutAPI(user?.userUId);
    } catch (err) {
      console.error("Logout failed:", err);
    } finally {
      localStorage.removeItem("token");
      localStorage.removeItem("user");
      window.location.href = "/";
    }
  };

  return (
    <div
      role="menu"
      aria-label="Account menu"
      className={[
        "absolute right-0 top-full mt-2 w-72 rounded-xl border shadow-xl z-50",
        "bg-white text-gray-900 border-gray-200",
        "dark:bg-[#1E1F22] dark:text-[#E8EAED] dark:border-[#3F4147]",
      ].join(" ")}
    >
      <SectionTitle>
        <span className="text-gray-700 dark:text-[#E8EAED]">Account</span>
      </SectionTitle>

      <div className="p-3 flex items-center gap-3">
        <div
          className="
            w-10 h-10 rounded-full grid place-items-center font-bold
            bg-amber-400 text-gray-900
            dark:bg-amber-300 dark:text-gray-900
            ring-1 ring-amber-300/70 dark:ring-amber-200/50
          "
        >
          {initials}
        </div>

        <div className="min-w-0">
          <div className="font-semibold truncate dark:text-[#E8EAED]">
            {user?.userName}
          </div>
          <div className="text-xs text-gray-500 dark:text-[#9AA0A6] truncate">
            {user?.email}
          </div>
        </div>
      </div>

      <ul className="py-1">
        <MenuItem text="Switch Account" onClick={onClose} />
        <MenuItem
          text={
            <span className="inline-flex items-center gap-2">
              Manage account{" "}
              <ExternalLink
                size={14}
                className="opacity-70 text-gray-600 dark:text-[#E8EAED]"
              />
            </span>
          }
          onClick={onClose}
        />
      </ul>

      <Divider />

      <SectionTitle>Settings</SectionTitle>

      <ul className="py-1">
        <MenuItem
          text="Profile and visibility"
          keepOpen
          onClick={() => onOpenSettings?.("profile")}
        />
        <MenuItem
          text="Activity"
          keepOpen
          onClick={() => onOpenSettings?.("activity")}
        />
        <MenuItem
          text="Cards"
          keepOpen
          onClick={() => onOpenSettings?.("cards")}
        />
        <MenuItem
          text="Settings"
          keepOpen
          onClick={() => onOpenSettings?.("settings")}
        />

        {/* THEME */}
        <li
          ref={themeRef}
          role="menuitem"
          tabIndex={0}
          aria-haspopup="menu"
          aria-expanded={themeOpen}
          className={[
            "px-3 py-2 cursor-pointer outline-none text-sm flex items-center justify-between",
            "hover:bg-gray-100 focus:bg-gray-100",
            "dark:hover:bg-[#3A3C42] dark:focus:bg-[#3A3C42]",
            "dark:text-[#E8EAED]",
          ].join(" ")}
          onClick={() => setThemeOpen((v) => !v)}
        >
          <span>Theme</span>
          <ChevronRight size={16} className="text-gray-500 dark:text-[#E8EAED]" />
        </li>
      </ul>

      <Divider>
        <ul className="py-1">
          <MenuItem text="Create Workspace" onClick={onClose} />
        </ul>
      </Divider>

      <ul className="py-1">
        <MenuItem text="Help" onClick={onClose} />
        <MenuItem text="Shortcuts" onClick={onClose} />
      </ul>

      <Divider />

      <ul className="py-1">
        <MenuItem
          text="Log out"
          onClick={() => {
            onClose();
            handleLogout();
          }}
        />
      </ul>

      <ThemeSubmenu
        anchorEl={themeRef.current}
        open={themeOpen}
        onClose={() => setThemeOpen(false)}
      />
    </div>
  );
}

/* ====================================================== */

function MenuItem({ icon, text, onClick, keepOpen = false }) {
  return (
    <li>
      <button
        role="menuitem"
        onPointerDown={(e) => {
          if (keepOpen) e.currentTarget.dataset.profileKeepopen = "";
        }}
        onClick={onClick}
        className="
          w-full flex items-center gap-2 px-4 py-2 text-left
          hover:bg-gray-50 
          dark:hover:bg-[#3A3C42]
          dark:text-[#E8EAED]
        "
      >
        {icon}
        <span className="text-sm">{text}</span>
      </button>
    </li>
  );
}

function SectionTitle({ children }) {
  return (
    <div
      className="
        w-full flex items-center gap-2 px-4 py-2 text-sm
        text-gray-700
        dark:text-[#B5BAC1]
      "
    >
      {children}
    </div>
  );
}

function Divider({ children }) {
  return (
    <div className="my-2">
      <div className="h-px bg-gray-200 dark:bg-[#3F4147]" />
      {children}
      {children && (
        <div className="h-px bg-gray-200 dark:bg-[#3F4147] mt-2" />
      )}
    </div>
  );
}

/* =================== Theme Submenu =================== */

function ThemeSubmenu({ anchorEl, open, onClose, onEnter, onLeave }) {
  const menuRef = useRef(null);
  const [style, setStyle] = useState({
    top: 0,
    left: 0,
    position: "fixed",
    zIndex: 9999,
    opacity: 0,
  });
  const [theme, setTheme] = useState(getInitialTheme());

  useEffect(() => {
    applyTheme(theme);
    localStorage.setItem("theme", theme);
  }, [theme]);

  useLayoutEffect(() => {
    if (!open || !anchorEl || !menuRef.current) return;

    const GAP = 2;
    const anchorRect = anchorEl.getBoundingClientRect();
    const menuRect = menuRef.current.getBoundingClientRect();

    let top = anchorRect.top;
    let left = anchorRect.left - GAP - menuRect.width;

    if (left < 8) left = anchorRect.right + GAP;

    const maxTop = Math.max(8, window.innerHeight - menuRect.height - 8);
    top = Math.min(Math.max(8, top), maxTop);

    setStyle({ position: "fixed", top, left, zIndex: 9999, opacity: 1 });
  }, [open, anchorEl]);

  const selectTheme = (v) => {
    setTheme(v);
    onClose?.();
  };

  if (!open) return null;

  const node = (
    <div
      data-profile-keepopen
      ref={menuRef}
      style={style}
      role="menu"
      aria-label="Theme submenu"
      className="
        w-64 rounded-xl border shadow-xl overflow-hidden
        bg-white text-gray-900 border-gray-200
        dark:bg-[#1E1F22] dark:border-[#3F4147] dark:text-[#E8EAED]
      "
      onMouseEnter={onEnter}
      onMouseLeave={onLeave}
    >
      <ul className="py-1">
        <ThemeOption
          value="light"
          label="Light"
          selected={theme === "light"}
          onSelect={selectTheme}
          Preview={ThemePreviewLight}
        />
        <ThemeOption
          value="dark"
          label="Dark"
          selected={theme === "dark"}
          onSelect={selectTheme}
          Preview={ThemePreviewDark}
        />
        <ThemeOption
          value="system"
          label="Match system"
          selected={theme === "system"}
          onSelect={selectTheme}
          Preview={ThemePreviewSystem}
        />
      </ul>
    </div>
  );

  return createPortal(node, document.body);
}

/* =================== Previews =================== */

function ThemePreviewLight() {
  return (
    <div className="w-9 h-6 rounded-md border bg-white grid grid-cols-4 gap-0.5 p-0.5 border-gray-200 dark:border-[#3F4147]">
      <div className="bg-gray-200 rounded-sm col-span-1 dark:bg-[#3A3C42]" />
      <div className="bg-gray-100 rounded-sm col-span-3 dark:bg-[#2B2D31]" />
    </div>
  );
}

function ThemePreviewDark() {
  return (
    <div className="w-9 h-6 rounded-md border bg-gray-900 grid grid-cols-4 gap-0.5 p-0.5 border-[#3F4147] dark:border-[#3F4147]">
      <div className="bg-gray-700 rounded-sm col-span-1" />
      <div className="bg-gray-800 rounded-sm col-span-3" />
    </div>
  );
}

function ThemePreviewSystem() {
  return (
    <div className="relative w-9 h-6 rounded-md border overflow-hidden border-gray-200 dark:border-[#3F4147]">
      <div className="absolute inset-0 bg-white grid grid-cols-4 gap-0.5 p-0.5 dark:bg-[#1E1F22]">
        <div className="bg-gray-200 rounded-sm col-span-1 dark:bg-[#3A3C42]" />
        <div className="bg-gray-100 rounded-sm col-span-3 dark:bg-[#2B2D31]" />
      </div>
      <div className="absolute inset-0 translate-x-1/3 rotate-[-25deg] origin-bottom-left w-1/2 bg-gray-900" />
    </div>
  );
}

/* =================== Single Option =================== */

function ThemeOption({ value, label, selected, onSelect, Preview }) {
  return (
    <li>
      <button
        role="menuitemradio"
        aria-checked={selected}
        onClick={() => onSelect(value)}
        className={[
          "w-full flex items-center gap-3 px-3 py-2 text-left outline-none",
          "hover:bg-gray-50 dark:hover:bg-[#3A3C42]",
          selected
            ? "bg-blue-50 ring-1 ring-inset ring-blue-400 dark:bg-blue-950/30 dark:ring-[#8AB4F8]/60"
            : "",
        ].join(" ")}
      >
        <span
          className={[
            "inline-block w-4 h-4 rounded-full border grid place-items-center",
            selected
              ? "border-blue-500 dark:border-[#8AB4F8]"
              : "border-gray-300 dark:border-[#5A5A5A]",
          ].join(" ")}
          aria-hidden
        >
          <span
            className={[
              "w-2 h-2 rounded-full",
              selected ? "bg-blue-600 dark:bg-[#8AB4F8]" : "bg-transparent",
            ].join(" ")}
          />
        </span>

        <div className="shrink-0">
          <Preview />
        </div>

        <span className="text-sm text-gray-800 dark:text-[#E8EAED]">
          {label}
        </span>
      </button>
    </li>
  );
}

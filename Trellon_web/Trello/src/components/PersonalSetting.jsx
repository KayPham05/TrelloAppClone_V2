// src/components/settings/PersonalSettings.jsx
import React, { useCallback, useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { X } from "lucide-react";
import SettingsSidebar from "./SettingsSidebar.jsx";
import SettingsContent from "./SettingsContent.jsx";
import ActivityContent from "./ActivityContent.jsx";
import {
  getUsernameByUserUIdAPI,
  getBioByUserUIdAPI,
  addBioByUserUIdAPI,
  addUsernameByUserUIdAPI
} from "../services/UserAPI.jsx";

export default function PersonalSettings({
  open,
  initialTab = "profile",
  onClose
}) {
  const [tab, setTab] = useState(initialTab);
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const panelRef = useRef(null);

  // mỗi lần mở, reset tab
  useEffect(() => { if (open) setTab(initialTab); }, [open, initialTab]);

  // ESC đóng
  useEffect(() => {
    if (!open) return;
    const onKey = (e) => { if (e.key === "Escape") onClose?.(); };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  // LẤY userUId/email TỪ localStorage (CHỈ ĐỌC)
  const getAuthUser = useCallback(() => {
    try {
      const u = JSON.parse(localStorage.getItem("user") || "{}");
      return { userUId: u?.userUId, email: u?.email || "" };
    } catch { return { userUId: undefined, email: "" }; }
  }, []);

  // FETCH DB: username + bio
  const fetchProfile = useCallback(async () => {
    const { userUId, email } = getAuthUser();
    if (!userUId) return;

    setLoading(true);
    try {
      const [uRes, bRes] = await Promise.all([
        getUsernameByUserUIdAPI(userUId),
        getBioByUserUIdAPI(userUId)
      ]);
      const userName = typeof uRes === "string"
        ? uRes
        : (uRes?.userName ?? uRes?.username ?? "");
      const bio = typeof bRes === "string"
        ? bRes
        : (bRes?.bio ?? "");

     const profile = { userUId, email, userName, bio };
      setCurrentUser(profile);
      return profile;
    } catch (e) {
      console.error("Load profile failed:", e);
      return null;
    } finally {
      setLoading(false);
    }
  }, [getAuthUser]);

  // mở modal => fetch DB
  useEffect(() => {
    if (!open) return;
    fetchProfile();
  }, [open, fetchProfile]);

  // SAVE -> gọi API -> refetch từ DB (không đụng localStorage)
  const handleSaveProfile = useCallback(async (form) => {
    const { userUId } = getAuthUser();
    if (!userUId) {
      console.warn("Missing userUId -> Can't save.");
      return;
    }
    setLoading(true);
    try {
      await Promise.all([
        addUsernameByUserUIdAPI(userUId, form.userName),
        addBioByUserUIdAPI(userUId, form.bio)
      ]);
      const latest = await fetchProfile();        // DB là nguồn sự thật
      if (latest) {
        // phát tín hiệu để nơi khác (AccountMenu, Header...) tự cập nhật
        window.dispatchEvent(new CustomEvent("user:updated", { detail: latest }));
      }
    } catch (e) {
      console.error("Save profile failed:", e);
    } finally {
      setLoading(false);
    }
  }, [getAuthUser, fetchProfile]);

  if (!open) return null;

  return createPortal(
    <div className="fixed inset-0 z-[100]">
      {/* backdrop */}
      <div
        className="absolute inset-0 bg-black/40 backdrop-blur-[1px]"
        onClick={onClose}
      />
      {/* panel */}
      <div className="relative h-full w-full flex justify-center items-start p-4 md:p-6">
        <div
          ref={panelRef}
          role="dialog"
          aria-modal="true"
          className="
            relative w-full max-w-[1280px]
            h-[calc(100vh-2rem)] md:h-[calc(100vh-3rem)]
            bg-white dark:bg-neutral-900 text-gray-900 dark:text-gray-100
            rounded-2xl shadow-2xl overflow-hidden
            grid grid-cols-12
            border border-gray-200 dark:border-neutral-800
          "
          onClick={(e) => e.stopPropagation()} // NGĂN click xuyên panel
        >
          <aside className="col-span-12 md:col-span-3 lg:col-span-3 h-full">
            <SettingsSidebar tab={tab} onChange={setTab} />
          </aside>

          <section className="col-span-12 md:col-span-9 lg:col-span-9 h-full overflow-hidden">
            <SettingsContent
              tab={tab}
              currentUser={currentUser}
              onSaveProfile={handleSaveProfile}
              loading={loading}
            />
          </section>

          <button
            type="button"
            onClick={onClose}
            aria-label="Close"
            className="absolute right-3 top-3 p-2 rounded-full hover:bg-gray-100 dark:hover:bg-neutral-800"
          >
            <X size={18} className ="dark:!text-gray-300" />
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
}

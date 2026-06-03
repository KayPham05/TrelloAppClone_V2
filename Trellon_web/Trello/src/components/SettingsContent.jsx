// SettingsContent.jsx
import React, { useMemo, useState, useEffect } from "react";
import ActivityContent from "./ActivityContent.jsx";
import TwoFactorSection from "./TwoFactorSection.jsx";

export default function SettingsContent({ tab, currentUser, onSaveProfile, loading }) {
  if (tab === "profile")
    return <ProfileVisibility currentUser={currentUser} onSave={onSaveProfile} loading={loading} />;
  if (tab === "settings") return <Placeholder title="Settings" />;
  if (tab === "activity")
    return <ActivityContent currentUser={currentUser} />; 
  if (tab === "twofactor")
    return <TwoFactorSection currentUser={currentUser} />;
  if (tab === "cards")    return <Placeholder title="Cards" />;
  if (tab === "theme")    return <Placeholder title="Theme" />;
  return null;
}

function Placeholder({ title }) {
  return (
    <div className="h-full flex flex-col dark:text-[#E8EAED]">
      <Header title={title} subtitle="Developing..." />

      <div className="px-8 pb-8 overflow-auto">
        <div className="text-sm text-gray-600 dark:text-[#9AA0A6]">
          Layout border is ready
        </div>
      </div>

      <SaveBar disabled />
    </div>
  );
}


/* ================= Profile & Visibility ================= */

function ProfileVisibility({ currentUser, onSave, loading }) {
  const init = useMemo(() => ({
    userName: currentUser?.userName || "",
    email: currentUser?.email || "",
    bio: currentUser?.bio || "",
    visibility: { userName: "public", email: "private", bio: "public" }
  }), [currentUser?.userName, currentUser?.email, currentUser?.bio]);

  const [form, setForm] = useState(init);
  useEffect(() => { setForm(init); }, [init]);

  const [saving, setSaving] = useState(false);
  const dirty = JSON.stringify(form) !== JSON.stringify(init);

  const onField = (k, v) => setForm(s => ({ ...s, [k]: v }));
  const onVis   = (k, v) => setForm(s => ({ ...s, visibility: { ...s.visibility, [k]: v }}));

  const handleSave = async () => {
    if (!dirty || saving) return;
    setSaving(true);
    try { await onSave?.(form); }
    finally { setSaving(false); }
  };

  return (
    <div className="h-full flex flex-col dark:text-[#E8EAED]">
      <Header
        title="Profile and Visibility"
        subtitle="Personal information and visibility management"
      />

      <div className="px-8 pb-28 overflow-auto space-y-6">

        <div className="rounded-xl border border-gray-200 dark:border-[#3F4147] overflow-hidden">
          <div className="bg-gray-50 dark:bg-[#1E1F22] px-5 py-4">
            <h3 className="font-semibold dark:text-[#E8EAED] dark:font-bold">
              Manage your personal information
            </h3>
            <p className="text-sm text-gray-600 dark:text-[#9AA0A6]">
              Trellone Account Management. You may modify your information below.
            </p>
          </div>

          <div className="p-5 grid grid-cols-1 md:grid-cols-2 gap-6">
            
            {/* Username */}
            <Field label="Username">
              <input
                className="mt-1 w-full rounded-lg border px-3 py-2
                  border-gray-300 dark:border-[#3F4147]
                  bg-white dark:bg-[#2B2D31]
                  text-gray-800 dark:text-[#E8EAED]
                  focus:outline-none focus:ring-2 focus:ring-blue-500/40"
                value={form.userName}
                onChange={e => onField("userName", e.target.value)}
                placeholder="Let's make a cool username!"
                disabled={loading || saving}
              />
              <VisPicker value={form.visibility.userName} onChange={v => onVis("userName", v)} />
            </Field>

            {/* Email */}
            <Field label="Email">
              <input
                className="mt-1 w-full rounded-lg border px-3 py-2
                  border-gray-300 dark:border-[#3F4147]
                  bg-gray-50 dark:bg-[#3A3C42]
                  text-gray-700 dark:text-[#E8EAED]"
                value={form.email}
                readOnly
              />
              <VisPicker value={form.visibility.email} onChange={v => onVis("email", v)} />
            </Field>

            {/* Bio */}
            <Field label="Bio" className="md:col-span-2">
              <textarea
                rows={6}
                className="mt-1 w-full rounded-lg border px-3 py-2
                  border-gray-300 dark:border-[#3F4147]
                  bg-white dark:bg-[#2B2D31]
                  text-gray-800 dark:text-[#E8EAED]
                  focus:outline-none focus:ring-2 focus:ring-blue-500/40"
                value={form.bio}
                onChange={e => onField("bio", e.target.value)}
                placeholder="Tell people a bit about you…"
                disabled={loading || saving}
              />
              <VisPicker value={form.visibility.bio} onChange={v => onVis("bio", v)} />
            </Field>
          </div>
        </div>
      </div>

      <SaveBar disabled={!dirty || saving || loading} saving={saving} onSave={handleSave} />
    </div>
  );
}


/* ================= Small Pieces ================= */

function Header({ title, subtitle }) {
  return (
    <div className="px-8 pt-8 pb-4">
      <h1 className="text-2xl font-extrabold tracking-tight dark:text-[#E8EAED]">
        {title}
      </h1>

      {subtitle && (
        <p className="text-sm text-gray-600 dark:text-[#9AA0A6] mt-1">
          {subtitle}
        </p>
      )}
    </div>
  );
}


function Field({ label, children, className = "" }) {
  return (
    <div className={className}>
      <label className="text-sm font-medium dark:text-[#E8EAED]">{label}</label>
      {children}
    </div>
  );
}


function VisPicker({ value, onChange }) {
  const Opt = ({ v, label }) => (
    <button
      type="button"
      onClick={() => onChange(v)}
      className={[
        "mt-2 text-xs px-2 py-1 rounded-md border transition",
        value === v
          ? "bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-950/30 dark:text-[#8AB4F8] dark:border-blue-900/60"
          : "text-gray-600 dark:text-[#B5BAC1] border-gray-300 dark:border-[#3F4147] hover:bg-gray-100 dark:hover:bg-[#3A3C42]"
      ].join(" ")}
    >
      {label}
    </button>
  );

  return (
    <div className="flex items-center gap-2">
      <span className="mt-2 text-xs text-gray-500 dark:text-[#9AA0A6]">Visibility:</span>
      <Opt v="public"  label="Public" />
      <Opt v="private" label="Private" />
    </div>
  );
}


function SaveBar({ disabled = true, saving = false, onSave }) {
  return (
    <div
      className="
        sticky bottom-0 w-full border-t
        border-gray-200 dark:border-[#3F4147]
        bg-white/85 dark:bg-[#2B2D31]/85 backdrop-blur
        px-8 py-3
      "
    >
      <button
        onClick={onSave}
        disabled={disabled}
        className={[
          "px-4 py-2 rounded-lg text-white transition",
          !disabled
            ? "bg-blue-600 hover:bg-blue-700"
            : "bg-gray-300 cursor-not-allowed dark:text-[#555]"
        ].join(" ")}
      >
        {saving ? "Saving…" : "Save"}
      </button>
    </div>
  );
}
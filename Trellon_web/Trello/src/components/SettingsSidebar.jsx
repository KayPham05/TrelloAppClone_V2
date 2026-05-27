// src/components/settings/SettingsSidebar.jsx
import React from "react";
import { UserCircle2, Cog, Activity, CreditCard, Palette, ShieldCheck } from "lucide-react";

const NAV = [
  { key: "profile",   label: "Profile and Visibility", icon: UserCircle2 },
  { key: "settings",  label: "Settings",               icon: Cog },
  { key: "activity",  label: "Activity",               icon: Activity },
  { key: "twofactor", label: "Two-Factor Authentication", icon: ShieldCheck },
  { key: "cards",     label: "Cards",                  icon: CreditCard },
  { key: "theme",     label: "Theme",                  icon: Palette },
];

export default function SettingsSidebar({ tab, onChange }) {
  return (
    <div
      className="
        h-full w-full md:w-[320px]
        border-r border-gray-200 dark:border-[#3F4147]
        bg-gray-50 dark:bg-[#2B2D31]
        flex flex-col
      "
    >
      {/* Header */}
      <div className="p-4 border-b dark:border-[#3F4147] bg-gray-50 dark:bg-[#1E1F22]">
        <h3 className="text-sm font-semibold text-gray-600 dark:text-[#E8EAED]">
          Personal Settings
        </h3>
      </div>

      {/* Navigation */}
      <nav className="px-2 space-y-1 overflow-auto">
        {NAV.map(item => {
          const Icon = item.icon;
          const active = tab === item.key;

          return (
            <button
              key={item.key}
              onClick={() => onChange(item.key)}
              className={[
                "w-full flex items-center gap-3 px-3 py-2 rounded-lg text-left transition",
                active
                  ? `
                    bg-blue-50 text-blue-700 ring-1 ring-inset ring-blue-200
                    dark:bg-[#1E1F22] dark:text-[#8AB4F8] dark:ring-[#4C8BF5]/40
                  `
                  : `
                    text-gray-700 dark:text-[#B5BAC1]
                    hover:bg-gray-100 dark:hover:bg-[#3A3C42]
                  `
              ].join(" ")}
            >
              <Icon
                size={18}
                className={
                  active
                    ? "text-inherit"
                    : "text-gray-500 dark:text-[#9AA0A6]"
                }
              />

              <span
                className={[
                  "text-sm truncate",
                  active ? "dark:text-[#8AB4F8]" : "dark:text-[#E8EAED]"
                ].join(" ")}
              >
                {item.label}
              </span>
            </button>
          );
        })}
      </nav>
    </div>
  );
}
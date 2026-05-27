import React from "react";
import Header from "../components/Header";
import { Outlet } from "react-router-dom";

export default function AppLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-[#1E1F22]">
      {/* 🔹 Header cố định */}
      <Header className="fixed top-0 left-0 right-0 z-50" />

      {/* 🔹 Phần nội dung chính */}
      <main className="overflow-hidden">
        <Outlet />
      </main>
    </div>
  );
}

import React, { useEffect, useState, useCallback } from "react";
import { useNavigate } from "react-router-dom"; 
import { toast } from "react-toastify";
import Sidebar from "../components/Sidebar";
import RightSidebar from "../components/RightSidebar";
import RecentBoardsSection from "../components/RecentBoardsSection";
import PersonalBoardSection from "../components/PersonalBoardSection";
import WorkspaceSection from "../components/WorkspaceSection";
import InviteUserModal from "./InviteUserModel";
import { getBoardsAPI } from "../services/BoardAPI";
import WorkspaceSettingModal from "./WorkspaceSettingModal";
import {
  getAllWorkspacesAPI,
  createWorkspaceAPI,
  getWorkspaceBoardsAPI,
  getWorkspaceMembersAPI,
} from "../services/WorkspaceAPI";
import {
  getRecentBoardsAPI,
  saveRecentBoardAPI,
} from "../services/RecentBoardAPI";
import CreateBoardModal from "./CreateBoardModal";
import { getBoardMembersAPI } from "../services/BoardMemberAPI";
import { logoutAPI } from "../services/LoginAPI";
import { Ping } from "../services/PingPoinAPI";
import "../components/css/home.css";

export default function Home() {
  const [boardsPersonal, setBoardsPersonal] = useState([]);
  const [boardsWorkspace, setBoardsWorkspace] = useState([]);
  const [recentBoards, setRecentBoards] = useState([]);
  const [workspaces, setWorkspaces] = useState([]);
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState(null);
  const [boardMembers, setBoardMembers] = useState({});
  const [showCreateWorkspaceModal, setShowCreateWorkspaceModal] =
    useState(false);
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [selectedWorkspace, setSelectedWorkspace] = useState(null);
  const [showSettingModal, setShowSettingModal] = useState(false);
  const [selectedWorkspaceSetting, setSelectedWorkspaceSetting] =
    useState(null);
  const [showCreateBoardModal, setShowCreateBoardModal] = useState(false);
  const [selectedWorkspaceId, setSelectedWorkspaceId] = useState(null);
  const [workspaceMembersMap, setWorkspaceMembersMap] = useState({});
  const navigate = useNavigate();

  const fetchBoards = useCallback(async (currentUser, userWorkspaces = []) => {
    if (!currentUser) return [];

    try {
      const userUId = currentUser.userUId;

      const personalPromise = getBoardsAPI(userUId)
        .then((res) => (Array.isArray(res) ? res : []))
        .catch(() => {
          toast.error("Error occurs when getting personal list");
          return [];
        });

      const workspacePromise = Promise.all(
        userWorkspaces.map((ws) =>
          getWorkspaceBoardsAPI(ws.workspaceUId, userUId)
            .then((res) => (Array.isArray(res) ? res : []))
            .catch(() => [])
        )
      )
        .then((arr) => arr.flat())
        .catch(() => {
          toast.error("Error occurs when getting table list in workspace");
          return [];
        });

      const recentPromise = getRecentBoardsAPI(userUId)
        .then((res) => (Array.isArray(res) ? res : []))
        .catch(() => {
          toast.error("Error occurs when getting recent table list");
          return [];
        });

      const [personalBoards, workspaceBoards, recentBoardsData] =
        await Promise.all([personalPromise, workspacePromise, recentPromise]);

      setBoardsPersonal(personalBoards);
      setBoardsWorkspace(workspaceBoards);
      setRecentBoards(recentBoardsData);

      console.log("Boards loaded:", {
        personal: personalBoards.length,
        workspace: workspaceBoards.length,
        recent: recentBoardsData.length,
      });
    } catch (err) {
      console.error("Board-Data Loading Error", err);
      setBoardsPersonal([]);
      setBoardsWorkspace([]);
      setRecentBoards([]);
    }
  }, []);
  const fetchWorkspaceMembers = useCallback(async (workspacesData) => {
  if (!workspacesData || workspacesData.length === 0) {
    setWorkspaceMembersMap({});
    return;
  }

  const map = {};

  await Promise.all(
    workspacesData.map(async (ws) => {
      try {
        const res = await getWorkspaceMembersAPI(ws.workspaceUId);

        // axiosClient thường trả data trực tiếp giống mấy API khác
        const data = Array.isArray(res)
          ? res
          : Array.isArray(res?.members)
          ? res.members
          : [];

        map[ws.workspaceUId] = data;
      } catch (err) {
        console.error(
          `Error occurs when getting members for workspace ${ws.name}`,
          err
        );
        map[ws.workspaceUId] = [];
      }
    })
  );

  setWorkspaceMembersMap(map);
  console.log("Workspace members loaded:", map);
}, []);
  const fetchWorkspaces = useCallback(async (currentUser) => {
    if (!currentUser) return [];

    try {
      const userUId = currentUser.userUId;
      const res = await getAllWorkspacesAPI(userUId);
      const workspacesData = Array.isArray(res) ? res : res.data || [];

      setWorkspaces(workspacesData);
      console.log("Workspaces loaded:", workspacesData.length);
      return workspacesData;
    } catch (err) {
      console.error("Loading workspace error", err);
      setWorkspaces([]);
      return [];
    }
  }, []);

  const fetchBoardMembers = useCallback(async (boards) => {
    try {
      const membersData = {};
      await Promise.all(
        boards.map(async (board) => {
          try {
            const res = await getBoardMembersAPI(board.boardUId);
            membersData[board.boardUId] = Array.isArray(res) ? res : [];
          } catch (err) {
            console.error(
              `Error occurs when getting members for board ${board.boardName}`,
              err
            );
            membersData[board.boardUId] = [];
          }
        })
      );
      setBoardMembers(membersData);
      console.log("👥 Board members loaded:", membersData);
    } catch (err) {
      console.error("Error occurs when getting all board members:", err);
    }
  }, []);

  const refreshAllData = useCallback(async () => {
  if (!user) return;
  setLoading(true);

  const userWorkspaces = await fetchWorkspaces(user);

  await Promise.all([
    fetchBoards(user, userWorkspaces),
    fetchWorkspaceMembers(userWorkspaces),
  ]);

  setLoading(false);
}, [user, fetchBoards, fetchWorkspaces, fetchWorkspaceMembers]);
  useEffect(() => {
    const storedUser = JSON.parse(localStorage.getItem("user"));
    if (!storedUser) {
      window.location.href = "/";
      return;
    }
    setUser(storedUser);

    // Cải thiện: Không logout nếu chỉ là lỗi network/timeout thông thường
    (async () => {
  try {
      await Ping(); // Trigger refresh token nếu accessToken hết hạn
      const workspacesData = await fetchWorkspaces(storedUser);

      await Promise.all([
        fetchBoards(storedUser, workspacesData),
        fetchWorkspaceMembers(workspacesData),
      ]);

      setLoading(false);
    } catch (err) {
      console.error("Error during initial load:", err);
      console.log("Error details:", {
        status: err.response?.status,
        message: err.message,
        code: err.code,
      });
      if (err.response?.status === 401 || err.response?.status === 403) {
        console.error("Authentication failed, logging out...");
        handleLogout();
      } else {
        console.warn("Non-auth error, keeping session active");
        setLoading(false);
      }
    }
  })();
  }, [fetchBoards, fetchWorkspaces]);

  const handleLogout = async () => {
    try {
      await logoutAPI(user.userUId); // gọi API xóa refreshToken cookie
    } catch (err) {
      console.error("Logout failed:", err);
    } finally {
      localStorage.removeItem("token");
      localStorage.removeItem("user");
      window.location.href = "/";
    }
  };

  useEffect(() => {
    if (boardsWorkspace.length > 0) {
      fetchBoardMembers(boardsWorkspace);
    }
  }, [boardsWorkspace, fetchBoardMembers]);
  const handleCreateWorkspace = async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const name = formData.get("name");
    const description = formData.get("description");

    if (!name?.trim() || !user) return;

    const creatorUserId = user.userUId;

    try {
      await createWorkspaceAPI(
        creatorUserId,
        name.trim(),
        description?.trim() || ""
      );
      toast.success("Create workspace successfully");
      await refreshAllData();
      setShowCreateWorkspaceModal(false);
    } catch (err) {
      console.error("Create workspace error", err);
      toast.error("Can't create workspace right now :(");
    }
  };

  const handleCreateBoard = (workspaceId = null) => {
    setSelectedWorkspaceId(workspaceId);
    setShowCreateBoardModal(true);
  };

  const openDashboard = async (board) => {
    localStorage.setItem("currentBoard", JSON.stringify(board));
    try {
      await saveRecentBoardAPI(user.userUId, board.boardUId);
    } catch (err) {
      console.error("Recent board saving error:", err);
    }
    navigate("/dashboard");
  };

  const workspacesWithBoards = workspaces.map((ws) => ({
    ...ws,
    boards: boardsWorkspace.filter((b) => b.workspaceUId === ws.workspaceUId),
  }));

  return (
  <div className="flex flex-col min-h-screen bg-gray-50 dark:bg-[#2B2D31] home">
    <div className="flex flex-1 overflow-hidden">

      {/* LEFT SIDEBAR (đã có dark mode riêng) */}
      <Sidebar
        workspaces={workspacesWithBoards}
        onCreateWorkspace={() => setShowCreateWorkspaceModal(true)}
        onCreateBoard={handleCreateBoard}
        onSelectBoard={openDashboard}
      />

      {/* MAIN CONTENT */}
      <main className="flex-1 p-8 overflow-y-auto bg-white dark:bg-[#2B2D31]">
        <div className="max-w-7xl mx-auto space-y-10">

          <RecentBoardsSection
            recentBoards={recentBoards}
            workspaces={workspaces}
            loading={loading}
            onSelectBoard={openDashboard}
            boardMembers={boardMembers}
          />

          <PersonalBoardSection
            boards={boardsPersonal}
            loading={loading}
            onCreateBoard={handleCreateBoard}
            onSelectBoard={openDashboard}
          />

          <WorkspaceSection
            workspaces={workspacesWithBoards}
            loading={loading}
            onCreateWorkspace={() => setShowCreateWorkspaceModal(true)}
            onCreateBoard={handleCreateBoard}
            onSelectBoard={openDashboard}
            onInviteUser={(ws) => {
              setSelectedWorkspace(ws);
              setShowInviteModal(true);
            }}
            onOpenSetting={(ws) => {
              setSelectedWorkspaceSetting(ws);
              setShowSettingModal(true);
            }}
            boardMembers={boardMembers}
            workspaceMembersMap={workspaceMembersMap}
          />
        </div>
      </main>

      {/* RIGHT SIDEBAR (đã có dark mode riêng) */}
      <RightSidebar
        recentBoards={recentBoards}
        onCreateBoard={() => handleCreateBoard()}
        onSelectBoard={openDashboard}
      />
    </div>

    {/* CREATE WORKSPACE MODAL */}
    {showCreateWorkspaceModal && (
      <div
        className="fixed inset-0 bg-black/50 dark:bg-black/60
                   flex items-center justify-center z-50 p-4"
        onClick={(e) => {
          if (e.target === e.currentTarget)
            setShowCreateWorkspaceModal(false);
        }}
      >
        <div className="bg-white dark:bg-[#1E1F22]
                        dark:border dark:border-[#3F4147]
                        rounded-xl shadow-2xl max-w-md w-full p-6">

          <h2 className="text-xl font-semibold text-gray-800 dark:text-[#E8EAED] mb-5">
            New Workspace
          </h2>

          <form onSubmit={handleCreateWorkspace} className="space-y-4">

            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-[#E8EAED] mb-2">
                Workspace name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="name"
                required
                autoFocus
                placeholder="VD: Dev Team, Marketing Team..."
                className="w-full px-4 py-2.5 border border-gray-300 
                           dark:border-[#3F4147]
                           rounded-lg bg-white dark:bg-[#2B2D31]
                           text-gray-800 dark:text-[#E8EAED]
                           focus:ring-2 focus:ring-blue-500 
                           outline-none transition"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-[#E8EAED] mb-2">
                Description (Optional)
              </label>
              <textarea
                name="description"
                rows="3"
                placeholder="Ex: Product Development Project Management"
                className="w-full px-4 py-2.5 border border-gray-300 
                           dark:border-[#3F4147]
                           rounded-lg bg-white dark:bg-[#2B2D31]
                           text-gray-800 dark:text-[#E8EAED]
                           focus:ring-2 focus:ring-blue-500
                           outline-none resize-none transition"
              ></textarea>
            </div>

            {/* Action buttons */}
            <div className="flex gap-3 pt-3">
              <button
                type="button"
                onClick={() => setShowCreateWorkspaceModal(false)}
                className="flex-1 px-4 py-2.5 border border-gray-300 dark:border-[#3F4147]
                           text-gray-700 dark:text-[#E8EAED]
                           rounded-lg hover:bg-gray-50 dark:hover:bg-[#3A3C42]
                           transition"
              >
                Cancel
              </button>

              <button
                type="submit"
                className="flex-1 px-4 py-2.5 
                           bg-blue-600 hover:bg-blue-700 
                           text-white font-medium rounded-lg shadow-sm
                           transition dark:bg-[#8AB4F8] dark:hover:bg-[#A8C7FA]
                           dark:text-[#1E1F22]"
              >
                Create Workspace
              </button>
            </div>

          </form>
        </div>
      </div>
    )}

    {/* OTHER MODALS – giữ nguyên logic */}
    {showInviteModal && selectedWorkspace && (
      <InviteUserModal
        workspace={selectedWorkspace}
        onClose={() => {
          setShowInviteModal(false);
          setSelectedWorkspace(null);
        }}
        currentUser={user}
        onSuccess={refreshAllData}
      />
    )}

    {showSettingModal && selectedWorkspaceSetting && (
      <WorkspaceSettingModal
        workspace={selectedWorkspaceSetting}
        currentUser={user}
        onClose={() => {
          setShowSettingModal(false);
          setSelectedWorkspaceSetting(null);
        }}
        onSuccess={refreshAllData}
      />
    )}

    {showCreateBoardModal && (
      <CreateBoardModal
        currentUser={user}
        workspaces={workspaces}
        defaultWorkspaceId={selectedWorkspaceId}
        onClose={() => setShowCreateBoardModal(false)}
        onSuccess={refreshAllData}
      />
    )}

  </div>
);

}

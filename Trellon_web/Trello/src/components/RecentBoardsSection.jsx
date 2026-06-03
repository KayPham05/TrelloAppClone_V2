import React from "react";
import { Clock } from "lucide-react";

export default function RecentBoardsSection({
  recentBoards = [],
  workspaces = [],
  loading = false,
  onSelectBoard,
  boardMembers
}) {
  const getBoardGradient = (index) => {
    const gradients = [
      "from-blue-500 to-purple-600",
      "from-purple-500 to-pink-600",
      "from-orange-500 to-red-600",
      "from-green-500 to-teal-600",
      "from-pink-500 to-rose-600",
      "from-indigo-500 to-blue-600",
    ];
    return gradients[index % gradients.length];
  };

  return (
  <section>
    {/* Header */}
    <div className="flex items-center gap-2 mb-4">
      <Clock className="text-gray-600 dark:text-[#E8EAED]" size={22} />
      <h2 className="text-xl font-bold text-gray-800 dark:text-[#E8EAED]">
        Recently Opened
      </h2>
    </div>

    {/* Loading */}
    {loading ? (
      <div className="flex items-center gap-3 text-gray-500 dark:text-[#9AA0A6] py-8">
        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 dark:border-[#8AB4F8]"></div>
        <p className="text-sm italic">Data loading...</p>
      </div>
    ) : recentBoards.length === 0 ? (
      /* Empty */
      <div className="bg-white dark:bg-[#2B2D31] rounded-xl border-2 border-dashed 
                      border-gray-300 dark:border-[#3F4147] p-12 text-center">
        <Clock size={48} className="mx-auto text-gray-300 dark:text-[#9AA0A6] mb-3" />

        <h3 className="text-gray-700 dark:text-[#E8EAED] font-semibold mb-2">
          There is no board yet.
        </h3>

        <p className="text-gray-500 dark:text-[#9AA0A6] text-sm">
          Let's create one or join a workspace!
        </p>
      </div>
    ) : (
      /* Grid */
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {recentBoards.map((board, index) => (
          <div
            key={board.boardUId}
            onClick={() => onSelectBoard && onSelectBoard(board)}
            className={`
              h-32 rounded-xl overflow-hidden shadow-md cursor-pointer relative group
              bg-gradient-to-br ${getBoardGradient(index)}
              hover:shadow-xl hover:scale-[1.03] transition-all duration-200
              dark:shadow-black/40
            `}
          >
            {/* Board Members Avatar */}
            {boardMembers[board.boardUId] &&
              boardMembers[board.boardUId].length > 0 && (
                <div className="absolute top-2 right-2 flex -space-x-2 z-20">
                  {boardMembers[board.boardUId]
                    .filter((m) => ["Owner", "Admin", "Member"].includes(m.role))
                    .map((member, index) => {
                      const avatarColors = [
                        "bg-blue-700",
                        "bg-yellow-600",
                        "bg-orange-600",
                        "bg-emerald-600",
                        "bg-green-600",
                        "bg-violet-600",
                        "bg-rose-600",
                        "bg-teal-600",
                        "bg-indigo-600",
                      ];
                      const colorClass = avatarColors[index % avatarColors.length];

                      return (
                        <div
                          key={member.userUId}
                          title={`${member.userName} (${member.role})`}
                          className={`
                            w-7 h-7 ${colorClass} text-white text-sm flex items-center justify-center font-semibold  
                            rounded-full shadow-md hover:scale-110 transition-transform
                          `}
                        >
                          {member.userName
                            ?.split(" ")
                            .map((n) => n[0])
                            .join("")
                            .toUpperCase()
                            .slice(0, 2)}
                        </div>
                      );
                    })}

                  {/* +N members */}
                  {boardMembers[board.boardUId].filter((m) =>
                    ["Owner", "Admin", "Member"].includes(m.role)
                  ).length > 4 && (
                    <div className="
                      w-7 h-7 bg-gray-200 text-gray-700 dark:bg-[#3A3C42] dark:text-[#E8EAED]
                      text-sm flex items-center justify-center font-semibold 
                      border-2 border-white/60 dark:border-[#2B2D31] rounded-full shadow-sm
                    ">
                      +
                      {boardMembers[board.boardUId].filter((m) =>
                        ["Owner", "Admin", "Member"].includes(m.role)
                      ).length - 4}
                    </div>
                  )}
                </div>
              )}

            {/* Overlay */}
            <div className="
              absolute inset-0 bg-black/20 group-hover:bg-black/10 
              dark:bg-black/30 dark:group-hover:bg-black/20 transition
            "></div>

            {/* Content */}
            <div className="absolute bottom-4 left-4 right-4 z-10">
              <h3 className="text-white font-bold text-base truncate mb-1 drop-shadow-lg">
                {board.boardName}
              </h3>

              <div className="flex items-center gap-2">
                <span className="
                  text-white/90 text-xs font-medium 
                  bg-white/20 dark:bg-white/10 px-2 py-0.5 rounded-full backdrop-blur-sm
                ">
                  {board.workspaceUId
                    ? workspaces.find(
                        (ws) => ws.workspaceUId == board.workspaceUId
                      )?.name || "Not found"
                    : "Personal"}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    )}
  </section>
);

}

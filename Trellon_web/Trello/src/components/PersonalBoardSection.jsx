import React,{useEffect, useState} from "react";
import { User, Plus, Settings } from "lucide-react";
import EditBoardModal from "./EditBoardModal";

export default function PersonalBoardSection({
  boards = [],
  loading = false,
  workspaces = [],
  onCreateBoard,
  onSelectBoard,
  onRefresh,
}) {
  const [editingBoard, setEditingBoard] = useState(null);
  const [boardsLocal, setBoardsLocal] = useState(boards);

  useEffect(() => {setBoardsLocal(boards);}, [boards]);
  const getBoardGradient = (index) => {
    const gradients = [
      "from-indigo-500 to-purple-600",
      "from-cyan-500 to-blue-600",
      "from-rose-500 to-pink-600",
      "from-amber-500 to-orange-600",
      "from-emerald-500 to-green-600",
      "from-violet-500 to-fuchsia-600",
    ];
    return gradients[index % gradients.length];
  };

  const handleSaved = (e)=>{
    if(!e) return;
    if(e.type === "update" && e.board){
      setBoardsLocal((prev)=>
        prev.map((b)=>(b.boardUId === e.board.boardUId ? {...b, ...e.board} : b))
      );
    }
    else if(e.type === "delete" && e.boardUId){
      setBoardsLocal((prev) => prev.filter((b) => b.boardUId !== e.boardUId));
    }
    onRefresh?.();
  };

  return (
    <section className="transition-colors">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <User className="text-gray-600 dark:!text-gray-300" size={22} />
          <h2 className="text-xl font-bold text-gray-800 dark:!text-gray-100">
            Personal board
            
          </h2>
        </div>
        <button
          onClick={() => onCreateBoard && onCreateBoard(null)}
          className="flex items-center gap-2 px-5 py-2.5 bg-green-600 hover:bg-green-700 text-white text-sm font-semibold rounded-lg shadow-md hover:shadow-lg transition"
        >
          <Plus size={18} />
          Create Personal board
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="text-center">
            <div className="dark:border-emerald-500 animate-spin rounded-full h-10 w-10 border-b-2 border-green-600 mx-auto mb-3"></div>
            <p className="dark:!text-gray-300 text-gray-500 text-sm">Loading Personal Board...</p>
          </div>
        </div>
      ) : boardsLocal.length === 0 ? (
        <div className="dark:bg-zinc-900 dark:border-zinc-700 bg-white rounded-xl border-2 border-dashed border-gray-300 p-16 text-center">
          <User className="dark:!text-gray-400 mx-auto text-gray-300 mb-4" size={64} />
          <h3 className="dark:!text-gray-100 text-gray-700 font-bold mb-2 text-xl">
            Let's create a personal board
          </h3>
          <p className="dark:!text-gray-300 text-gray-500 text-sm mb-6 max-w-md mx-auto">
            Create a personal board to manage your tasks efficiently
          </p>
          <button
            onClick={() => onCreateBoard && onCreateBoard(null)}
            className="dark:bg-emerald-600 dark:hover:bg-emerald-700 px-6 py-3 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg shadow-md hover:shadow-lg transition"
          >
            Create Your First Board
          </button>
        </div>
      ) : (
        <div className="dark:bg-zinc-900 dark:border-zinc-700 bg-white rounded-xl p-6 shadow-sm border border-gray-200 hover:shadow-md transition">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {boardsLocal.map((board, index) => (
              <div
                key={board.boardUId}
                onClick={() => onSelectBoard && onSelectBoard(board)}
                className={`h-32 rounded-xl overflow-hidden shadow-md cursor-pointer relative group bg-gradient-to-br ${getBoardGradient(
                  index
                )} hover:shadow-xl hover:scale-[1.03] transition-all duration-200`}
              >
                {/* Overlay */}
                <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition"></div>
                {/*Setting Button*/}
                <button
                  title = "Board settings"
                    onClick={(e)=>{
                      e.stopPropagation();
                      setEditingBoard(board);
                    }}
                    className = "absolute top-2 right-2 z-20 p-2 hover:rounded-full hover:bg-white/30 backdrop-blur-sm text-white"
                >
                  <Settings size = {16}/>
                </button>
                {/* Content */}
                <div className="absolute bottom-4 left-4 right-4 z-10">
                  <h4 className="text-white font-bold text-base truncate mb-1">
                    {board.boardName}
                  </h4>
                  <p className="text-white/90 text-xs font-medium bg-white/20 px-2 py-0.5 rounded-full backdrop-blur-sm w-fit">
                    Personal
                  </p>
                </div>
              </div>
            ))}

            {/* Nút tạo board */}
            <button
              onClick={() => onCreateBoard && onCreateBoard(null)}
              className="h-32 rounded-xl border-2 border-dashed border-gray-300 flex flex-col items-center justify-center hover:bg-gray-50 hover:border-green-400 text-gray-600 transition group dark:border-zinc-700 dark:hover:bg-zinc-800 dark:text-zinc-300"
            >
              <div className="dark:text-emerald-400 dark:group-hover:text-emerald-300 w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center mb-2 group-hover:bg-green-200 transition">
                <Plus
                  size={28}
                  className="text-green-600 group-hover:text-green-700 transition"
                />
              </div>
              <span className="dark:!text-zinc-100 dark:group-hover:!text-emerald-300 text-sm font-semibold group-hover:text-green-600 transition">
                Create Your New Board
              </span>
            </button>
          </div>
        </div>
      )}
      <EditBoardModal
              open ={!!editingBoard}
              onClose={()=>setEditingBoard(null)}
              board = {editingBoard}
              onSaved = {handleSaved}
      >
      </EditBoardModal>
    </section>
  );
}
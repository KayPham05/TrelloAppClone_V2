using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace TodoAppAPI.Hubs
{
    [Authorize]
    public class BoardHub : Hub
    {
        public async Task JoinBoard(string boardUId)
        {
            if (!string.IsNullOrWhiteSpace(boardUId))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, BoardGroup(boardUId));
            }
        }

        public async Task LeaveBoard(string boardUId)
        {
            if (!string.IsNullOrWhiteSpace(boardUId))
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, BoardGroup(boardUId));
            }
        }

        public static string BoardGroup(string boardUId) => $"board_{boardUId}";
    }
}

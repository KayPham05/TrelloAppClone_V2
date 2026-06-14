using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;

namespace TodoAppAPI.Service
{
    public class CardMemberService : ICardMemberService
    {
        private readonly TodoDbContext _dbContext;
        private readonly INotificationService _notificationService;

        public CardMemberService(TodoDbContext dbContext, INotificationService notificationService)
        {
            _dbContext = dbContext;
            _notificationService = notificationService;
        }

        public async Task<bool> AddCardMember(string userUId, string requesterUId, string boardUId, string cardUId)
        {
            try
            {
                // B1: Kiểm tra người gửi request có trong BoardMember hay không
                var requester = await _dbContext.BoardMembers
                    .FirstOrDefaultAsync(bm =>
                        bm.BoardUId == boardUId &&
                        bm.UserUId == requesterUId &&
                        (bm.BoardRole == "Owner" || bm.BoardRole == "Admin"));

                if (requester == null)
                {
                    Console.WriteLine("Requester không có quyền thêm thành viên vào card");
                    return false;
                }

                // B2: Kiểm tra user được thêm có tồn tại không
                var targetUser = await _dbContext.Users.FindAsync(userUId);
                if (targetUser == null)
                {
                    Console.WriteLine("User cần thêm không tồn tại");
                    return false;
                }

                // B3: Kiểm tra card có tồn tại không
                var card = await _dbContext.Todos.FindAsync(cardUId);
                if (card == null)
                {
                    Console.WriteLine("Card không tồn tại");
                    return false;
                }

                // B4: Kiểm tra user đã nằm trong card chưa
                var existingMember = await _dbContext.CardMembers
                    .FirstOrDefaultAsync(cm => cm.CardUId == cardUId && cm.UserUId == userUId);

                if (existingMember != null)
                {
                    Console.WriteLine("User đã là member của card này");
                    return false;
                }

                // B5: Thêm mới
                var newMember = new CardMember
                {
                    CardMemberUId = Guid.NewGuid().ToString(),
                    CardUId = cardUId,
                    UserUId = userUId,
                    Role = "Assignee",
                    AssignedAt = DateTime.UtcNow
                };

                _dbContext.Add(newMember);
                await _dbContext.SaveChangesAsync();

                if (userUId != requesterUId)
                {
                    var actorName = await GetUserDisplayNameAsync(requesterUId);
                    var cardTitle = card.Title ?? card.CardUId;
                    await _notificationService.TryCreateInternalAsync(new NotificationDTO
                    {
                        RecipientId = userUId,
                        ActorId = requesterUId,
                        Type = NotificationType.Assign,
                        Title = "Bạn đã được phân công vào thẻ",
                        Message = $"Bạn đã được {actorName} phân công vào {cardTitle}.",
                        BoardId = boardUId,
                        CardId = cardUId,
                        Link = $"/card-detail/{cardUId}"
                    }, "card member add");
                }

                Console.WriteLine("Thêm thành viên vào card thành công");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi thêm CardMember: {ex.Message}");
                return false;
            }
        }

        public async Task<List<MemberDTO>> GetAllUserMemberByCardUId(string cardUId)
        {
            return await _dbContext.CardMembers
                .AsNoTracking()
                .Where(cm => cm.CardUId == cardUId)
                .Include(cm => cm.User)
                .Select(cm => new MemberDTO
                {
                    UserUId   = cm.UserUId,
                    UserName  = cm.User.UserName,
                    Email     = cm.User.Email,
                    AvatarUrl = cm.User.AvatarUrl,
                    Role      = cm.Role
                })
                .ToListAsync();
        }

        public async Task<bool> RemoveCardMember(string userUId, string requesterUId, string boardUId, string cardUId)
        {
            try
            {
                // 1: Kiểm tra người thực hiện có quyền Owner/Admin trong Board đó không
                var requester = await _dbContext.BoardMembers
                    .AsNoTracking()
                    .FirstOrDefaultAsync(bm =>
                        bm.BoardUId == boardUId &&
                        bm.UserUId == requesterUId &&
                        (bm.BoardRole == "Owner" || bm.BoardRole == "Admin"));

                if (requester == null)
                {
                    Console.WriteLine("Requester không có quyền xóa thành viên khỏi card này.");
                    return false;
                }

                // 2: Tìm thành viên cần xóa trong CardMembers
                var targetMember = await _dbContext.CardMembers
                    .FirstOrDefaultAsync(cm => cm.CardUId == cardUId && cm.UserUId == userUId);

                if (targetMember == null)
                {
                    Console.WriteLine("Thành viên không tồn tại trong card.");
                    return false;
                }

                // 3: Xóa
                var card = await _dbContext.Todos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.CardUId == cardUId);

                _dbContext.CardMembers.Remove(targetMember);
                await _dbContext.SaveChangesAsync();

                if (userUId != requesterUId)
                {
                    var actorName = await GetUserDisplayNameAsync(requesterUId);
                    var cardTitle = card?.Title ?? cardUId;
                    await _notificationService.TryCreateInternalAsync(new NotificationDTO
                    {
                        RecipientId = userUId,
                        ActorId = requesterUId,
                        Type = NotificationType.CardUnassigned,
                        Title = "Bạn đã bị xóa khỏi thẻ",
                        Message = $"Bạn đã bị {actorName} xóa khỏi {cardTitle}.",
                        BoardId = boardUId,
                        CardId = cardUId,
                        Link = $"/card-detail/{cardUId}"
                    }, "card member remove");
                }

                Console.WriteLine($"Đã xóa user {userUId} khỏi card {cardUId}");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi xóa CardMember: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateCardMemberRole(string cardUId, string userUId, string newRole, string requesterUId)
        {
            try
            {
                // Lấy board của card để kiểm tra quyền requester
                var card = await _dbContext.Todos.AsNoTracking()
                    .FirstOrDefaultAsync(c => c.CardUId == cardUId);
                if (card == null) return false;

                var list = await _dbContext.Lists.AsNoTracking()
                    .FirstOrDefaultAsync(l => l.ListUId == card.ListUId);
                if (list == null) return false;

                var requesterIsAdmin = await _dbContext.BoardMembers.AnyAsync(bm =>
                    bm.BoardUId == list.BoardUId &&
                    bm.UserUId == requesterUId &&
                    (bm.BoardRole == "Owner" || bm.BoardRole == "Admin"));

                if (!requesterIsAdmin) return false;

                var target = await _dbContext.CardMembers
                    .FirstOrDefaultAsync(cm => cm.CardUId == cardUId && cm.UserUId == userUId);
                if (target == null) return false;

                target.Role = newRole;
                await _dbContext.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật role CardMember: {ex.Message}");
                return false;
            }
        }

        private async Task<string> GetUserDisplayNameAsync(string userUId)
        {
            var name = await _dbContext.Users
                .AsNoTracking()
                .Where(u => u.UserUId == userUId)
                .Select(u => u.UserName)
                .FirstOrDefaultAsync();

            return string.IsNullOrWhiteSpace(name) ? userUId : name;
        }
    }
}

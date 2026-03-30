using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.Interfaces;
using TodoAppAPI.Models;
namespace TodoAppAPI.Service
{
    public class CardMemberService : ICardMemberService
    {
        private readonly TodoDbContext _dbContext;
        public CardMemberService(TodoDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public async Task<bool> AddCardMember(string userUId, string requesterUId, string boardUId ,string cardUId)
        {
            try
            {
                //  B1: Kiểm tra người gửi request có trong BoardMember hay không
                var requester = await _dbContext.BoardMembers
                    .FirstOrDefaultAsync(bm =>
                        bm.BoardUId == boardUId &&
                        bm.UserUId == requesterUId &&
                        (bm.BoardRole == "Owner" || bm.BoardRole == "Admin"));

                if (requester == null)
                {
                    //Không có quyền
                    Console.WriteLine("Requester không có quyền thêm thành viên vào card");
                    return false;
                }

                //  B2: Kiểm tra user được thêm có tồn tại không
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
                var existingMember = await _dbContext.CardMembers.FirstOrDefaultAsync(cm => cm.CardUId == cardUId && cm.UserUId == userUId);

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

                Console.WriteLine(" Thêm thành viên vào card thành công");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Lỗi khi thêm CardMember: {ex.Message}");
                return false;
            }
        }

        public async Task<List<CardMember>> GetAllUserMemberByCardUId(string cardUId)
        {
            return await _dbContext.CardMembers
                        .AsNoTracking()
                        .Where(cm => cm.CardUId == cardUId)
                        .Include(cm => cm.User)
                        .ToListAsync();
        }

        public async Task<bool> RemoveCardMember(string userUId, string requesterUId, string boardUId, string cardUId)
        {
            try
            {
                // 1️⃣ Kiểm tra người thực hiện có quyền Owner/Admin trong Board đó không
                var requester = await _dbContext.BoardMembers
                    .AsNoTracking()
                    .FirstOrDefaultAsync(bm =>
                        bm.BoardUId == boardUId &&
                        bm.UserUId == requesterUId &&
                        (bm.BoardRole == "Owner" || bm.BoardRole == "Admin"));

                if (requester == null)
                {
                    Console.WriteLine(" Requester không có quyền xóa thành viên khỏi card này.");
                    return false;
                }

                // 2️⃣ Tìm thành viên cần xóa trong CardMembers
                var targetMember = await _dbContext.CardMembers
                    .FirstOrDefaultAsync(cm =>
                        cm.CardUId == cardUId &&
                        cm.UserUId == userUId);

                if (targetMember == null)
                {
                    Console.WriteLine(" Thành viên không tồn tại trong card.");
                    return false;
                }

                // 3️⃣ Xóa
                _dbContext.CardMembers.Remove(targetMember);
                await _dbContext.SaveChangesAsync();

                Console.WriteLine($" Đã xóa user {userUId} khỏi card {cardUId}");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Lỗi khi xóa CardMember: {ex.Message}");
                return false;
            }
        }
    }
}

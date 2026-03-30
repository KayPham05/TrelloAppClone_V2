using TodoAppAPI.Models;

namespace TodoAppAPI.DTOs
{
    public class AddInboxCard
    {
        public string UserUId { get; set; }
        public Card? Card { get; set; }
    }
}

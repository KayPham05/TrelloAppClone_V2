namespace TodoAppAPI.DTOs
{
    public class CardMemberDto
    {
        public string CardMemberUId { get; set; } = string.Empty;
        public string CardUId { get; set; } = string.Empty;
        public string UserUId { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public DateTime? AssignedAt { get; set; }
        
        public UserDto? User { get; set; }
    }
}

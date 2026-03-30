namespace TodoAppAPI.DTOs
{
    public class WorkspaceMembersDto
    {
        public string UserUId { get; set; } = string.Empty;
        public string Role { get; set; } = "Member";
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }
}

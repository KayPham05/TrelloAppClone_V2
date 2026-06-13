namespace TodoAppAPI.DTOs;

public class UserInviteSuggestionDTO
{
    public string UserUId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public string? WorkspaceRole { get; set; }
}

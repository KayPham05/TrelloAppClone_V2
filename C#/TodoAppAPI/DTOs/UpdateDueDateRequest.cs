namespace TodoAppAPI.DTOs
{
    public class UpdateDueDateRequest
    {
        public DateTime? DueDate { get; set; }
        public string UserUId { get; set; } = string.Empty;
    }
}

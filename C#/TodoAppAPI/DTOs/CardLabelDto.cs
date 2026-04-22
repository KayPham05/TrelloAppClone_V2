namespace TodoAppAPI.DTOs
{
    public class CardLabelDto
    {
        public string CardLabelUId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string ColorCode { get; set; } = string.Empty;
    }

    public class CreateCardLabelRequest
    {
        public string Title { get; set; } = string.Empty;
        public string ColorCode { get; set; } = string.Empty;
    }

    public class UpdateCardLabelRequest
    {
        public string Title { get; set; } = string.Empty;
        public string ColorCode { get; set; } = string.Empty;
    }
}

namespace TodoAppAPI.Models
{
    public class GeminiSettings
    {
        public string ApiKey { get; set; } = string.Empty;
        public string Model { get; set; } = "gemini-3.5-flash";
        public int TimeoutSeconds { get; set; } = 30;
        public int CacheMinutes { get; set; } = 5;
        public int MaxRisks { get; set; } = 5;
        public int MaxSuggestions { get; set; } = 5;
    }
}

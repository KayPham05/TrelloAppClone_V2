namespace TodoAppAPI.Interfaces
{
    public interface IGeminiClient
    {
        Task<string> GenerateJsonAsync(string prompt, object responseSchema, CancellationToken cancellationToken);
    }
}

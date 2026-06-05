using System.Net;
using System.Text.Json;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using TodoAppAPI.Models;
using TodoAppAPI.Service.Gemini;
using Xunit;

namespace TodoAppAPI.Tests;

public class GeminiClientTests
{
    [Fact]
    public async Task GenerateJsonAsync_sends_gemini_rest_structured_output_fields()
    {
        using var handler = new CapturingHandler();
        using var httpClient = new HttpClient(handler);
        var client = new GeminiClient(
            httpClient,
            Options.Create(new GeminiSettings
            {
                ApiKey = "test-key",
                Model = "gemini-2.0-flash"
            }),
            NullLogger<GeminiClient>.Instance);

        var result = await client.GenerateJsonAsync(
            "Analyze board",
            new { type = "object" },
            CancellationToken.None);

        Assert.Equal("""{"summary":"ok","risks":[],"suggestions":[],"inferredMilestones":[]}""", result);
        Assert.NotNull(handler.RequestBody);
        using var document = JsonDocument.Parse(handler.RequestBody);
        var generationConfig = document.RootElement.GetProperty("generationConfig");
        Assert.Equal("application/json", generationConfig.GetProperty("responseMimeType").GetString());
        Assert.True(generationConfig.TryGetProperty("responseSchema", out _));
        Assert.False(generationConfig.TryGetProperty("responseFormat", out _));
        Assert.Equal("test-key", handler.RequestHeaders["x-goog-api-key"]);
        Assert.EndsWith("/v1beta/models/gemini-2.0-flash:generateContent", handler.RequestUri!.AbsoluteUri);
    }

    private sealed class CapturingHandler : HttpMessageHandler
    {
        public string? RequestBody { get; private set; }
        public Uri? RequestUri { get; private set; }
        public Dictionary<string, string> RequestHeaders { get; } = [];

        protected override async Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            RequestUri = request.RequestUri;
            foreach (var header in request.Headers)
            {
                RequestHeaders[header.Key] = header.Value.Single();
            }

            RequestBody = request.Content == null
                ? null
                : await request.Content.ReadAsStringAsync(cancellationToken);

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("""
                {
                  "candidates": [
                    {
                      "content": {
                        "parts": [
                          {
                            "text": "{\"summary\":\"ok\",\"risks\":[],\"suggestions\":[],\"inferredMilestones\":[]}"
                          }
                        ]
                      }
                    }
                  ]
                }
                """)
            };
        }
    }
}

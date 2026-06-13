using System.Text.Json;
using TodoAppAPI.DTOs.ProjectAnalysis;
using TodoAppAPI.Service.Gemini;
using Xunit;

namespace TodoAppAPI.Tests;

public class ProjectAnalysisPromptBuilderTests
{
    [Fact]
    public void BuildPrompt_includes_serialized_snapshot_and_metrics()
    {
        var builder = new ProjectAnalysisPromptBuilder();
        var snapshot = new ProjectAnalysisSnapshotDto
        {
            ScopeType = "board",
            ScopeUId = "board-1",
            Title = "Sprint Board",
            Lists = new List<ProjectAnalysisSnapshotListDto>(),
            Cards = new List<ProjectAnalysisSnapshotCardDto>()
        };
        var metrics = new ProjectAnalysisMetricDto
        {
            TotalCards = 10,
            CompletedCards = 5
        };

        var prompt = builder.BuildPrompt(snapshot, metrics, 50);

        Assert.Contains("Sprint Board", prompt);
        Assert.Contains("\"overallProgress\": 50", prompt);
        Assert.Contains("\"TotalCards\": 10", prompt);
        Assert.Contains("\"CompletedCards\": 5", prompt);
        Assert.Contains("You are a project progress analysis assistant", prompt);
    }

    [Fact]
    public void BuildResponseSchema_returns_valid_gemini_schema_object()
    {
        var builder = new ProjectAnalysisPromptBuilder();

        var schema = builder.BuildResponseSchema();

        var json = JsonSerializer.Serialize(schema);
        Assert.Contains("\"type\":\"object\"", json);
        Assert.Contains("\"properties\"", json);
        Assert.Contains("\"summary\"", json);
        Assert.Contains("\"risks\"", json);
        Assert.Contains("\"suggestions\"", json);
        Assert.Contains("\"inferredMilestones\"", json);
    }
}

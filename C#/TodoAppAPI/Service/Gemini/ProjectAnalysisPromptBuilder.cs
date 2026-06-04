using System.Text.Json;
using TodoAppAPI.DTOs.ProjectAnalysis;

namespace TodoAppAPI.Service.Gemini
{
    public class ProjectAnalysisPromptBuilder
    {
        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            WriteIndented = true
        };

        public string BuildPrompt(ProjectAnalysisSnapshotDto snapshot, ProjectAnalysisMetricDto metrics, int overallProgress)
        {
            var snapshotJson = JsonSerializer.Serialize(snapshot, JsonOptions);
            var metricsJson = JsonSerializer.Serialize(new
            {
                overallProgress,
                metrics.TotalCards,
                metrics.TodoCards,
                metrics.InProgressCards,
                metrics.CompletedCards,
                metrics.OtherCards,
                metrics.OverdueCards,
                metrics.DueSoonCards,
                metrics.TotalTodoItems,
                metrics.CompletedTodoItems,
                metrics.StatusDistribution
            }, JsonOptions);

            return $"""
            You are a project progress analysis assistant for a Trello-like project management application.
            Only use the snapshot data provided below. Do not invent card IDs, member names, deadlines,
            or milestones that are not present in the snapshot. Respond entirely in Vietnamese.
            If the data is too thin to make a meaningful observation, say so clearly in the summary.

            === SNAPSHOT ===
            {snapshotJson}

            === METRICS (pre-calculated, do not recalculate) ===
            {metricsJson}

            === INSTRUCTIONS ===
            Return a JSON object matching the schema provided by the API request.
            Do not include any text outside the JSON object.
            Do NOT mention the project progress percentage or the number of completed cards in the summary, as this is already visible in the UI. Keep the summary under 300 characters.
            Limit risks to at most 5 items.
            Limit suggestions to at most 5 items.
            Keep each description under 200 characters.
            For relatedCardUIds, only use card UIDs that appear in the snapshot.
            """;
        }

        public object BuildResponseSchema()
        {
            return new
            {
                type = "object",
                properties = new Dictionary<string, object>
                {
                    ["summary"] = new { type = "string" },
                    ["risks"] = new
                    {
                        type = "array",
                        items = new
                        {
                            type = "object",
                            properties = new Dictionary<string, object>
                            {
                                ["severity"] = new { type = "string" },
                                ["title"] = new { type = "string" },
                                ["description"] = new { type = "string" },
                                ["relatedCardUIds"] = new
                                {
                                    type = "array",
                                    items = new { type = "string" }
                                }
                            },
                            required = new[] { "severity", "title", "description", "relatedCardUIds" }
                        }
                    },
                    ["suggestions"] = new
                    {
                        type = "array",
                        items = new
                        {
                            type = "object",
                            properties = new Dictionary<string, object>
                            {
                                ["priority"] = new { type = "string" },
                                ["title"] = new { type = "string" },
                                ["description"] = new { type = "string" }
                            },
                            required = new[] { "priority", "title", "description" }
                        }
                    },
                    ["inferredMilestones"] = new
                    {
                        type = "array",
                        items = new
                        {
                            type = "object",
                            properties = new Dictionary<string, object>
                            {
                                ["name"] = new { type = "string" },
                                ["status"] = new { type = "string" },
                                ["description"] = new { type = "string" }
                            },
                            required = new[] { "name", "status", "description" }
                        }
                    }
                },
                required = new[] { "summary", "risks", "suggestions", "inferredMilestones" }
            };
        }
    }
}

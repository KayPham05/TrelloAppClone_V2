using System;

namespace TodoAppAPI.DTOs
{
    public class ActivityDto
    {
        public string ActivityUId { get; set; } = string.Empty;
        public string Action { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }

        // Human-friendly relative time (can remain as-is)
        public string TimeAgo => GetTimeAgo(CreatedAt);

        // New: CreatedAt converted to UTC+7 formatted string
        public string CreatedAtLocal => ConvertToTimeZoneString(CreatedAt, "Asia/Ho_Chi_Minh", "SE Asia Standard Time");

        public UserDto? User { get; set; }

        private static string GetTimeAgo(DateTime dateTime)
        {
            var timeSpan = DateTime.UtcNow - dateTime.ToUniversalTime();

            if (timeSpan.TotalSeconds < 60)
                return $"{(int)timeSpan.TotalSeconds} seconds ago";
            if (timeSpan.TotalMinutes < 60)
                return $"{(int)timeSpan.TotalMinutes} minutes ago";
            if (timeSpan.TotalHours < 24)
                return $"{(int)timeSpan.TotalHours} hours ago";
            if (timeSpan.TotalDays < 30)
                return $"{(int)timeSpan.TotalDays} days ago";
            if (timeSpan.TotalDays < 365)
                return $"{(int)(timeSpan.TotalDays / 30)} months ago";
            return $"{(int)(timeSpan.TotalDays / 365)} years ago";
        }

        // Cross-platform TZ conversion: prefer IANA id, fallback to Windows id
        private static string ConvertToTimeZoneString(DateTime utcDateTime, string ianaId, string windowsId, string format = "yyyy-MM-dd HH:mm:ss")
        {
            if (utcDateTime.Kind != DateTimeKind.Utc)
                utcDateTime = DateTime.SpecifyKind(utcDateTime, DateTimeKind.Utc);

            try
            {
                // Try IANA first (Linux/macOS)
                var tz = TimeZoneInfo.FindSystemTimeZoneById(ianaId);
                var local = TimeZoneInfo.ConvertTimeFromUtc(utcDateTime, tz);
                return local.ToString(format);
            }
            catch
            {
                try
                {
                    // Fallback to Windows id (Windows)
                    var tz = TimeZoneInfo.FindSystemTimeZoneById(windowsId);
                    var local = TimeZoneInfo.ConvertTimeFromUtc(utcDateTime, tz);
                    return local.ToString(format);
                }
                catch
                {
                    // Last resort: add 7 hours
                    var local = utcDateTime.AddHours(7);
                    return local.ToString(format);
                }
            }
        }
    }
}

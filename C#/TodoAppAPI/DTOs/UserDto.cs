using System;
using System.Linq;

namespace TodoAppAPI.DTOs
{
    public class UserDto
    {
        public string UserUId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }

        public static string GetInitialsAvatar(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return "https://ui-avatars.com/api/?name=U&background=random";

            var initials = string.Join("", name
                .Split(' ', System.StringSplitOptions.RemoveEmptyEntries)
                .Select(w => w.FirstOrDefault())
                .Take(2));

            var escaped = System.Uri.EscapeDataString(initials);
            return $"https://ui-avatars.com/api/?name={escaped}&background=random";
        }
    }
}

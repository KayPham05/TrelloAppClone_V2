using TodoAppAPI.Models;

namespace TodoAppAPI.DTOs
{
    public class ReorderRequest
    {
        public string BoardUId { get; set; }
        public List<List> Order { get; set; }
    }
}

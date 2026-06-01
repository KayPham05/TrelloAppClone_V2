using System.Collections.Generic;

namespace TodoAppAPI.DTOs.Search
{
    public class SearchResultDTO
    {
        public List<SearchBoardDTO> Boards { get; set; } = new List<SearchBoardDTO>();
        public List<SearchCardDTO> Cards { get; set; } = new List<SearchCardDTO>();
    }
}

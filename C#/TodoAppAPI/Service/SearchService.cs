using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TodoAppAPI.Data;
using TodoAppAPI.DTOs.Search;
using TodoAppAPI.Interfaces;

namespace TodoAppAPI.Service
{
    public class SearchService : ISearchService
    {
        private readonly TodoDbContext _context;

        public SearchService(TodoDbContext context)
        {
            _context = context;
        }

        public async Task<SearchResultDTO> SearchBoardsAndCardsAsync(string query, string userUId)
        {
            var result = new SearchResultDTO();

            if (string.IsNullOrWhiteSpace(query))
            {
                return result;
            }

            var lowerQuery = query.ToLower();

            // Search Boards
            var boards = await _context.Boards
                .Where(b => EF.Functions.Like(b.BoardName, $"%{query}%") &&
                            (b.UserUId == userUId || (b.Members != null && b.Members.Any(m => m.UserUId == userUId))))
                .Select(b => new SearchBoardDTO
                {
                    BoardUId = b.BoardUId,
                    BoardName = b.BoardName,
                    BackgroundUrl = b.BackgroundUrl
                })
                .Take(20)
                .ToListAsync();

            // Search Cards
            var cards = await _context.Todos
                .Where(c => c.Title != null && EF.Functions.Like(c.Title, $"%{query}%") &&
                            (c.UserUId == userUId || 
                            (c.List != null && c.List.Board != null && 
                             (c.List.Board.UserUId == userUId || (c.List.Board.Members != null && c.List.Board.Members.Any(m => m.UserUId == userUId))))))
                .Select(c => new SearchCardDTO
                {
                    CardUId = c.CardUId,
                    Title = c.Title,
                    BoardUId = c.List != null && c.List.Board != null ? c.List.Board.BoardUId : null,
                    BoardName = c.List != null && c.List.Board != null ? c.List.Board.BoardName : null
                })
                .Take(20)
                .ToListAsync();

            result.Boards = boards;
            result.Cards = cards;

            return result;
        }
    }
}

using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface ICardLabelService
    {
        Task<CardLabelDto> AddLabelAsync(string cardId, CreateCardLabelRequest request);
        Task<bool> UpdateLabelAsync(string labelId, UpdateCardLabelRequest request);
        Task<bool> DeleteLabelAsync(string labelId);
    }
}

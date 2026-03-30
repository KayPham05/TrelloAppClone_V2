using TodoAppAPI.DTOs;

namespace TodoAppAPI.Interfaces
{
    public interface IAddInboxCardService
    {
        Task<bool> AddCardToInbox(AddInboxCard addInboxCard);
    }
}

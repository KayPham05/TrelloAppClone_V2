using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace TodoAppAPI.Interfaces
{
    public interface ICloudinaryService
    {
        Task<(string Url, string FileName, string PublicId)?> UploadFileAsync(IFormFile file);
    }
}

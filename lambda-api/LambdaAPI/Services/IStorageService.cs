using Amazon.S3.Model;
using LambdaAPI.DTO;

namespace LambdaAPI.Services
{
    public interface IStorageService
    {
        Task<PutObjectResponse> UploadFile(IFormFile file);

        Task<IList<S3ObjectResponse>> GetFiles();

        Task<ObjectResponse> Get(string objeckey);

        Task<DeleteObjectResponse> DeleteFile(string objeckey);
    }
}
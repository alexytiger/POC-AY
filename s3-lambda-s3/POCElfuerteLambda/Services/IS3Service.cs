using Amazon.S3.Model;
using System.Threading.Tasks;
using static Amazon.Lambda.S3Events.S3Event;

namespace POCElfuerteLambda.Services
{
    public interface IS3Service
    {
        Task<PutObjectResponse> UploadFile(S3EventNotificationRecord request, string guid);
    }
}
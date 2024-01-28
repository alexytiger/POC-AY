using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using System.Net;
using System.Text;
using static Amazon.Lambda.S3Events.S3Event;

namespace POCElfuerteLambda.Services.Impl
{
    public class S3Service : IS3Service
    {
        private readonly IAmazonS3 _amazonS3;
        private readonly IOptionsSnapshot<StorageOptions> _options;

        public S3Service(IOptionsSnapshot<StorageOptions> options, IAmazonS3 amazonS3)
        {
            _options = options ?? throw new ArgumentNullException(nameof(options));
            _amazonS3 = amazonS3 ?? throw new ArgumentNullException(nameof(amazonS3));
        }

        public async Task<PutObjectResponse> UploadFile(S3EventNotificationRecord request, string guid)
        {
            string jsonData = JsonConvert.SerializeObject(request.S3);
            using MemoryStream stream = new MemoryStream(Encoding.UTF8.GetBytes(jsonData));
            var fileObject = new PutObjectRequest()
            {
                BucketName = _options.Value.BucketName,
                Key = guid,
                InputStream = stream,
                ContentType = "application/json",
            };

            var result = await _amazonS3.PutObjectAsync(fileObject);

            if (result.HttpStatusCode != HttpStatusCode.OK)
            {
                throw new Exception("this file cannot be processed.");
            }

            return result;
        }
    }
}
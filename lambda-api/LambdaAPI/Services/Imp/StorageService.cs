using Amazon.S3;
using Amazon.S3.Model;
using AutoMapper;
using LambdaAPI.DTO;

namespace LambdaAPI.Services.Imp
{
    public class StorageService : IStorageService
    {
        private readonly IConfiguration _configuration;
        private readonly IAmazonS3 _amazonS3;
        private readonly IMapper _mapper;
        private readonly ILogger<StorageService> _logger;

        public StorageService(IConfiguration configuration, IAmazonS3 amazonS3, IMapper mapper, ILogger<StorageService> logger)
        {
            _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            _amazonS3 = amazonS3 ?? throw new ArgumentNullException(nameof(configuration));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger)); ;
        }

        public async Task<DeleteObjectResponse> DeleteFile(string objeckey)
        {
            var request = new DeleteObjectRequest()
            {
                BucketName = GetBucketName(),
                Key = objeckey
            };

            var response = await _amazonS3.DeleteObjectAsync(request);
            return response;
        }

        public async Task<ObjectResponse> Get(string objeckey)
        {
            var request = new GetObjectRequest()
            {
                BucketName = GetBucketName(),
                Key = objeckey
            };

            var responseObject = await _amazonS3.GetObjectAsync(request);
            var response = _mapper.Map<ObjectResponse>(responseObject);
            return response;
        }

        public async Task<IList<S3ObjectResponse>> GetFiles()
        {
            var request = new ListObjectsRequest()
            {
                BucketName = GetBucketName(),
            };

            IList<S3ObjectResponse> response = new List<S3ObjectResponse>();

            try
            {
                var resultObjects = await _amazonS3.ListObjectsAsync(request);
                response = _mapper.Map<IList<S3ObjectResponse>>(resultObjects.S3Objects);
                _logger.LogInformation("Processed File");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return response;
        }

        public async Task<PutObjectResponse> UploadFile(IFormFile file)
        {
            string guid = Guid.NewGuid().ToString();
            var request = new PutObjectRequest()
            {
                BucketName = GetBucketUpload(),
                Key = guid,
                InputStream = file.OpenReadStream(),
                ContentType = file.ContentType
            };

            var response = await _amazonS3.PutObjectAsync(request);
            return response;
        }

        private string GetBucketUpload()
        {
            return _configuration.GetValue<string>("Storage:BucketUpload");
        }

        private string GetBucketName()
        {
            return _configuration.GetValue<string>("Storage:BucketDownload");
        }
    }
}
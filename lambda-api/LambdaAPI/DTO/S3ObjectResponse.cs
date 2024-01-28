namespace LambdaAPI.DTO
{
    public class S3ObjectResponse
    {
        public string BucketName { get; set; }
        public string Key { get; set; }
        public long Size { get; set; }
        public string ETag { get; set; }
        public DateTime LastModified { get; set; }
        public OwnerResponse Owner { get; set; }
    }
}
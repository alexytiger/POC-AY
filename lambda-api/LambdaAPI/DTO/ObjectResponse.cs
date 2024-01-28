namespace LambdaAPI.DTO
{
    public class ObjectResponse
    {
        public string BucketName { get; set; }
        public string Key { get; set; }
        public long Size { get; set; }
        public DateTime LastModified { get; set; }
        public string ETag { get; set; }
        public string ContentType { get; set; }
    }
}
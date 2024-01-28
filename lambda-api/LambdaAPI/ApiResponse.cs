using Newtonsoft.Json;

namespace LambdaAPI
{
    public class ApiResponse
    {
        public int StatusCode { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Message { get; set; }

        public ApiResponse(int statusCode, string message = null)
        {
            StatusCode = statusCode;
            Message = message;
        }
    }
}
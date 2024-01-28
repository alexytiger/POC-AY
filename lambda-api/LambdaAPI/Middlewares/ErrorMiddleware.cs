using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Net;

namespace LambdaAPI.Middlewares
{
    public class ErrorMiddleware
    {
        private readonly RequestDelegate _next;
        private string Message { get; set; }

        public ErrorMiddleware(RequestDelegate next)
        {
            _next = next ?? throw new ArgumentNullException(nameof(next));
        }

        public async Task Invoke(HttpContext context)
        {
            Message = string.Empty;

            try
            {
                await _next.Invoke(context);
            }
            catch (Exception ex)
            {
                Message = ex.Message;
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            }

            if (!context.Response.HasStarted && context.Response.StatusCode != (int)HttpStatusCode.NoContent)
            {
                context.Response.ContentType = "application/json";
                var response = new ApiResponse(context.Response.StatusCode, Message);

                var json = JsonConvert.SerializeObject(response, new JsonSerializerSettings
                {
                    ContractResolver = new CamelCasePropertyNamesContractResolver()
                });

                await context.Response.WriteAsync(json);
            }
        }
    }
}
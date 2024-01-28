using Microsoft.OpenApi.Models;

namespace LambdaAPI.Extension
{
    public static class SwaggerConfigurationExtensions
    {
        private const string Title = "LambdaAPI {0}";

        public static IServiceCollection ConfigureSwagger(this IServiceCollection services) =>
            services
            .AddEndpointsApiExplorer()
            .AddSwaggerGen(options =>
            {
                options.SwaggerDoc("V1", new OpenApiInfo()
                {
                    Title = string.Format(Title, "V1"),
                    Version = "V1.0"
                });
                options.ResolveConflictingActions(apiDescriptions => apiDescriptions.First());
                options.CustomSchemaIds(x => x.FullName);
            });

        public static IApplicationBuilder ConfigureSwaggerUI(this IApplicationBuilder app) =>
            app.UseSwaggerUI(options =>
            {
                options.SwaggerEndpoint($"/swagger/V1/swagger.json", "V1.0");
            });
    }
}
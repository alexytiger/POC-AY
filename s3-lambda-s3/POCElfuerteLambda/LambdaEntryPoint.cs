using Amazon.Lambda.Core;
using Amazon.Lambda.S3Events;
using Amazon.Lambda.Serialization.SystemTextJson;
using Amazon.S3;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using POCElfuerteLambda.Services;
using POCElfuerteLambda.Services.Impl;
using System.Net;
using System.Text;

[assembly: LambdaSerializer(typeof(DefaultLambdaJsonSerializer))]

namespace POCElfuerteLambda
{
    public class LambdaEntryPoint
    {
        public async Task<HttpResponseMessage> FunctionHandlerAsync(S3Event evt, ILambdaContext context)
        {
            var serviceCollection = new ServiceCollection();
            ConfigureServices(serviceCollection);
            var serviceProvider = serviceCollection.BuildServiceProvider();

            var storageService = serviceProvider.GetRequiredService<IS3Service>();
            string guid = Guid.NewGuid().ToString();
            if (evt.Records.Count > 0)
            {
                var result = await storageService.UploadFile(evt.Records[0], guid);

                var response = new HttpResponseMessage();
                response.StatusCode = HttpStatusCode.OK;
                response.Content = new StringContent(result.ETag, Encoding.UTF8, "text/plain");

                return response;
            }

            throw new Exception("this file cannot be processed.");
        }

        public void ConfigureServices(IServiceCollection services)
        {
            var environmentName = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");

            IConfigurationBuilder configurationBuilder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{environmentName}.json", optional: true, reloadOnChange: true);

            var configuration = configurationBuilder.Build();
            var awsOptions = configuration.GetAWSOptions();

            services.
                AddSingleton<IConfiguration>(configuration)
                .AddAWSService<IAmazonS3>()
                .AddDefaultAWSOptions(awsOptions)
                .Configure<StorageOptions>(opts =>
                {
                    opts.BucketName = configuration.GetSection("Storage")["Bucket"];
                })
                .AddTransient<IS3Service, S3Service>();
        }
    }
}
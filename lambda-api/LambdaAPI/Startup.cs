using Amazon.S3;
using LambdaAPI.Extension;
using LambdaAPI.Filters;
using LambdaAPI.Middlewares;
using LambdaAPI.Services;
using LambdaAPI.Services.Imp;
using Newtonsoft.Json;

namespace LambdaAPI;

public class Startup
{
    public Startup(IWebHostEnvironment environment)
    {
        var builder = new ConfigurationBuilder()
             .SetBasePath(environment.ContentRootPath)
             .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
             .AddJsonFile($"appsettings.{environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
             .AddEnvironmentVariables();
        Configuration = builder.Build();

        env = environment;
    }

    public IWebHostEnvironment env { get; }
    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container
    public void ConfigureServices(IServiceCollection services)
    {
        services.ConfigureSwagger();

        services.AddCors(opts =>
        {
            opts.AddDefaultPolicy(builder =>
            builder.SetIsOriginAllowed(_ => true)
            .AllowAnyMethod()
            .AllowAnyOrigin());
        });

        services.AddAutoMapper(typeof(Startup));

        var awsOptions = Configuration.GetAWSOptions();
        services
            .AddAWSService<IAmazonS3>()
            .AddDefaultAWSOptions(awsOptions);

        services.AddTransient<IStorageService, StorageService>();

        services.AddControllers(config =>
        {
            config.Filters.Add(typeof(ApiValidationFilterAttribute));
            config.EnableEndpointRouting = false;
        })
        .AddNewtonsoftJson(opt =>
        {
            opt.SerializerSettings.ReferenceLoopHandling = ReferenceLoopHandling.Ignore;
        });
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseSwagger();
            app.ConfigureSwaggerUI();
            app.UseDeveloperExceptionPage();
        }

        app.UseHttpsRedirection();

        app.UseRouting();

        app.UseCors();

        app.UseMiddleware(typeof(ErrorMiddleware));

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
            endpoints.MapGet("/", async context =>
            {
                await context.Response.WriteAsync("Welcome to running ASP.NET Core on AWS Lambda");
            });
        });
    }
}
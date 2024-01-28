using Amazon.S3.Model;
using AutoMapper;
using LambdaAPI.DTO;

namespace LambdaAPI
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Owner, OwnerResponse>();

            CreateMap<S3Object, S3ObjectResponse>();

            CreateMap<GetObjectResponse, ObjectResponse>()
                .ForMember(o => o.BucketName, opts => opts.MapFrom(source => source.BucketName))
                .ForMember(o => o.Key, opts => opts.MapFrom(source => source.Key))
                .ForMember(o => o.Size, opts => opts.MapFrom(source => source.ContentLength))
                .ForMember(o => o.LastModified, opts => opts.MapFrom(source => source.LastModified.ToLocalTime()))
                .ForMember(o => o.ContentType, opts => opts.MapFrom(source => source.Headers["Content-Type"]));
        }
    }
}
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Net;

namespace LambdaAPI
{
    public class ApiBadRequestResponse : ApiResponse
    {
        public IEnumerable<string> Errors { get; }

        public ApiBadRequestResponse(ModelStateDictionary modelState) : base((int)HttpStatusCode.BadRequest)
        {
            if (modelState.IsValid)
            {
                throw new ArgumentException("modelState must be invalid", nameof(modelState));
            }

            Errors = modelState.SelectMany(x => x.Value.Errors).Select(x => x.ErrorMessage).ToArray();
        }
    }
}
using LambdaAPI.Services;
using Microsoft.AspNetCore.Mvc;
using System.Net;


namespace LambdaAPI.Controllers;

[Route("api/[controller]")]
[ApiController]
public class FileController : Controller
{
    private readonly IStorageService _storageService;

    public FileController(IStorageService storageService)
    {
        _storageService = storageService ?? throw new ArgumentNullException(nameof(storageService));
    }

    [HttpGet]
    [Route("list")]
    [ProducesResponseType((int)HttpStatusCode.OK)]
    public async Task<IActionResult> GetFiles()
    {
        var result = await _storageService.GetFiles();
        return Ok(result);
    }

    [HttpGet]
    [Route("{key}")]
    [ProducesResponseType((int)HttpStatusCode.OK)]
    public async Task<IActionResult> Get(string key)
    {
        var result = await _storageService.Get(key);
        return Ok(result);
    }

    [HttpPost]
    [Route("upload")]
    [ProducesResponseType((int)HttpStatusCode.OK)]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Post(IFormFile file)
    {
        var result = await _storageService.UploadFile(file);
        return Ok(result);
    }

    [HttpDelete]
    [Route("{key}")]
    [ProducesResponseType((int)HttpStatusCode.OK)]
    public async Task<IActionResult> Delete(string key)
    {
        var result = await _storageService.DeleteFile(key);
        return Ok(result);
    }
}
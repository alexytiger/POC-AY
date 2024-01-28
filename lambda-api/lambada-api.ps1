param ([String] $artifactStagingDirectory)
Write-Host "StagingDirectory $artifactStagingDirectory"

try {
		openssl dgst -sha256 -binary "$artifactStagingDirectory/_POC-Elfuerte/lambda/LambdaAPI.zip" | openssl enc -base64 | tr -d "\n" > "$artifactStagingDirectory/_POC-Elfuerte/lambda/LambdaAPI.zip.base64sha256"
		Write-Host "Generated $artifactStagingDirectory/_POC-Elfuerte/lambda/LambdaAPI.zip.base64sha256"
} 
catch {
		$ErrorMessage = $_.Exception.Message
		Write-Host "Exception while executing base64sha256.ps1 ErrorMessage: $ErrorMessage"
}
param (
  $PullRequestNumber,
  $VsoPRCreatorVariable,
  $AuthToken
)

$headers = @{ }

if ($AuthToken) {
    $headers = @{
        Authorization = "bearer $AuthToken"
    }
}

try
{
    $prApiUrl = "https://api.github.com/repos/Azure/azure-sdk-tools/pulls/${PullRequestNumber}"
    $response = Invoke-RestMethod -Headers $headers $prApiUrl
    Write-Host "##vso[task.setvariable variable=$VsoPRCreatorVariable;]$($response.user.login)"
}
catch
{
    Write-Error "Invoke-RestMethod ${prApiUrl} failed with exception:`n$_"
    exit 1
}


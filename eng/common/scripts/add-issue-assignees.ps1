param(
    [Parameter(Mandatory = $true)]
    $RepoOwner,

    [Parameter(Mandatory = $true)]
    $RepoName,

    [Parameter(Mandatory = $false)]
    $GitHubUsers = "",

    [Parameter(Mandatory = $true)]
    $IssueNumber,
  
    [Parameter(Mandatory = $true)]
    $AuthToken
)

function AddMembers($memberName, $additionSet) {
  $headers = @{
    Authorization = "bearer $AuthToken"
  }
  $uri = "https://api.github.com/repos/$RepoOwner/$RepoName/issues/$IssueNumber"
  $errorOccurred = $false

  foreach ($id in $additionSet) {
    try {
      $postResp = @{}
      $postResp[$memberName] = @($id)
      $postResp = $postResp | ConvertTo-Json

      Write-Host $postResp
      $resp = Invoke-RestMethod -Method Patch -Headers $headers -Body $postResp -Uri $uri -MaximumRetryCount 3
      $resp | Write-Verbose
    }
    catch {
      Write-Host "Error attempting to add $user`n$_"
      $errorOccurred = $true
    }
  }

  return $errorOccurred
}

if (-not $GitHubUsers) {
  Write-Host "No user provided for addition, exiting."
  exit 0
}

$userAdditions = @($GitHubUsers.Split(",") | % { $_.Trim() } | ? { return $_ })

$errorsOccurredAddingUsers = AddMembers -memberName "assignees" -additionSet $userAdditions

if ($errorsOccurredAddingUsers) {
  exit 1
}

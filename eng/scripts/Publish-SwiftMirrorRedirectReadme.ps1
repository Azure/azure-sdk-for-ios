param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $GitSourcePath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $GitDestinationPath,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $UpstreamBranch = "main",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $Repository = "azure"
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot/../common/scripts common.ps1)

Push-Location $GitDestinationPath

git checkout $UpstreamBranch

$repoContents = (Get-ChildItem -Attributes Hidden,!Hidden -Exclude ".git").Name
# If there is a diff from a single README.md file, clear the repo
if (Compare-Object $repoContents @("README.md")) {
    $repoContents | Remove-Item -Recurse -Force
    LogDebug "Adding commit to clear $UpstreamBranch branch contents"
    git add -u
    git -c user.name="azure-sdk" -c user.email="azuresdk@microsoft.com" commit -m "Clear $UpstreamBranch branch contents"
}

Copy-Item -Path $GitSourcePath/eng/mirror.README.md -Destination README.md
$repoUrl = git config --get remote.origin.url
# Convert ssh remotes to https urls
if ($repoUrl -imatch ".*($Repository/SwiftPM-.*)") {
    $repoUrl = "https://github.com/$($matches[1])"
}
$readme = cat README.md
$readme.Replace("#mirror_repo_url", $repoUrl) | Out-File README.md

if (git status --porcelain) {
    LogDebug "Committing mirror README.md to $UpstreamBranch"
    git add README.md
    git -c user.name="azure-sdk" -c user.email="azuresdk@microsoft.com" commit -m "Add/update mirror README"
}

if (git diff origin/$UpstreamBranch..HEAD) {
    LogDebug "Pushing changes to $UpstreamBranch"
    git push origin $UpstreamBranch
}

Pop-Location

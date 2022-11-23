param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $GitSourcePath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $GitDestinationPath
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot/../common/scripts common.ps1)

try {

    Push-Location -Path $GitDestinationPath

    LogDebug "Searching for *.podspec.json files in: $GitSourcePath"
    $podspecFiles = Get-ChildItem -Path $GitSourcePath -Filter *.podspec.json
    LogDebug "Found $($podspecFiles.Count) *.podspec.json files in: $GitSourcePath"

    if ($podspecFiles.Count -ne 1) {
        throw "The path $GitSourcePath must contain one, and only one *.podspec.json file."
    }

    LogDebug "Parsing $($podspecFiles[0].Name)"
    $podspec = Get-Content -Raw -Path $podspecFiles[0] | ConvertFrom-Json
    $name = $podspec.name
    $version = $podspec.version

    LogDebug "Publishing: $name@$version"


    $orphanBranchName = [Guid]::NewGuid()
    LogDebug "Checking out orphan branch: $orphanBranchName"
    git checkout --orphan $orphanBranchName
    git reset --hard

    LogDebug "Copying package to orphan branch"
    Copy-Item -Path $GitSourcePath/* -Destination $GitDestinationPath -Recurse

    LogDebug "Committing files to branch"
    git add .
    git -c user.name="azure-sdk" -c user.email="azuresdk@microsoft.com" commit -m "Releasing $version"

    LogDebug "Tagging and pushing version: $version"
    git -c user.name="azure-sdk" -c user.email="azuresdk@microsoft.com" tag -a $version -m "$version"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to tag repository because tag $version already exists!"
    }

    git push origin $version
}
finally {
    Pop-Location
}
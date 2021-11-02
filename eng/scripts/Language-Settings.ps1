$Language = "swift"
$LanguageDisplayName = "iOS"
$PackageRepository = "CocoaPods"
$packagePattern = "*.podspec.json"

function Get-AllPackageInfoFromRepo($serviceDirectory)
{
    $allPackageProps = @()
    $searchPath = "sdk"

    if ($serviceDirectory)
    {
        $searchPath = Join-Path sdk ${serviceDirectory}
    }

    $podSpecFiles = Get-ChildItem -Path $searchPath -Include *.podspec.json -Recurse

    foreach ($file in $podSpecFiles)
    {
        $podSpecContent = Get-Content -Path $file | ConvertFrom-Json
        $pkgPath = $file.Directory.FullName
        $pkgName = $podSpecContent.Name
        $pkgVersion = $podSpecContent.Version

        $pkgProp = [PackageProps]::new($pkgName, $pkgVersion, $pkgPath, $serviceDirectory)
        $pkgProp.SdkType = "client"
        $pkgProp.IsNewSdk = $true
        $pkgProp.ArtifactName = $pkgName

        $allPackageProps += $pkgProp
    }

    return $allPackageProps
}

function SetPackageVersion ($PackageName, $Version, $ReleaseDate, $ReplaceLatestEntryTitle=$true)
{
  if($null -eq $ReleaseDate)
  {
    $ReleaseDate = Get-Date -Format "yyyy-MM-dd"
  }
  & "$EngDir/scripts/Update-PkgVersion.ps1" -PackageName $PackageName `
  -NewVersionString $Version -ReleaseDate $ReleaseDate -ReplaceLatestEntryTitle $ReplaceLatestEntryTitle
}

function ComputeCocoaPodsSpecUrl($PackageId, $PackageVersion)
{
    # The CocoaPods spec repo is a repository for JSONified versions of the PodSpec file. The path to the JSON
    # file is derived from the name of the package where the repo URL relative URL is:
    #
    #   Spec/x/y/z/[Package]/[Version]/[Package].podspec.json
    #
    # The x/y/z values are the first three characters from the MD5 hash of the package name. For example 4/4/a
    # for the package AzureCore.

    $csp = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $encoder = New-Object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($csp.ComputeHash($encoder.GetBytes($PackageId)))
    $hash = $hash.ToLower() -replace '-', ''
    $url = "https://raw.githubusercontent.com/CocoaPods/Specs/blob/master/Specs/$($hash[0])/$($hash[1])/$($hash[2])/$PackageId/$PackageVersion/$PackageId.podspec.json"
    return $url
}

# Returns the CocoaPods trunk publish status of a package id and version.
function IsCocoaPodsPackageVersionPublished($PackageId, $PackageVersion)
{
    $url = ComputeCocoaPodsSpecUrl -PackageId $PackageId -PackageVersion $PackageVersion

    Write-Host "Checking $url"

    try
    {
        $podspecContent = Invoke-RestMethod -MaximumRetryCount 3 -RetryIntervalSec 10 -Method "GET" -Uri $url

        if ($podspecContent -ne $null -or $podspecContent.Length -eq 0)
        {
        return $true
        }
        else
        {
        return $false
        }
    }
    catch
    {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription

        # if this is 404ing, then this pkg has never been published before
        if ($statusCode -eq 404) {
        return $false
        }

        Write-Host "VersionCheck to CocoaPods for packageId $PackageId failed with statuscode $statusCode"
        Write-Host $statusDescription
        exit(1)
    }
    return $false
}

# Parse out package publishing information given a CocoaPod spec files
function Get-swift-PackageInfoFromPackageFile ($pkg, $workingDirectory)
{
    $podspec = Get-Content -Raw -Path $pkg | ConvertFrom-Json
    $pkgId = $podspec.name
    $pkgVersion = $podspec.version
    $docsReadMeName = $pkgId -replace "^Azure" , ""
    $releaseNotes = ""
    $readmeContent = ""

    $changeLogLoc = @(Get-ChildItem -Path $pkg.DirectoryName -Recurse -Include "$($pkg.Basename)-changelog.md")[0]
    if ($changeLogLoc) {
        $releaseNotes = Get-ChangeLogEntryAsString -ChangeLogLocation $changeLogLoc -VersionString $pkgVersion
    }

    $readmeContentLoc = @(Get-ChildItem -Path $pkg.DirectoryName -Recurse -Include "$($pkg.Basename)-readme.md")[0]
    if ($readmeContentLoc) {
        $readmeContent = Get-Content -Raw $readmeContentLoc
    }

    return New-Object PSObject -Property @{
       PackageId      = $pkgId
       PackageVersion = $pkgVersion
       ReleaseTag     = "$($pkgId)_$($pkgVersion)"
       Deployable     = $forceCreate -or !(IsCocoaPodsPackageVersionPublished -PackageId $pkgId -PackageVersion $pkgVersion)
       ReleaseNotes   = $releaseNotes
       ReadmeContent  = $readmeContent
       DocsReadMeName = $docsReadMeName
    }
}
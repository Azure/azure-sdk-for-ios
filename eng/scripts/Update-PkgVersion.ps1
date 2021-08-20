
[CmdletBinding()]
Param (
  [Parameter(Mandatory=$True)]
  [string] $PackageName,
  [string] $NewVersionString,
  [string] $ReleaseDate
)

. (Join-Path $PSScriptRoot ".." common scripts common.ps1)

$pkgProperties = Get-PkgProperties -PackageName $PackageName
$packageVersion = $pkgProperties.Version

$packageSemVer = [AzureEngSemanticVersion]::new($packageVersion)

if ([System.String]::IsNullOrEmpty($NewVersionString))
{
    $packageSemVer.IncrementAndSetToPrerelease()
    & "${EngCommonScriptsDir}/Update-ChangeLog.ps1" -Version $packageSemVer.ToString() `
    -ChangelogPath $pkgProperties.ChangeLogPath -Unreleased $True
}
else
{
    $packageSemVer = [AzureEngSemanticVersion]::new($NewVersionString)
    & "${EngCommonScriptsDir}/Update-ChangeLog.ps1" -Version $packageSemVer.ToString() `
    -ChangelogPath $pkgProperties.ChangeLogPath -Unreleased $False `
    -ReplaceLatestEntryTitle $True -ReleaseDate $ReleaseDate
}

$podSpecFile = Join-Path $pkgProperties.DirectoryPath "$($pkgProperties.Name).podspec.json"
$podSpecContent = Get-Content -Path $podSpecFile | ConvertFrom-Json

$podSpecContent.Version = $packageSemVer.ToString()
Set-Content -Path $podSpecFile -Value ($podSpecContent | ConvertTo-Json) -NoNewline
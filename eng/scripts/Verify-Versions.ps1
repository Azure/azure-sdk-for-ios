param(
    [Parameter(Mandatory=$true)][string]$Path
)

Write-Host "Searching for *.podspec.json files in $Path"
$podspecFiles = Get-ChildItem -Path $Path -Filter *.podspec.json

if ($podspecFiles.Count -gt 0) {
    Write-Host "Found $($podspecFiles.Length) *.podspec.json files."
    $podspecFile | Format-Table
} else {
    throw "No *.podspec.json files found."
}

Write-Host "Parsing *.podspec.json files."
$podspecs = $podspecFiles | % { Get-Content $_ | ConvertFrom-Json }
$podspecs | Format-Table name,version

Write-Host "Checking version alignment."

[Array]$versionGroups = $podspecs | Group-Object -Property version

if ($versionGroups.Length -gt 1) {
     throw "Podspec versions are not aligned."
} else {
    Write-Host "All versions are aligned to: $($versionGroups.Name)"
}


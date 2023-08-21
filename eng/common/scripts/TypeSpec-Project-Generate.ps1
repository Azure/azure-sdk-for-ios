# For details see https://github.com/Azure/azure-sdk-tools/blob/main/doc/common/TypeSpec-Project-Scripts.md

[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string] $ProjectDirectory,
    [string] $TypespecAdditionalOptions = $null, ## addtional typespec emitter options, separated by semicolon if more than one, e.g. option1=value1;option2=value2
    [switch] $SaveInputs = $false ## saves the temporary files during execution, default false
)

$ErrorActionPreference = "Stop"
. $PSScriptRoot/Helpers/PSModule-Helpers.ps1
. $PSScriptRoot/common.ps1
Install-ModuleIfNotInstalled "powershell-yaml" "0.4.1" | Import-Module

function NpmInstallForProject([string]$workingDirectory) {
    Push-Location $workingDirectory
    try {
        $currentDur = Resolve-Path "."
        Write-Host "Generating from $currentDur"

        if (Test-Path "package.json") {
            Remove-Item -Path "package.json" -Force
        }

        if (Test-Path ".npmrc") {
            Remove-Item -Path ".npmrc" -Force
        }

        if (Test-Path "node_modules") {
            Remove-Item -Path "node_modules" -Force -Recurse
        }

        if (Test-Path "package-lock.json") {
            Remove-Item -Path "package-lock.json" -Force
        }

        #default to root/eng/emitter-package.json but you can override by writing
        #Get-${Language}-EmitterPackageJsonPath in your Language-Settings.ps1
        $emitterPackageJson = Join-Path $RepoRoot "eng/emitter-package.json"
        
        if (Test-Path "Function:$GetEmitterPackageJsonPathFn") {
          $emitterPackageJson = &$GetEmitterPackageJsonPathFn
        }

        #default to root/eng/emitter-package.json but you can override by writing
        #Get-${Language}-EmitterPackageLockPath in your Language-Settings.ps1
        $emitterPackageLock = Join-Path $RepoRoot "eng/emitter-package-lock.json"

        if (Test-Path "Function:$GetEmitterPackageLockPathFn") {
            $emitterPackageLock = &$GetEmitterPackageLockPathFn
        }

        Write-Host("Copying package.json from $emitterPackageJson")
        Copy-Item -Path $emitterPackageJson -Destination "package.json" -Force

        if (Test-Path $emitterPackageLock) {
          Write-Host("Copying package-lock.json from $emitterPackageJson")
          Copy-Item -Path $emitterPackageLock -Destination "package-lock.json" -Force
        }

        Write-Host "Creating .npmrc using public/azure-sdk-for-js-test-autorest feed."
        $useAlphaNpmRegistry = (Get-Content $emitterPackageJson -Raw).Contains("-alpha.")

        if ($useAlphaNpmRegistry) {
          $npmrcPath = "$workingDirectory/.npmrc"
          Write-Host "Package.json contains '-alpha.' in the version, Creating .npmrc using public/azure-sdk-for-js-test-autorest feed."
          "registry=https://pkgs.dev.azure.com/azure-sdk/public/_packaging/azure-sdk-for-js-test-autorest@local/npm/registry/ `n`nalways-auth=true" | Out-File $npmrcPath
        }

        npm install | Tee-Object -Variable npmInstallOutput

        if ($LASTEXITCODE) { 
          if ($npmInstallOutput -contains "code E401") {
            Write-Host ""
            Write-Host "npm install failed with code E401. This is likely due to missing or stale credentials."
            Write-Host "Install and run the vsts-npm-auth package to refresh your credentials:"
            Write-Host "    npm install -g vsts-npm-auth --registry https://registry.npmjs.com --always-auth false"
            Write-Host "    vsts-npm-auth -config `"$npmrcPath`""
          }

          exit $LASTEXITCODE
        }
    }
    finally {
        Pop-Location
    }
}

$resolvedProjectDirectory = Resolve-Path $ProjectDirectory
$emitterName = &$GetEmitterNameFn
$typespecConfigurationFile = Resolve-Path "$ProjectDirectory/tsp-location.yaml"

Write-Host "Reading configuration from $typespecConfigurationFile"
$configuration = Get-Content -Path $typespecConfigurationFile -Raw | ConvertFrom-Yaml

$specSubDirectory = $configuration["directory"]
$innerFolder = Split-Path $specSubDirectory -Leaf

$tempFolder = "$ProjectDirectory/TempTypeSpecFiles"
$npmWorkingDir = Resolve-Path $tempFolder/$innerFolder
$mainTypeSpecFile = If (Test-Path "$npmWorkingDir/client.*") { Resolve-Path "$npmWorkingDir/client.*" } Else { Resolve-Path "$npmWorkingDir/main.*"}

try {
    Push-Location $npmWorkingDir
    NpmInstallForProject $npmWorkingDir

    if ($LASTEXITCODE) { exit $LASTEXITCODE }

    if (Test-Path "Function:$GetEmitterAdditionalOptionsFn") {
        $emitterAdditionalOptions = &$GetEmitterAdditionalOptionsFn $resolvedProjectDirectory
        if ($emitterAdditionalOptions.Length -gt 0) {
            $emitterAdditionalOptions = " $emitterAdditionalOptions"
        }
    }
    $typespecCompileCommand = "npx tsp compile $mainTypeSpecFile --emit $emitterName$emitterAdditionalOptions"
    if ($TypespecAdditionalOptions) {
        $options = $TypespecAdditionalOptions.Split(";");
        foreach ($option in $options) {
            $typespecCompileCommand += " --option $emitterName.$option"
        }
    }

    if ($SaveInputs) {
        $typespecCompileCommand += " --option $emitterName.save-inputs=true"
    }

    Write-Host($typespecCompileCommand)
    Invoke-Expression $typespecCompileCommand

    if ($LASTEXITCODE) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}

$shouldCleanUp = !$SaveInputs
if ($shouldCleanUp) {
    Remove-Item $tempFolder -Recurse -Force
}
exit 0

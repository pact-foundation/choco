$ErrorActionPreference = 'Stop'

$packageName = 'pact-broker-client'
$url64 = 'https://github.com/pact-foundation/pact-broker-cli/releases/download/v0.8.6/pact-broker-cli-x86_64-pc-windows-msvc.zip'
$urlARM64 = 'https://github.com/pact-foundation/pact-broker-cli/releases/download/v0.8.6/pact-broker-cli-x86_64-pc-windows-msvc.zip'
$checksum64 = 'bb639caabdcfde754c4059b99f181efa9f64a5a87699bf185c8a75b7c7e8dc40'
$checksumARM64 = 'bb639caabdcfde754c4059b99f181efa9f64a5a87699bf185c8a75b7c7e8dc40'

# Determine architecture
$is64bit = [System.Environment]::Is64BitOperatingSystem
$isARM64 = $env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64'

# Get package parameters
$packageParameters = Get-PackageParameters

# Allow user to override architecture detection via package parameters
if ($packageParameters.ContainsKey('ForceARM64')) {
    $isARM64 = $true
    Write-Host "Forcing ARM64 architecture via package parameter" -ForegroundColor Yellow
} elseif ($packageParameters.ContainsKey('Forcex64')) {
    $isARM64 = $false
    Write-Host "Forcing x64 architecture via package parameter" -ForegroundColor Yellow
}

if ($isARM64) {
    $url = $urlARM64
    $checksum = $checksumARM64
    $architecture = 'ARM64'
} elseif ($is64bit) {
    $url = $url64
    $checksum = $checksum64
    $architecture = 'x64'
} else {
    throw "32-bit Windows is not supported. Please use a 64-bit or ARM64 system."
}

Write-Host "Installing Pact Broker Client for Windows $architecture..." -ForegroundColor Green

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$executableName = 'pact-broker-cli.exe'
$executablePath = Join-Path $toolsDir $executableName
$shimName = 'pact-broker-client'

$packageArgs = @{
  packageName   = $packageName
  url64bit      = $url
    unzipLocation = $toolsDir
  checksum64    = $checksum
  checksumType64= 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

if (-not (Test-Path $executablePath)) {
        throw "Expected executable not found after extraction: $executablePath"
}

# Prevent automatic shim for pact-broker-cli.exe; we only expose pact-broker-client.
New-Item -Path ("$executablePath.ignore") -ItemType File -Force | Out-Null

Install-BinFile -Name $shimName -Path $executablePath

Write-Host ""
Write-Host "Pact Broker Client installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Quick start:" -ForegroundColor Yellow
Write-Host "  pact-broker-client --help           # Show all available commands"
Write-Host "  pact-broker-client publish          # Publish pacts to broker"
Write-Host "  pact-broker-client can-i-deploy     # Check deployment safety"
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  - CLI Docs: https://github.com/pact-foundation/pact-broker-cli/blob/main/README.md"
Write-Host "  - Pact Docs: https://docs.pact.io"
Write-Host ""
Write-Host "Ready to use! Try 'pact-broker-client --help' to get started." -ForegroundColor Green
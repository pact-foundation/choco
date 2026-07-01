$ErrorActionPreference = 'Stop'

$packageName = 'pact-stub-server'
$url64 = 'https://github.com/pact-foundation/pact-stub-server/releases/download/v0.7.1/pact-stub-server-windows-x86_64.exe.gz'
$urlARM64 = 'https://github.com/pact-foundation/pact-stub-server/releases/download/v0.7.1/pact-stub-server-windows-aarch64.exe.gz'
$checksum64 = '55f3a428ab3745a2e99fe3d4bf83eb538bd4cfac65cebea335c1dcc8f15902ef'
$checksumARM64 = 'fea6ac0035b893bfc0c08ebad6b1f4fe544bbd7e23fb083d1b2e508dab590a6f'

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

Write-Host "Installing Pact Stub Server for Windows $architecture..." -ForegroundColor Green

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$gzFilePath = Join-Path $toolsDir 'pact-stub-server.exe.gz'
$executablePath = Join-Path $toolsDir 'pact-stub-server.exe'

$packageArgs = @{
  packageName   = $packageName
  url64bit      = $url
  fileFullPath  = $gzFilePath
  checksum64    = $checksum
  checksumType64= 'sha256'
}

# Download the gz file
Get-ChocolateyWebFile @packageArgs

# Decompress the gz file
if (Test-Path $gzFilePath) {
    Write-Host "Decompressing $gzFilePath..." -ForegroundColor Yellow
    
    # Use .NET System.IO.Compression.GzipStream to decompress
    Add-Type -AssemblyName System.IO.Compression
    $gzStream = New-Object System.IO.FileStream($gzFilePath, [System.IO.FileMode]::Open)
    $decompressStream = New-Object System.IO.Compression.GzipStream($gzStream, [System.IO.Compression.CompressionMode]::Decompress)
    $outputStream = New-Object System.IO.FileStream($executablePath, [System.IO.FileMode]::Create)
    
    $decompressStream.CopyTo($outputStream)
    
    $outputStream.Close()
    $decompressStream.Close()
    $gzStream.Close()
    
    # Remove the gz file
    Remove-Item -Path $gzFilePath -Force
    
    Write-Host "Decompressed to: $executablePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "Pact Stub Server installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Quick start:" -ForegroundColor Yellow
Write-Host "  pact-stub-server --help             # Show all available commands"
Write-Host "  pact-stub-server start              # Start stub server"
Write-Host "  pact-stub-server --file <pact>      # Start with specific pact file"
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  - CLI Docs: https://github.com/pact-foundation/pact-stub-server/blob/master/README.md"
Write-Host "  - Pact Docs: https://docs.pact.io"
Write-Host ""
Write-Host "Ready to use! Try 'pact-stub-server --help' to get started." -ForegroundColor Green
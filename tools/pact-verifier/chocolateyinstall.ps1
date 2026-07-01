$ErrorActionPreference = 'Stop'

$packageName = 'pact-verifier'
$url64 = 'https://github.com/pact-foundation/pact-reference/releases/download/pact_verifier_cli-v1.3.3/pact-verifier-windows-x86_64.exe.gz'
$urlARM64 = 'https://github.com/pact-foundation/pact-reference/releases/download/pact_verifier_cli-v1.3.3/pact-verifier-windows-aarch64.exe.gz'
$checksum64 = '3839e9cc2dc6fac1672712765c756ef7861fbef3d6d0c9af7bf43f7766b47925'
$checksumARM64 = '62fca25320e336ae45f073635c923a7c6781d123075fe29bcb2db1d2d8ea9020'

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

Write-Host "Installing Pact Verifier for Windows $architecture..." -ForegroundColor Green

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$gzFilePath = Join-Path $toolsDir 'pact-verifier.exe.gz'
$executablePath = Join-Path $toolsDir 'pact-verifier.exe'

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
Write-Host "Pact Verifier installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Quick start:" -ForegroundColor Yellow
Write-Host "  pact-verifier --help                # Show all available commands"
Write-Host "  pact-verifier verify                # Verify provider against pacts"
Write-Host "  pact-verifier --file <file>         # Verify from pact file"
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  - CLI Docs: https://github.com/pact-foundation/pact-reference/blob/master/rust/pact_verifier_cli/README.md"
Write-Host "  - Pact Docs: https://docs.pact.io"
Write-Host ""
Write-Host "Ready to use! Try 'pact-verifier --help' to get started." -ForegroundColor Green
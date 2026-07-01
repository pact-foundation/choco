# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# 1. See the _TODO.md that is generated top level and read through that
# 2. Follow the documentation below to learn how to create a package for the package type you are creating.
# 3. In Chocolatey scripts, ALWAYS use absolute paths - $toolsDir gets you to the package's tools directory.
$ErrorActionPreference = 'Stop' # stop on all errors
#Items that could be replaced based on what you call chocopkgup.exe with
#{{PackageName}} - Package Name (should be same as nuspec file and folder) |/p
#{{PackageVersion}} - The updated version | /v
#{{DownloadUrl}} - The url for the native file | /u
#{{PackageFilePath}} - Downloaded file if including it in package | /pp
#{{PackageGuid}} - This will be used later | /pg
#{{DownloadUrlx64}} - The 64-bit url for the native file | /u64
#{{Checksum}} - The checksum for the url | /c
#{{Checksumx64}} - The checksum for the 64-bit url | /c64
#{{ChecksumType}} - The checksum type for the url | /ct
#{{ChecksumTypex64}} - The checksum type for the 64-bit url | /ct64
$packageName = 'pact-legacy'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$pactLegacy = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  url           = 'https://github.com/pact-foundation/pact-standalone/releases/download/v2.6.4/pact-2.6.4-windows-x86_64.zip'
  softwareName  = 'pact-legacy'
  checksum      = '3e189b2958631c07de2f3ce5985fb24767a6bfc01afbb033b58753bd1ce5fb6e'
  checksumType  = 'sha256' 
}
 # https://docs.chocolatey.org/en-us/create/functions/install-chocolateypackage
Install-ChocolateyZipPackage @pactLegacy

# We need to exclude these from being shimmed to avoid polluting the users path
New-Item "$toolsDir\pact\lib\ruby\bin.real\rubyw.exe.ignore" -type file -force | Out-Null
New-Item "$toolsDir\pact\lib\ruby\bin.real\ruby.exe.ignore" -type file -force | Out-Null
# Ignore pact.bat as it conflicts with the new pact CLI
New-Item "$toolsDir\pact\bin\pact.bat.ignore" -type file -force | Out-Null
# Exclude rust binaries, now packaged seperately
New-Item "$toolsDir\pact\bin\pact-plugin-cli.exe.ignore" -type file -force | Out-Null
New-Item "$toolsDir\pact\bin\pact_mock_server_cli.exe.ignore" -type file -force | Out-Null
New-Item "$toolsDir\pact\bin\pact_verifier_cli.exe.ignore" -type file -force | Out-Null
New-Item "$toolsDir\pact\bin\pact-stub-server.exe.ignore" -type file -force | Out-Null
# Create shims for the legacy executables
Install-BinFile -Name 'pact-publish' -Path "$toolsDir\pact\bin\pact-publish.bat"
Install-BinFile -Name 'pact-broker' -Path "$toolsDir\pact\bin\pact-broker.bat"
Install-BinFile -Name 'pact-stub-service' -Path "$toolsDir\pact\bin\pact-stub-service.bat"
Install-BinFile -Name 'pactflow' -Path "$toolsDir\pact\bin\pactflow.bat"
Install-BinFile -Name 'pact-mock-service' -Path "$toolsDir\pact\bin\pact-mock-service.bat"
Install-BinFile -Name 'pact-message' -Path "$toolsDir\pact\bin\pact-message.bat"
Install-BinFile -Name 'pact-provider-verifier' -Path "$toolsDir\pact\bin\pact-provider-verifier.bat"
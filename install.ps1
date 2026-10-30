# cxtify installer for Windows (PowerShell 5.1+).
#   irm https://cxtify.com/install.ps1 | iex
# Env: CXTIFY_VERSION (default latest), CXTIFY_INSTALL_DIR (default %LOCALAPPDATA%\Programs\cxtify)
$ErrorActionPreference = 'Stop'

$repo = 'cxtify/cxtify'
$version = if ($env:CXTIFY_VERSION) { $env:CXTIFY_VERSION } else { 'latest' }
$arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { 'amd64' }
$dir = if ($env:CXTIFY_INSTALL_DIR) { $env:CXTIFY_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\cxtify' }

if ($version -eq 'latest') {
  $url = "https://github.com/$repo/releases/latest/download/cxtify_windows_$arch.zip"
} else {
  $url = "https://github.com/$repo/releases/download/$version/cxtify_windows_$arch.zip"
}

New-Item -ItemType Directory -Force -Path $dir | Out-Null
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("cxtify-" + [System.Guid]::NewGuid().ToString('n'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  Write-Host "Downloading $url"
  Invoke-WebRequest -Uri $url -OutFile (Join-Path $tmp 'cxtify.zip') -UseBasicParsing
  Expand-Archive -Path (Join-Path $tmp 'cxtify.zip') -DestinationPath $tmp -Force
  Copy-Item (Join-Path $tmp 'cxtify.exe') (Join-Path $dir 'cxtify.exe') -Force
  Set-Content -Path (Join-Path $dir 'ctxify.cmd') -Value "@echo off`r`n`"%~dp0cxtify.exe`" %*" -Encoding ASCII
} finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (($userPath -split ';') -contains $dir)) {
  [Environment]::SetEnvironmentVariable('Path', "$dir;$userPath", 'User')
  $env:Path = "$dir;$env:Path"
  Write-Host "Added $dir to your user PATH (open a new terminal to pick it up)."
}

$exe = Join-Path $dir 'cxtify.exe'
Write-Host "Installed $(& $exe version) to $exe (alias: ctxify)"
try { & $exe skill install } catch { Write-Warning "Could not install the Claude Code skill; run 'cxtify skill install' later." }

Write-Host ''
Write-Host 'Next: cxtify login'
Write-Host '      cd <project>; cxtify link <topic>'

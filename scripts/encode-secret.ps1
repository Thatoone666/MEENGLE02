param(
  [Parameter(Mandatory=$true)]
  [string]$Path
)

if (-not (Test-Path $Path)) { Write-Error "File not found: $Path"; exit 2 }
$bytes = [IO.File]::ReadAllBytes($Path)
$base64 = [Convert]::ToBase64String($bytes)
Write-Output $base64
*** End Patch
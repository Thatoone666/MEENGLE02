param(
  [string]$deviceId
)

# Helper script to run the Flutter app from project root
Push-Location "$PSScriptRoot\flutter_app"
try {
  flutter pub get
  if ($deviceId -and $deviceId.Length -gt 0) {
    flutter run -d $deviceId
  } else {
    flutter run
  }
} finally {
  Pop-Location
}

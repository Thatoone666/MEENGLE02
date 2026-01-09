# Build and deploy script for Meengle web app

# Clean the build directory
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Cyan
flutter test

# Build web app
Write-Host "🏗️ Building web app..." -ForegroundColor Cyan
flutter build web `
    --release `
    --web-renderer canvaskit `
    --dart2js-optimization O4 `
    --pwa-strategy offline-first `
    --base-href "/" `
    --source-maps false `
    --tree-shake-icons `
    --no-null-assertions

# Compress static assets
Write-Host "📦 Compressing assets..." -ForegroundColor Cyan
Get-ChildItem -Path "build/web" -Recurse -File |
    Where-Object { $_.Extension -match "\.(js|css|html)$" } |
    ForEach-Object {
        Write-Host "Compressing $($_.Name)..."
        gzip -9 -k $_.FullName
    }

Write-Host "✅ Build completed!" -ForegroundColor Green
Write-Host "Deploy the contents of the build/web directory to your hosting service."
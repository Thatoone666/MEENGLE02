@echo off
REM Meengle Complete Build Script for Windows
REM Supports frontend, backend, Docker, and deployment preparation

setlocal enabledelayedexpansion

echo ======================================
echo MEENGLE COMPLETE BUILD SCRIPT
echo ======================================
echo.

REM Parse command line arguments
set BUILD_BACKEND=false
set BUILD_FRONTEND=true
set RUN_TESTS=false
set BUILD_DOCKER=false
set CLEAN_BEFORE=false

for %%A in (%*) do (
    if "%%A"=="--backend" set BUILD_BACKEND=true
    if "%%A"=="--all" (
        set BUILD_BACKEND=true
        set BUILD_FRONTEND=true
    )
    if "%%A"=="--test" set RUN_TESTS=true
    if "%%A"=="--docker" set BUILD_DOCKER=true
    if "%%A"=="--clean" set CLEAN_BEFORE=true
    if "%%A"=="--help" (
        echo Usage: build-web.bat [options]
        echo Options:
        echo   --all        Build frontend and backend
        echo   --backend    Build backend only
        echo   --test       Run tests
        echo   --docker     Build Docker images
        echo   --clean      Clean before building
        echo   --help       Show this help message
        exit /b 0
    )
)

REM Check for required tools
echo [*] Checking required tools...
where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js is not installed. Please install it first.
    exit /b 1
)
echo [OK] Node.js %node --version%

where npm >nul 2>nul
if errorlevel 1 (
    echo [ERROR] npm is not installed. Please install it first.
    exit /b 1
)
echo [OK] npm %npm --version%

if "%BUILD_BACKEND%"=="true" (
    where git >nul 2>nul
    if errorlevel 1 (
        echo [WARN] Git is not installed. Some features may not work.
    ) else (
        echo [OK] Git installed
    )
)

echo.

REM Environment validation
echo [*] Validating environment configuration...
if not exist ".env.example" (
    echo [WARN] .env.example not found
) else (
    echo [OK] .env.example found
)

if not exist ".env" (
    echo [WARN] .env file not found. Using .env.example as template.
    copy .env.example .env >nul 2>&1
)
echo [OK] Environment configuration ready
echo.

REM Clean if requested
if "%CLEAN_BEFORE%"=="true" (
    echo [*] Cleaning previous builds...
    if exist "dist" rmdir /s /q dist >nul 2>&1
    if exist "frontend\node_modules" rmdir /s /q frontend\node_modules >nul 2>&1
    if "%BUILD_BACKEND%"=="true" (
        if exist "backend\node_modules" rmdir /s /q backend\node_modules >nul 2>&1
    )
    echo [OK] Clean complete
    echo.
)

REM Build frontend
if "%BUILD_FRONTEND%"=="true" (
    echo ======================================
    echo BUILDING FRONTEND
    echo ======================================
    echo.
    
    echo [*] Installing frontend dependencies...
    cd frontend
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install frontend dependencies
        exit /b 1
    )
    cd ..
    echo [OK] Frontend dependencies installed
    echo.

    echo [*] Building frontend assets...
    cd frontend
    call npm run build
    if errorlevel 1 (
        echo [ERROR] Frontend build failed
        exit /b 1
    )
    cd ..
    echo [OK] Frontend assets built
    echo.

    echo [*] Creating distribution structure...
    if not exist "dist" mkdir dist
    if not exist "dist\assets" mkdir dist\assets
    if not exist "dist\assets\css" mkdir dist\assets\css
    if not exist "dist\assets\js" mkdir dist\assets\js
    if not exist "dist\assets\icons" mkdir dist\assets\icons
    if not exist "dist\assets\images" mkdir dist\assets\images
    if not exist "dist\pages" mkdir dist\pages

    echo [*] Copying HTML files...
    copy frontend\index.html dist\ >nul 2>&1
    for %%f in (frontend\pages\*.html) do copy "%%f" dist\pages\ >nul 2>&1
    copy frontend\manifest.json dist\ >nul 2>&1
    copy frontend\service-worker.js dist\ >nul 2>&1

    echo [*] Verifying required pages...
    set missing_pages=0
    for %%p in (
        "login.html"
        "signup.html"
        "forgot-password.html"
        "landing.html"
        "dashboard.html"
        "terms.html"
        "privacy.html"
        "community-guidelines.html"
        "help.html"
        "safety.html"
        "error.html"
        "404.html"
        "verify-email.html"
        "profile.html"
        "settings.html"
        "subscription.html"
        "payment.html"
        "chat.html"
        "create-profile.html"
    ) do (
        if not exist "dist\pages\%%p" (
            echo [WARN] Missing page: %%p
            set /a missing_pages+=1
        )
    )

    if %missing_pages% gtr 0 (
        echo [WARN] %missing_pages% pages are missing
    ) else (
        echo [OK] All required pages found
    )
    echo.

    echo [*] Copying assets...
    if exist "frontend\assets\css" (
        xcopy /E /I /Y frontend\assets\css\* dist\assets\css\ >nul 2>&1
        echo [OK] CSS files copied
    )

    if exist "frontend\assets\js" (
        xcopy /E /I /Y frontend\assets\js\* dist\assets\js\ >nul 2>&1
        echo [OK] JavaScript files copied
    )

    if exist "frontend\assets\images" (
        xcopy /E /I /Y frontend\assets\images\* dist\assets\images\ >nul 2>&1
        echo [OK] Images copied
    )

    if exist "frontend\assets\icons" (
        xcopy /E /I /Y frontend\assets\icons\* dist\assets\icons\ >nul 2>&1
        echo [OK] Icons copied
    )
    echo.

    echo [*] Validating frontend build...
    set validation_passed=true

    if not exist "dist\index.html" (
        echo [ERROR] dist\index.html not found
        set validation_passed=false
    )

    if not exist "dist\manifest.json" (
        echo [ERROR] dist\manifest.json not found
        set validation_passed=false
    )

    if not exist "dist\service-worker.js" (
        echo [ERROR] dist\service-worker.js not found
        set validation_passed=false
    )

    if "%validation_passed%"=="true" (
        echo [OK] Frontend build validation passed
    ) else (
        echo [ERROR] Frontend build validation failed
        exit /b 1
    )
    echo.
)

REM Build backend
if "%BUILD_BACKEND%"=="true" (
    echo ======================================
    echo BUILDING BACKEND
    echo ======================================
    echo.
    
    echo [*] Installing backend dependencies...
    cd backend
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install backend dependencies
        exit /b 1
    )
    cd ..
    echo [OK] Backend dependencies installed
    echo.

    echo [*] Validating backend structure...
    set backend_valid=true
    
    for %%d in (middleware models routes services config) do (
        if not exist "backend\%%d" (
            echo [ERROR] Missing backend directory: %%d
            set backend_valid=false
        ) else (
            echo [OK] Backend/%%d found
        )
    )

    if "%backend_valid%"=="false" (
        echo [ERROR] Backend structure validation failed
        exit /b 1
    )
    echo.

    echo [*] Validating backend files...
    set backend_files_valid=true
    
    for %%f in (index.js package.json) do (
        if not exist "backend\%%f" (
            echo [WARN] Missing backend file: %%f
            set backend_files_valid=false
        )
    )
    echo.
)

REM Run tests
if "%RUN_TESTS%"=="true" (
    echo ======================================
    echo RUNNING TESTS
    echo ======================================
    echo.
    
    if "%BUILD_FRONTEND%"=="true" (
        echo [*] Running frontend tests...
        cd frontend
        if exist "package.json" (
            call npm test >nul 2>&1
            if errorlevel 1 (
                echo [WARN] Frontend tests failed or not configured
            ) else (
                echo [OK] Frontend tests passed
            )
        ) else (
            echo [WARN] Frontend test configuration not found
        )
        cd ..
    )

    if "%BUILD_BACKEND%"=="true" (
        echo [*] Running backend tests...
        cd backend
        if exist "package.json" (
            call npm test >nul 2>&1
            if errorlevel 1 (
                echo [WARN] Backend tests failed or not configured
            ) else (
                echo [OK] Backend tests passed
            )
        ) else (
            echo [WARN] Backend test configuration not found
        )
        cd ..
    )
    echo.
)

REM Build Docker images
if "%BUILD_DOCKER%"=="true" (
    echo ======================================
    echo BUILDING DOCKER IMAGES
    echo ======================================
    echo.
    
    where docker >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] Docker is not installed. Cannot build Docker images.
        exit /b 1
    )
    
    if exist "docker-compose.yml" (
        echo [*] Building Docker images with docker-compose...
        call docker-compose build
        if errorlevel 1 (
            echo [ERROR] Docker build failed
            exit /b 1
        )
        echo [OK] Docker images built successfully
    ) else (
        echo [WARN] docker-compose.yml not found
    )
    echo.
)

REM Summary and next steps
echo.
echo ======================================
echo BUILD COMPLETE
echo ======================================
echo.

if "%BUILD_FRONTEND%"=="true" (
    echo Frontend Build:
    echo   - Distribution folder: dist\
    echo   - Ready for web deployment
    echo   - Ready for Capacitor/APK build
    echo.
)

if "%BUILD_BACKEND%"=="true" (
    echo Backend Build:
    echo   - Ready for deployment
    echo   - Run: npm start
    echo.
)

echo Next steps:
if "%BUILD_FRONTEND%"=="true" (
    echo 1. For web deployment:
    echo    Upload 'dist\' folder to your server
    echo.
    echo 2. For local testing:
    echo    npm install -g http-server
    echo    http-server dist\
    echo.
)

if "%BUILD_BACKEND%"=="true" (
    echo 3. For backend (if available^):
    echo    cd backend
    echo    npm start
    echo.
)

if "%BUILD_DOCKER%"=="true" (
    echo 4. For Docker deployment:
    echo    docker-compose up
    echo.
)

echo 5. For production deployment:
    echo    See SETUP.md for detailed instructions
    echo.

echo BUILD READY! ??
pause

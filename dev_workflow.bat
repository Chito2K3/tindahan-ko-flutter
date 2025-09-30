@echo off
echo ========================================
echo    Tindahan Ko - Development Workflow
echo ========================================
echo.

:menu
echo Choose your testing option:
echo 1. Run on Chrome (Web - Fastest for UI testing)
echo 2. Run on Windows Desktop (Native feel)
echo 3. Hot Reload Development Mode
echo 4. Build and Test APK
echo 5. Clean and Reset
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto web
if "%choice%"=="2" goto windows
if "%choice%"=="3" goto hotreload
if "%choice%"=="4" goto apk
if "%choice%"=="5" goto clean
if "%choice%"=="6" goto exit

:web
echo.
echo Starting Web version on Chrome...
echo This is fastest for testing UI changes
flutter run -d chrome --web-port=8080
goto menu

:windows
echo.
echo Starting Windows Desktop version...
echo This gives you native desktop feel
flutter run -d windows
goto menu

:hotreload
echo.
echo Starting Hot Reload Development Mode...
echo Press 'r' to hot reload, 'R' to hot restart, 'q' to quit
flutter run -d chrome --hot
goto menu

:apk
echo.
echo Building APK for Android testing...
echo This will take a few minutes...
flutter build apk --release
echo.
echo APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
goto menu

:clean
echo.
echo Cleaning project...
flutter clean
flutter pub get
echo Project cleaned and dependencies restored!
pause
goto menu

:exit
echo.
echo Happy coding! 👑
exit
@echo off
echo Android Simulation Setup 📱
echo.

REM Check if Chrome is available
where chrome >nul 2>nul
if %errorlevel% neq 0 (
    echo Chrome not found in PATH. Using default browser...
    set BROWSER_CMD=start
) else (
    set BROWSER_CMD=chrome
)

echo Starting Flutter web with mobile simulation...
echo This mimics Android experience in your browser
echo.
echo Features enabled:
echo - Mobile viewport (360x640)
echo - Touch simulation
echo - Mobile user agent
echo - Device pixel ratio simulation
echo.

REM Start Flutter web server
start /b flutter run -d chrome --web-port=8080 --web-browser-flag="--user-agent=Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36" --web-browser-flag="--window-size=360,640" --web-browser-flag="--device-scale-factor=3"

echo.
echo Web server starting...
echo Open Chrome and go to: http://localhost:8080
echo.
echo For better Android simulation:
echo 1. Press F12 to open DevTools
echo 2. Click the mobile device icon (top-left)
echo 3. Select "Galaxy S20 Ultra" or similar Android device
echo 4. Refresh the page
echo.
pause
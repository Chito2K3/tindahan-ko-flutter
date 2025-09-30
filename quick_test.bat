@echo off
echo Quick Testing - Tindahan Ko 👑
echo.
echo Starting Chrome with camera access for barcode testing...
echo Camera will open when you click barcode scanner
echo Press Ctrl+C to stop
echo.
flutter run -d chrome --web-port=8080 --hot --web-browser-flag="--use-fake-ui-for-media-stream" --web-browser-flag="--use-fake-device-for-media-stream"
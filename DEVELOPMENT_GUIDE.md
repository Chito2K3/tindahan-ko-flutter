# Development Workflow Guide 🚀

## Quick Start for Testing Changes

### 1. **Fastest Testing** (Recommended for UI changes)
```bash
# Double-click or run:
quick_test.bat
```
- Opens in Chrome web browser
- Hot reload enabled (press 'r' to reload changes)
- Fastest feedback loop for UI/UX testing

### 2. **Android-like Experience**
```bash
# Double-click or run:
android_sim.bat
```
- Simulates mobile Android experience
- Mobile viewport and touch simulation
- Use Chrome DevTools for device simulation

### 3. **Native Desktop Testing**
```bash
# In terminal:
flutter run -d windows
```
- Native Windows app experience
- Good for testing desktop-specific features

### 4. **Full Development Menu**
```bash
# Double-click or run:
dev_workflow.bat
```
- Complete menu with all options
- Includes APK building when ready

## Development Tips

### Hot Reload Workflow
1. Make your code changes
2. Press `r` in terminal for hot reload
3. Press `R` for hot restart (if needed)
4. Press `q` to quit

### Testing Barcode Scanner
Since mobile_scanner is disabled for web testing:
- Test UI flow with mock data
- Use manual input fallback
- Enable mobile_scanner when building APK

### Before Building APK
1. Test thoroughly in web/desktop
2. Uncomment mobile_scanner dependencies in pubspec.yaml
3. Run `flutter pub get`
4. Build APK with `flutter build apk --release`

## File Structure for Changes
```
lib/
├── screens/          # UI screens
├── providers/        # State management
├── models/          # Data models
├── services/        # Business logic
└── utils/           # Utilities & theme
```

## Common Commands
```bash
# Clean project
flutter clean && flutter pub get

# Run tests
flutter test

# Check for issues
flutter analyze

# Format code
flutter format .
```

## Troubleshooting
- If hot reload stops working: Press `R` for hot restart
- If dependencies fail: Run `flutter clean && flutter pub get`
- If Chrome doesn't open: Manually go to http://localhost:8080
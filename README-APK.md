# APK Setup Instructions

## To enable Android APK download:

1. **Build your Flutter APK:**
   ```bash
   flutter build apk --release
   ```

2. **Copy the APK file:**
   - Find the APK at: `build/app/outputs/flutter-apk/app-release.apk`
   - Rename it to: `tindahan-ko.apk`
   - Place it in the root directory (same folder as index.html)

3. **Upload to your hosting:**
   - Make sure `tindahan-ko.apk` is uploaded alongside `index.html`
   - The download will work automatically

## File Structure:
```
your-project/
├── index.html
├── tindahan-ko.apk  ← Your Flutter APK here
├── _redirects
└── README-APK.md
```

## Note:
- APK file should be around 20-50MB for a Flutter app
- Users will need to enable "Install from unknown sources" on Android
- Consider signing your APK for production use
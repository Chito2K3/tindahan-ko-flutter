# Tindahan Ko Flutter - Para sa mga Reyna ng Tahanan 👑

A complete POS and Inventory Management System for Sari-Sari stores, built with Flutter for native Android, iOS, and Web experience.

## Latest Version: v1.4.1 🎉

### ✨ New Features
- **🎨 Improved Inventory UI** - Redesigned product cards with cleaner layout
- **➕ Better Add Item Button** - Moved to top stats section, removed floating button
- **📊 Enhanced Reports** - Fixed Total Value calculation including cigarette inventory
- **🚬 Cigarette Stock Display** - Shows packs + loose sticks in Stock Lookup
- **💾 Excel Export Fix** - Now saves to Downloads folder with proper notifications
- **📁 File Manager Support** - Import works with all Android file managers
- **✅ File Validation** - Only accepts valid Tindahan Ko Excel files
- **📱 Android Compatibility** - Works on Android 6.0+ with proper permissions

## Core Features

### 📱 Native Barcode Scanner
- Professional camera overlay with scanning frame
- Real-time barcode detection using mobile_scanner
- Vibration feedback on successful scan
- Flashlight toggle for low-light scanning
- Manual barcode input as fallback

### 💰 Point of Sale (POS)
- Product search and category filtering
- Cart management with quantity controls
- Real-time total calculation
- Payment processing with confirmation
- Barcode scanning integration
- Sales data persistence
- **Cigarette selection dialog**: Choose between pack or piece when adding cigarettes
- **Dual cart controls**: Separate +/- buttons for packs and pieces

### 📦 Inventory Management
- Product listing with stock levels
- Low stock warnings with visual indicators
- Statistics dashboard
- Category-based organization
- SQLite database persistence
- **Cigarette dual-unit system**: Track packs and loose pieces separately
- **Smart inventory deduction**: Auto-opens packs when loose pieces run out
- **Clean product cards**: Organized layout with single-line product names
- **Add Item card**: Quick access button in top stats section

### 📊 Reports & Analytics
- **Sales Report**: Daily/weekly sales charts, top-selling items
- **Inventory Report**: Stock overview, low stock alerts, category stats
- **Total Value**: Accurate calculation including all product inventory
- **Stock Lookup**: Search with cigarette pack + stick display
- Interactive charts using FL Chart library
- Real-time data visualization

### 💾 Backup & Restore
- **Excel Export**: Saves to Downloads folder on Android
- **Excel Import**: Works with all file managers
- **File Validation**: Only accepts valid Tindahan Ko files
- **Storage Permissions**: Compatible with Android 6.0+
- **Notifications**: Shows file location after export
- Manual data editing support
- Data validation and confirmation dialogs

### ⚙️ Settings Management
- Store information configuration
- Owner details and contact info
- Professional about section
- Developer information

### 🎨 Beautiful UI
- Pink gradient theme with "Tindahan Ko" branding
- Imperial Script font for elegant typography
- Glass morphism effects with blur and transparency
- Custom TK app icons
- Responsive design for all screen sizes

## Tech Stack

- **Flutter 3.10+** - Cross-platform framework
- **SQLite** - Local database storage
- **Provider** - State management
- **Mobile Scanner** - Native barcode scanning
- **FL Chart** - Interactive charts and graphs
- **Excel** - Spreadsheet export/import
- **File Picker** - File selection functionality
- **Google Fonts** - Typography (Imperial Script)
- **Universal HTML** - Web compatibility

## Download & Installation

### 📱 Android APK
Build the APK locally using the instructions below.

### 🌐 Web Version
Access the web version at: [Your Web URL]

### 💻 Development Setup

#### Prerequisites
- Flutter SDK 3.10 or higher
- Android Studio / VS Code
- Android device/emulator or iOS device/simulator

#### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/tindahan-ko-flutter.git
cd tindahan-ko-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For mobile
flutter run

# For web
flutter run -d chrome

# Build APK
flutter build apk --release
```

### 📋 Permissions

The app requires the following permissions:
- **Camera** - For barcode scanning
- **Storage** - For Excel file import/export
- **Vibration** - For scan feedback

## 📊 Data Management

### Excel Format
When exporting/importing data, the Excel file contains these columns:
- **ID** - Unique product identifier
- **Name** - Product name
- **Price** - Product price (₱)
- **Stock** - Current stock quantity
- **Category** - Product category
- **Emoji** - Product emoji icon
- **Reorder Level** - Minimum stock threshold
- **Has Barcode** - YES/NO for barcode availability
- **Barcode** - Barcode number (if applicable)

### Database
- **SQLite** database for local storage
- **Persistent** data across app sessions
- **Automatic** backup on sales completion
- **Real-time** inventory updates

## 📈 Version History

### v1.4.1 (Latest) - UI Improvements & Export/Import Fixes
- ✅ Redesigned Inventory screen with cleaner product cards
- ✅ Moved Add Item button to top stats section
- ✅ Fixed Total Value calculation in Reports (includes all cigarette inventory)
- ✅ Added loose sticks display in Stock Lookup for cigarettes
- ✅ Fixed Excel export to save directly to Downloads folder
- ✅ Added proper file notifications and location display
- ✅ Enhanced Excel import with file validation
- ✅ Added support for all Android file managers
- ✅ Improved Android storage permissions (Android 6.0+)
- ✅ Better error messages for invalid files

### v1.4.0 - Cigarette System & Payment Fix
- ✅ Dual-unit cigarette inventory (packs + pieces)
- ✅ Separate pricing for packs and loose cigarettes
- ✅ Smart inventory deduction with auto-pack opening
- ✅ Enhanced POS with cigarette selection dialog
- ✅ Fixed payment processing hang issue
- ✅ Real sales data integration in reports
- ✅ Database v4 with automatic migration

### v1.3.1 - TK Icons Fixed
- ✅ Custom TK app icons with Imperial Script font
- ✅ Professional branding across all platforms
- ✅ Updated web manifest and favicons

### v1.3.0 - Batch Payment
- ✅ Enhanced batch selling functionality
- ✅ Improved payment processing
- ✅ Better inventory management

### v1.2.2 - Final Fixed
- ✅ Bug fixes and performance improvements
- ✅ Stable release with all features

### v1.2.1 - Keyboard Fixed
- ✅ Fixed keyboard input issues
- ✅ Improved user experience

### v1.2.0 - Excel & Reports Update
- ✅ Reports dashboard with sales/inventory analytics
- ✅ Excel export/import functionality
- ✅ Interactive charts and graphs
- ✅ Enhanced backup & restore features

### v1.0.0 - Initial Release
- ✅ Basic POS functionality
- ✅ Barcode scanning
- ✅ Inventory management
- ✅ Beautiful UI design

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

**Chito Saba**
- 📧 Email: chitosaba@gmail.com
- 🏢 Company: Jungleworks
- 💼 Role: Flutter Developer

## 🙏 Acknowledgments

- Original web version inspiration
- Flutter community for amazing packages
- Sari-sari store owners - our queens of the household! 👑
- FL Chart library for beautiful data visualization
- Excel package for spreadsheet functionality
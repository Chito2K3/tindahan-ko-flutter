# Changelog

All notable changes to Tindahan Ko Flutter will be documented in this file.

## [1.2.0] - 2024-12-19

### 🆕 Added
- **Reports Dashboard**: Complete analytics with Sales and Inventory reports
  - Interactive line charts for daily/weekly sales data
  - Top-selling items with revenue tracking
  - Inventory overview with statistics
  - Low stock alerts with visual indicators
- **Excel Export/Import**: Full backup and restore functionality
  - Export products to .xlsx format for manual editing
  - Import Excel files with data validation
  - Confirmation dialogs for data safety
  - Support for all product fields including barcodes
- **Enhanced UI**: Professional branding improvements
  - Custom TK app icons with Imperial Script font
  - Updated web favicons and manifest
  - Consistent pink gradient theme

### 🔧 Improved
- Database persistence across all screens
- Error handling for file operations
- User feedback with success/error messages
- Mobile and web compatibility for all features

### 📦 Dependencies Added
- `fl_chart: ^0.68.0` - Interactive charts and graphs
- `excel: ^4.0.6` - Excel file generation and parsing
- `file_picker: ^8.1.2` - File selection functionality
- `universal_html: ^2.2.4` - Web compatibility

## [1.1.3] - 2024-12-19

### 🆕 Added
- Custom "TK" app icons for Android
- Professional branding with Imperial Script font
- Updated web icons and favicons

### 🔧 Improved
- App icon consistency across platforms
- Professional appearance on home screen and app drawer

## [1.1.2] - 2024-12-18

### 🆕 Added
- Functional Store Information management
- Professional About dialog with developer info
- Enhanced Settings screen with working features

### 🔧 Improved
- Header design with "Tindahan Ko" branding
- Imperial Script font integration
- Seamless background blending

## [1.1.1] - 2024-12-18

### 🆕 Added
- SQLite database integration for persistent storage
- Database service with CRUD operations
- Automatic data loading on app startup

### 🔧 Improved
- Data persistence across app sessions
- Enhanced inventory management
- Better error handling for database operations

### 🗑️ Removed
- Platform selection logic (simplified app flow)
- In-memory storage (replaced with SQLite)

## [1.0.0] - 2024-12-17

### 🆕 Initial Release
- Point of Sale (POS) system with cart management
- Native barcode scanner with camera overlay
- Inventory management with stock tracking
- Beautiful pink gradient UI design
- Product categories and search functionality
- Basic settings and store setup
- Web and mobile platform support

### 🔧 Core Features
- Real-time barcode scanning
- Product search and filtering
- Cart management with quantity controls
- Payment processing
- Stock level monitoring
- Responsive design for all screen sizes

### 📦 Initial Dependencies
- Flutter 3.10+
- Provider for state management
- Mobile Scanner for barcode functionality
- Google Fonts for typography
- SQLite for local storage
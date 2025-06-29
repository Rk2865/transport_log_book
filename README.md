# 🚛 Sharma Enterprises - Transport Log Book

A comprehensive Flutter application designed to streamline transport business operations for Sharma Enterprises. This digital solution provides efficient billing, payment tracking, vehicle and driver management with a modern, user-friendly interface.

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.8.1-blue?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## ✨ Features

### 🔐 Authentication & Security
- **Secure Login System** - User ID and password authentication
- **Biometric Authentication** - Optional fingerprint/face recognition support
- **Session Management** - Secure user sessions with proper state handling

### 📊 Dashboard & Navigation
- **Modern Dashboard** - Clean interface with company branding
- **Intuitive Navigation** - Quick access to all major features
- **Responsive Design** - Optimized for various screen sizes

### 💰 Bill Management
- **Create Bills** - Detailed transport bill creation with:
  - Load/unload weight tracking
  - Rate calculations
  - Expense management
  - Automatic round-off calculations
  - Net balance computation
- **Generate Bills** - View and generate bills by date and vehicle
- **PDF Export** - Download professional bills with complete details
- **Bill Viewer** - Comprehensive bill viewing and management

### 👨‍💼 Driver Management (Khata)
- **Driver Profiles** - Add, view, and manage driver information
- **Financial Tracking** - Record driver transactions including:
  - Punji (advance payments)
  - Expenses
  - Total expense calculations
  - Detailed notes and remarks
- **Expandable Interface** - User-friendly driver card system

### 💳 Advance Payment System
- **Payment Tracking** - Record and monitor advance payments
- **Vehicle Association** - Link payments to specific vehicles
- **Payment History** - Complete payment record management

### 🚗 Vehicle Management
- **Vehicle Database** - Add and manage vehicle information
- **Vehicle Profiles** - Comprehensive vehicle details
- **Fleet Management** - Complete fleet overview and control

### ⚙️ Settings & Configuration
- **Password Management** - Change application password
- **Biometric Settings** - Enable/disable biometric authentication
- **Backup Options** - Local and cloud backup functionality
- **Data Management** - Export and import capabilities

---

## 🎨 UI/UX Design Highlights

- **Modern Material Design** - Clean, professional interface
- **Company Branding** - Integrated logo and branding elements
- **Intuitive Navigation** - Easy-to-use menu system
- **Form Validation** - Real-time error feedback and validation
- **Responsive Layout** - Adapts to different screen sizes
- **Color-coded Actions** - Visual distinction between different operations
- **Professional PDF Output** - Clean, formatted bill generation

---

## 🏗️ Project Architecture

```
transport_log_book/
├── lib/
│   ├── main.dart                 # App entry point and routing
│   ├── models/                   # Data models
│   │   ├── bill.dart            # Bill data structure
│   │   ├── driver.dart          # Driver information model
│   │   ├── vehicle.dart         # Vehicle data model
│   │   └── advance_payment.dart # Payment tracking model
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart     # Main dashboard
│   │   ├── login_page.dart      # Authentication screen
│   │   ├── new_bill_screen.dart # Bill creation interface
│   │   ├── generate_bill_screen.dart # Bill generation
│   │   ├── driver_khata_screen.dart # Driver management
│   │   ├── advance_payment_screen.dart # Payment tracking
│   │   ├── manage_vehicles_screen.dart # Vehicle management
│   │   ├── settings_screen.dart # App configuration
│   │   ├── record_screen.dart   # Record management
│   │   └── bill_viewer_screen.dart # Bill viewing
│   ├── services/                 # Business logic
│   │   ├── backup_service.dart  # Data backup functionality
│   │   ├── bill_generator.dart  # PDF generation
│   │   └── google_drive_service.dart # Cloud integration
│   ├── database/                 # Data persistence
│   │   ├── database_helper.dart # Database operations
│   │   └── database_service.dart # Database management
│   └── utils/                    # Utilities
│       └── logger.dart          # Logging functionality
├── assets/                       # Static assets
│   ├── logo_1.png              # Company logo variant 1
│   ├── logo_2.png              # Company logo variant 2
│   ├── logo.png                # Main logo
│   └── app_logo.png            # App icon
├── test/                        # Test files
├── pubspec.yaml                 # Dependencies and configuration
└── README.md                    # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Rk2865/transport_log_book.git
   cd transport_log_book
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 📱 Key Dependencies

- **sqflite** - Local database management
- **pdf** - PDF generation for bills
- **path_provider** - File system access
- **share_plus** - File sharing capabilities
- **local_auth** - Biometric authentication
- **googleapis** - Google Drive integration
- **intl** - Internationalization and formatting
- **provider** - State management

---

## 🤝 Contributing

We welcome contributions to improve the Transport Log Book application!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Maintain consistent code formatting
- Add appropriate comments and documentation
- Write tests for new features
- Ensure responsive design compatibility

---

## 📄 License

This project is licensed under the MIT License.

---

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation for common solutions

---

**Built with ❤️ for Sharma Enterprises**
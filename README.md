# Internal Ledger - iOS App

<div align="center">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/SwiftUI-5.0-green.svg" alt="SwiftUI 5.0">
  <img src="https://img.shields.io/badge/Xcode-15.0+-blue.svg" alt="Xcode 15.0+">
</div>

## 📱 Overview

**Internal Ledger** is a modern iOS application built with SwiftUI for managing financial accounts and transactions. It provides a clean, intuitive interface for tracking account balances, viewing transaction history, and performing CRUD operations on financial data.

The app connects to a deployed backend API hosted on Azure, demonstrating real-world API integration patterns and modern iOS development best practices.

## ✨ Features

### Account Management
- 📊 **View All Accounts** - Dashboard showing all accounts with real-time balance totals
- ➕ **Create Accounts** - Add new financial accounts with initial balance
- ✏️ **Edit Accounts** - Update account details and status
- 🗑️ **Delete Accounts** - Remove accounts from the system
- 🔄 **Pull to Refresh** - Update data with a simple swipe down gesture

### Transaction Management
- 💰 **View Transactions** - See all transactions for any account
- 📝 **Create Transactions** - Record credit and debit transactions
- 🔍 **Transaction Details** - View complete transaction information
- ✏️ **Edit Transactions** - Update transaction details
- 🗑️ **Delete Transactions** - Remove transactions

### User Experience
- 📱 **Mobile-First Design** - Optimized for iPhone with modern UI
- 🎨 **Clean Interface** - Beautiful, intuitive layouts with proper spacing
- ⚡ **Real-time Updates** - Instant feedback on all operations
- 🔔 **Error Handling** - User-friendly error messages and alerts
- 🔄 **Loading States** - Progress indicators for all async operations
- 🏷️ **Status Badges** - Visual indicators for account status (Active/Inactive/Pending)

## 🏗️ Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel (MVVM) architectural pattern:

```
InternalLedger/
├── Models/              # Data structures (Account, Transaction)
├── ViewModels/          # Business logic & state management (AppState)
├── Views/               # SwiftUI views for each screen
├── Components/          # Reusable UI components
├── Services/            # API service layer
├── Utilities/           # Helper functions (formatters)
└── Data/                # Mock data (for reference)
```

### Key Components

#### **Models** (`Finance.swift`)
- `Account` - Represents a financial account with balance, status, and metadata
- `Transaction` - Represents a financial transaction with amount, type, and description
- Custom `Codable` implementations for API field mapping

#### **ViewModels** (`AppState.swift`)
- Central state management using `ObservableObject`
- Handles all business logic and API interactions
- Published properties for reactive UI updates

#### **Services** (`APIService.swift`)
- Singleton service for all backend communication
- RESTful API client with proper error handling
- Custom date formatting for ISO8601 dates
- Async/await pattern for modern concurrency

#### **Views**
- `AccountsOverviewView` - Main dashboard
- `AccountDetailView` - Single account details
- `AccountFormView` - Create/edit account form
- `TransactionListView` - Transaction history
- `TransactionFormView` - Create/edit transaction form

#### **Components**
- `MobileLayout` - Consistent layout wrapper
- `PageHeader` - Reusable navigation header
- `FloatingButton` - Floating action button for creating items
- `StatusBadge` - Visual status indicators

## 🔌 API Integration

### Backend
- **Host**: `ledger-backend-app.azurewebsites.net`
- **Protocol**: HTTPS
- **Format**: JSON
- **Authentication**: None (demo app)

### Endpoints

#### Accounts
- `GET /accounts` - List all accounts
- `GET /accounts/{id}` - Get account by ID
- `POST /accounts` - Create new account
- `PUT /accounts/{id}` - Update account
- `DELETE /accounts/{id}` - Delete account

#### Transactions
- `GET /transactions?accountId={id}` - List transactions for account
- `GET /transactions/{id}` - Get transaction by ID
- `POST /transactions` - Create new transaction
- `PUT /transactions/{id}` - Update transaction
- `DELETE /transactions/{id}` - Delete transaction

### Data Mapping
The app handles field name differences between the API and local models:
- API `accountId` (numeric) ↔ Model `id` (string)
- API `accountName` ↔ Model `name`
- API `transactionId` (numeric) ↔ Model `id` (string)
- API `transactionDate` ↔ Model `date`

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- iOS 17.0 or later (for deployment target)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/soham04/internal-ledger-ios.git
   cd internal-ledger-ios
   ```

2. **Open in Xcode**
   ```bash
   cd InternalLedger
   open InternalLedger.xcodeproj
   ```

3. **Select a target device/simulator**
   - Choose any iPhone simulator (iPhone 15 Pro recommended)
   - Or connect a physical iOS device

4. **Build and Run**
   - Press `Cmd + R` or click the Play button
   - The app will compile and launch

### Configuration

The API endpoint is configured in `APIService.swift`:
```swift
private let baseURL = "https://ledger-backend-app.azurewebsites.net"
```

To use a different backend, simply update this URL.

## 📱 Screenshots

### Main Features
- **Accounts Overview**: Dashboard with total balance and account list
- **Account Details**: Individual account view with transaction access
- **Transaction List**: Complete transaction history with type indicators
- **Forms**: Clean, validated forms for creating/editing data

## 🛠️ Technical Details

### Technologies
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Architecture**: MVVM
- **Networking**: URLSession with async/await
- **State Management**: Combine (`@ObservableObject`, `@Published`)
- **Data Persistence**: None (API-backed only)

### Key Features Implementation

#### Async/Await Networking
```swift
func fetchAccounts() async throws -> [Account] {
    let (data, response) = try await URLSession.shared.data(from: url)
    // Handle response...
}
```

#### Custom Date Formatting
```swift
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter
}()
```

#### Environment Object State Management
```swift
@main
struct InternalLedgerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AccountsOverviewView()
                .environmentObject(appState)
        }
    }
}
```

## 🔧 Development

### Project Structure
```
InternalLedger.xcodeproj/    # Xcode project file
InternalLedger/              # Source code
├── Components/              # Reusable UI components
├── Data/                    # Mock data for reference
├── Models/                  # Data models
├── Services/               # API services
├── Utilities/              # Helper utilities
├── ViewModels/             # State management
├── Views/                  # SwiftUI views
└── InternalLedgerApp.swift # App entry point
```

### Adding New Features

1. **Add Model** - Update `Finance.swift`
2. **Update Service** - Add API methods to `APIService.swift`
3. **Update ViewModel** - Add business logic to `AppState.swift`
4. **Create View** - Build SwiftUI view in `Views/`
5. **Update Navigation** - Link view in parent views

## 🐛 Troubleshooting

### Common Issues

**App won't build**
- Ensure Xcode 15.0+ is installed
- Clean build folder: `Cmd + Shift + K`
- Restart Xcode

**API errors**
- Check internet connection
- Verify backend is running: `https://ledger-backend-app.azurewebsites.net/health`
- Check console logs for detailed error messages

**Date parsing errors**
- Backend must return dates in format: `"yyyy-MM-dd'T'HH:mm:ss"`
- Check `dateFormatter` in `APIService.swift`

## 📝 API Response Examples

### Account Response
```json
{
  "accountId": 1,
  "accountName": "Demo Account",
  "status": "Active",
  "balance": 2500.5000,
  "lastUpdated": "2025-12-31T17:30:00"
}
```

### Transaction Response
```json
{
  "transactionId": 1,
  "accountId": 1,
  "amount": 500.0000,
  "type": "Credit",
  "description": "Initial deposit",
  "transactionDate": "2025-12-31T17:30:00"
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**Soham**
- GitHub: [@soham04](https://github.com/soham04)

## 🙏 Acknowledgments

- Built with SwiftUI
- Backend hosted on Azure App Service
- Inspired by modern financial tracking apps

## 📚 Related Projects

- [Internal Ledger Backend](https://github.com/soham04/internal-ledger) - The React version of this project

---

<div align="center">
  Made with ❤️ using SwiftUI
</div>


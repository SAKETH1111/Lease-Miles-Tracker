# Lease Miles Tracker

A comprehensive iOS app built with SwiftUI and SwiftData for tracking lease mileage and avoiding overage charges.

## Features

### Core Functionality
- **Manual Odometer Recording**: Easy entry of odometer readings with date and notes
- **Lease Management**: Track lease start/end dates, starting odometer, and allowed mileage
- **Real-time Calculations**: 
  - Miles driven vs. allowed
  - Remaining miles
  - Months left in lease
  - Running cost based on cost per mile
  - Projected overage calculations

### Smart Alerts
- **Threshold Warnings**: Alert when approaching mileage limits (configurable percentage)
- **Projected Overage**: Early warning if on track to exceed lease mileage
- **Monthly Reminders**: Optional monthly notifications to update odometer

### Data Management
- **Export to CSV**: Share mileage history with dealership or for record keeping
- **Edit/Delete Entries**: Full CRUD operations on mileage entries
- **Data Validation**: Prevents invalid odometer readings (monotonic validation)
- **Reset Functionality**: Complete data reset option

## Technical Architecture

### Tech Stack
- **Swift 5.10+**
- **SwiftUI** for UI framework
- **SwiftData** for persistence (no third-party dependencies)
- **UserNotifications** for local reminders
- **iOS 17+** minimum deployment target

### Architecture Pattern
- **MVVM** with service layer
- **SwiftData** for reactive data management
- **Dependency Injection** via ModelContainer

### Project Structure
```
LeaseMilesTracker/
├── LeaseMilesTrackerApp.swift          # Main app entry point
├── Models/
│   ├── LeaseSettings.swift             # Singleton lease configuration
│   └── MileageEntry.swift              # Individual odometer readings
├── Services/
│   ├── LeaseCalculator.swift           # Pure calculation logic
│   ├── NotificationManager.swift       # Local notification handling
│   └── CSVExporter.swift               # CSV export functionality
├── Stores/
│   ├── LeaseSettingsStore.swift        # Settings persistence
│   └── MileageStore.swift              # Mileage entries persistence
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift        # First-time setup
│   ├── Dashboard/
│   │   ├── DashboardView.swift         # Main metrics display
│   │   └── MetricCard.swift            # Reusable metric component
│   ├── Entries/
│   │   ├── AddEntryView.swift          # New odometer entry
│   │   ├── EditEntryView.swift         # Edit existing entry
│   │   └── HistoryView.swift           # Entry history with export
│   └── Settings/
│       └── SettingsView.swift          # Configuration management
├── Utils/
│   └── Formatters.swift                # Number and date formatting
└── Tests/
    └── LeaseCalculatorTests.swift      # Unit tests for calculations
```

## Key Components

### LeaseCalculator Service
Pure, testable calculation engine that computes:
- Miles driven and remaining
- Average daily mileage
- Projected mileage at lease end
- Cost calculations (running and projected overage)
- Warning threshold logic

### NotificationManager
Handles local notifications:
- Permission requests
- Monthly reminder scheduling
- Threshold alert delivery
- Notification lifecycle management

### Data Models
- **LeaseSettings**: Singleton configuration model
- **MileageEntry**: Individual odometer readings with validation

## Usage

### Initial Setup
1. Launch app to see onboarding flow
2. Enter lease details:
   - Start and end dates
   - Starting odometer reading
   - Total allowed miles
   - Cost per mile for overage calculations
   - Optional monthly reminder day
   - Low miles threshold percentage

### Daily Usage
1. **Dashboard**: View current status and key metrics
2. **Add Entry**: Record new odometer readings
3. **History**: Review past entries, edit/delete as needed
4. **Export**: Generate CSV files for sharing

### Settings Management
- Modify lease parameters anytime
- Enable/disable monthly reminders
- Adjust warning thresholds
- Reset all data if needed

## Testing

The app includes comprehensive unit tests covering:
- Zero entry scenarios
- Same-day start calculations
- Threshold crossing detection
- Projected overage calculations
- Month boundary handling
- Lease end date scenarios
- Input validation edge cases

Run tests with:
```bash
xcodebuild test -scheme LeaseMilesTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.10+**

## Privacy & Permissions

- **Local Notifications**: Used for mileage reminders and threshold alerts
- **No Network Access**: All data stored locally using SwiftData
- **No Third-party Dependencies**: Pure iOS frameworks only

## Data Persistence

- **SwiftData**: Modern Core Data replacement
- **Local Storage Only**: No cloud sync or external services
- **Automatic Backup**: Included in device backups via iCloud/iTunes

## Accessibility

- **Dynamic Type**: Supports all text size preferences
- **VoiceOver**: Full VoiceOver compatibility
- **High Contrast**: Proper contrast ratios throughout
- **SF Symbols**: Consistent iconography

## Future Enhancements

Potential additions for future versions:
- **Widgets**: Home screen widgets for quick mileage viewing
- **Charts**: Visual mileage trends using Swift Charts
- **Quick Actions**: Home screen shortcuts for adding entries
- **Multiple Leases**: Support for tracking multiple vehicles
- **iCloud Sync**: Optional cloud synchronization

## License

This project is created as a demonstration of modern iOS development practices using SwiftUI and SwiftData.

---

**Built with ❤️ using SwiftUI, SwiftData, and modern iOS development practices.**
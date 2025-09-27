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
├── ContentView.swift                   # Main content view with tab navigation
├── Models/
│   ├── Car.swift                       # Car model with lease settings
│   ├── LeaseSettings.swift             # Singleton lease configuration
│   └── MileageEntry.swift              # Individual odometer readings
├── Services/
│   ├── LeaseCalculator.swift           # Pure calculation logic
│   ├── NotificationManager.swift       # Local notification handling
│   ├── CSVExporter.swift               # CSV export functionality
│   └── QuickActionsManager.swift       # Home screen quick actions
├── Stores/
│   ├── CarStore.swift                  # Car management and persistence
│   ├── LeaseSettingsStore.swift        # Settings persistence
│   └── MileageStore.swift              # Mileage entries persistence
├── Shared/
│   └── SharedDataManager.swift         # App Groups data sharing
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift        # First-time setup
│   ├── Dashboard/
│   │   ├── DashboardView.swift         # Main metrics display
│   │   └── MetricCard.swift            # Reusable metric component
│   ├── Charts/
│   │   └── MileageChartsView.swift     # Swift Charts analytics
│   ├── Entries/
│   │   ├── AddEntryView.swift          # New odometer entry
│   │   ├── EditEntryView.swift         # Edit existing entry
│   │   └── HistoryView.swift           # Entry history with export
│   ├── Cars/
│   │   ├── AddCarView.swift            # Add new car
│   │   ├── CarSelectionView.swift      # Car management
│   │   └── EditCarView.swift           # Edit car details
│   ├── Settings/
│   │   └── SettingsView.swift          # Configuration management
│   └── Testing/
│       └── NotificationTestView.swift  # Notification testing interface
├── Widget/
│   ├── LeaseMilesWidget.swift          # Main widget implementation
│   ├── LeaseMilesWidgetBundle.swift    # Widget bundle
│   ├── LeaseMilesWidgetConfiguration.swift # Widget configuration
│   └── InteractiveWidget.swift         # Interactive widget with buttons
├── Utils/
│   └── Formatters.swift                # Number and date formatting
└── Tests/
    ├── LeaseCalculatorTests.swift      # Unit tests for calculations
    ├── NotificationManagerTests.swift  # Notification tests
    ├── SharedDataManagerTests.swift    # Widget data tests
    ├── WidgetTests.swift               # Widget functionality tests
    └── UI/
        └── LeaseMilesTrackerUITests.swift # UI automation tests
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

## New Features (Latest Version)

### 🎯 **Interactive Widgets**
- **Quick Actions**: Add entries, view history, and access settings directly from widgets
- **Multiple Widget Sizes**: Small, medium, and large widgets with customizable content
- **Real-time Updates**: Widgets update automatically with your latest data
- **Configuration Options**: Customize what information is displayed

### 📊 **Advanced Charts & Analytics**
- **Miles Over Time**: Visual timeline of your mileage progression
- **Daily Averages**: Bar charts showing daily mileage patterns
- **Projected Trends**: Forecast your mileage at lease end
- **Multiple Time Ranges**: 1 month, 3 months, 6 months, 1 year, or all time
- **Summary Statistics**: Key metrics and insights

### ⚡ **Quick Actions**
- **Home Screen Shortcuts**: Long-press app icon for quick access
- **Add Entry**: Jump directly to adding a new mileage entry
- **View Dashboard**: Quick access to your lease status
- **View History**: Instantly see your mileage history
- **View Charts**: Access analytics and trends

### 🔧 **Enhanced Widget Configuration**
- **Display Styles**: Compact, detailed, or minimal layouts
- **Customizable Content**: Show/hide projected overage, months left, running cost
- **Interactive Buttons**: Direct actions from widget interface
- **Smart Updates**: Automatic refresh every hour

## Future Enhancements

Potential additions for future versions:
- **Apple Watch**: Widget complications for quick glances
- **Multiple Leases**: Support for tracking multiple vehicles simultaneously
- **iCloud Sync**: Optional cloud synchronization across devices
- **Advanced Analytics**: More detailed reporting and insights
- **Export Options**: Additional export formats (PDF, Excel)

## License

This project is created as a demonstration of modern iOS development practices using SwiftUI and SwiftData.

---

**Built with ❤️ using SwiftUI, SwiftData, and modern iOS development practices.**
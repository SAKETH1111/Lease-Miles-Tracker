# Widget and Notifications Guide

## Widget Features

The Lease Miles Tracker now includes a comprehensive widget system that allows you to track your lease mileage directly from your home screen.

### Widget Sizes

#### Small Widget
- Displays miles driven and remaining miles
- Shows projected overage warning if applicable
- Compact design perfect for quick glances

#### Medium Widget
- Shows miles driven and remaining miles side by side
- Displays months left and projected overage
- More detailed information in a horizontal layout

#### Large Widget
- Grid layout with all key metrics
- Miles driven, remaining miles, months left
- Status indicator (On Track or Projected Over)
- Most comprehensive view of your lease status

### Adding the Widget

1. Long press on your home screen
2. Tap the "+" button in the top-left corner
3. Search for "Lease Miles Tracker"
4. Select the widget size you prefer
5. Tap "Add Widget"

### Widget Data

The widget automatically updates with your latest lease data:
- Updates every hour
- Shows real-time calculations
- Displays warnings for projected overages
- Falls back to "No Data" state if app hasn't been set up

## Notification Features

### Notification Testing

The app now includes a comprehensive notification testing system accessible from the dashboard:

1. Tap the bell icon in the top-right corner of the dashboard
2. Test different notification types:
   - **Request Permission**: Enable notifications if not already enabled
   - **Send Test Notification**: Immediate test notification
   - **Schedule Test Reminder**: 5-second delayed notification
   - **Test Threshold Alert**: Simulate mileage threshold warning

### Notification Types

#### Monthly Reminders
- Configurable day of the month
- Reminds you to update your odometer reading
- Can be set in Settings

#### Threshold Alerts
- Automatic alerts when you reach 90% of allowed mileage
- Projected overage warnings
- Immediate notifications for critical situations

#### Test Notifications
- Verify notification permissions
- Test notification delivery
- Debug notification issues

### Notification Settings

Access notification settings through:
1. Dashboard → Settings (gear icon)
2. Notification section
3. Configure reminder day and threshold percentage

## Technical Implementation

### App Groups
The widget uses App Groups to share data between the main app and widget:
- Group ID: `group.com.leasemilestracker.shared`
- Shared UserDefaults for data persistence
- Automatic widget timeline updates

### Data Sharing
- `SharedDataManager` handles data synchronization
- Widget data updates when dashboard is viewed
- JSON encoding for cross-process communication

### Widget Timeline
- Updates every hour automatically
- Manual refresh when app is opened
- Efficient data loading with fallbacks

## Troubleshooting

### Widget Not Updating
1. Ensure the main app has been opened at least once
2. Check that lease settings are complete
3. Try removing and re-adding the widget
4. Restart the device if issues persist

### Notifications Not Working
1. Check notification permissions in Settings
2. Use the notification test feature in the app
3. Ensure Do Not Disturb is not enabled
4. Verify notification settings in iOS Settings

### Data Not Syncing
1. Open the main app to trigger data sync
2. Check that App Groups are properly configured
3. Verify lease settings are complete
4. Try logging out and back in

## Future Enhancements

- Interactive widget buttons for quick actions
- Multiple widget configurations
- Customizable widget appearance
- Advanced notification scheduling
- Widget complications for Apple Watch
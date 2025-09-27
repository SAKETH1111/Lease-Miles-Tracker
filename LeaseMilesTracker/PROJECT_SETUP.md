# Project Setup Guide

This guide covers the complete setup and configuration required to build and run the Lease Miles Tracker app.

## Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+** deployment target
- **Swift 5.10+**
- **macOS 14.0+** for development

## Project Configuration

### 1. App Groups Configuration

The app uses App Groups to share data between the main app and widgets. You need to configure this in Xcode:

#### In Xcode:
1. Select your project in the navigator
2. Select the main app target
3. Go to "Signing & Capabilities"
4. Click "+ Capability" and add "App Groups"
5. Add the group identifier: `group.com.leasemilestracker.shared`

#### For Widget Target:
1. Select the widget target
2. Go to "Signing & Capabilities"
3. Add "App Groups" capability
4. Add the same group identifier: `group.com.leasemilestracker.shared`

### 2. Bundle Identifiers

Configure the following bundle identifiers:

- **Main App**: `com.leasemilestracker.app`
- **Widget Extension**: `com.leasemilestracker.app.widget`
- **App Group**: `group.com.leasemilestracker.shared`

### 3. Required Capabilities

#### Main App Target:
- **App Groups**: `group.com.leasemilestracker.shared`
- **Background Modes**: 
  - Background processing
  - Background app refresh
- **Push Notifications**: For local notifications

#### Widget Target:
- **App Groups**: `group.com.leasemilestracker.shared`

### 4. Info.plist Configuration

The following keys are already configured in `Info.plist`:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>This app sends reminders to update your odometer reading and alerts when you're approaching your lease mileage limit.</string>

<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.leasemilestracker.shared</string>
</array>

<key>NSUbiquitousContainers</key>
<dict>
    <key>group.com.leasemilestracker.shared</key>
    <dict>
        <key>NSUbiquitousContainerIsDocumentScopePublic</key>
        <true/>
        <key>NSUbiquitousContainerName</key>
        <string>Lease Miles Tracker Shared</string>
    </dict>
</dict>
```

## Build Configuration

### 1. Build Settings

Ensure the following build settings are configured:

- **iOS Deployment Target**: 17.0
- **Swift Language Version**: Swift 5
- **Swift Compilation Mode**: Incremental
- **Enable Bitcode**: No (for iOS 14+)

### 2. Code Signing

1. Select your development team
2. Ensure automatic code signing is enabled
3. Verify bundle identifiers match your provisioning profiles

### 3. Widget Configuration

The widget extension should be configured as follows:

- **Target Type**: Widget Extension
- **Bundle Identifier**: `com.leasemilestracker.app.widget`
- **Deployment Target**: iOS 17.0
- **App Groups**: `group.com.leasemilestracker.shared`

## Running the App

### 1. Simulator

1. Select an iOS 17.0+ simulator
2. Build and run the main app target
3. The widget will be automatically included

### 2. Device

1. Connect your iOS device
2. Ensure it's running iOS 17.0+
3. Select your development team
4. Build and run

### 3. Widget Testing

To test widgets:

1. Run the app on device/simulator
2. Add some mileage entries
3. Long press on home screen
4. Tap "+" to add widgets
5. Search for "Lease Miles Tracker"
6. Add the widget to home screen

## Testing

### 1. Unit Tests

Run unit tests with:
```bash
xcodebuild test -scheme LeaseMilesTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 2. UI Tests

Run UI tests with:
```bash
xcodebuild test -scheme LeaseMilesTracker -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:LeaseMilesTrackerUITests
```

### 3. Widget Tests

Widget functionality is tested through the main app's data flow. Ensure:

1. App Groups are properly configured
2. Data syncs between app and widget
3. Widget updates when app data changes

## Troubleshooting

### Common Issues

#### 1. App Groups Not Working
- Verify both app and widget targets have App Groups capability
- Check bundle identifiers match
- Ensure provisioning profiles include App Groups

#### 2. Widget Not Updating
- Check App Groups configuration
- Verify SharedDataManager is updating data
- Test on device (simulator may have limitations)

#### 3. Notifications Not Working
- Check notification permissions
- Verify notification settings in iOS Settings
- Test with the built-in notification testing feature

#### 4. Build Errors
- Clean build folder (Cmd+Shift+K)
- Reset package caches
- Check deployment target compatibility

### Debug Tips

1. **Widget Debugging**: Use the widget preview in Xcode
2. **Data Sync**: Check SharedDataManager logs
3. **Notifications**: Use the notification testing view
4. **Charts**: Ensure Swift Charts framework is available

## Deployment

### 1. App Store

1. Archive the app
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

### 2. TestFlight

1. Archive the app
2. Upload to App Store Connect
3. Add test users
4. Distribute via TestFlight

## Performance Considerations

- **Widget Updates**: Limited to hourly updates
- **Data Storage**: Uses SwiftData for efficient storage
- **Memory Usage**: Optimized for minimal memory footprint
- **Battery Life**: Efficient background processing

## Security

- **Data Privacy**: All data stored locally
- **No Network Access**: No external API calls
- **App Groups**: Secure data sharing between app and widget
- **User Permissions**: Only notification permissions required

## Future Enhancements

Potential areas for future development:

1. **iCloud Sync**: Optional cloud synchronization
2. **Apple Watch**: Widget complications
3. **Multiple Leases**: Support for multiple vehicles
4. **Advanced Analytics**: More detailed reporting
5. **Export Options**: Additional export formats

---

For additional support, refer to the main README.md file or check the test files for usage examples.
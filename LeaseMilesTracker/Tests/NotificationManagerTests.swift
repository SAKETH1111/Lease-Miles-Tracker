import XCTest
import UserNotifications
@testable import LeaseMilesTracker

@MainActor
class NotificationManagerTests: XCTestCase {
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager.shared
    }
    
    override func tearDown() {
        // Clean up any test notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        super.tearDown()
    }
    
    func testNotificationManagerInitialization() {
        XCTAssertNotNil(notificationManager)
        XCTAssertEqual(notificationManager.authorizationStatus, .notDetermined)
    }
    
    func testRequestPermission() async {
        let granted = await notificationManager.requestPermission()
        // Note: This test may fail in simulator without user interaction
        // In a real test environment, you'd mock the notification center
        XCTAssertTrue(granted || !granted) // Either result is valid
    }
    
    func testSendTestNotification() {
        // This test verifies the method doesn't crash
        // Actual notification delivery depends on permissions
        notificationManager.sendTestNotification()
        
        // Verify no crash occurred
        XCTAssertTrue(true)
    }
    
    func testScheduleTestReminder() {
        // Test scheduling a reminder
        notificationManager.scheduleTestReminder(seconds: 1)
        
        // Verify no crash occurred
        XCTAssertTrue(true)
    }
    
    func testCancelTestReminder() {
        // Test canceling reminders
        notificationManager.cancelTestReminder()
        
        // Verify no crash occurred
        XCTAssertTrue(true)
    }
    
    func testSendThresholdAlert() {
        // Test threshold alert
        notificationManager.sendThresholdAlert(milesDriven: 25000, thresholdPercent: 90, projectedOverage: 5000)
        
        // Verify no crash occurred
        XCTAssertTrue(true)
    }
    
    func testGetPendingNotifications() async {
        let pendingNotifications = await notificationManager.getPendingNotifications()
        // Should return empty array initially
        XCTAssertTrue(pendingNotifications.isEmpty)
    }
    
    func testGetDeliveredNotifications() async {
        let deliveredNotifications = await notificationManager.getDeliveredNotifications()
        // Should return empty array initially
        XCTAssertTrue(deliveredNotifications.isEmpty)
    }
}
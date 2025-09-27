import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func scheduleMonthlyReminder(dayOfMonth: Int) {
        guard authorizationStatus == .authorized else { return }
        
        cancelAllReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "Mileage Update Reminder"
        content.body = "Don't forget to update your odometer reading!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.day = dayOfMonth
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        // If the day has passed this month, schedule for next month
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        
        if dayOfMonth <= currentDay {
            dateComponents.month = calendar.component(.month, from: today) + 1
        } else {
            dateComponents.month = calendar.component(.month, from: today)
        }
        
        dateComponents.year = calendar.component(.year, from: today)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "monthly-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling monthly reminder: \(error)")
            }
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func sendThresholdAlert(milesDriven: Int, thresholdPercent: Int, projectedOverage: Int) {
        guard authorizationStatus == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Mileage Alert"
        
        if projectedOverage > 0 {
            content.body = "You're projected to exceed your lease mileage by \(projectedOverage) miles!"
        } else {
            content.body = "You've used \(thresholdPercent)% of your allowed mileage!"
        }
        
        content.sound = .default
        content.userInfo = ["action": "open_and_update"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "threshold-alert", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending threshold alert: \(error)")
            }
        }
    }
}
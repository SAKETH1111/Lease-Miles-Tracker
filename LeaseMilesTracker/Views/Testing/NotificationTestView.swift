import SwiftUI
import UserNotifications

struct NotificationTestView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var testScheduled = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notification Testing")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Test your notification settings and schedule test alerts.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    // Permission Status
                    HStack {
                        Image(systemName: notificationIcon)
                            .foregroundColor(notificationColor)
                        VStack(alignment: .leading) {
                            Text("Permission Status")
                                .font(.headline)
                            Text(permissionStatusText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Test Buttons
                    VStack(spacing: 12) {
                        Button(action: requestPermission) {
                            HStack {
                                Image(systemName: "bell.badge")
                                Text("Request Permission")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(notificationManager.authorizationStatus == .authorized)
                        
                        Button(action: sendTestNotification) {
                            HStack {
                                Image(systemName: "paperplane")
                                Text("Send Test Notification")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(notificationManager.authorizationStatus != .authorized)
                        
                        Button(action: scheduleTestReminder) {
                            HStack {
                                Image(systemName: "clock")
                                Text(testScheduled ? "Cancel Test Reminder" : "Schedule Test Reminder (5s)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(testScheduled ? Color.red : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(notificationManager.authorizationStatus != .authorized)
                        
                        Button(action: testThresholdAlert) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Test Threshold Alert")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(notificationManager.authorizationStatus != .authorized)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Notification Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss the view
                    }
                }
            }
            .alert("Notification Test", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                notificationManager.checkAuthorizationStatus()
            }
        }
    }
    
    private var notificationIcon: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        case .provisional:
            return "exclamationmark.circle.fill"
        case .ephemeral:
            return "clock.circle.fill"
        @unknown default:
            return "questionmark.circle.fill"
        }
    }
    
    private var notificationColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        case .provisional:
            return .blue
        case .ephemeral:
            return .purple
        @unknown default:
            return .gray
        }
    }
    
    private var permissionStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "Notifications are enabled"
        case .denied:
            return "Notifications are disabled. Enable in Settings."
        case .notDetermined:
            return "Permission not requested yet"
        case .provisional:
            return "Provisional notifications enabled"
        case .ephemeral:
            return "Ephemeral notifications enabled"
        @unknown default:
            return "Unknown status"
        }
    }
    
    private func requestPermission() {
        Task {
            let granted = await notificationManager.requestPermission()
            await MainActor.run {
                if granted {
                    alertMessage = "Notification permission granted!"
                } else {
                    alertMessage = "Notification permission denied. Please enable in Settings."
                }
                showingAlert = true
            }
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from Lease Miles Tracker!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Error sending test notification: \(error.localizedDescription)"
                } else {
                    alertMessage = "Test notification sent!"
                }
                showingAlert = true
            }
        }
    }
    
    private func scheduleTestReminder() {
        if testScheduled {
            // Cancel the test reminder
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["test-reminder"])
            testScheduled = false
            alertMessage = "Test reminder cancelled"
        } else {
            // Schedule a test reminder for 5 seconds
            let content = UNMutableNotificationContent()
            content.title = "Test Reminder"
            content.body = "This is a test reminder scheduled 5 seconds ago!"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "test-reminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        alertMessage = "Error scheduling test reminder: \(error.localizedDescription)"
                    } else {
                        testScheduled = true
                        alertMessage = "Test reminder scheduled for 5 seconds!"
                    }
                    showingAlert = true
                }
            }
        }
    }
    
    private func testThresholdAlert() {
        notificationManager.sendThresholdAlert(milesDriven: 25000, thresholdPercent: 90, projectedOverage: 5000)
        alertMessage = "Threshold alert sent! Check your notifications."
        showingAlert = true
    }
}

#Preview {
    NotificationTestView()
}
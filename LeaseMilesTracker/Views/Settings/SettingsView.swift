import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [LeaseSettings]
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var leaseStartDate = Date()
    @State private var leaseEndDate = Date()
    @State private var startingOdometer = ""
    @State private var allowedMilesTotal = ""
    @State private var costPerMile = ""
    @State private var reminderDayOfMonth = ""
    @State private var lowMilesThresholdPercent = ""
    @State private var isNotificationEnabled = false
    @State private var showingResetAlert = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var settingsStore: LeaseSettingsStore {
        LeaseSettingsStore(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let leaseSettings = settings.first {
                    Section("Lease Details") {
                        DatePicker("Lease Start Date", selection: $leaseStartDate, displayedComponents: .date)
                        DatePicker("Lease End Date", selection: $leaseEndDate, displayedComponents: .date)
                    }
                    
                    Section("Odometer") {
                        TextField("Starting Odometer", text: $startingOdometer)
                            .keyboardType(.numberPad)
                    }
                    
                    Section("Mileage Allowance") {
                        TextField("Allowed Miles Total", text: $allowedMilesTotal)
                            .keyboardType(.numberPad)
                    }
                    
                    Section("Cost") {
                        TextField("Cost Per Mile ($)", text: $costPerMile)
                            .keyboardType(.decimalPad)
                    }
                    
                    Section("Notifications") {
                        Toggle("Enable Monthly Reminders", isOn: $isNotificationEnabled)
                        
                        if isNotificationEnabled {
                            TextField("Day of Month (1-28)", text: $reminderDayOfMonth)
                                .keyboardType(.numberPad)
                        }
                        
                        if notificationManager.authorizationStatus != .authorized {
                            Button("Request Notification Permission") {
                                Task {
                                    await notificationManager.requestPermission()
                                }
                            }
                        }
                    }
                    
                    Section("Threshold") {
                        TextField("Low Miles Threshold %", text: $lowMilesThresholdPercent)
                            .keyboardType(.numberPad)
                    }
                    
                    Section {
                        Button("Save Changes") {
                            saveSettings()
                        }
                        .disabled(!isValidInput)
                    }
                    
                    Section("Danger Zone") {
                        Button("Reset All Data", role: .destructive) {
                            showingResetAlert = true
                        }
                    }
                } else {
                    Section {
                        Text("No settings found. Please restart the app.")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadCurrentSettings()
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your lease settings and mileage entries. This action cannot be undone.")
            }
        }
    }
    
    private var isValidInput: Bool {
        return !startingOdometer.isEmpty &&
               !allowedMilesTotal.isEmpty &&
               !costPerMile.isEmpty &&
               Int(startingOdometer) != nil &&
               Int(allowedMilesTotal) != nil &&
               Double(costPerMile) != nil &&
               leaseEndDate > leaseStartDate
    }
    
    private func loadCurrentSettings() {
        guard let leaseSettings = settings.first else { return }
        
        leaseStartDate = leaseSettings.leaseStartDate
        leaseEndDate = leaseSettings.leaseEndDate
        startingOdometer = String(leaseSettings.startingOdometer)
        allowedMilesTotal = String(leaseSettings.allowedMilesTotal)
        costPerMile = String(describing: leaseSettings.costPerMile)
        reminderDayOfMonth = leaseSettings.reminderDayOfMonth.map(String.init) ?? ""
        lowMilesThresholdPercent = String(leaseSettings.lowMilesThresholdPercent)
        isNotificationEnabled = leaseSettings.reminderDayOfMonth != nil
    }
    
    private func saveSettings() {
        guard let startingOdometerInt = Int(startingOdometer),
              let allowedMilesTotalInt = Int(allowedMilesTotal),
              let costPerMileDouble = Double(costPerMile),
              leaseEndDate > leaseStartDate else {
            alertMessage = "Please fill in all required fields with valid values."
            showingAlert = true
            return
        }
        
        let reminderDay = isNotificationEnabled ? Int(reminderDayOfMonth) : nil
        let thresholdPercent = Int(lowMilesThresholdPercent) ?? 90
        
        if let reminderDay = reminderDay, (reminderDay < 1 || reminderDay > 28) {
            alertMessage = "Reminder day must be between 1 and 28."
            showingAlert = true
            return
        }
        
        settingsStore.updateSettings(
            leaseStartDate: leaseStartDate,
            leaseEndDate: leaseEndDate,
            startingOdometer: startingOdometerInt,
            allowedMilesTotal: allowedMilesTotalInt,
            costPerMile: Decimal(costPerMileDouble),
            reminderDayOfMonth: reminderDay,
            lowMilesThresholdPercent: thresholdPercent
        )
        
        // Update notification scheduling
        if isNotificationEnabled, let day = reminderDay {
            if notificationManager.authorizationStatus == .authorized {
                notificationManager.scheduleMonthlyReminder(dayOfMonth: day)
            }
        } else {
            notificationManager.cancelAllReminders()
        }
    }
    
    private func resetAllData() {
        settingsStore.resetData()
        notificationManager.cancelAllReminders()
    }
}
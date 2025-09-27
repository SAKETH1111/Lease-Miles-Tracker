import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var leaseStartDate = Date()
    @State private var leaseEndDate = Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
    @State private var startingOdometer = ""
    @State private var allowedMilesTotal = ""
    @State private var costPerMile = ""
    @State private var reminderDayOfMonth = ""
    @State private var lowMilesThresholdPercent = "90"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isNotificationEnabled = false
    
    private var settingsStore: LeaseSettingsStore {
        LeaseSettingsStore(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            Form {
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
                }
                
                Section("Threshold") {
                    TextField("Low Miles Threshold %", text: $lowMilesThresholdPercent)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Setup Your Lease")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .disabled(!isValidInput)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
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
        
        let settings = LeaseSettings(
            leaseStartDate: leaseStartDate,
            leaseEndDate: leaseEndDate,
            startingOdometer: startingOdometerInt,
            allowedMilesTotal: allowedMilesTotalInt,
            costPerMile: Decimal(costPerMileDouble),
            reminderDayOfMonth: reminderDay,
            lowMilesThresholdPercent: thresholdPercent
        )
        
        settingsStore.saveSettings(settings)
        
        // Request notification permission if enabled
        if isNotificationEnabled {
            Task {
                let granted = await NotificationManager.shared.requestPermission()
                if granted, let day = reminderDay {
                    NotificationManager.shared.scheduleMonthlyReminder(dayOfMonth: day)
                }
            }
        }
    }
}
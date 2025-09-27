import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
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
    
    private var carStore: CarStore {
        CarStore(modelContext: modelContext)
    }
    
    private var activeCar: Car? {
        cars.first { $0.isActive }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let activeCar = activeCar {
                    Section("Active Car") {
                        HStack {
                            Image(systemName: "car.circle.fill")
                                .foregroundColor(.blue)
                            Text(activeCar.displayName)
                                .font(.headline)
                        }
                    }
                    
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
                        Button("Reset This Car's Data", role: .destructive) {
                            showingResetAlert = true
                        }
                    }
                } else {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "car.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Active Car")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Select a car from your garage to manage its settings")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
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
            .alert("Reset Car Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetCarData()
                }
            } message: {
                Text("This will delete all mileage entries for the active car. This action cannot be undone.")
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
        guard let activeCar = activeCar else { return }
        
        leaseStartDate = activeCar.leaseStartDate
        leaseEndDate = activeCar.leaseEndDate
        startingOdometer = String(activeCar.startingOdometer)
        allowedMilesTotal = String(activeCar.allowedMilesTotal)
        costPerMile = String(describing: activeCar.costPerMile)
        reminderDayOfMonth = activeCar.reminderDayOfMonth.map(String.init) ?? ""
        lowMilesThresholdPercent = String(activeCar.lowMilesThresholdPercent)
        isNotificationEnabled = activeCar.reminderDayOfMonth != nil
    }
    
    private func saveSettings() {
        guard let activeCar = activeCar,
              let startingOdometerInt = Int(startingOdometer),
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
        
        // Update the active car's settings
        activeCar.leaseStartDate = leaseStartDate
        activeCar.leaseEndDate = leaseEndDate
        activeCar.startingOdometer = startingOdometerInt
        activeCar.allowedMilesTotal = allowedMilesTotalInt
        activeCar.costPerMile = Decimal(costPerMileDouble)
        activeCar.reminderDayOfMonth = reminderDay
        activeCar.lowMilesThresholdPercent = thresholdPercent
        
        carStore.updateCar(activeCar)
        
        // Update notification scheduling
        if isNotificationEnabled, let day = reminderDay {
            if notificationManager.authorizationStatus == .authorized {
                notificationManager.scheduleMonthlyReminder(dayOfMonth: day)
            }
        } else {
            notificationManager.cancelAllReminders()
        }
    }
    
    private func resetCarData() {
        guard let activeCar = activeCar else { return }
        
        // Delete all mileage entries for this car
        let mileageStore = MileageStore(modelContext: modelContext)
        let entries = mileageStore.loadEntries(for: activeCar)
        for entry in entries {
            mileageStore.deleteEntry(entry)
        }
        
        notificationManager.cancelAllReminders()
    }
}
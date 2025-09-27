import Foundation
import SwiftData

@MainActor
class LeaseSettingsStore: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadSettings() -> LeaseSettings? {
        let descriptor = FetchDescriptor<LeaseSettings>()
        return try? modelContext.fetch(descriptor).first
    }
    
    func saveSettings(_ settings: LeaseSettings) {
        // Delete existing settings if any
        let existingSettings = loadSettings()
        if let existing = existingSettings {
            modelContext.delete(existing)
        }
        
        modelContext.insert(settings)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving lease settings: \(error)")
        }
    }
    
    func updateSettings(
        leaseStartDate: Date,
        leaseEndDate: Date,
        startingOdometer: Int,
        allowedMilesTotal: Int,
        costPerMile: Decimal,
        reminderDayOfMonth: Int?,
        lowMilesThresholdPercent: Int
    ) {
        if let existing = loadSettings() {
            existing.leaseStartDate = leaseStartDate
            existing.leaseEndDate = leaseEndDate
            existing.startingOdometer = startingOdometer
            existing.allowedMilesTotal = allowedMilesTotal
            existing.costPerMile = costPerMile
            existing.reminderDayOfMonth = reminderDayOfMonth
            existing.lowMilesThresholdPercent = lowMilesThresholdPercent
            
            do {
                try modelContext.save()
            } catch {
                print("Error updating lease settings: \(error)")
            }
        }
    }
    
    func resetData() {
        // Delete all settings
        if let existing = loadSettings() {
            modelContext.delete(existing)
        }
        
        // Delete all mileage entries
        let entriesDescriptor = FetchDescriptor<MileageEntry>()
        if let entries = try? modelContext.fetch(entriesDescriptor) {
            for entry in entries {
                modelContext.delete(entry)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error resetting data: \(error)")
        }
    }
}
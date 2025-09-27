import Foundation
import SwiftData

@Model
class LeaseSettings {
    var leaseStartDate: Date
    var leaseEndDate: Date
    var startingOdometer: Int
    var allowedMilesTotal: Int
    var costPerMile: Decimal
    var reminderDayOfMonth: Int?
    var lowMilesThresholdPercent: Int
    
    init(
        leaseStartDate: Date = Date(),
        leaseEndDate: Date = Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date(),
        startingOdometer: Int = 0,
        allowedMilesTotal: Int = 36000,
        costPerMile: Decimal = 0.25,
        reminderDayOfMonth: Int? = nil,
        lowMilesThresholdPercent: Int = 90
    ) {
        self.leaseStartDate = leaseStartDate
        self.leaseEndDate = leaseEndDate
        self.startingOdometer = startingOdometer
        self.allowedMilesTotal = allowedMilesTotal
        self.costPerMile = costPerMile
        self.reminderDayOfMonth = reminderDayOfMonth
        self.lowMilesThresholdPercent = lowMilesThresholdPercent
    }
    
    var isComplete: Bool {
        return startingOdometer > 0 && allowedMilesTotal > 0 && costPerMile > 0
    }
}
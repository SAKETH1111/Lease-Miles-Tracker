import Foundation
import SwiftData

@Model
class Car {
    var id: UUID
    var name: String
    var make: String?
    var model: String?
    var year: Int?
    var color: String?
    var leaseStartDate: Date
    var leaseEndDate: Date
    var startingOdometer: Int
    var allowedMilesTotal: Int
    var costPerMile: Decimal
    var reminderDayOfMonth: Int?
    var lowMilesThresholdPercent: Int
    var isActive: Bool
    var dateCreated: Date
    
    @Relationship(deleteRule: .cascade, inverse: \MileageEntry.car)
    var mileageEntries: [MileageEntry] = []
    
    init(
        name: String,
        make: String? = nil,
        model: String? = nil,
        year: Int? = nil,
        color: String? = nil,
        leaseStartDate: Date = Date(),
        leaseEndDate: Date = Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date(),
        startingOdometer: Int = 0,
        allowedMilesTotal: Int = 36000,
        costPerMile: Decimal = 0.25,
        reminderDayOfMonth: Int? = nil,
        lowMilesThresholdPercent: Int = 90,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.make = make
        self.model = model
        self.year = year
        self.color = color
        self.leaseStartDate = leaseStartDate
        self.leaseEndDate = leaseEndDate
        self.startingOdometer = startingOdometer
        self.allowedMilesTotal = allowedMilesTotal
        self.costPerMile = costPerMile
        self.reminderDayOfMonth = reminderDayOfMonth
        self.lowMilesThresholdPercent = lowMilesThresholdPercent
        self.isActive = isActive
        self.dateCreated = Date()
    }
    
    var displayName: String {
        if let make = make, let model = model {
            return "\(year.map { "\($0) " } ?? "")\(make) \(model)"
        } else {
            return name
        }
    }
    
    var isComplete: Bool {
        return startingOdometer > 0 && allowedMilesTotal > 0 && costPerMile > 0 && !name.isEmpty
    }
    
    var leaseSettings: LeaseSettings {
        return LeaseSettings(
            leaseStartDate: leaseStartDate,
            leaseEndDate: leaseEndDate,
            startingOdometer: startingOdometer,
            allowedMilesTotal: allowedMilesTotal,
            costPerMile: costPerMile,
            reminderDayOfMonth: reminderDayOfMonth,
            lowMilesThresholdPercent: lowMilesThresholdPercent
        )
    }
    
    func updateFromLeaseSettings(_ settings: LeaseSettings) {
        self.leaseStartDate = settings.leaseStartDate
        self.leaseEndDate = settings.leaseEndDate
        self.startingOdometer = settings.startingOdometer
        self.allowedMilesTotal = settings.allowedMilesTotal
        self.costPerMile = settings.costPerMile
        self.reminderDayOfMonth = settings.reminderDayOfMonth
        self.lowMilesThresholdPercent = settings.lowMilesThresholdPercent
    }
}
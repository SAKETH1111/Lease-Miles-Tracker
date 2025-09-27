import Foundation

struct LeaseSnapshot {
    let milesDriven: Int
    let remainingMiles: Int
    let monthsLeft: Int
    let avgMilesPerDay: Double
    let projectedMilesAtEnd: Int
    let projectedOverage: Int
    let runningCost: Decimal
    let projectedOverageCost: Decimal
}

struct LeaseCalculator {
    static func calculateSnapshot(
        settings: LeaseSettings,
        entries: [MileageEntry]
    ) -> LeaseSnapshot {
        let calendar = Calendar.current
        let today = Date()
        
        // Get latest odometer reading
        let latestOdometer = entries.max(by: { $0.date < $1.date })?.odometer ?? settings.startingOdometer
        let milesDriven = max(0, latestOdometer - settings.startingOdometer)
        let remainingMiles = max(0, settings.allowedMilesTotal - milesDriven)
        
        // Calculate months left
        let monthsLeft = max(0, calendar.dateComponents([.month], from: today, to: settings.leaseEndDate).month ?? 0)
        
        // Calculate average miles per day since lease start
        let daysSinceStart = max(1, calendar.dateComponents([.day], from: settings.leaseStartDate, to: today).day ?? 1)
        let avgMilesPerDay = Double(milesDriven) / Double(daysSinceStart)
        
        // Calculate projected miles at end of lease
        let daysUntilEnd = max(1, calendar.dateComponents([.day], from: today, to: settings.leaseEndDate).day ?? 1)
        let projectedMilesAtEnd = milesDriven + Int(avgMilesPerDay * Double(daysUntilEnd))
        let projectedOverage = max(0, projectedMilesAtEnd - settings.allowedMilesTotal)
        
        // Calculate costs
        let runningCost = Decimal(milesDriven) * settings.costPerMile
        let projectedOverageCost = Decimal(projectedOverage) * settings.costPerMile
        
        return LeaseSnapshot(
            milesDriven: milesDriven,
            remainingMiles: remainingMiles,
            monthsLeft: monthsLeft,
            avgMilesPerDay: avgMilesPerDay,
            projectedMilesAtEnd: projectedMilesAtEnd,
            projectedOverage: projectedOverage,
            runningCost: runningCost,
            projectedOverageCost: projectedOverageCost
        )
    }
    
    static func shouldShowWarning(
        settings: LeaseSettings,
        snapshot: LeaseSnapshot
    ) -> Bool {
        let thresholdMiles = Int(Double(settings.allowedMilesTotal) * Double(settings.lowMilesThresholdPercent) / 100.0)
        return snapshot.milesDriven >= thresholdMiles || snapshot.projectedOverage > 0
    }
    
    static func validateOdometerEntry(
        newOdometer: Int,
        previousOdometer: Int,
        startingOdometer: Int
    ) -> ValidationResult {
        if newOdometer < startingOdometer {
            return .failure("Odometer reading cannot be less than starting odometer (\(startingOdometer))")
        }
        
        if newOdometer < previousOdometer {
            return .failure("Odometer reading cannot be less than previous reading (\(previousOdometer))")
        }
        
        return .success
    }
}

enum ValidationResult {
    case success
    case failure(String)
}
import XCTest
@testable import LeaseMilesTracker

class LeaseCalculatorTests: XCTestCase {
    
    func testCalculateSnapshotWithZeroEntries() {
        let settings = LeaseSettings(
            leaseStartDate: Date(),
            leaseEndDate: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [])
        
        XCTAssertEqual(snapshot.milesDriven, 0)
        XCTAssertEqual(snapshot.remainingMiles, 36000)
        XCTAssertEqual(snapshot.avgMilesPerDay, 0.0)
        XCTAssertEqual(snapshot.runningCost, 0)
        XCTAssertEqual(snapshot.projectedOverage, 0)
        XCTAssertEqual(snapshot.projectedOverageCost, 0)
    }
    
    func testCalculateSnapshotWithEntries() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let settings = LeaseSettings(
            leaseStartDate: startDate,
            leaseEndDate: calendar.date(byAdding: .year, value: 3, to: startDate) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        let entry1 = MileageEntry(date: calendar.date(byAdding: .day, value: -15, to: Date()) ?? Date(), odometer: 10500)
        let entry2 = MileageEntry(date: Date(), odometer: 11000)
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [entry1, entry2])
        
        XCTAssertEqual(snapshot.milesDriven, 1000) // 11000 - 10000
        XCTAssertEqual(snapshot.remainingMiles, 35000) // 36000 - 1000
        XCTAssertEqual(snapshot.avgMilesPerDay, 1000.0 / 30.0, accuracy: 0.1)
        XCTAssertEqual(snapshot.runningCost, 250) // 1000 * 0.25
    }
    
    func testSameDayStart() {
        let today = Date()
        let settings = LeaseSettings(
            leaseStartDate: today,
            leaseEndDate: Calendar.current.date(byAdding: .year, value: 3, to: today) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        let entry = MileageEntry(date: today, odometer: 10100)
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [entry])
        
        XCTAssertEqual(snapshot.milesDriven, 100)
        XCTAssertEqual(snapshot.avgMilesPerDay, 100.0, accuracy: 0.1) // Should handle same day gracefully
    }
    
    func testCrossingThreshold() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let settings = LeaseSettings(
            leaseStartDate: startDate,
            leaseEndDate: calendar.date(byAdding: .year, value: 3, to: startDate) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25,
            lowMilesThresholdPercent: 90
        )
        
        // Entry that crosses 90% threshold (32,400 miles)
        let entry = MileageEntry(date: Date(), odometer: 42400) // 32,400 miles driven
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [entry])
        
        XCTAssertTrue(LeaseCalculator.shouldShowWarning(settings: settings, snapshot: snapshot))
        XCTAssertEqual(snapshot.milesDriven, 32400)
        XCTAssertEqual(snapshot.remainingMiles, 3600)
    }
    
    func testProjectedOverage() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -365, to: Date()) ?? Date()
        let settings = LeaseSettings(
            leaseStartDate: startDate,
            leaseEndDate: calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        // High mileage entry that projects overage
        let entry = MileageEntry(date: Date(), odometer: 45000) // 35,000 miles driven in 1 year
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [entry])
        
        XCTAssertTrue(snapshot.projectedOverage > 0)
        XCTAssertTrue(LeaseCalculator.shouldShowWarning(settings: settings, snapshot: snapshot))
    }
    
    func testMonthsCalculationAcrossBoundaries() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -60, to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        let settings = LeaseSettings(
            leaseStartDate: startDate,
            leaseEndDate: endDate,
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [])
        
        // Should handle month boundaries correctly
        XCTAssertGreaterThanOrEqual(snapshot.monthsLeft, 0)
        XCTAssertLessThanOrEqual(snapshot.monthsLeft, 1) // Should be about 1 month left
    }
    
    func testLeasePastEndDate() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -400, to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date() // Lease ended 10 days ago
        let settings = LeaseSettings(
            leaseStartDate: startDate,
            leaseEndDate: endDate,
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        let entry = MileageEntry(date: Date(), odometer: 50000) // 40,000 miles driven
        
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: [entry])
        
        XCTAssertEqual(snapshot.monthsLeft, 0) // Should be 0 since lease has ended
        XCTAssertEqual(snapshot.milesDriven, 40000)
        XCTAssertTrue(snapshot.projectedOverage > 0) // Should show overage
    }
    
    func testOdometerValidation() {
        let validation1 = LeaseCalculator.validateOdometerEntry(
            newOdometer: 10500,
            previousOdometer: 10000,
            startingOdometer: 10000
        )
        XCTAssertEqual(validation1, .success)
        
        let validation2 = LeaseCalculator.validateOdometerEntry(
            newOdometer: 9500,
            previousOdometer: 10000,
            startingOdometer: 10000
        )
        XCTAssertEqual(validation2, .failure("Odometer reading cannot be less than previous reading (10000)"))
        
        let validation3 = LeaseCalculator.validateOdometerEntry(
            newOdometer: 9500,
            previousOdometer: 10000,
            startingOdometer: 10000
        )
        XCTAssertEqual(validation3, .failure("Odometer reading cannot be less than previous reading (10000)"))
    }
}
import XCTest
@testable import LeaseMilesTracker

class WidgetTests: XCTestCase {
    
    func testWidgetDataEncoding() {
        let widgetData = WidgetData(
            milesDriven: 15000,
            remainingMiles: 21000,
            monthsLeft: 18,
            projectedOverage: 0,
            lastUpdated: Date()
        )
        
        // Test encoding
        let encodedData = try? JSONEncoder().encode(widgetData)
        XCTAssertNotNil(encodedData)
        
        // Test decoding
        let decodedData = try? JSONDecoder().decode(WidgetData.self, from: encodedData!)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.milesDriven, 15000)
        XCTAssertEqual(decodedData?.remainingMiles, 21000)
        XCTAssertEqual(decodedData?.monthsLeft, 18)
        XCTAssertEqual(decodedData?.projectedOverage, 0)
    }
    
    func testWidgetDataWithOverage() {
        let widgetData = WidgetData(
            milesDriven: 35000,
            remainingMiles: 1000,
            monthsLeft: 6,
            projectedOverage: 5000,
            lastUpdated: Date()
        )
        
        let encodedData = try? JSONEncoder().encode(widgetData)
        XCTAssertNotNil(encodedData)
        
        let decodedData = try? JSONDecoder().decode(WidgetData.self, from: encodedData!)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.projectedOverage, 5000)
    }
    
    func testSharedDataManagerSingleton() {
        let instance1 = SharedDataManager.shared
        let instance2 = SharedDataManager.shared
        XCTAssertIdentical(instance1, instance2)
    }
    
    func testWidgetDataUpdate() {
        let settings = LeaseSettings(
            leaseStartDate: Date(),
            leaseEndDate: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        let entry = MileageEntry(date: Date(), odometer: 15000)
        
        SharedDataManager.shared.updateWidgetData(settings: settings, entries: [entry])
        
        let widgetData = SharedDataManager.shared.getWidgetData()
        XCTAssertNotNil(widgetData)
        XCTAssertEqual(widgetData?.milesDriven, 5000) // 15000 - 10000
    }
}

class QuickActionsManagerTests: XCTestCase {
    var quickActionsManager: QuickActionsManager!
    
    override func setUp() {
        super.setUp()
        quickActionsManager = QuickActionsManager.shared
    }
    
    func testQuickActionsManagerSingleton() {
        let instance1 = QuickActionsManager.shared
        let instance2 = QuickActionsManager.shared
        XCTAssertIdentical(instance1, instance2)
    }
    
    func testSetupQuickActions() {
        // This test verifies the method doesn't crash
        quickActionsManager.setupQuickActions()
        
        // Verify no crash occurred
        XCTAssertTrue(true)
    }
    
    func testHandleQuickAction() {
        let addEntryAction = UIApplicationShortcutItem(
            type: "com.leasemilestracker.addentry",
            localizedTitle: "Add Mileage Entry",
            localizedSubtitle: "Quickly add a new odometer reading",
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"),
            userInfo: nil
        )
        
        let result = quickActionsManager.handleQuickAction(addEntryAction)
        XCTAssertTrue(result)
    }
    
    func testHandleUnknownQuickAction() {
        let unknownAction = UIApplicationShortcutItem(
            type: "unknown.action",
            localizedTitle: "Unknown Action",
            localizedSubtitle: "This should not be handled",
            icon: UIApplicationShortcutIcon(systemImageName: "questionmark"),
            userInfo: nil
        )
        
        let result = quickActionsManager.handleQuickAction(unknownAction)
        XCTAssertFalse(result)
    }
}

class CarModelTests: XCTestCase {
    
    func testCarInitialization() {
        let car = Car(
            name: "Test Car",
            make: "Toyota",
            model: "Camry",
            year: 2023,
            color: "Blue",
            leaseStartDate: Date(),
            leaseEndDate: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25,
            reminderDayOfMonth: 15,
            lowMilesThresholdPercent: 90
        )
        
        XCTAssertEqual(car.name, "Test Car")
        XCTAssertEqual(car.make, "Toyota")
        XCTAssertEqual(car.model, "Camry")
        XCTAssertEqual(car.year, 2023)
        XCTAssertEqual(car.color, "Blue")
        XCTAssertEqual(car.startingOdometer, 10000)
        XCTAssertEqual(car.allowedMilesTotal, 36000)
        XCTAssertEqual(car.costPerMile, 0.25)
        XCTAssertEqual(car.reminderDayOfMonth, 15)
        XCTAssertEqual(car.lowMilesThresholdPercent, 90)
        XCTAssertTrue(car.isActive)
    }
    
    func testCarDisplayName() {
        let carWithMakeModel = Car(
            name: "My Car",
            make: "Toyota",
            model: "Camry",
            year: 2023
        )
        
        XCTAssertEqual(carWithMakeModel.displayName, "2023 Toyota Camry")
        
        let carWithoutMakeModel = Car(name: "My Car")
        XCTAssertEqual(carWithoutMakeModel.displayName, "My Car")
    }
    
    func testCarIsComplete() {
        let completeCar = Car(
            name: "Test Car",
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25
        )
        
        XCTAssertTrue(completeCar.isComplete)
        
        let incompleteCar = Car(
            name: "",
            startingOdometer: 0,
            allowedMilesTotal: 0,
            costPerMile: 0
        )
        
        XCTAssertFalse(incompleteCar.isComplete)
    }
    
    func testCarLeaseSettings() {
        let car = Car(
            name: "Test Car",
            leaseStartDate: Date(),
            leaseEndDate: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date(),
            startingOdometer: 10000,
            allowedMilesTotal: 36000,
            costPerMile: 0.25,
            reminderDayOfMonth: 15,
            lowMilesThresholdPercent: 90
        )
        
        let settings = car.leaseSettings
        
        XCTAssertEqual(settings.leaseStartDate, car.leaseStartDate)
        XCTAssertEqual(settings.leaseEndDate, car.leaseEndDate)
        XCTAssertEqual(settings.startingOdometer, car.startingOdometer)
        XCTAssertEqual(settings.allowedMilesTotal, car.allowedMilesTotal)
        XCTAssertEqual(settings.costPerMile, car.costPerMile)
        XCTAssertEqual(settings.reminderDayOfMonth, car.reminderDayOfMonth)
        XCTAssertEqual(settings.lowMilesThresholdPercent, car.lowMilesThresholdPercent)
    }
}

class MileageEntryTests: XCTestCase {
    
    func testMileageEntryInitialization() {
        let date = Date()
        let entry = MileageEntry(
            date: date,
            odometer: 15000,
            notes: "Test entry"
        )
        
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.odometer, 15000)
        XCTAssertEqual(entry.notes, "Test entry")
    }
    
    func testMileageEntryWithoutNotes() {
        let date = Date()
        let entry = MileageEntry(date: date, odometer: 15000)
        
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.odometer, 15000)
        XCTAssertNil(entry.notes)
    }
}

class FormattersTests: XCTestCase {
    
    func testNumberFormatting() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        XCTAssertEqual(1000.formatted, "1,000")
        XCTAssertEqual(1000000.formatted, "1,000,000")
        XCTAssertEqual(0.formatted, "0")
    }
    
    func testCurrencyFormatting() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let amount = Decimal(25.50)
        let formatted = formatter.string(from: NSDecimalNumber(decimal: amount)) ?? ""
        
        XCTAssertTrue(formatted.contains("$25.50"))
    }
    
    func testDateFormatting() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
    }
}
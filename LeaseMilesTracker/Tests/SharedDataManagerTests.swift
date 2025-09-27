import XCTest
@testable import LeaseMilesTracker

class SharedDataManagerTests: XCTestCase {
    var sharedDataManager: SharedDataManager!
    
    override func setUp() {
        super.setUp()
        sharedDataManager = SharedDataManager.shared
    }
    
    func testSharedDataManagerSingleton() {
        let instance1 = SharedDataManager.shared
        let instance2 = SharedDataManager.shared
        XCTAssertIdentical(instance1, instance2)
    }
    
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
}
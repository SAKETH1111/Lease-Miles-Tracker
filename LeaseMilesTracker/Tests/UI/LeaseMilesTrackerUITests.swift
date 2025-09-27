import XCTest
@testable import LeaseMilesTracker

class LeaseMilesTrackerUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testOnboardingFlow() throws {
        // Test the onboarding flow when no cars exist
        XCTAssertTrue(app.staticTexts["Car Information"].exists)
        
        // Fill in car information
        let nameField = app.textFields["Car Name *"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Test Car")
        
        let makeField = app.textFields["Make"]
        makeField.tap()
        makeField.typeText("Toyota")
        
        let modelField = app.textFields["Model"]
        modelField.tap()
        modelField.typeText("Camry")
        
        let yearField = app.textFields["Year"]
        yearField.tap()
        yearField.typeText("2023")
        
        // Fill in lease details
        let startingOdometerField = app.textFields["Starting Odometer"]
        startingOdometerField.tap()
        startingOdometerField.typeText("10000")
        
        let allowedMilesField = app.textFields["Total Allowed Miles"]
        allowedMilesField.tap()
        allowedMilesField.typeText("36000")
        
        let costPerMileField = app.textFields["Cost Per Mile"]
        costPerMileField.tap()
        costPerMileField.typeText("0.25")
        
        // Complete onboarding
        let completeButton = app.buttons["Complete Setup"]
        XCTAssertTrue(completeButton.exists)
        completeButton.tap()
        
        // Verify we're now on the dashboard
        XCTAssertTrue(app.staticTexts["Dashboard"].exists)
    }
    
    func testAddMileageEntry() throws {
        // Assuming we have a car set up from previous test
        // Navigate to add entry
        let addButton = app.buttons["plus.circle.fill"]
        if addButton.exists {
            addButton.tap()
        }
        
        // Fill in mileage entry
        let odometerField = app.textFields["Odometer Reading"]
        if odometerField.exists {
            odometerField.tap()
            odometerField.typeText("10500")
        }
        
        let notesField = app.textFields["Notes (Optional)"]
        if notesField.exists {
            notesField.tap()
            notesField.typeText("Test entry")
        }
        
        // Save entry
        let saveButton = app.buttons["Save Entry"]
        if saveButton.exists {
            saveButton.tap()
        }
    }
    
    func testDashboardNavigation() throws {
        // Test navigation between tabs
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.exists)
        dashboardTab.tap()
        
        let chartsTab = app.tabBars.buttons["Charts"]
        XCTAssertTrue(chartsTab.exists)
        chartsTab.tap()
        
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.exists)
        historyTab.tap()
        
        let carsTab = app.tabBars.buttons["Cars"]
        XCTAssertTrue(carsTab.exists)
        carsTab.tap()
        
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
    }
    
    func testSettingsModification() throws {
        // Navigate to settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Test modifying lease settings
        let startingOdometerField = app.textFields["Starting Odometer"]
        if startingOdometerField.exists {
            startingOdometerField.tap()
            startingOdometerField.clearText()
            startingOdometerField.typeText("12000")
        }
        
        let allowedMilesField = app.textFields["Total Allowed Miles"]
        if allowedMilesField.exists {
            allowedMilesField.tap()
            allowedMilesField.clearText()
            allowedMilesField.typeText("40000")
        }
        
        // Save settings
        let saveButton = app.buttons["Save Settings"]
        if saveButton.exists {
            saveButton.tap()
        }
    }
    
    func testHistoryView() throws {
        // Navigate to history
        let historyTab = app.tabBars.buttons["History"]
        historyTab.tap()
        
        // Test export functionality
        let exportButton = app.buttons["Export CSV"]
        if exportButton.exists {
            exportButton.tap()
            
            // Verify share sheet appears
            XCTAssertTrue(app.sheets.firstMatch.exists)
            
            // Dismiss share sheet
            app.buttons["Cancel"].tap()
        }
    }
    
    func testCarManagement() throws {
        // Navigate to cars tab
        let carsTab = app.tabBars.buttons["Cars"]
        carsTab.tap()
        
        // Test adding a new car
        let addCarButton = app.buttons["Add Car"]
        if addCarButton.exists {
            addCarButton.tap()
            
            // Fill in car details
            let nameField = app.textFields["Car Name *"]
            nameField.tap()
            nameField.typeText("Second Car")
            
            let makeField = app.textFields["Make"]
            makeField.tap()
            makeField.typeText("Honda")
            
            let modelField = app.textFields["Model"]
            modelField.tap()
            modelField.typeText("Accord")
            
            // Save car
            let saveButton = app.buttons["Save Car"]
            if saveButton.exists {
                saveButton.tap()
            }
        }
    }
    
    func testNotificationTesting() throws {
        // Navigate to dashboard
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        dashboardTab.tap()
        
        // Test notification testing
        let notificationButton = app.buttons["bell.badge"]
        if notificationButton.exists {
            notificationButton.tap()
            
            // Test permission request
            let requestPermissionButton = app.buttons["Request Permission"]
            if requestPermissionButton.exists {
                requestPermissionButton.tap()
            }
            
            // Test sending test notification
            let testNotificationButton = app.buttons["Send Test Notification"]
            if testNotificationButton.exists {
                testNotificationButton.tap()
            }
            
            // Dismiss notification test view
            let doneButton = app.buttons["Done"]
            if doneButton.exists {
                doneButton.tap()
            }
        }
    }
    
    func testChartsView() throws {
        // Navigate to charts
        let chartsTab = app.tabBars.buttons["Charts"]
        chartsTab.tap()
        
        // Test time range picker
        let timeRangePicker = app.segmentedControls.firstMatch
        if timeRangePicker.exists {
            timeRangePicker.buttons["3 Months"].tap()
            timeRangePicker.buttons["6 Months"].tap()
            timeRangePicker.buttons["1 Year"].tap()
        }
        
        // Test chart type picker
        let chartTypePicker = app.segmentedControls.element(boundBy: 1)
        if chartTypePicker.exists {
            chartTypePicker.buttons["Daily Average"].tap()
            chartTypePicker.buttons["Projected Trend"].tap()
            chartTypePicker.buttons["Miles Over Time"].tap()
        }
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
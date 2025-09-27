import Foundation
import SwiftData

class SharedDataManager: ObservableObject {
    static let shared = SharedDataManager()
    
    private let appGroupIdentifier = "group.com.leasemilestracker.shared"
    private let userDefaults = UserDefaults(suiteName: "group.com.leasemilestracker.shared")
    
    private init() {}
    
    func updateWidgetData(settings: LeaseSettings, entries: [MileageEntry]) {
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: entries)
        
        let widgetData = WidgetData(
            milesDriven: snapshot.milesDriven,
            remainingMiles: snapshot.remainingMiles,
            monthsLeft: snapshot.monthsLeft,
            projectedOverage: snapshot.projectedOverage,
            lastUpdated: Date()
        )
        
        if let data = try? JSONEncoder().encode(widgetData) {
            userDefaults?.set(data, forKey: "widgetData")
        }
        
        // Request widget timeline update
        WidgetCenter.shared.reloadTimelines(ofKind: "LeaseMilesWidget")
    }
    
    func getWidgetData() -> WidgetData? {
        guard let data = userDefaults?.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return nil
        }
        return widgetData
    }
}

struct WidgetData: Codable {
    let milesDriven: Int
    let remainingMiles: Int
    let monthsLeft: Int
    let projectedOverage: Int
    let lastUpdated: Date
}
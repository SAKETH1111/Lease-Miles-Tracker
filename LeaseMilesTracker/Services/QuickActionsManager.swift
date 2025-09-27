import UIKit
import SwiftUI

class QuickActionsManager: ObservableObject {
    static let shared = QuickActionsManager()
    
    private init() {}
    
    func setupQuickActions() {
        let addEntryAction = UIApplicationShortcutItem(
            type: "com.leasemilestracker.addentry",
            localizedTitle: "Add Mileage Entry",
            localizedSubtitle: "Quickly add a new odometer reading",
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"),
            userInfo: nil
        )
        
        let viewDashboardAction = UIApplicationShortcutItem(
            type: "com.leasemilestracker.dashboard",
            localizedTitle: "View Dashboard",
            localizedSubtitle: "Check your lease status",
            icon: UIApplicationShortcutIcon(systemImageName: "gauge"),
            userInfo: nil
        )
        
        let viewHistoryAction = UIApplicationShortcutItem(
            type: "com.leasemilestracker.history",
            localizedTitle: "View History",
            localizedSubtitle: "See your mileage entries",
            icon: UIApplicationShortcutIcon(systemName: "clock"),
            userInfo: nil
        )
        
        let viewChartsAction = UIApplicationShortcutItem(
            type: "com.leasemilestracker.charts",
            localizedTitle: "View Charts",
            localizedSubtitle: "See mileage trends",
            icon: UIApplicationShortcutIcon(systemImageName: "chart.line.uptrend.xyaxis"),
            userInfo: nil
        )
        
        UIApplication.shared.shortcutItems = [
            addEntryAction,
            viewDashboardAction,
            viewHistoryAction,
            viewChartsAction
        ]
    }
    
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        switch shortcutItem.type {
        case "com.leasemilestracker.addentry":
            NotificationCenter.default.post(name: .quickActionAddEntry, object: nil)
            return true
        case "com.leasemilestracker.dashboard":
            NotificationCenter.default.post(name: .quickActionDashboard, object: nil)
            return true
        case "com.leasemilestracker.history":
            NotificationCenter.default.post(name: .quickActionHistory, object: nil)
            return true
        case "com.leasemilestracker.charts":
            NotificationCenter.default.post(name: .quickActionCharts, object: nil)
            return true
        default:
            return false
        }
    }
}

extension Notification.Name {
    static let quickActionAddEntry = Notification.Name("quickActionAddEntry")
    static let quickActionDashboard = Notification.Name("quickActionDashboard")
    static let quickActionHistory = Notification.Name("quickActionHistory")
    static let quickActionCharts = Notification.Name("quickActionCharts")
}
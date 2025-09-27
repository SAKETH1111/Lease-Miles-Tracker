import SwiftUI
import SwiftData

@main
struct LeaseMilesTrackerApp: App {
    let modelContainer: ModelContainer
    @StateObject private var quickActionsManager = QuickActionsManager.shared
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Car.self, MileageEntry.self, LeaseSettings.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .onAppear {
                    quickActionsManager.setupQuickActions()
                }
        }
    }
}

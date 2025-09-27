import SwiftUI
import SwiftData

@main
struct LeaseMilesTrackerApp: App {
    let modelContainer: ModelContainer
    
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
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
    
    private var carStore: CarStore {
        CarStore(modelContext: modelContext)
    }
    
    var body: some View {
        Group {
            if cars.isEmpty {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            // Migrate from old data if needed
            carStore.migrateFromOldData()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Dashboard")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            
            CarSelectionView()
                .tabItem {
                    Image(systemName: "car.circle")
                    Text("Cars")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}
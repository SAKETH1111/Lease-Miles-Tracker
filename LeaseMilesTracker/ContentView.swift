import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
    @State private var selectedTab = 0
    @State private var showingAddEntry = false
    
    private var carStore: CarStore {
        CarStore(modelContext: modelContext)
    }
    
    var body: some View {
        Group {
            if cars.isEmpty {
                OnboardingView()
            } else {
                MainTabView(selectedTab: $selectedTab, showingAddEntry: $showingAddEntry)
            }
        }
        .onAppear {
            // Migrate from old data if needed
            carStore.migrateFromOldData()
            
            // Setup quick action listeners
            setupQuickActionListeners()
        }
    }
    
    private func setupQuickActionListeners() {
        NotificationCenter.default.addObserver(
            forName: .quickActionAddEntry,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 0 // Dashboard tab
            showingAddEntry = true
        }
        
        NotificationCenter.default.addObserver(
            forName: .quickActionDashboard,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 0
        }
        
        NotificationCenter.default.addObserver(
            forName: .quickActionHistory,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 2 // History tab
        }
        
        NotificationCenter.default.addObserver(
            forName: .quickActionCharts,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 1 // Charts tab
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @Binding var showingAddEntry: Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
    
    private var activeCar: Car? {
        cars.first { $0.isActive }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Dashboard")
                }
                .tag(0)
            
            MileageChartsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Charts")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)
            
            CarSelectionView()
                .tabItem {
                    Image(systemName: "car.circle")
                    Text("Cars")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        .sheet(isPresented: $showingAddEntry) {
            if let activeCar = activeCar {
                AddEntryView(car: activeCar)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Car.self, MileageEntry.self, LeaseSettings.self])
}
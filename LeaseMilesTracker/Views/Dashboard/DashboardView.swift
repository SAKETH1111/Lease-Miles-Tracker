import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [LeaseSettings]
    @Query private var entries: [MileageEntry]
    @State private var showingAddEntry = false
    @State private var showingOnboarding = false
    @State private var showingNotificationTest = false
    
    private var settingsStore: LeaseSettingsStore {
        LeaseSettingsStore(modelContext: modelContext)
    }
    
    private var mileageStore: MileageStore {
        MileageStore(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let leaseSettings = settings.first {
                        let snapshot = LeaseCalculator.calculateSnapshot(settings: leaseSettings, entries: entries)
                        
                        // Warning Banner
                        if LeaseCalculator.shouldShowWarning(settings: leaseSettings, snapshot: snapshot) {
                            warningBanner(snapshot: snapshot, settings: leaseSettings)
                        }
                        
                        // Metric Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            MetricCard(
                                title: "Miles Driven",
                                value: snapshot.milesDriven.formatted,
                                subtitle: "of \(leaseSettings.allowedMilesTotal.formatted)",
                                icon: "road.lanes",
                                color: .blue
                            )
                            
                            MetricCard(
                                title: "Remaining Miles",
                                value: snapshot.remainingMiles.formatted,
                                subtitle: nil,
                                icon: "road.lanes.curved.left",
                                color: snapshot.remainingMiles > 0 ? .green : .red
                            )
                            
                            MetricCard(
                                title: "Months Left",
                                value: "\(snapshot.monthsLeft)",
                                subtitle: nil,
                                icon: "calendar",
                                color: .orange
                            )
                            
                            MetricCard(
                                title: "Running Cost",
                                value: snapshot.runningCost.currencyFormatted,
                                subtitle: "\(String(format: "%.1f", snapshot.avgMilesPerDay)) miles/day",
                                icon: "dollarsign.circle",
                                color: .purple
                            )
                        }
                        
                        // Projected Overage (if applicable)
                        if snapshot.projectedOverage > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Projected Overage")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(snapshot.projectedMilesAtEnd.formatted) miles projected")
                                            .font(.subheadline)
                                        Text("\(snapshot.projectedOverage.formatted) miles over limit")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(snapshot.projectedOverageCost.currencyFormatted)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingNotificationTest = true
                        } label: {
                            Image(systemName: "bell.badge")
                        }
                        
                        Button {
                            showingAddEntry = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
            }
            .sheet(isPresented: $showingNotificationTest) {
                NotificationTestView()
            }
            .onAppear {
                if settings.isEmpty {
                    showingOnboarding = true
                } else {
                    // Update widget data when dashboard appears
                    if let leaseSettings = settings.first {
                        SharedDataManager.shared.updateWidgetData(settings: leaseSettings, entries: entries)
                    }
                }
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
        }
    }
    
    private func warningBanner(snapshot: LeaseSnapshot, settings: LeaseSettings) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Mileage Alert")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            if snapshot.projectedOverage > 0 {
                Text("You're projected to exceed your lease mileage by \(snapshot.projectedOverage.formatted) miles.")
                    .font(.subheadline)
            } else {
                let thresholdMiles = Int(Double(settings.allowedMilesTotal) * Double(settings.lowMilesThresholdPercent) / 100.0)
                Text("You've used \(settings.lowMilesThresholdPercent)% (\(thresholdMiles.formatted) miles) of your allowed mileage.")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}
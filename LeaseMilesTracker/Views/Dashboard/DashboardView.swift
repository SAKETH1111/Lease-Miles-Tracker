import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
    @State private var showingAddEntry = false
    @State private var showingCarSelection = false
    
    private var carStore: CarStore {
        CarStore(modelContext: modelContext)
    }
    
    private var mileageStore: MileageStore {
        MileageStore(modelContext: modelContext)
    }
    
    private var activeCar: Car? {
        cars.first { $0.isActive }
    }
    
    private var entriesForActiveCar: [MileageEntry] {
        guard let activeCar = activeCar else { return [] }
        return mileageStore.loadEntries(for: activeCar)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let activeCar = activeCar {
                        let snapshot = LeaseCalculator.calculateSnapshot(settings: activeCar.leaseSettings, entries: entriesForActiveCar)
                        
                        // Car Header
                        carHeaderView(activeCar)
                        
                        // Warning Banner
                        if LeaseCalculator.shouldShowWarning(settings: activeCar.leaseSettings, snapshot: snapshot) {
                            warningBanner(snapshot: snapshot, settings: activeCar.leaseSettings)
                        }
                        
                        // Metric Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            MetricCard(
                                title: "Miles Driven",
                                value: snapshot.milesDriven.formatted,
                                subtitle: "of \(activeCar.allowedMilesTotal.formatted)",
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
                    } else {
                        // No active car state
                        noCarStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingCarSelection = true
                    } label: {
                        Image(systemName: "car.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if activeCar != nil {
                        Button {
                            showingAddEntry = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                if let activeCar = activeCar {
                    AddEntryView(car: activeCar)
                }
            }
            .sheet(isPresented: $showingCarSelection) {
                CarSelectionView()
            }
            .onAppear {
                // Migrate from old data if needed
                carStore.migrateFromOldData()
            }
        }
    }
    
    private func carHeaderView(_ car: Car) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "car.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(car.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let make = car.make, let model = car.model {
                        Text("\(car.year.map { "\($0) " } ?? "")\(make) \(model)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("Active")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var noCarStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Active Car")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select a car from your garage to view the dashboard")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCarSelection = true
            } label: {
                Text("Manage Cars")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
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
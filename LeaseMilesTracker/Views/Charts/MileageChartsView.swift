import SwiftUI
import Charts
import SwiftData

struct MileageChartsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
    
    private var activeCar: Car? {
        cars.first { $0.isActive }
    }
    
    private var entriesForActiveCar: [MileageEntry] {
        guard let activeCar = activeCar else { return [] }
        return MileageStore(modelContext: modelContext).loadEntries(for: activeCar)
    }
    
    @State private var selectedTimeRange: TimeRange = .sixMonths
    @State private var selectedChartType: ChartType = .milesOverTime
    
    enum TimeRange: String, CaseIterable {
        case oneMonth = "1 Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case oneYear = "1 Year"
        case allTime = "All Time"
        
        var days: Int {
            switch self {
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .oneYear: return 365
            case .allTime: return Int.max
            }
        }
    }
    
    enum ChartType: String, CaseIterable {
        case milesOverTime = "Miles Over Time"
        case dailyAverage = "Daily Average"
        case projectedTrend = "Projected Trend"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let activeCar = activeCar, !entriesForActiveCar.isEmpty {
                    // Chart Controls
                    VStack(spacing: 16) {
                        // Time Range Picker
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Chart Type Picker
                        Picker("Chart Type", selection: $selectedChartType) {
                            ForEach(ChartType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    
                    // Chart
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedChartType {
                            case .milesOverTime:
                                MilesOverTimeChart(
                                    entries: filteredEntries,
                                    settings: activeCar.leaseSettings
                                )
                            case .dailyAverage:
                                DailyAverageChart(
                                    entries: filteredEntries,
                                    settings: activeCar.leaseSettings
                                )
                            case .projectedTrend:
                                ProjectedTrendChart(
                                    entries: filteredEntries,
                                    settings: activeCar.leaseSettings
                                )
                            }
                            
                            // Summary Stats
                            SummaryStatsView(
                                entries: filteredEntries,
                                settings: activeCar.leaseSettings
                            )
                        }
                        .padding()
                    }
                } else {
                    // No data state
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Data Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add some mileage entries to see charts and trends.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Mileage Trends")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var filteredEntries: [MileageEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return entriesForActiveCar.filter { $0.date >= cutoffDate }
    }
}

struct MilesOverTimeChart: View {
    let entries: [MileageEntry]
    let settings: LeaseSettings
    
    private var chartData: [ChartDataPoint] {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        var data: [ChartDataPoint] = []
        
        // Add starting point
        data.append(ChartDataPoint(
            date: settings.leaseStartDate,
            milesDriven: 0,
            cumulativeMiles: 0
        ))
        
        // Add entries
        for entry in sortedEntries {
            let milesDriven = entry.odometer - settings.startingOdometer
            data.append(ChartDataPoint(
                date: entry.date,
                milesDriven: milesDriven,
                cumulativeMiles: milesDriven
            ))
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Miles Driven Over Time")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(chartData) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Miles", dataPoint.cumulativeMiles)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Miles", dataPoint.cumulativeMiles)
                )
                .foregroundStyle(.blue.opacity(0.1))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue.formatted)")
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct DailyAverageChart: View {
    let entries: [MileageEntry]
    let settings: LeaseSettings
    
    private var dailyAverages: [DailyAverageData] {
        let calendar = Calendar.current
        let groupedEntries = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return groupedEntries.map { date, dayEntries in
            let totalMiles = dayEntries.reduce(0) { total, entry in
                total + (entry.odometer - settings.startingOdometer)
            }
            return DailyAverageData(
                date: date,
                averageMiles: Double(totalMiles) / Double(dayEntries.count)
            )
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Average Miles")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(dailyAverages) { data in
                BarMark(
                    x: .value("Date", data.date),
                    y: .value("Average Miles", data.averageMiles)
                )
                .foregroundStyle(.green)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(String(format: "%.1f", doubleValue))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProjectedTrendChart: View {
    let entries: [MileageEntry]
    let settings: LeaseSettings
    
    private var projectedData: [ProjectedDataPoint] {
        let snapshot = LeaseCalculator.calculateSnapshot(settings: settings, entries: entries)
        let calendar = Calendar.current
        let today = Date()
        
        var data: [ProjectedDataPoint] = []
        
        // Add historical data
        let sortedEntries = entries.sorted { $0.date < $1.date }
        for entry in sortedEntries {
            let milesDriven = entry.odometer - settings.startingOdometer
            data.append(ProjectedDataPoint(
                date: entry.date,
                milesDriven: milesDriven,
                isProjected: false
            ))
        }
        
        // Add projected data
        let daysRemaining = calendar.dateComponents([.day], from: today, to: settings.leaseEndDate).day ?? 0
        if daysRemaining > 0 {
            let projectedMilesPerDay = Double(snapshot.projectedMilesAtEnd - snapshot.milesDriven) / Double(daysRemaining)
            
            for i in 1...min(30, daysRemaining) {
                if let futureDate = calendar.date(byAdding: .day, value: i, to: today) {
                    let projectedMiles = snapshot.milesDriven + Int(projectedMilesPerDay * Double(i))
                    data.append(ProjectedDataPoint(
                        date: futureDate,
                        milesDriven: projectedMiles,
                        isProjected: true
                    ))
                }
            }
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projected Mileage Trend")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(projectedData) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Miles", dataPoint.milesDriven)
                )
                .foregroundStyle(dataPoint.isProjected ? .orange : .blue)
                .lineStyle(StrokeStyle(lineWidth: 3, dash: dataPoint.isProjected ? [5, 5] : []))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue.formatted)")
                        }
                    }
                }
            }
            
            HStack {
                HStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                    Text("Actual")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(.orange)
                        .frame(width: 8, height: 8)
                    Text("Projected")
                        .font(.caption)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SummaryStatsView: View {
    let entries: [MileageEntry]
    let settings: LeaseSettings
    
    private var snapshot: LeaseSnapshot {
        LeaseCalculator.calculateSnapshot(settings: settings, entries: entries)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Total Miles",
                    value: "\(snapshot.milesDriven.formatted)",
                    subtitle: "of \(settings.allowedMilesTotal.formatted)",
                    color: .blue
                )
                
                StatCard(
                    title: "Daily Average",
                    value: String(format: "%.1f", snapshot.avgMilesPerDay),
                    subtitle: "miles per day",
                    color: .green
                )
                
                StatCard(
                    title: "Remaining",
                    value: "\(snapshot.remainingMiles.formatted)",
                    subtitle: "miles left",
                    color: snapshot.remainingMiles > 0 ? .green : .red
                )
                
                StatCard(
                    title: "Projected",
                    value: "\(snapshot.projectedMilesAtEnd.formatted)",
                    subtitle: "at lease end",
                    color: snapshot.projectedOverage > 0 ? .red : .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let milesDriven: Int
    let cumulativeMiles: Int
}

struct DailyAverageData: Identifiable {
    let id = UUID()
    let date: Date
    let averageMiles: Double
}

struct ProjectedDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let milesDriven: Int
    let isProjected: Bool
}

#Preview {
    MileageChartsView()
        .modelContainer(for: [Car.self, MileageEntry.self, LeaseSettings.self])
}
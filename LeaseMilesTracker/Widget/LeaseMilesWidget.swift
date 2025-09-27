import WidgetKit
import SwiftUI
import SwiftData

struct LeaseMilesWidget: Widget {
    let kind: String = "LeaseMilesWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: LeaseMilesWidgetConfiguration.self, provider: LeaseMilesProvider()) { entry in
            LeaseMilesWidgetEntryView(entry: entry, configuration: entry.configuration)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Lease Miles Tracker")
        .description("Track your lease mileage and remaining miles at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct LeaseMilesProvider: TimelineProvider {
    func placeholder(in context: Context) -> LeaseMilesEntry {
        LeaseMilesEntry(
            date: Date(),
            milesDriven: 15000,
            remainingMiles: 21000,
            monthsLeft: 18,
            projectedOverage: 0,
            isDataAvailable: true,
            configuration: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LeaseMilesEntry) -> ()) {
        let entry = loadLeaseData(context: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeaseMilesEntry>) -> ()) {
        let entry = loadLeaseData(context: context)
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadLeaseData(context: Context) -> LeaseMilesEntry {
        guard let widgetData = SharedDataManager.shared.getWidgetData() else {
            return LeaseMilesEntry(
                date: Date(),
                milesDriven: 0,
                remainingMiles: 0,
                monthsLeft: 0,
                projectedOverage: 0,
                isDataAvailable: false,
                configuration: nil
            )
        }
        
        return LeaseMilesEntry(
            date: widgetData.lastUpdated,
            milesDriven: widgetData.milesDriven,
            remainingMiles: widgetData.remainingMiles,
            monthsLeft: widgetData.monthsLeft,
            projectedOverage: widgetData.projectedOverage,
            isDataAvailable: true,
            configuration: context.configuration as? LeaseMilesWidgetConfiguration
        )
    }
}

struct LeaseMilesEntry: TimelineEntry {
    let date: Date
    let milesDriven: Int
    let remainingMiles: Int
    let monthsLeft: Int
    let projectedOverage: Int
    let isDataAvailable: Bool
    let configuration: LeaseMilesWidgetConfiguration?
}

struct LeaseMilesWidgetEntryView: View {
    var entry: LeaseMilesProvider.Entry
    @Environment(\.widgetFamily) var family
    var configuration: LeaseMilesWidgetConfiguration?

    var body: some View {
        if entry.isDataAvailable {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry, configuration: configuration)
            case .systemMedium:
                MediumWidgetView(entry: entry, configuration: configuration)
            case .systemLarge:
                LargeWidgetView(entry: entry, configuration: configuration)
            default:
                SmallWidgetView(entry: entry, configuration: configuration)
            }
        } else {
            NoDataView()
        }
    }
}

struct SmallWidgetView: View {
    let entry: LeaseMilesEntry
    let configuration: LeaseMilesWidgetConfiguration?
    
    private var showProjectedOverage: Bool {
        configuration?.showProjectedOverage?.boolValue ?? true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                Text("Lease")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entry.milesDriven.formatted)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("miles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(entry.remainingMiles.formatted) left")
                    .font(.caption)
                    .foregroundColor(entry.remainingMiles > 0 ? .green : .red)
                
                if showProjectedOverage && entry.projectedOverage > 0 {
                    Text("⚠️ \(entry.projectedOverage.formatted)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let entry: LeaseMilesEntry
    let configuration: LeaseMilesWidgetConfiguration?
    
    private var showProjectedOverage: Bool {
        configuration?.showProjectedOverage?.boolValue ?? true
    }
    
    private var showMonthsLeft: Bool {
        configuration?.showMonthsLeft?.boolValue ?? true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                Text("Lease Tracker")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.milesDriven.formatted)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Miles Driven")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.remainingMiles.formatted)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(entry.remainingMiles > 0 ? .green : .red)
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                if showMonthsLeft {
                    Text("\(entry.monthsLeft) months left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showProjectedOverage && entry.projectedOverage > 0 {
                    Text("⚠️ \(entry.projectedOverage.formatted) over")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct LargeWidgetView: View {
    let entry: LeaseMilesEntry
    let configuration: LeaseMilesWidgetConfiguration?
    
    private var showProjectedOverage: Bool {
        configuration?.showProjectedOverage?.boolValue ?? true
    }
    
    private var showMonthsLeft: Bool {
        configuration?.showMonthsLeft?.boolValue ?? true
    }
    
    private var showRunningCost: Bool {
        configuration?.showRunningCost?.boolValue ?? false
    }
    
    private var displayStyle: DisplayStyle {
        configuration?.displayStyle ?? .compact
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                Text("Lease Miles Tracker")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if displayStyle == .minimal {
                minimalView
            } else if displayStyle == .detailed {
                detailedView
            } else {
                compactView
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var minimalView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(entry.milesDriven.formatted)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("miles driven")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Text("\(entry.remainingMiles.formatted)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(entry.remainingMiles > 0 ? .green : .red)
                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
    
    private var compactView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.milesDriven.formatted)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Miles Driven")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.remainingMiles.formatted)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(entry.remainingMiles > 0 ? .green : .red)
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if showMonthsLeft {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.monthsLeft)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Months Left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if showProjectedOverage {
                VStack(alignment: .leading, spacing: 4) {
                    if entry.projectedOverage > 0 {
                        Text("\(entry.projectedOverage.formatted)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Projected Over")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("On Track")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Status")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.milesDriven.formatted)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Miles Driven")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(entry.remainingMiles.formatted)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(entry.remainingMiles > 0 ? .green : .red)
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if showMonthsLeft || showProjectedOverage {
                HStack {
                    if showMonthsLeft {
                        Text("\(entry.monthsLeft) months left")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if showProjectedOverage && entry.projectedOverage > 0 {
                        Text("⚠️ \(entry.projectedOverage.formatted) projected over")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

struct NoDataView: View {
    var body: some View {
        VStack {
            Image(systemName: "car")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No Data")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Open app to set up")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview(as: .systemSmall) {
    LeaseMilesWidget()
} timeline: {
    LeaseMilesEntry(
        date: .now,
        milesDriven: 15000,
        remainingMiles: 21000,
        monthsLeft: 18,
        projectedOverage: 0,
        isDataAvailable: true,
        configuration: nil
    )
    LeaseMilesEntry(
        date: .now,
        milesDriven: 25000,
        remainingMiles: 11000,
        monthsLeft: 12,
        projectedOverage: 5000,
        isDataAvailable: true,
        configuration: nil
    )
}
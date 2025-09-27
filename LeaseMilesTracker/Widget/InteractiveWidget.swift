import WidgetKit
import SwiftUI
import AppIntents

struct InteractiveWidget: Widget {
    let kind: String = "InteractiveWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: LeaseMilesWidgetConfiguration.self, provider: InteractiveWidgetProvider()) { entry in
            InteractiveWidgetEntryView(entry: entry, configuration: entry.configuration)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Interactive Lease Tracker")
        .description("Quick actions for adding mileage entries and viewing status.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct InteractiveWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> InteractiveWidgetEntry {
        InteractiveWidgetEntry(
            date: Date(),
            milesDriven: 15000,
            remainingMiles: 21000,
            monthsLeft: 18,
            projectedOverage: 0,
            isDataAvailable: true,
            configuration: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (InteractiveWidgetEntry) -> ()) {
        let entry = loadLeaseData(context: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InteractiveWidgetEntry>) -> ()) {
        let entry = loadLeaseData(context: context)
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadLeaseData(context: Context) -> InteractiveWidgetEntry {
        guard let widgetData = SharedDataManager.shared.getWidgetData() else {
            return InteractiveWidgetEntry(
                date: Date(),
                milesDriven: 0,
                remainingMiles: 0,
                monthsLeft: 0,
                projectedOverage: 0,
                isDataAvailable: false,
                configuration: nil
            )
        }
        
        return InteractiveWidgetEntry(
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

struct InteractiveWidgetEntry: TimelineEntry {
    let date: Date
    let milesDriven: Int
    let remainingMiles: Int
    let monthsLeft: Int
    let projectedOverage: Int
    let isDataAvailable: Bool
    let configuration: LeaseMilesWidgetConfiguration?
}

struct InteractiveWidgetEntryView: View {
    var entry: InteractiveWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    var configuration: LeaseMilesWidgetConfiguration?

    var body: some View {
        if entry.isDataAvailable {
            switch family {
            case .systemMedium:
                InteractiveMediumWidgetView(entry: entry, configuration: configuration)
            case .systemLarge:
                InteractiveLargeWidgetView(entry: entry, configuration: configuration)
            default:
                InteractiveMediumWidgetView(entry: entry, configuration: configuration)
            }
        } else {
            NoDataView()
        }
    }
}

struct InteractiveMediumWidgetView: View {
    let entry: InteractiveWidgetEntry
    let configuration: LeaseMilesWidgetConfiguration?
    
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
            
            // Interactive Buttons
            HStack(spacing: 8) {
                Button(intent: AddMileageEntryIntent()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Entry")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(intent: ViewHistoryIntent()) {
                    HStack {
                        Image(systemName: "clock")
                        Text("History")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct InteractiveLargeWidgetView: View {
    let entry: InteractiveWidgetEntry
    let configuration: LeaseMilesWidgetConfiguration?
    
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.monthsLeft)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Months Left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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
            
            // Interactive Buttons
            HStack(spacing: 8) {
                Button(intent: AddMileageEntryIntent()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Entry")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(intent: ViewHistoryIntent()) {
                    HStack {
                        Image(systemName: "clock")
                        Text("View History")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(intent: ViewSettingsIntent()) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - App Intents

struct AddMileageEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Mileage Entry"
    static var description = IntentDescription("Add a new mileage entry to your lease tracker.")
    
    func perform() async throws -> some IntentResult {
        // This will open the app to the add entry view
        return .result()
    }
}

struct ViewHistoryIntent: AppIntent {
    static var title: LocalizedStringResource = "View History"
    static var description = IntentDescription("View your mileage entry history.")
    
    func perform() async throws -> some IntentResult {
        // This will open the app to the history view
        return .result()
    }
}

struct ViewSettingsIntent: AppIntent {
    static var title: LocalizedStringResource = "View Settings"
    static var description = IntentDescription("Open lease settings and configuration.")
    
    func perform() async throws -> some IntentResult {
        // This will open the app to the settings view
        return .result()
    }
}

#Preview(as: .systemMedium) {
    InteractiveWidget()
} timeline: {
    InteractiveWidgetEntry(
        date: .now,
        milesDriven: 15000,
        remainingMiles: 21000,
        monthsLeft: 18,
        projectedOverage: 0,
        isDataAvailable: true,
        configuration: nil
    )
}
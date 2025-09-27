import WidgetKit
import SwiftUI

struct LeaseMilesWidgetConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Display Style", default: .compact)
    var displayStyle: DisplayStyle
    
    @Parameter(title: "Show Projected Overage", default: true)
    var showProjectedOverage: NSNumber
    
    @Parameter(title: "Show Months Left", default: true)
    var showMonthsLeft: NSNumber
    
    @Parameter(title: "Show Running Cost", default: false)
    var showRunningCost: NSNumber
}

enum DisplayStyle: String, CaseIterable, AppEnum {
    case compact = "compact"
    case detailed = "detailed"
    case minimal = "minimal"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Display Style"
    
    static var caseDisplayRepresentations: [DisplayStyle: DisplayRepresentation] = [
        .compact: "Compact",
        .detailed: "Detailed", 
        .minimal: "Minimal"
    ]
}
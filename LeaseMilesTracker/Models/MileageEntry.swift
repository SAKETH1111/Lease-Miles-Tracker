import Foundation
import SwiftData

@Model
class MileageEntry {
    var id: UUID
    var date: Date
    var odometer: Int
    var notes: String?
    
    init(date: Date = Date(), odometer: Int, notes: String? = nil) {
        self.id = UUID()
        self.date = date
        self.odometer = odometer
        self.notes = notes
    }
}
import Foundation
import SwiftUI

struct CSVExporter {
    static func exportEntries(_ entries: [MileageEntry]) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = DateFormatter.timestamp.string(from: Date())
        let filename = "mileage_export_\(timestamp).csv"
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        var csvContent = "Date,Odometer,Delta,Notes\n"
        
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        for (index, entry) in sortedEntries.enumerated() {
            let dateString = DateFormatter.shortDate.string(from: entry.date)
            let delta = index > 0 ? entry.odometer - sortedEntries[index - 1].odometer : 0
            let notes = entry.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csvContent += "\(dateString),\(entry.odometer),\(delta),\(notes)\n"
        }
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
}
import Foundation
import SwiftData

@MainActor
class MileageStore: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadEntries() -> [MileageEntry] {
        let descriptor = FetchDescriptor<MileageEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func addEntry(date: Date, odometer: Int, notes: String?) {
        let entry = MileageEntry(date: date, odometer: odometer, notes: notes)
        modelContext.insert(entry)
        
        do {
            try modelContext.save()
        } catch {
            print("Error adding mileage entry: \(error)")
        }
    }
    
    func updateEntry(_ entry: MileageEntry, date: Date, odometer: Int, notes: String?) {
        entry.date = date
        entry.odometer = odometer
        entry.notes = notes
        
        do {
            try modelContext.save()
        } catch {
            print("Error updating mileage entry: \(error)")
        }
    }
    
    func deleteEntry(_ entry: MileageEntry) {
        modelContext.delete(entry)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting mileage entry: \(error)")
        }
    }
    
    func getLatestOdometer() -> Int? {
        let entries = loadEntries()
        return entries.max(by: { $0.date < $1.date })?.odometer
    }
}
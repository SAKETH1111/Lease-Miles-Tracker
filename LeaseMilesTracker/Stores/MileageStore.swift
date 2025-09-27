import Foundation
import SwiftData

@MainActor
class MileageStore: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadEntries(for car: Car) -> [MileageEntry] {
        let descriptor = FetchDescriptor<MileageEntry>(
            predicate: #Predicate<MileageEntry> { $0.car?.id == car.id },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func loadAllEntries() -> [MileageEntry] {
        let descriptor = FetchDescriptor<MileageEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func addEntry(date: Date, odometer: Int, notes: String?, car: Car) {
        let entry = MileageEntry(date: date, odometer: odometer, notes: notes, car: car)
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
    
    func getLatestOdometer(for car: Car) -> Int? {
        let entries = loadEntries(for: car)
        return entries.max(by: { $0.date < $1.date })?.odometer
    }
    
    // Legacy method for backward compatibility
    func loadEntries() -> [MileageEntry] {
        return loadAllEntries()
    }
    
    func getLatestOdometer() -> Int? {
        let entries = loadAllEntries()
        return entries.max(by: { $0.date < $1.date })?.odometer
    }
}
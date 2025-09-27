import Foundation
import SwiftData

@MainActor
class CarStore: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadCars() -> [Car] {
        let descriptor = FetchDescriptor<Car>(
            sortBy: [SortDescriptor(\.isActive, order: .reverse), SortDescriptor(\.dateCreated, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func loadActiveCars() -> [Car] {
        let descriptor = FetchDescriptor<Car>(
            predicate: #Predicate<Car> { $0.isActive == true },
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getCar(by id: UUID) -> Car? {
        let descriptor = FetchDescriptor<Car>(
            predicate: #Predicate<Car> { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func addCar(_ car: Car) {
        modelContext.insert(car)
        
        do {
            try modelContext.save()
        } catch {
            print("Error adding car: \(error)")
        }
    }
    
    func updateCar(_ car: Car) {
        do {
            try modelContext.save()
        } catch {
            print("Error updating car: \(error)")
        }
    }
    
    func deleteCar(_ car: Car) {
        modelContext.delete(car)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting car: \(error)")
        }
    }
    
    func setActiveCar(_ car: Car) {
        // Deactivate all cars first
        let allCars = loadCars()
        for existingCar in allCars {
            existingCar.isActive = false
        }
        
        // Activate the selected car
        car.isActive = true
        
        do {
            try modelContext.save()
        } catch {
            print("Error setting active car: \(error)")
        }
    }
    
    func getActiveCar() -> Car? {
        let descriptor = FetchDescriptor<Car>(
            predicate: #Predicate<Car> { $0.isActive == true }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func migrateFromOldData() {
        // This method helps migrate from the old single-car system
        let cars = loadCars()
        
        // If we already have cars, no migration needed
        if !cars.isEmpty {
            return
        }
        
        // Check if we have old LeaseSettings data
        let settingsDescriptor = FetchDescriptor<LeaseSettings>()
        if let oldSettings = try? modelContext.fetch(settingsDescriptor).first {
            // Create a new car from the old settings
            let newCar = Car(
                name: "My Car",
                leaseStartDate: oldSettings.leaseStartDate,
                leaseEndDate: oldSettings.leaseEndDate,
                startingOdometer: oldSettings.startingOdometer,
                allowedMilesTotal: oldSettings.allowedMilesTotal,
                costPerMile: oldSettings.costPerMile,
                reminderDayOfMonth: oldSettings.reminderDayOfMonth,
                lowMilesThresholdPercent: oldSettings.lowMilesThresholdPercent,
                isActive: true
            )
            
            // Get old mileage entries and associate them with the new car
            let entriesDescriptor = FetchDescriptor<MileageEntry>()
            let oldEntries = (try? modelContext.fetch(entriesDescriptor)) ?? []
            
            for entry in oldEntries {
                entry.car = newCar
            }
            
            // Add the new car
            addCar(newCar)
            
            // Delete the old settings
            modelContext.delete(oldSettings)
            
            do {
                try modelContext.save()
                print("Successfully migrated from old data structure")
            } catch {
                print("Error during migration: \(error)")
            }
        }
    }
}
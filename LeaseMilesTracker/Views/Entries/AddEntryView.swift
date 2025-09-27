import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let car: Car
    
    @State private var date = Date()
    @State private var odometer = ""
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var mileageStore: MileageStore {
        MileageStore(modelContext: modelContext)
    }
    
    private var entriesForCar: [MileageEntry] {
        mileageStore.loadEntries(for: car)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Car") {
                    HStack {
                        Image(systemName: "car.circle.fill")
                            .foregroundColor(.blue)
                        Text(car.displayName)
                            .font(.headline)
                    }
                }
                
                Section("Entry Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Odometer Reading", text: $odometer)
                        .keyboardType(.numberPad)
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes about this entry", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Odometer Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(!isValidInput)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isValidInput: Bool {
        return !odometer.isEmpty && Int(odometer) != nil
    }
    
    private func saveEntry() {
        guard let odometerInt = Int(odometer) else {
            alertMessage = "Invalid odometer reading."
            showingAlert = true
            return
        }
        
        let latestOdometer = mileageStore.getLatestOdometer(for: car) ?? car.startingOdometer
        let validation = LeaseCalculator.validateOdometerEntry(
            newOdometer: odometerInt,
            previousOdometer: latestOdometer,
            startingOdometer: car.startingOdometer
        )
        
        switch validation {
        case .failure(let message):
            alertMessage = message
            showingAlert = true
            return
        case .success:
            break
        }
        
        let entry = MileageEntry(
            date: date,
            odometer: odometerInt,
            notes: notes.isEmpty ? nil : notes,
            car: car
        )
        
        modelContext.insert(entry)
        
        do {
            try modelContext.save()
            
            // Check if we should send a threshold alert
            let updatedEntries = entriesForCar + [entry]
            let snapshot = LeaseCalculator.calculateSnapshot(settings: car.leaseSettings, entries: updatedEntries)
            if LeaseCalculator.shouldShowWarning(settings: car.leaseSettings, snapshot: snapshot) {
                NotificationManager.shared.sendThresholdAlert(
                    milesDriven: snapshot.milesDriven,
                    thresholdPercent: car.lowMilesThresholdPercent,
                    projectedOverage: snapshot.projectedOverage
                )
            }
            
            dismiss()
        } catch {
            alertMessage = "Error saving entry: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    let car = Car(name: "Test Car", make: "Toyota", model: "Camry", year: 2023)
    return AddEntryView(car: car)
        .modelContainer(for: [Car.self, MileageEntry.self])
}
import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [LeaseSettings]
    @Query private var entries: [MileageEntry]
    
    @State private var date = Date()
    @State private var odometer = ""
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var mileageStore: MileageStore {
        MileageStore(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            Form {
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
        guard let odometerInt = Int(odometer),
              let leaseSettings = settings.first else {
            alertMessage = "Invalid odometer reading."
            showingAlert = true
            return
        }
        
        let latestOdometer = mileageStore.getLatestOdometer() ?? leaseSettings.startingOdometer
        let validation = LeaseCalculator.validateOdometerEntry(
            newOdometer: odometerInt,
            previousOdometer: latestOdometer,
            startingOdometer: leaseSettings.startingOdometer
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
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(entry)
        
        do {
            try modelContext.save()
            
            // Check if we should send a threshold alert
            let snapshot = LeaseCalculator.calculateSnapshot(settings: leaseSettings, entries: entries + [entry])
            if LeaseCalculator.shouldShowWarning(settings: leaseSettings, snapshot: snapshot) {
                NotificationManager.shared.sendThresholdAlert(
                    milesDriven: snapshot.milesDriven,
                    thresholdPercent: leaseSettings.lowMilesThresholdPercent,
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
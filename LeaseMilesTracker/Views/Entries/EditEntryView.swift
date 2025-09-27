import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [LeaseSettings]
    
    let entry: MileageEntry
    
    @State private var date: Date
    @State private var odometer: String
    @State private var notes: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(entry: MileageEntry) {
        self.entry = entry
        self._date = State(initialValue: entry.date)
        self._odometer = State(initialValue: String(entry.odometer))
        self._notes = State(initialValue: entry.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Entry Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Odometer Reading", text: $odometer)
                        .keyboardType(.numberPad)
                }
                
                Section("Notes") {
                    TextField("Add notes about this entry", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Entry")
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
        
        // Get all other entries to validate against
        let descriptor = FetchDescriptor<MileageEntry>()
        let allEntries = (try? modelContext.fetch(descriptor)) ?? []
        let otherEntries = allEntries.filter { $0.id != entry.id }
        
        // Find the latest entry before this one chronologically
        let latestOdometer = otherEntries.max { $0.date < $1.date }?.odometer ?? leaseSettings.startingOdometer
        
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
        
        entry.date = date
        entry.odometer = odometerInt
        entry.notes = notes.isEmpty ? nil : notes
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Error updating entry: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
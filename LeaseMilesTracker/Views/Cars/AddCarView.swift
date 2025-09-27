import SwiftUI
import SwiftData

struct AddCarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var color = ""
    @State private var leaseStartDate = Date()
    @State private var leaseEndDate = Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
    @State private var startingOdometer = ""
    @State private var allowedMilesTotal = ""
    @State private var costPerMile = ""
    @State private var reminderDayOfMonth = ""
    @State private var lowMilesThresholdPercent = "90"
    @State private var isActive = true
    
    private var carStore: CarStore {
        CarStore(modelContext: modelContext)
    }
    
    private var isValid: Bool {
        !name.isEmpty && 
        !startingOdometer.isEmpty && 
        !allowedMilesTotal.isEmpty && 
        !costPerMile.isEmpty &&
        Int(startingOdometer) != nil &&
        Int(allowedMilesTotal) != nil &&
        Decimal(string: costPerMile) != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Car Information") {
                    TextField("Car Name *", text: $name)
                        .textContentType(.name)
                    
                    HStack {
                        TextField("Make", text: $make)
                            .textContentType(.organizationName)
                        
                        TextField("Model", text: $model)
                            .textContentType(.organizationName)
                    }
                    
                    HStack {
                        TextField("Year", text: $year)
                            .keyboardType(.numberPad)
                        
                        TextField("Color", text: $color)
                    }
                }
                
                Section("Lease Details") {
                    DatePicker("Lease Start Date", selection: $leaseStartDate, displayedComponents: .date)
                    DatePicker("Lease End Date", selection: $leaseEndDate, displayedComponents: .date)
                    
                    TextField("Starting Odometer *", text: $startingOdometer)
                        .keyboardType(.numberPad)
                    
                    TextField("Allowed Miles Total *", text: $allowedMilesTotal)
                        .keyboardType(.numberPad)
                    
                    TextField("Cost Per Mile ($) *", text: $costPerMile)
                        .keyboardType(.decimalPad)
                }
                
                Section("Notifications") {
                    TextField("Reminder Day of Month (1-31)", text: $reminderDayOfMonth)
                        .keyboardType(.numberPad)
                    
                    TextField("Low Miles Threshold (%)", text: $lowMilesThresholdPercent)
                        .keyboardType(.numberPad)
                }
                
                Section("Settings") {
                    Toggle("Set as Active Car", isOn: $isActive)
                }
            }
            .navigationTitle("Add New Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCar()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func saveCar() {
        let newCar = Car(
            name: name,
            make: make.isEmpty ? nil : make,
            model: model.isEmpty ? nil : model,
            year: year.isEmpty ? nil : Int(year),
            color: color.isEmpty ? nil : color,
            leaseStartDate: leaseStartDate,
            leaseEndDate: leaseEndDate,
            startingOdometer: Int(startingOdometer) ?? 0,
            allowedMilesTotal: Int(allowedMilesTotal) ?? 36000,
            costPerMile: Decimal(string: costPerMile) ?? 0.25,
            reminderDayOfMonth: reminderDayOfMonth.isEmpty ? nil : Int(reminderDayOfMonth),
            lowMilesThresholdPercent: Int(lowMilesThresholdPercent) ?? 90,
            isActive: isActive
        )
        
        carStore.addCar(newCar)
        
        if isActive {
            carStore.setActiveCar(newCar)
        }
        
        dismiss()
    }
}

#Preview {
    AddCarView()
        .modelContainer(for: [Car.self, MileageEntry.self])
}
import SwiftUI
import SwiftData

struct EditCarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let car: Car
    
    @State private var name: String
    @State private var make: String
    @State private var model: String
    @State private var year: String
    @State private var color: String
    @State private var leaseStartDate: Date
    @State private var leaseEndDate: Date
    @State private var startingOdometer: String
    @State private var allowedMilesTotal: String
    @State private var costPerMile: String
    @State private var reminderDayOfMonth: String
    @State private var lowMilesThresholdPercent: String
    @State private var isActive: Bool
    
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
    
    init(car: Car) {
        self.car = car
        self._name = State(initialValue: car.name)
        self._make = State(initialValue: car.make ?? "")
        self._model = State(initialValue: car.model ?? "")
        self._year = State(initialValue: car.year?.description ?? "")
        self._color = State(initialValue: car.color ?? "")
        self._leaseStartDate = State(initialValue: car.leaseStartDate)
        self._leaseEndDate = State(initialValue: car.leaseEndDate)
        self._startingOdometer = State(initialValue: car.startingOdometer.description)
        self._allowedMilesTotal = State(initialValue: car.allowedMilesTotal.description)
        self._costPerMile = State(initialValue: car.costPerMile.description)
        self._reminderDayOfMonth = State(initialValue: car.reminderDayOfMonth?.description ?? "")
        self._lowMilesThresholdPercent = State(initialValue: car.lowMilesThresholdPercent.description)
        self._isActive = State(initialValue: car.isActive)
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
            .navigationTitle("Edit Car")
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
        car.name = name
        car.make = make.isEmpty ? nil : make
        car.model = model.isEmpty ? nil : model
        car.year = year.isEmpty ? nil : Int(year)
        car.color = color.isEmpty ? nil : color
        car.leaseStartDate = leaseStartDate
        car.leaseEndDate = leaseEndDate
        car.startingOdometer = Int(startingOdometer) ?? 0
        car.allowedMilesTotal = Int(allowedMilesTotal) ?? 36000
        car.costPerMile = Decimal(string: costPerMile) ?? 0.25
        car.reminderDayOfMonth = reminderDayOfMonth.isEmpty ? nil : Int(reminderDayOfMonth)
        car.lowMilesThresholdPercent = Int(lowMilesThresholdPercent) ?? 90
        
        if isActive && !car.isActive {
            carStore.setActiveCar(car)
        } else {
            car.isActive = isActive
        }
        
        carStore.updateCar(car)
        dismiss()
    }
}

#Preview {
    let car = Car(name: "Test Car", make: "Toyota", model: "Camry", year: 2023)
    return EditCarView(car: car)
        .modelContainer(for: [Car.self, MileageEntry.self])
}
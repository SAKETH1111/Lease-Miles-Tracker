import SwiftUI
import SwiftData

struct CarSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cars: [Car]
    @State private var showingAddCar = false
    @State private var showingEditCar: Car?
    
    private var carStore: CarStore {
        CarStore(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if cars.isEmpty {
                    emptyStateView
                } else {
                    carsListView
                }
            }
            .navigationTitle("My Cars")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCar = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddCar) {
                AddCarView()
            }
            .sheet(item: $showingEditCar) { car in
                EditCarView(car: car)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Cars Added")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first car to start tracking lease mileage")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddCar = true
            } label: {
                Text("Add Your First Car")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var carsListView: some View {
        List {
            ForEach(cars, id: \.id) { car in
                CarRowView(car: car, onTap: {
                    carStore.setActiveCar(car)
                }, onEdit: {
                    showingEditCar = car
                })
            }
            .onDelete(perform: deleteCars)
        }
    }
    
    private func deleteCars(offsets: IndexSet) {
        for index in offsets {
            let car = cars[index]
            carStore.deleteCar(car)
        }
    }
}

struct CarRowView: View {
    let car: Car
    let onTap: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(car.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let make = car.make, let model = car.model {
                        Text("\(car.year.map { "\($0) " } ?? "")\(make) \(model)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Lease: \(car.leaseStartDate.formatted(date: .abbreviated, time: .omitted)) - \(car.leaseEndDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if car.isActive {
                            Text("Active")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CarSelectionView()
        .modelContainer(for: [Car.self, MileageEntry.self])
}
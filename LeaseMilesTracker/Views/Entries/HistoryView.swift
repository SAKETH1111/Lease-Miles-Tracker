import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MileageEntry.date, order: .reverse) private var entries: [MileageEntry]
    @Query private var settings: [LeaseSettings]
    
    @State private var showingAddEntry = false
    @State private var showingEditEntry: MileageEntry?
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: MileageEntry?
    @State private var showingShareSheet = false
    @State private var csvFileURL: URL?
    
    private var mileageStore: MileageStore {
        MileageStore(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Entries Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add your first odometer reading to get started.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Entry") {
                            showingAddEntry = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(entries) { entry in
                            EntryRowView(
                                entry: entry,
                                previousEntry: getPreviousEntry(for: entry)
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    entryToDelete = entry
                                    showingDeleteAlert = true
                                }
                                
                                Button("Edit") {
                                    showingEditEntry = entry
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !entries.isEmpty {
                            Button {
                                exportToCSV()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        
                        Button {
                            showingAddEntry = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
            }
            .sheet(item: $showingEditEntry) { entry in
                EditEntryView(entry: entry)
            }
            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        mileageStore.deleteEntry(entry)
                        entryToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let csvFileURL = csvFileURL {
                    ShareSheet(activityItems: [csvFileURL])
                }
            }
        }
    }
    
    private func getPreviousEntry(for entry: MileageEntry) -> MileageEntry? {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard let currentIndex = sortedEntries.firstIndex(where: { $0.id == entry.id }),
              currentIndex > 0 else {
            return nil
        }
        return sortedEntries[currentIndex - 1]
    }
    
    private func exportToCSV() {
        guard let csvURL = CSVExporter.exportEntries(entries) else {
            return
        }
        
        csvFileURL = csvURL
        showingShareSheet = true
    }
}

struct EntryRowView: View {
    let entry: MileageEntry
    let previousEntry: MileageEntry?
    
    private var delta: Int {
        guard let previous = previousEntry else {
            return 0
        }
        return entry.odometer - previous.odometer
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(DateFormatter.shortDate.string(from: entry.date))
                    .font(.headline)
                
                Spacer()
                
                Text(entry.odometer.formatted)
                    .font(.headline)
                    .monospacedDigit()
            }
            
            if delta > 0 {
                HStack {
                    Text("+\(delta) miles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
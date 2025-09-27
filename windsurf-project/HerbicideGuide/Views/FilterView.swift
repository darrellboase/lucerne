import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: HerbicideStore
    // Bindings passed from ContentView
    @Binding var selectedTypes: Set<String>
    @Binding var selectedPhytotoxicity: Set<String>
    @Binding var selectedTiming: Set<String>
    @Binding var selectedWeeds: Set<String>
    
    private var allTypes: [String] {
        Array(Set(store.herbicides.map { $0.type })).sorted()
    }
    
    private var allPhytotoxicity: [String] {
        Array(Set(store.herbicides.map { $0.phytoxicity })).sorted()
    }
    
    private var allTiming: [String] {
        Array(Set(store.herbicides.flatMap { $0.applicationTiming })).sorted()
    }
    
    private var allWeeds: [String] {
        Array(Set(store.herbicides.flatMap { $0.weedsControlled })).sorted()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Herbicide Type")) {
                    ForEach(allTypes, id: \.self) { type in
                        Toggle(type, isOn: Binding(
                            get: { selectedTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    selectedTypes.insert(type)
                                } else {
                                    selectedTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Phytotoxicity")) {
                    ForEach(allPhytotoxicity, id: \.self) { level in
                        Toggle(level, isOn: Binding(
                            get: { selectedPhytotoxicity.contains(level) },
                            set: { isSelected in
                                if isSelected {
                                    selectedPhytotoxicity.insert(level)
                                } else {
                                    selectedPhytotoxicity.remove(level)
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Application Timing")) {
                    ForEach(allTiming, id: \.self) { timing in
                        Toggle(timing, isOn: Binding(
                            get: { selectedTiming.contains(timing) },
                            set: { isSelected in
                                if isSelected {
                                    selectedTiming.insert(timing)
                                } else {
                                    selectedTiming.remove(timing)
                                }
                            }
                        ))
                    }
                }
                
                 Section(header: Text("Weeds Controlled")) {
                     // A simple searchable list to pick weeds
                     List(allWeeds, id: \.self) { weed in
                         HStack {
                             Text(weed)
                             Spacer()
                             if selectedWeeds.contains(weed) {
                                 Image(systemName: "checkmark").foregroundColor(.accentColor)
                             }
                         }
                         .contentShape(Rectangle())
                         .onTapGesture {
                             if selectedWeeds.contains(weed) {
                                 selectedWeeds.remove(weed)
                             } else {
                                 selectedWeeds.insert(weed)
                             }
                         }
                     }
                     .frame(minHeight: 200)
                 }
            }
            .navigationTitle("Filter")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedTypes.removeAll()
                        selectedPhytotoxicity.removeAll()
                        selectedTiming.removeAll()
                        selectedWeeds.removeAll()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        // Apply filters
                        // In a real app, you would implement the actual filtering logic here
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            selectedTypes: .constant([]),
            selectedPhytotoxicity: .constant([]),
            selectedTiming: .constant([]),
            selectedWeeds: .constant([])
        )
        .environmentObject(HerbicideStore())
    }
}

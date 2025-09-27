import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: HerbicideStore
    @State private var searchText = ""
    @State private var selectedHerbicide: Herbicide?
    @State private var showingFilter = false
    // Filters
    @State private var selectedTypes: Set<String> = []
    @State private var selectedPhytotoxicity: Set<String> = []
    @State private var selectedTiming: Set<String> = []
    @State private var selectedWeeds: Set<String> = []
    
    var filteredHerbicides: [Herbicide] {
        let searched = store.searchHerbicides(query: searchText)
        return searched.filter { herbicide in
            // Type filter (AND across selected values means: if any selected, herbicide.type must be in selected)
            if !selectedTypes.isEmpty && !selectedTypes.contains(herbicide.type) { return false }
            // Phytotoxicity filter
            if !selectedPhytotoxicity.isEmpty && !selectedPhytotoxicity.contains(herbicide.phytoxicity) { return false }
            // Timing filter: require ANY overlap with selected timings if any selected
            if !selectedTiming.isEmpty && selectedTiming.isDisjoint(with: Set(herbicide.applicationTiming)) { return false }
            // Weeds filter: require herbicide controls ALL selected weeds
            if !selectedWeeds.isEmpty && !selectedWeeds.isSubset(of: Set(herbicide.weedsControlled)) { return false }
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredHerbicides) { herbicide in
                    HerbicideRow(herbicide: herbicide)
                        .onTapGesture {
                            selectedHerbicide = herbicide
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search herbicides...")
            .navigationTitle("Lucerne Herbicides")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilter = true }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedHerbicide) { herbicide in
                HerbicideDetailView(herbicide: herbicide)
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(
                    selectedTypes: $selectedTypes,
                    selectedPhytotoxicity: $selectedPhytotoxicity,
                    selectedTiming: $selectedTiming,
                    selectedWeeds: $selectedWeeds
                )
                .environmentObject(store)
            }
        }
    }
}

struct HerbicideRow: View {
    let herbicide: Herbicide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(herbicide.name)
                .font(.headline)
            Text(herbicide.commonName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                ForEach(herbicide.weedsControlled.prefix(3), id: \.self) { weed in
                    Text(weed)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
                if herbicide.weedsControlled.count > 3 {
                    Text("+\\(herbicide.weedsControlled.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HerbicideStore())
    }
}

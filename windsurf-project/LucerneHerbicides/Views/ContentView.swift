import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: HerbicideStore
    @State private var searchText = ""
    @State private var showingAddHerbicide = false
    
    var filteredHerbicides: [Herbicide] {
        if searchText.isEmpty {
            return store.herbicides
        } else {
            return store.herbicides.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.activeIngredient.localizedCaseInsensitiveContains(searchText) ||
                $0.targetWeeds.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredHerbicides) { herbicide in
                    NavigationLink(destination: HerbicideDetailView(herbicide: herbicide)) {
                        HerbicideRow(herbicide: herbicide)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search herbicides...")
            .navigationTitle("Lucerne Herbicides")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHerbicide = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHerbicide) {
                AddHerbicideView()
            }
        }
    }
}

struct HerbicideRow: View {
    let herbicide: Herbicide
    @EnvironmentObject var store: HerbicideStore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(herbicide.name)
                    .font(.headline)
                Text(herbicide.activeIngredient)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(herbicide.targetWeeds.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                store.toggleFavorite(herbicide)
            }) {
                Image(systemName: herbicide.isFavorited ? "star.fill" : "star")
                    .foregroundColor(herbicide.isFavorited ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HerbicideStore())
    }
}

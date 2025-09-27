import SwiftUI

struct HerbicideDetailView: View {
    let herbicide: Herbicide
    @EnvironmentObject var store: HerbicideStore
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with name and favorite button
                HStack {
                    Text(herbicide.name)
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        store.toggleFavorite(herbicide)
                    }) {
                        Image(systemName: herbicide.isFavorited ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(herbicide.isFavorited ? .yellow : .gray)
                    }
                }
                
                // Active Ingredient
                DetailRow(label: "Active Ingredient", value: herbicide.activeIngredient)
                
                // Target Weeds
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target Weeds")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    ForEach(herbicide.targetWeeds, id: \.self) { weed in
                        Text("• \(weed)")
                    }
                }
                .padding(.vertical, 8)
                
                // Application Details
                Group {
                    DetailRow(label: "Application Rate", value: herbicide.applicationRate)
                    DetailRow(label: "Pre-harvest Interval", value: herbicide.preHarvestInterval)
                    DetailRow(label: "Grazing Withholding Period", value: herbicide.grazingWithholdingPeriod)
                }
                
                // Notes
                if !herbicide.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(herbicide.notes)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationView {
                AddHerbicideView(herbicideToEdit: herbicide, isEditing: true)
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

struct HerbicideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HerbicideDetailView(herbicide: Herbicide.sampleData[0])
                .environmentObject(HerbicideStore())
        }
    }
}

import SwiftUI

struct AddHerbicideView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: HerbicideStore
    
    @State private var name = ""
    @State private var activeIngredient = ""
    @State private var targetWeeds = ""
    @State private var applicationRate = ""
    @State private var preHarvestInterval = ""
    @State private var grazingWithholdingPeriod = ""
    @State private var notes = ""
    
    var herbicideToEdit: Herbicide?
    var isEditing = false
    
    init(herbicideToEdit: Herbicide? = nil, isEditing: Bool = false) {
        self.herbicideToEdit = herbicideToEdit
        self.isEditing = isEditing
        
        if let herbicide = herbicideToEdit {
            _name = State(initialValue: herbicide.name)
            _activeIngredient = State(initialValue: herbicide.activeIngredient)
            _targetWeeds = State(initialValue: herbicide.targetWeeds.joined(separator: ", "))
            _applicationRate = State(initialValue: herbicide.applicationRate)
            _preHarvestInterval = State(initialValue: herbicide.preHarvestInterval)
            _grazingWithholdingPeriod = State(initialValue: herbicide.grazingWithholdingPeriod)
            _notes = State(initialValue: herbicide.notes)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Herbicide Name", text: $name)
                    TextField("Active Ingredient", text: $activeIngredient)
                    TextField("Target Weeds (comma separated)", text: $targetWeeds)
                }
                
                Section(header: Text("Application Details")) {
                    TextField("Application Rate", text: $applicationRate)
                    TextField("Pre-harvest Interval", text: $preHarvestInterval)
                    TextField("Grazing Withholding Period", text: $grazingWithholdingPeriod)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Herbicide" : "Add Herbicide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        saveHerbicide()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || activeIngredient.isEmpty)
                }
            }
        }
    }
    
    private func saveHerbicide() {
        let targetWeedsArray = targetWeeds
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let newHerbicide = Herbicide(
            name: name,
            activeIngredient: activeIngredient,
            targetWeeds: targetWeedsArray,
            applicationRate: applicationRate,
            preHarvestInterval: preHarvestInterval,
            grazingWithholdingPeriod: grazingWithholdingPeriod,
            notes: notes
        )
        
        if isEditing, let index = store.herbicides.firstIndex(where: { $0.id == herbicideToEdit?.id }) {
            store.herbicides[index] = newHerbicide
        } else {
            store.herbicides.append(newHerbicide)
        }
    }
}

struct AddHerbicideView_Previews: PreviewProvider {
    static var previews: some View {
        AddHerbicideView()
            .environmentObject(HerbicideStore())
    }
}

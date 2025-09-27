import Foundation

struct Herbicide: Identifiable, Codable {
    var id = UUID()
    var name: String
    var activeIngredient: String
    var targetWeeds: [String]
    var applicationRate: String
    var preHarvestInterval: String
    var grazingWithholdingPeriod: String
    var notes: String
    var isFavorited: Bool = false
    
    static let sampleData: [Herbicide] = [
        Herbicide(
            name: "Butyrac 200",
            activeIngredient: "2,4-DB 200g/L",
            targetWeeds: ["Broadleaf weeds"],
            applicationRate: "1.0-1.5 L/ha",
            preHarvestInterval: "- ",
            grazingWithholdingPeriod: "7 days",
            notes: "Apply to seedling lucerne from 3 trifoliate leaf stage up to 10% bloom or when regrowth is 7.5-15 cm high."
        ),
        Herbicide(
            name: "Verdict 520",
            activeIngredient: "Haloxyfop 520 g/L",
            targetWeeds: ["Grass weeds"],
            applicationRate: "0.35-0.75 L/ha",
            preHarvestInterval: "- ",
            grazingWithholdingPeriod: "7 days",
            notes: "For control of annual and perennial grasses in established lucerne."
        )
    ]
}

class HerbicideStore: ObservableObject {
    @Published var herbicides: [Herbicide] = []
    
    init() {
        loadHerbicides()
    }
    
    func loadHerbicides() {
        // In a real app, you would load from persistent storage
        self.herbicides = Herbicide.sampleData
    }
    
    func toggleFavorite(_ herbicide: Herbicide) {
        if let index = herbicides.firstIndex(where: { $0.id == herbicide.id }) {
            herbicides[index].isFavorited.toggle()
        }
    }
}

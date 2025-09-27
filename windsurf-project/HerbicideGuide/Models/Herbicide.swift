import Foundation

struct Herbicide: Identifiable, Codable {
    let id = UUID()
    let name: String
    let commonName: String
    let type: String  // Pre-emergent, Post-emergent, etc.
    let activeIngredients: [String]
    let applicationRate: String
    let applicationTiming: [String]  // e.g., ["Pre-emergence", "Early post-emergence"]
    let weedsControlled: [String]
    let phytoxicity: String  // Low, Moderate, High
    let rainfastness: String // Time until rainfast
    let grazingRestriction: String
    let notes: String
    let safetyInformation: String
}

class HerbicideStore: ObservableObject {
    @Published var herbicides: [Herbicide] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Attempt to load from bundled JSON
        if let url = Bundle.main.url(forResource: "herbicides", withExtension: "json", subdirectory: "Data") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let items = try decoder.decode([Herbicide].self, from: data)
                DispatchQueue.main.async {
                    self.herbicides = items
                }
                return
            } catch {
                print("Failed to load herbicides.json: \(error)")
            }
        }
        // Fallback minimal seed if JSON missing
        herbicides = [
            Herbicide(
                name: "Roundup Biactive®",
                commonName: "Glyphosate",
                type: "Non-selective, systemic",
                activeIngredients: ["Glyphosate 360 g/L"],
                applicationRate: "1.5–2.0 L/ha in 100–200 L water/ha",
                applicationTiming: ["Pre-plant", "Pre-emergence", "Spot treatment"],
                weedsControlled: ["Annual grasses", "Perennial grasses", "Broadleaf weeds"],
                phytoxicity: "Low",
                rainfastness: "6 hours",
                grazingRestriction: "7 days before grazing",
                notes: "Use as a knockdown herbicide before planting lucerne. Not for use on established lucerne.",
                safetyInformation: "Wear protective clothing. Keep away from watercourses."
            )
        ]
    }
    
    func searchHerbicides(query: String) -> [Herbicide] {
        if query.isEmpty { return herbicides }
        return herbicides.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.commonName.localizedCaseInsensitiveContains(query) ||
            $0.weedsControlled.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}

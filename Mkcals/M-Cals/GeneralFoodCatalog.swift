import Foundation

struct GeneralFood: Decodable, Identifiable {
    let id: Int
    let name: String
    let kcal: Double
    let pro: Double
    let fat: Double
    let cho: Double

    var caloriesText: String { String(format: "%.0fkcal", kcal) }
    var proteinText: String { String(format: "%.1fgm", pro) }
    var fatText: String { String(format: "%.1fgm", fat) }
    var carbsText: String { String(format: "%.1fgm", cho) }
}

enum GeneralFoodCatalog {
    static let foods: [GeneralFood] = {
        guard let url = Bundle.main.url(forResource: "USDA_FNDDS_Foods", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foods = try? JSONDecoder().decode([GeneralFood].self, from: data) else {
            return []
        }
        return foods
    }()
}

import SwiftUI

struct AddFood: View {
    @State var foodList: [String] = []
    let urlString = "https://api.studentlife.umich.edu/menu/xml2print.php?controller=print&view=json&location=Mosher%20Jordan%20Dining%20Hall"
    
    init() {
        fetchData()
    }
    
    // Function to fetch data
    func fetchData() {
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if error == nil, let data = data {
                let decoder = JSONDecoder()
                do {
                    let foodFeed = try decoder.decode(FoodFeed.self, from: data)
                    processMenu(menuResponse: foodFeed)
                } catch {
                    print("Error in JSON parsing \(error)")
                }
            }
        }
        dataTask.resume()
    }
    
    struct FoodFeed: Codable {
        var menu: Menu?
    }
    
    struct Menu: Codable {
        var meal: [Meal]?
    }
    
    struct Meal: Codable {
        var name: String?
        var course: [Course]?
    }
    
    struct Course: Codable {
        var name: String?
        var menuitem: EitherMenuItem
    }
    
    struct MenuItem: Codable {
        var name: String?
    }
    
    enum EitherMenuItem: Codable {
        case single(MenuItem)
        case multiple([MenuItem])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let singleItem = try? container.decode(MenuItem.self) {
                self = .single(singleItem)
            } else if let multipleItems = try? container.decode([MenuItem].self) {
                self = .multiple(multipleItems)
            } else {
                throw DecodingError.typeMismatch(EitherMenuItem.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Neither single nor multiple items found"))
            }
        }
    }
    
    // Function to process the menu
    func processMenu(menuResponse: FoodFeed) {
        if let menu = menuResponse.menu {  // Now accessing single menu object
            if let meals = menu.meal {
                for meal in meals {
                    if let courses = meal.course {
                        for course in courses {
                            switch course.menuitem {
                            case .single(let menuItem):
                                print("Single menu item: \(menuItem.name ?? "No name")")
                                foodList.append("\(menuItem.name ?? "No Name")")
                                
                            case .multiple(let menuItems):
                                for item in menuItems {
                                    print("Multiple menu items: \(item.name ?? "No name")")
                                    foodList.append("\(item.name ?? "No Name")")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    var body: some View {
        Text("Hello World")
        List(foodList, id: \.self) { foodItem in
                    Text(foodItem)
                }
        .onAppear {
            fetchData()
        }
    }
}

#Preview {
    AddFood()
}

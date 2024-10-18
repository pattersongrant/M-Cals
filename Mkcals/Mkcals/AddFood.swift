import SwiftUI

struct AddFood: View {
    @State private var foodList: [String] = []
    @State private var mealList: [[String]] = []
    @State private var selectedDiningHall: String = "Mosher Jordan Dining Hall" // Default selection
    @State private var isRefreshing = false
    
    // Dining halls array
    let diningHalls = [
        "Mosher Jordan Dining Hall",
        "Bursley Dining Hall",
        "East Quad Dining Hall",
        "Lawyers Club Dining Hall",
        "Markley Dining Hall",
        "Martha Cook Dining Hall",
        "North Quad Dining Hall",
        "South Quad Dining Hall",
        "Twigs at Oxford"
    ]
    
    // Function to construct the URL
    private func getURL(for diningHall: String) -> String {
        return "https://api.studentlife.umich.edu/menu/xml2print.php?controller=print&view=json&location=\(diningHall.replacingOccurrences(of: " ", with: "%20"))"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Set spacing to 0 for VStack
                Picker("Select Dining Hall", selection: $selectedDiningHall) {
                    ForEach(diningHalls, id: \.self) { hall in
                        Text(hall).tag(hall)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Use menu style for dropdown
                .padding(.top, 10) // Optional padding

                // Updated onChange method without deprecated warning
                .onChange(of: selectedDiningHall) { newValue in
                    fetchData(forceRefresh: true) // Fetch new data on selection change
                }
                
                List {
                    ForEach(foodList.indices, id: \.self) { mealIndex in
                        Section(header: Text(foodList[mealIndex]).font(.headline)) {
                            ForEach(mealList[mealIndex].indices, id: \.self) { itemIndex in
                                Text(mealList[mealIndex][itemIndex])
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Use plain style for less padding
            }

            .padding(.top, 0) // Ensure there's no padding
            .refreshable {
                fetchData(forceRefresh: true) // Refresh data on pull down
            }
            .onAppear {
                fetchData(forceRefresh: false) // Fetch data on view appear
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use Stack style for better control
        .edgesIgnoringSafeArea(.top) // Ignore the safe area at the top
    }
    
    // Function to fetch data from cache or server
    func fetchData(forceRefresh: Bool) {
        let urlString = getURL(for: selectedDiningHall) // Get the URL for the selected dining hall
        
        if !forceRefresh, isCacheValid() {
            if let cachedData = UserDefaults.standard.data(forKey: "cachedMenuData") {
                processMenuData(cachedData)
                return
            }
        }
        
        // Fetch from the server if cache is invalid or forceRefresh is true
        guard let url = URL(string: urlString) else { return }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    saveDataToCache(data)  // Save new data
                    processMenuData(data)   // Process new data
                }
            } else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        dataTask.resume()
    }
    
    // Save menu data with timestamp to UserDefaults
    func saveDataToCache(_ data: Data) {
        let currentDate = Date()
        UserDefaults.standard.set(data, forKey: "cachedMenuData")
        UserDefaults.standard.set(currentDate, forKey: "cacheTimestamp")
    }
    
    // Check if the cached data is from today
    func isCacheValid() -> Bool {
        if let cachedDate = UserDefaults.standard.object(forKey: "cacheTimestamp") as? Date {
            return Calendar.current.isDateInToday(cachedDate)
        }
        return false
    }
    
    // Process the menu data to update foodList and mealList
    func processMenuData(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let foodFeed = try decoder.decode(FoodFeed.self, from: data)
            updateMenuLists(with: foodFeed)
        } catch {
            print("Error in JSON parsing \(error)")
        }
    }
    
    // Update the UI data structures from the parsed food feed
    func updateMenuLists(with foodFeed: FoodFeed) {
        guard let menu = foodFeed.menu else { return }
        foodList.removeAll()
        mealList.removeAll()
        
        if let meals = menu.meal {
            for meal in meals {
                foodList.append(meal.name ?? "Unnamed Meal")
                var itemList: [String] = []
                
                if let courses = meal.course {
                    for course in courses {
                        switch course.menuitem {
                        case .single(let menuItem):
                            itemList.append(menuItem.name ?? "Unnamed Item")
                        case .multiple(let menuItems):
                            for item in menuItems {
                                itemList.append(item.name ?? "Unnamed Item")
                            }
                        }
                    }
                }
                
                mealList.append(itemList)
            }
        }
    }
    
    // MARK: - Codable Structs
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
}

#Preview {
    AddFood()
}

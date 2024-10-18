import SwiftUI

struct AddFood: View {
    @State private var foodList: [String] = []
    @State private var mealList: [[String]] = []
    @State private var selectedDiningHall: String = "Mosher Jordan Dining Hall"
    @State private var isRefreshing = false
    @State private var selectedItems: [String] = []
    @State private var isNavigatingToHome = false // State to trigger navigation
    
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
    
    private func getURL(for diningHall: String) -> String {
        return "https://api.studentlife.umich.edu/menu/xml2print.php?controller=print&view=json&location=\(diningHall.replacingOccurrences(of: " ", with: "%20"))"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Select Dining Hall", selection: $selectedDiningHall) {
                    ForEach(diningHalls, id: \.self) { hall in
                        Text(hall).tag(hall)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.top, 10)
                .onChange(of: selectedDiningHall) { newValue in
                    fetchData(forceRefresh: true)
                }

                List {
                    ForEach(foodList.indices, id: \.self) { mealIndex in
                        Section(header: Text(foodList[mealIndex]).font(.headline)) {
                            ForEach(mealList[mealIndex].indices, id: \.self) { itemIndex in
                                HStack {
                                    Text(mealList[mealIndex][itemIndex])
                                    Spacer()
                                    Image(systemName: selectedItems.contains(mealList[mealIndex][itemIndex]) ? "checkmark.square.fill" : "square")
                                        .onTapGesture {
                                            toggleSelection(of: mealList[mealIndex][itemIndex])
                                        }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding(.top, 0)
            .refreshable {
                fetchData(forceRefresh: true)
            }
            .onAppear {
                fetchData(forceRefresh: false)
            }
            .navigationBarItems(trailing:
                Button(action: {
                    isNavigatingToHome = true // Set the state to true for navigation
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title)
                }
            )
            .background(
                NavigationLink(destination: Homepage(selectedItems: selectedItems), isActive: $isNavigatingToHome) {
                    EmptyView()
                }
                .hidden() // Keep the link hidden but active
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.top)
    }
    
    func toggleSelection(of item: String) {
        if selectedItems.contains(item) {
            selectedItems.removeAll { $0 == item }
        } else {
            selectedItems.append(item)
        }
    }
    
    func fetchData(forceRefresh: Bool) {
        let urlString = getURL(for: selectedDiningHall)
        if !forceRefresh, isCacheValid() {
            if let cachedData = UserDefaults.standard.data(forKey: "cachedMenuData") {
                processMenuData(cachedData)
                return
            }
        }
        guard let url = URL(string: urlString) else { return }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    saveDataToCache(data)
                    processMenuData(data)
                }
            } else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        dataTask.resume()
    }

    func saveDataToCache(_ data: Data) {
        let currentDate = Date()
        UserDefaults.standard.set(data, forKey: "cachedMenuData")
        UserDefaults.standard.set(currentDate, forKey: "cacheTimestamp")
    }

    func isCacheValid() -> Bool {
        if let cachedDate = UserDefaults.standard.object(forKey: "cacheTimestamp") as? Date {
            return Calendar.current.isDateInToday(cachedDate)
        }
        return false
    }

    func processMenuData(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let foodFeed = try decoder.decode(FoodFeed.self, from: data)
            updateMenuLists(with: foodFeed)
        } catch {
            print("Error in JSON parsing \(error)")
        }
    }

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

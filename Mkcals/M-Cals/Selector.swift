//
//  Selector.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/18/24.
//

import SwiftUI

import GRDB

class ToggleManager: ObservableObject {
    @Published var demoMode: Bool = false
}


class APIHandling {
    //get url and format it
    static func getURL (diningHall: String) -> String {
        return "https://api.studentlife.umich.edu/menu/xml2print.php?controller=print&view=json&location=\(diningHall.replacingOccurrences(of: " ", with: "%20"))"
    }

}




struct Selector: View {
    @State var selectedDiningHall: String = UserDefaults.standard.string(forKey: "selectedDiningHall") ?? "Mosher Jordan Dining Hall"
    @State var mealAddingTo: String
    @State private var menu: Menu? // Store the fetched menu data
    @State private var selectedItems: Set<String> = [] // Set to store selected menu items
    @State private var searchText = ""
    @State private var selectedGeneralFoodIDs: Set<Int> = []
    @State private var generalFoodQuantities: [Int: String] = [:]
    @State var selectedMeal = "Breakfast"
    @State var jsonBug = false
    @State var hallChanging = false
    @EnvironmentObject var toggleManager: ToggleManager
    @State private var quantities: [String: String] = [:]
    @State private var specialMenu: Menu?
    @State private var addButtonPressed: Bool = false
    @State private var noMenuItems: Bool = true
    @State private var preLoaded = false



 
    let hallNames = [
        "Mosher Jordan Dining Hall",
        "Markley Dining Hall",
        "Bursley Dining Hall",
        "South Quad Dining Hall",
        "East Quad Dining Hall",
        "Twigs at Oxford",
        "North Quad Dining Hall",
        "Martha Cook Dining Hall",
        "Lawyers Club Dining Hall",
        "Wolverine Village Dining Hall"
        
    ]

    private var searchTerm: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingMichiganItems: [Meal.CourseWrapper.Course.MenuItem] {
        guard !hallChanging, !searchTerm.isEmpty else { return [] }
        var seenNames = Set<String>()
        return (menu?.meal ?? [])
            .flatMap { $0.course?.courseitem ?? [] }
            .flatMap { $0.menuitem.item }
            .filter { item in
                guard let name = item.name,
                      name.localizedCaseInsensitiveContains(searchTerm) else { return false }
                return seenNames.insert(name).inserted
            }
    }

    private var matchingGeneralFoods: [GeneralFood] {
        guard !searchTerm.isEmpty else { return [] }
        return GeneralFoodCatalog.foods.filter {
            $0.name.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    
    // Update UserDefaults whenever the dining hall changes
    private func updateSelectedDiningHallCache() {
        UserDefaults.standard.set(selectedDiningHall, forKey: "selectedDiningHall")
    }
    
    
    //demo mode
    func loadDemoData() {
        print(selectedDiningHall.replacingOccurrences(of: " ", with: "_"))
        print(selectedDiningHall)
                                
                                                
        guard let path = Bundle.main.path(forResource: selectedDiningHall.replacingOccurrences(of: " ", with: "_"), ofType: "json") else {
            print("Demo JSON file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            //print(path)
            let decoder = JSONDecoder()
            let itemFeed = try decoder.decode(apiCalled.self, from: data)

            
            //print raw json
            //if let jsonString = String(data: data, encoding: .utf8) {
                //print("JSON Response: \(jsonString)")
            //}
            //let customMeal1 = Meal()
            

            DispatchQueue.main.async {
                self.menu = itemFeed.menu
                self.preLoaded = true
                self.noMenuItems = false
                self.hallChanging = false
            }
            print("Demo data loaded successfully.")
        } catch {
            print("Error loading demo data: \(error)")
        }
    }
    func loadSpecialData() {
        guard let path = Bundle.main.path(forResource: "special_menu", ofType: "json") else {
            print("Special JSON file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            //print(path)
            let decoder = JSONDecoder()
            let itemFeed = try decoder.decode(apiCalled.self, from: data)

            
            //print raw json
            //if let jsonString = String(data: data, encoding: .utf8) {
                //print("JSON Response: \(jsonString)")
            //}
            //let customMeal1 = Meal()
            

            self.specialMenu = itemFeed.menu
            
            print("Demo data loaded successfully.")
            hallChanging = false
        } catch {
            print("Error loading special data: \(error)")
        }
    }
    
    //api call
    func fetchData() {
            preLoaded = false
        
        //if toggleManager.demoMode {
            //loadDemoData()

          //  return
        //} else {
            
            let urlString = APIHandling.getURL(diningHall: selectedDiningHall)
            
            let url = URL(string: urlString)
            
            guard url != nil else {
                return
            }
            
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: url!) { (data,response,error) in
                
                //check for errors
                if error == nil && data != nil {
                    
                    
                    //parse json
                    let decoder = JSONDecoder()
                    
                    do{
                        
                        //print raw json
                        //if let jsonString = String(data: data!, encoding: .utf8) {
                        //print("JSON Response: \(jsonString)")
                        //}
                        
                        let itemFeed = try decoder.decode(apiCalled.self, from: data!)
                        //print(itemFeed)
                        DispatchQueue.main.async {
                            
                           
                            self.menu = itemFeed.menu //store decoded menu
                            self.hallChanging = false
                            self.preLoaded = false
                            
                            
                            
                            /* Print each course name and its menuitem names
                             if let meals = itemFeed.menu?.meal {
                             for meal in meals {
                             if let courses = meal.course?.courseitem {
                             for course in courses {
                             // Print the course name before the menuitems
                             if let courseName = course.name {
                             print("Course Name: \(courseName)")
                             }
                             
                             // Print each menuitem name under the course
                             for menuItem in course.menuitem.item {
                             if let itemName = menuItem.name {
                             print("  MenuItem Name: \(itemName)")
                             }
                             }
                             }
                             }
                             }
                             }*/
                            
                            
                        }
                    } catch {
                        print("error: \(error)")
                        loadDemoData()
                        //jsonBug = true
                    }
                    
                } else {
                    loadDemoData()
                    //jsonBug = true
                }
                
            }
            //make the API Call
            dataTask.resume()
        //}
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Set the format to include only year, month, and day
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    func saveSelectedItemsToDatabase() {
        let meals = menu?.meal ?? []
        //print(getCurrentDate())
        print(selectedItems)
        
        // Find or create the meal in the database and get its ID
        do {
            try DatabaseManager.addMeal(date: getCurrentDate(), mealName: mealAddingTo) // Example date, use current date dynamically if needed.
            
            // Get the last inserted meal ID (or you might need to fetch it based on date and meal name)
            let mealID = try dbQueue.read { db in
                try Int.fetchOne(db, sql: "SELECT id FROM meals WHERE date = ? AND mealname = ?", arguments: [getCurrentDate(), mealAddingTo])
            }
            
            
            guard let validMealID = mealID else { return }
            
            var addedItems = Set<String>()  // A Set to track added items (by their name)

            for selectedItem in selectedItems {
                //print(selectedItem)
                
                for meal in meals {
                    //print(meal)
                    if let courses = meal.course?.courseitem {
                        for course in courses {
                            
                            // Find the first matching item
                            if let item = course.menuitem.item.first(where: { $0.name == selectedItem }) {
                                
                                // Check if this item has already been added
                                if addedItems.contains(selectedItem) {
                                    continue  // Skip if already added
                                }
                                
                                // Mark this item as added
                                addedItems.insert(selectedItem)
                                
                                // If nutrition exists, add the food item to the database
                                if let nutrition = item.itemsize?.nutrition {
                                    let kcal = nutrition.kcal ?? "0kcal"
                                    let pro = nutrition.pro ?? "0gm"
                                    let fat = nutrition.fat ?? "0gm"
                                    let cho = nutrition.cho ?? "0gm"
                                    let serving = item.itemsize?.serving_size ?? "N/A"
                                    let qty = quantities[selectedItem] ?? "1"
                                    
                                    try DatabaseManager.addFoodItem(
                                        meal_id: validMealID,
                                        name: selectedItem,
                                        kcal: kcal,
                                        pro: pro,
                                        fat: fat,
                                        cho: cho,
                                        serving: serving,
                                        qty: qty
                                        
                                    )
                                }
                            }
                        }
                    }
                }
            }

            for food in GeneralFoodCatalog.foods where selectedGeneralFoodIDs.contains(food.id) {
                try DatabaseManager.addFoodItem(
                    meal_id: validMealID,
                    name: food.name,
                    kcal: food.caloriesText,
                    pro: food.proteinText,
                    fat: food.fatText,
                    cho: food.carbsText,
                    serving: "100 g",
                    qty: generalFoodQuantities[food.id] ?? "1"
                )
            }

            
            print("Items successfully added to the database.")
        } catch {
            print("Failed to add items: \(error)")
        }
    }

    
    
    
    //Structs for JSON decoding
    struct apiCalled: Codable {
        var menu: Menu?
    }
    struct Menu: Codable {
        var meal: [Meal]?
    }
    struct Meal: Codable {
        var name: String?
        var course: CourseWrapper?
        
        struct CourseWrapper: Codable {
            var courseitem: [Course] //makes an array called courseitem to store all courses for the meal (whether it be single or mutliple)
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let singleCourseItem = try? container.decode(Course.self) {
                    // If a single MenuItem is decoded, add it to the array
                    courseitem = [singleCourseItem]
                } else if let multipleItems = try? container.decode([Course].self) {
                    // If an array of MenuItem is decoded, assign it
                    courseitem = multipleItems
                } else {
                    throw DecodingError.typeMismatch(
                        CourseWrapper.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected single MenuItem or array of MenuItem."
                        )
                    )
                }
            }
            //array vs single item decoding for menuitem
            struct Course: Codable {
                var name: String?
                var menuitem: ItemWrapper
                
                struct ItemWrapper: Codable {
                    var item: [MenuItem]
                    
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        if let singleItem = try? container.decode(MenuItem.self) {
                            // If a single MenuItem is decoded, add it to the array
                            item = [singleItem]
                        } else if let multipleItems = try? container.decode([MenuItem].self) {
                            // If an array of MenuItem is decoded, assign it
                            item = multipleItems
                        } else {
                            throw DecodingError.typeMismatch(
                                ItemWrapper.self,
                                DecodingError.Context(
                                    codingPath: decoder.codingPath,
                                    debugDescription: "Expected single MenuItem or array of MenuItem."
                                )
                            )
                        }
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        if item.count == 1 {
                            try container.encode(item[0]) // Encode as a single item if there's only one
                        } else {
                            try container.encode(item) // Encode as an array if there are multiple items
                        }
                    }
                }
                
                struct MenuItem: Codable {
                    var name: String?
                    var itemsize: ItemSize? //added

                    
                    
                }
            }
            //end of array vs single item decoding
        }
    }
    
    
    

    
    
    // Struct for Nutrition (only 4 macros)
    struct Nutrition: Codable {
        var pro: String?  // Protein
        var fat: String?  // Fat
        var cho: String?  // Carbohydrates
        var kcal: String? // Calories
        
        // Initialize with default values
        init(from nutritionDict: [String: String]? = nil) {
            self.pro = nutritionDict?["pro"] ?? "0gm"
            self.fat = nutritionDict?["fat"] ?? "0gm"
            self.cho = nutritionDict?["cho"] ?? "0gm"
            self.kcal = nutritionDict?["kcal"] ?? "0kcal"
        }
    }

    // Struct for ItemSize, including Nutrition
    struct ItemSize: Codable {
        var serving_size: String?   // Optional, in case it's missing
        var portion_size: String?  // Optional, in case it's missing
        var nutrition: Nutrition?  // Optional, in case it's missing or malformed
        
        enum CodingKeys: String, CodingKey {
            case serving_size
            case portion_size
            case nutrition
        }
        
        // Custom initializer to handle the case where `nutrition` might be an empty array
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.serving_size = try? container.decode(String.self, forKey: .serving_size)
            self.portion_size = try? container.decode(String.self, forKey: .portion_size)
            
            // Attempt to decode `nutrition` as a dictionary
            if let nutritionDict = try? container.decode([String: String].self, forKey: .nutrition) {
                self.nutrition = Nutrition(from: nutritionDict)
            } else if let nutritionArray = try? container.decode([String].self, forKey: .nutrition), nutritionArray.isEmpty {
                // If `nutrition` is an empty array, initialize it with default values
                self.nutrition = Nutrition()
            } else {
                // Default to empty nutrition if unable to decode
                self.nutrition = Nutrition()
            }
        }
    }

    private func searchSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.mBlue)
            .cornerRadius(13)
            .padding(.horizontal, 15)
            .padding(.top, 12)
    }

    private func michiganSearchRow(_ item: Meal.CourseWrapper.Course.MenuItem) -> some View {
        let name = item.name ?? "Unnamed Menu Item"
        return VStack {
            HStack {
                Text(name)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .padding(.leading, 15)
                NavigationLink(destination: NutritionViewer(
                    name: name,
                    kcal: item.itemsize?.nutrition?.kcal ?? "0kcal",
                    pro: item.itemsize?.nutrition?.pro ?? "0gm",
                    fat: item.itemsize?.nutrition?.fat ?? "0gm",
                    cho: item.itemsize?.nutrition?.cho ?? "0gm",
                    serving: item.itemsize?.serving_size ?? "N/A"
                )) {
                    Image(systemName: "info.circle")
                }
                Spacer()
                if selectedItems.contains(name) {
                    Picker("Quantity", selection: Binding(
                        get: { quantities[name] ?? "1" },
                        set: { quantities[name] = $0 }
                    )) {
                        ForEach(["0.5", "1", "2", "3", "4"], id: \.self) { amount in
                            Text(amount).tag(amount)
                        }
                    }
                    .labelsHidden()
                    .tint(.black)
                }
                Toggle(isOn: Binding(
                    get: { selectedItems.contains(name) },
                    set: { selected in
                        if selected { selectedItems.insert(name) }
                        else { selectedItems.remove(name) }
                    }
                )) {
                    Image(systemName: selectedItems.contains(name) ? "checkmark.square.fill" : "square")
                        .foregroundStyle(Color.mBlue)
                        .font(.title)
                }
                .accessibilityLabel(name)
                .labelsHidden()
                .toggleStyle(.button)
                .buttonStyle(.plain)
                .padding(.trailing, 15)
            }
            Divider()
        }
    }

    private func generalSearchRow(_ food: GeneralFood) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(food.name)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    Text("\(food.caloriesText) · 100 g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 15)
                NavigationLink(destination: NutritionViewer(
                    name: food.name,
                    kcal: food.caloriesText,
                    pro: food.proteinText,
                    fat: food.fatText,
                    cho: food.carbsText,
                    serving: "100 g"
                )) {
                    Image(systemName: "info.circle")
                }
                Spacer()
                if selectedGeneralFoodIDs.contains(food.id) {
                    Picker("Quantity", selection: Binding(
                        get: { generalFoodQuantities[food.id] ?? "1" },
                        set: { generalFoodQuantities[food.id] = $0 }
                    )) {
                        ForEach(["0.5", "1", "2", "3", "4"], id: \.self) { amount in
                            Text(amount).tag(amount)
                        }
                    }
                    .labelsHidden()
                    .tint(.black)
                }
                Toggle(isOn: Binding(
                    get: { selectedGeneralFoodIDs.contains(food.id) },
                    set: { selected in
                        if selected { selectedGeneralFoodIDs.insert(food.id) }
                        else { selectedGeneralFoodIDs.remove(food.id) }
                    }
                )) {
                    Image(systemName: selectedGeneralFoodIDs.contains(food.id) ? "checkmark.square.fill" : "square")
                        .foregroundStyle(Color.mBlue)
                        .font(.title)
                }
                .accessibilityLabel(food.name)
                .labelsHidden()
                .toggleStyle(.button)
                .buttonStyle(.plain)
                .padding(.trailing, 15)
            }
            Divider()
        }
    }

    private var searchResultsView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            searchSectionTitle("Michigan Dining")
            if hallChanging || menu == nil {
                Text("Loading dining hall foods...")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
            } else if matchingMichiganItems.isEmpty {
                Text("No dining hall foods found.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
            } else {
                ForEach(matchingMichiganItems, id: \.name) { item in
                    michiganSearchRow(item)
                }
            }

            searchSectionTitle("General Foods · USDA")
            if matchingGeneralFoods.isEmpty {
                Text("No general foods found.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
            } else {
                ForEach(matchingGeneralFoods) { food in
                    generalSearchRow(food)
                }
            }
        }
    }

    
    
    

    

    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    
                    Picker("Select Dining Hall", selection: $selectedDiningHall) {
                        ForEach(hallNames, id: \.self) { hall in
                            Text(hall).tag(hall)
                                
                                
                                
                        }
                        .onChange(of: selectedDiningHall) { oldValue, newValue in
                            hallChanging = true
                            noMenuItems = true
                            updateSelectedDiningHallCache()
                            preLoaded = false
                            fetchData()
                            
                        }
                    } .accentColor(Color.black)
                        
                                            //.padding(.top, 12)
                    .padding(.leading,2)
                    
                    
                    
                        
                        
                    Spacer()
                    NavigationLink(destination: Custom(menu: $menu, quantities: $quantities, selectedItems: $selectedItems, mealAddingTo: mealAddingTo)) {
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("Custom")
                            
                            //.foregroundStyle(Color.mBlue)
                            
                            /*
                             .padding(.horizontal, 5)
                             .frame(height: 25)
                             .foregroundStyle(Color.white)
                             .background(Color.blue)
                             .cornerRadius(8)*/
                        }
                            
                        
                    }
                    
                        //.buttonStyle(.bordered)
                        
                        .padding(.trailing, 15)
                        //.tint(Color.blue)
                    /*if !preLoaded {
                        HStack{
                            Image(systemName: "dot.radiowaves.left.and.right")
                            
                                .foregroundStyle(Color.green)
                                .font(.system(size: 10))
                            Text("Up-To-Date")
                                .font(.system(size: 10))
                        }.padding(.trailing, 20)
                        
                        
                    }*/
                    
                }
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search foods", text: $searchText)
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(11)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 15)
                .padding(.bottom, 6)
                if preLoaded {
                    Text("Old menus loaded. Connect to U-M Wifi to use Updated Menus.")
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, 8)
                    
                        
                        
                        
                }
                ScrollView{
                    if !searchTerm.isEmpty {
                        searchResultsView
                    } else {
                    if let meals = menu?.meal{
                        if hallChanging == false{
                            ForEach(meals, id: \.name) { meal in
                                
                                if meal.course != nil {
                                    
                                    Text(meal.name?.lowercased().capitalized ?? "Unnamed Meal")
                                        
                                        .font(.largeTitle)
                                        .bold()
                                        .foregroundStyle(Color.white)
                                        .frame(width: 340, height: 60)
                                        .padding(.horizontal) // Add padding around the text
                                        .background(Color(.mBlue)) // Light gray background
                                        .cornerRadius(13) // Apply rounded corners
                                        
                                        .padding(.bottom, 8)
                                        
                                        
                                    
                                    
                                    
                                    
                                    
                                }
                                if let courses = meal.course?.courseitem {
                                    ForEach(courses, id: \.name) { course in
                                        VStack{
                                            HStack{
                                                Text(course.name ?? "Unnamed Course")
                                                    .foregroundStyle(Color.mmaize)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .padding(.leading, 15)
                                                //.underline(true)
                                                
                                                    .padding(.bottom, 4)
                                                    .onAppear {
                                                        noMenuItems = false
                                                    }
                                                    
                                                
                                                Spacer()
                                            }
                                            // Directly use `course.menuitem.item` without optional unwrapping
                                            
                                            ForEach(course.menuitem.item, id: \.name) { menuItem in
                                                
                                                VStack{
                                                    HStack{
                                                        Text(menuItem.name ?? "Unnamed MenuItem")
                                                            .font(. system(size: 14))
                                                            //.font(.title)
                                                            .padding(.leading, 15)
                                                            .fontWeight(.semibold)
                                                            
                                                        
                                                        
                                                        
                                                        NavigationLink(destination: NutritionViewer(name: menuItem.name ?? "Unnamed MenuItem", kcal: menuItem.itemsize?.nutrition?.kcal ?? "0kcal", pro: menuItem.itemsize?.nutrition?.pro ?? "0gm", fat: menuItem.itemsize?.nutrition?.fat ?? "0gm", cho: menuItem.itemsize?.nutrition?.cho ?? "0gm", serving: menuItem.itemsize?.serving_size ?? "N/A")){
                                                            Image(systemName: "info.circle")
                                                                .resizable()
                                                                .frame(width: 17, height: 17)
                                                                
                                                            
                                                        }
                                                        Spacer()
                                                        if selectedItems.contains(menuItem.name ?? "") {
                                                            Picker("", selection: Binding(
                                                                get: { quantities[menuItem.name ?? ""] ?? "1" },
                                                                set: { quantities[menuItem.name ?? ""] = $0 }
                                                            )) {
                                                                ForEach(["0.5", "1", "2", "3", "4"], id: \.self) { q in
                                                                    Text(q).tag(q)
                                                                }
                                                                
                                                            }
                                                            
                                                            .accentColor(Color.black)
                                                        }


                                                        
                                                        Toggle(isOn: Binding(
                                                            get: { selectedItems.contains(menuItem.name ?? "") },
                                                            set: { isSelected in
                                                                if isSelected {
                                                                    selectedItems.insert(menuItem.name ?? "")
                                                                } else {
                                                                    selectedItems.remove(menuItem.name ?? "")
                                                                }
                                                            }
                                                        )) {
                                                            
                                                            Image(systemName: selectedItems.contains(menuItem.name ?? "") ? "checkmark.square.fill" : "square") // Empty square when unselected, filled when selected
                                                                .foregroundStyle(Color.mBlue)
                                                                                             
                                                                .animation(nil, value:selectedItems)
                                                            //.frame(height:25)
                                                                .font(.title)
                                                                
                                                        }
                                                        .sensoryFeedback(.increase, trigger: selectedItems)
                                                        .labelsHidden()
                                                        .toggleStyle(.button)
                                                        .padding(.trailing, 15)
                                                        .buttonStyle(.plain)
                                                        // Show Picker only when the Toggle is checked

                                                        
                                                        
                                                        
                                                    }
                                                    Divider()
                                                }
                                            }
                                        }.padding(.bottom, 8)
                                    }
                                    
                                }
                            }
                            
                            if !noMenuItems{
                                SpecialViewer(mealAddingTo: mealAddingTo, selectedItems: $selectedItems, addToMealButtonPressed: $addButtonPressed)
                            } else {
                                Text("No menu items found!")
                                    .foregroundStyle(Color.gray)
                                    .padding()
                            }
                        } else if jsonBug == true{
                            Text("Error fetching menus.\nPlease connect to the U-M Wifi.")
                                .foregroundStyle(Color.gray)
                                .padding()
                        }
                                
                        else {
                            ProgressView()
                                .padding(.top, 15)
                            Text("Loading Menu...")
                                .foregroundStyle(Color.gray)
                        }
                    } else if jsonBug == true{
                        Text("Error fetching menus.\nPlease connect to the U-M Wifi.")
                            .foregroundStyle(Color.gray)
                            .padding()
                    }
                            
                    else {
                        ProgressView()
                            .padding(.top, 15)
                        Text("Loading Menu...")
                            .foregroundStyle(Color.gray)
                    }
                    }
                    
                }
                

                Spacer()
            } .onAppear{fetchData()}
            
        }.navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationLink(destination: Homepage()){
                HStack{
                    Text("Add to \(mealAddingTo)")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.mBlue)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.mBlue)
                }
                
            }
            .simultaneousGesture(TapGesture().onEnded {
                addButtonPressed = true
                saveSelectedItemsToDatabase()
                
            })
        }
        
            
        
    }
    
    
    
}
struct SpecialViewer: View {
    @State var mealAddingTo: String
    @State private var menu: Menu? // Store the fetched menu data
    @Binding var selectedItems: Set<String>
    @State var selectedMeal = "Breakfast"
    @State var jsonBug = false
    @State var hallChanging = false
    @EnvironmentObject var toggleManager: ToggleManager
    @State private var quantities: [String: String] = [:]
    @Binding var addToMealButtonPressed: Bool





    func loadSpecialData() {
        guard let path = Bundle.main.path(forResource: "special_menu", ofType: "json") else {
            print("Special JSON file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            //print(path)
            let decoder = JSONDecoder()
            let itemFeed = try decoder.decode(apiCalled.self, from: data)

            
            //print raw json
            //if let jsonString = String(data: data, encoding: .utf8) {
                //print("JSON Response: \(jsonString)")
            //}
            //let customMeal1 = Meal()
            

            self.menu = itemFeed.menu
            
            print("Demo data loaded successfully.")
            hallChanging = false
        } catch {
            print("Error loading demo data: \(error)")
        }
    }
    
    //api call
    func fetchData() {
        loadSpecialData()

    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Set the format to include only year, month, and day
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    func saveSelectedItemsToDatabase() {
        guard let meals = menu?.meal else { return }
        print(getCurrentDate())
        print(selectedItems)
        
        // Find or create the meal in the database and get its ID
        do {
            try DatabaseManager.addMeal(date: getCurrentDate(), mealName: mealAddingTo) // Example date, use current date dynamically if needed.
            
            // Get the last inserted meal ID (or you might need to fetch it based on date and meal name)
            let mealID = try dbQueue.read { db in
                try Int.fetchOne(db, sql: "SELECT id FROM meals WHERE date = ? AND mealname = ?", arguments: [getCurrentDate(), mealAddingTo])
            }
            
            
            guard let validMealID = mealID else { return }
            
            var addedItems = Set<String>()  // A Set to track added items (by their name)

            for selectedItem in selectedItems {
                print(selectedItem)
                
                for meal in meals {
                    print(meal)
                    if let courses = meal.course?.courseitem {
                        for course in courses {
                            
                            // Find the first matching item
                            if let item = course.menuitem.item.first(where: { $0.name == selectedItem }) {
                                
                                // Check if this item has already been added
                                if addedItems.contains(selectedItem) {
                                    continue  // Skip if already added
                                }
                                
                                // Mark this item as added
                                addedItems.insert(selectedItem)
                                
                                // If nutrition exists, add the food item to the database
                                if let nutrition = item.itemsize?.nutrition {
                                    let kcal = nutrition.kcal ?? "0kcal"
                                    let pro = nutrition.pro ?? "0gm"
                                    let fat = nutrition.fat ?? "0gm"
                                    let cho = nutrition.cho ?? "0gm"
                                    let serving = item.itemsize?.serving_size ?? "N/A"
                                    let qty = quantities[selectedItem] ?? "1"
                                    
                                    try DatabaseManager.addFoodItem(
                                        meal_id: validMealID,
                                        name: selectedItem,
                                        kcal: kcal,
                                        pro: pro,
                                        fat: fat,
                                        cho: cho,
                                        serving: serving,
                                        qty: qty
                                        
                                    )
                                }
                            }
                        }
                    }
                }
            }

            
            print("SPECIAL ITEMS successfully added to the database.")
        } catch {
            print("Failed to add items: \(error)")
        }
    }

    
    
    
    //Structs for JSON decoding
    struct apiCalled: Codable {
        var menu: Menu?
    }
    struct Menu: Codable {
        var meal: [Meal]?
    }
    struct Meal: Codable {
        var name: String?
        var course: CourseWrapper?
        
        struct CourseWrapper: Codable {
            var courseitem: [Course] //makes an array called courseitem to store all courses for the meal (whether it be single or mutliple)
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let singleCourseItem = try? container.decode(Course.self) {
                    // If a single MenuItem is decoded, add it to the array
                    courseitem = [singleCourseItem]
                } else if let multipleItems = try? container.decode([Course].self) {
                    // If an array of MenuItem is decoded, assign it
                    courseitem = multipleItems
                } else {
                    throw DecodingError.typeMismatch(
                        CourseWrapper.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected single MenuItem or array of MenuItem."
                        )
                    )
                }
            }
            //array vs single item decoding for menuitem
            struct Course: Codable {
                var name: String?
                var menuitem: ItemWrapper
                
                struct ItemWrapper: Codable {
                    var item: [MenuItem]
                    
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        if let singleItem = try? container.decode(MenuItem.self) {
                            // If a single MenuItem is decoded, add it to the array
                            item = [singleItem]
                        } else if let multipleItems = try? container.decode([MenuItem].self) {
                            // If an array of MenuItem is decoded, assign it
                            item = multipleItems
                        } else {
                            throw DecodingError.typeMismatch(
                                ItemWrapper.self,
                                DecodingError.Context(
                                    codingPath: decoder.codingPath,
                                    debugDescription: "Expected single MenuItem or array of MenuItem."
                                )
                            )
                        }
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        if item.count == 1 {
                            try container.encode(item[0]) // Encode as a single item if there's only one
                        } else {
                            try container.encode(item) // Encode as an array if there are multiple items
                        }
                    }
                }
                
                struct MenuItem: Codable {
                    var name: String?
                    var itemsize: ItemSize? //added

                    
                    
                }
            }
            //end of array vs single item decoding
        }
    }
    
    
    

    
    
    // Struct for Nutrition (only 4 macros)
    struct Nutrition: Codable {
        var pro: String?  // Protein
        var fat: String?  // Fat
        var cho: String?  // Carbohydrates
        var kcal: String? // Calories
        
        // Initialize with default values
        init(from nutritionDict: [String: String]? = nil) {
            self.pro = nutritionDict?["pro"] ?? "0gm"
            self.fat = nutritionDict?["fat"] ?? "0gm"
            self.cho = nutritionDict?["cho"] ?? "0gm"
            self.kcal = nutritionDict?["kcal"] ?? "0kcal"
        }
    }

    // Struct for ItemSize, including Nutrition
    struct ItemSize: Codable {
        var serving_size: String?   // Optional, in case it's missing
        var portion_size: String?  // Optional, in case it's missing
        var nutrition: Nutrition?  // Optional, in case it's missing or malformed
        
        enum CodingKeys: String, CodingKey {
            case serving_size
            case portion_size
            case nutrition
        }
        
        // Custom initializer to handle the case where `nutrition` might be an empty array
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.serving_size = try? container.decode(String.self, forKey: .serving_size)
            self.portion_size = try? container.decode(String.self, forKey: .portion_size)
            
            // Attempt to decode `nutrition` as a dictionary
            if let nutritionDict = try? container.decode([String: String].self, forKey: .nutrition) {
                self.nutrition = Nutrition(from: nutritionDict)
            } else if let nutritionArray = try? container.decode([String].self, forKey: .nutrition), nutritionArray.isEmpty {
                // If `nutrition` is an empty array, initialize it with default values
                self.nutrition = Nutrition()
            } else {
                // Default to empty nutrition if unable to decode
                self.nutrition = Nutrition()
            }
        }
    }

    
    
    

    

    var body: some View {

            VStack{
                ScrollView{
                    if let meals = menu?.meal{
                        if hallChanging == false{
                            ForEach(meals, id: \.name) { meal in
                                
                                if meal.course != nil {
                                    
                                    Text(meal.name?.lowercased().capitalized ?? "Unnamed Meal")
                                        
                                        .font(.largeTitle)
                                        .bold()
                                        .foregroundStyle(Color.white)
                                        .frame(width: 340, height: 60)
                                        .padding(.horizontal) // Add padding around the text
                                        .background(Color(.mBlue)) // Light gray background
                                        .cornerRadius(13) // Apply rounded corners
                                        
                                        .padding(.bottom, 8)
                                    
                                    
                                    
                                    
                                    
                                }
                                if let courses = meal.course?.courseitem {
                                    ForEach(courses, id: \.name) { course in
                                        VStack{
                                            HStack{
                                                Text(course.name ?? "Unnamed Course")
                                                    .foregroundStyle(Color.mmaize)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .padding(.leading, 15)
                                                //.underline(true)
                                                
                                                    .padding(.bottom, 4)
                                                    
                                                
                                                Spacer()
                                            }
                                            // Directly use `course.menuitem.item` without optional unwrapping
                                            
                                            ForEach(course.menuitem.item, id: \.name) { menuItem in
                                                
                                                VStack{
                                                    HStack{
                                                        Text(menuItem.name ?? "Unnamed MenuItem")
                                                            .font(. system(size: 14))
                                                            //.font(.title)
                                                            .padding(.leading, 15)
                                                            .fontWeight(.semibold)
                                                        
                                                        
                                                        
                                                        NavigationLink(destination: NutritionViewer(name: menuItem.name ?? "Unnamed MenuItem", kcal: menuItem.itemsize?.nutrition?.kcal ?? "0kcal", pro: menuItem.itemsize?.nutrition?.pro ?? "0gm", fat: menuItem.itemsize?.nutrition?.fat ?? "0gm", cho: menuItem.itemsize?.nutrition?.cho ?? "0gm", serving: menuItem.itemsize?.serving_size ?? "N/A")){
                                                            Image(systemName: "info.circle")
                                                                .resizable()
                                                                .frame(width: 17, height: 17)
                                                                
                                                            
                                                        }
                                                        Spacer()
                                                        if selectedItems.contains(menuItem.name ?? "") {
                                                            Picker("", selection: Binding(
                                                                get: { quantities[menuItem.name ?? ""] ?? "1" },
                                                                set: { quantities[menuItem.name ?? ""] = $0 }
                                                            )) {
                                                                ForEach(["0.5", "1", "2", "3", "4"], id: \.self) { q in
                                                                    Text(q).tag(q)
                                                                }
                                                                
                                                            }
                                                            
                                                            .accentColor(Color.black)
                                                        }


                                                        
                                                        Toggle(isOn: Binding(
                                                            get: { selectedItems.contains(menuItem.name ?? "") },
                                                            set: { isSelected in
                                                                if isSelected {
                                                                    selectedItems.insert(menuItem.name ?? "")
                                                                } else {
                                                                    selectedItems.remove(menuItem.name ?? "")
                                                                }
                                                            }
                                                        )) {
                                                            
                                                            Image(systemName: selectedItems.contains(menuItem.name ?? "") ? "checkmark.square.fill" : "square") // Empty square when unselected, filled when selected
                                                                .foregroundStyle(Color.mBlue)
                                                                                             
                                                                .animation(nil, value:selectedItems)
                                                            //.frame(height:25)
                                                                .font(.title)
                                                                
                                                        }
                                                        .sensoryFeedback(.increase, trigger: selectedItems)
                                                        .labelsHidden()
                                                        .toggleStyle(.button)
                                                        .padding(.trailing, 15)
                                                        .buttonStyle(.plain)
                                                        // Show Picker only when the Toggle is checked

                                                        
                                                        
                                                        
                                                    }
                                                    Divider()
                                                }
                                            }
                                        }.padding(.bottom, 8)
                                    }
                                    
                                }
                            }
                        } else if jsonBug == true{
                            Text("Error fetching menus.\nPlease connect to the U-M Wifi.")
                                .foregroundStyle(Color.gray)
                                .padding()
                        }
                                
                        else {
                            ProgressView()
                                .padding(.top, 15)
                            Text("Loading Menu...")
                                .foregroundStyle(Color.gray)
                        }
                    } else if jsonBug == true{
                        Text("Error fetching menus.\nPlease connect to the U-M Wifi.")
                            .foregroundStyle(Color.gray)
                            .padding()
                    }
                            
                    else {
                        ProgressView()
                            .padding(.top, 15)
                        Text("Loading Menu...")
                            .foregroundStyle(Color.gray)
                    }
                    
                }

                Spacer()
            } .onAppear{fetchData()}
            .onChange(of:addToMealButtonPressed) {
                saveSelectedItemsToDatabase()
            }
        
        
            
        
        
            
        
    }
    

    
    
    
}


#Preview {
    Selector(mealAddingTo: "Breakfast")
    //SpecialViewer(mealAddingTo: "Breakfast")
}

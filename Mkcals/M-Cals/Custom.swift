//
//  Custom.swift
//  M-Cals
//
//  Created by Grant Patterson on 1/21/25.
//

import SwiftUI
import Combine
struct Custom: View {
    enum FocusedField {
        case int, dec
    }
    //start copy
    @State var selectedDiningHall: String = UserDefaults.standard.string(forKey: "selectedDiningHall") ?? "Mosher Jordan Dining Hall"
    @State private var menu: Menu? // Store the fetched menu data
    @State var selectedMeal = "Breakfast"
    @State var jsonBug = false
    @State var hallChanging = false
    @EnvironmentObject var toggleManager: ToggleManager
    @Binding var quantities: [String: String]
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
        "Lawyers Club Dining Hall"
        
    ]
    
    // Update UserDefaults whenever the dining hall changes
    private func updateSelectedDiningHallCache() {
        UserDefaults.standard.set(selectedDiningHall, forKey: "selectedDiningHall")
    }
    
    
    //demo mode
    func loadDemoData() {
        preLoaded = true
        noMenuItems = false
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
            

            self.menu = itemFeed.menu
            
            print("Demo data loaded successfully.")
            hallChanging = false
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
                        hallChanging = false
                        preLoaded = false
                        
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
        guard let meals = menu?.meal else { return }
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

    
    
    

    

    
    
    
    
    
    
    
    //end of copy
    @Binding var selectedItems: Set<String>
    @State private var name: String = ""
    @State private var kcal: String = ""
    @State private var pro: String = ""
    @State private var fat: String = ""
    @State private var cho: String = ""
    @State private var qty: String = ""
    @State var mealAddingTo: String
    @FocusState private var focusedField: FocusedField?
    
    func saveTextFieldsToDatabase(name: String, kcal: String, pro: String, fat: String, cho: String, qty: String) {
        let mealName = mealAddingTo

        do {
            // Add meal to the database
            try DatabaseManager.addMeal(date: getCurrentDate(), mealName: mealName)
            
            // Retrieve the meal ID
            let mealID = try dbQueue.read { db in
                try Int.fetchOne(db, sql: "SELECT id FROM meals WHERE date = ? AND mealname = ?", arguments: [getCurrentDate(), mealName])
            }
            
            guard let validMealID = mealID else { return }
            
            // Validate and sanitize inputs
            let sanitizedName = name.isEmpty ? "Custom Item" : name
            let sanitizedKcal = (kcal.isEmpty ? "0" : kcal) + "kcal"
            let sanitizedPro = (pro.isEmpty ? "0" : pro) + "gm"
            let sanitizedFat = (fat.isEmpty ? "0" : fat) + "gm"
            let sanitizedCho = (cho.isEmpty ? "0" : cho) + "gm"
            let sanitizedQty = qty.isEmpty ? "1" : qty
            
            // Add the food item to the database
            try DatabaseManager.addFoodItem(
                meal_id: validMealID,
                name: sanitizedName,
                kcal: sanitizedKcal,
                pro: sanitizedPro,
                fat: sanitizedFat,
                cho: sanitizedCho,
                serving: "Custom",
                qty: sanitizedQty
            )
            
            print("Item successfully added to the database.")
        } catch {
            print("Failed to add item: \(error)")
        }
    }

    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    
                    TextField("Cheese", text: $name)
                        
                        .disableAutocorrection(true) // Disable autocorrection
                        .frame(width:150)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .int)
                        
                        .onReceive(Just(name)) { newValue in
                            let filtered = newValue.filter { "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 1234567890".contains($0) }
                            if filtered != newValue {
                                self.name = filtered
                            }
                        } .padding(.leading, 100)
                        
                    
                    Text("Name")
                    Spacer()
                }.padding(.top, 100)
                HStack{
                    
                    TextField("0", text: $kcal)
                        
                        
                        .frame(width:100)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .int)
                        .keyboardType(.numberPad)
                        .onReceive(Just(kcal)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.kcal = filtered
                            }
                        } .padding(.leading, 100)
                    
                    Text("Calories (kcal)")
                    Spacer()
                }
                HStack{
                    
                    TextField("0", text: $pro)
                        
                        .frame(width:100)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .int)
                        .keyboardType(.numberPad)
                        .onReceive(Just(pro)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.pro = filtered
                            }
                        }
                        .padding(.leading, 100)
                    Text("protein (g)")
                    
                    Spacer()
                }
                HStack{
                    
                    TextField("0", text: $fat)
                        
                        .frame(width:100)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .int)
                        .keyboardType(.numberPad)
                        .onReceive(Just(fat)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.fat = filtered
                            }
                        }
                        .padding(.leading, 100)
                    Text("Fat (g)")
                    Spacer()
                }
                HStack{
                    
                    TextField("0", text: $cho)
                        
                        .frame(width:100)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .int)
                        .keyboardType(.numberPad)
                        .onReceive(Just(cho)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.cho = filtered
                            }
                        }
                        .padding(.leading, 100)
                    Text("Carbs (g)")
                    Spacer()
                }
                HStack{
                    
                    TextField("1", text: $qty)
                        
                        .frame(width:100)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .int)
                        .keyboardType(.numberPad)
                        .onReceive(Just(qty)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.qty = filtered
                            }
                        }
                        .padding(.leading, 100)
                    Text("Quantity (int)")
                    Spacer()
                }
                NavigationLink(destination: Homepage()){
                    HStack{
                        /*Text("Add to \(mealAddingTo)")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.mBlue)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.mBlue)*/
                        Text("Add to \(mealAddingTo)")
                            //.font(.title3)
                            .foregroundStyle(Color.white)
                            
                            .frame(width: 150.0, height: 50.0)
                                .background(Color.mBlue)
                                .cornerRadius(13)
                                .padding(5)
                                .padding(.top, 15)
                    }
                    
                }   .simultaneousGesture(TapGesture().onEnded {
                    saveTextFieldsToDatabase(name: name, kcal: kcal, pro: pro, fat: fat, cho: cho, qty: qty)
                    saveSelectedItemsToDatabase()
                    
                })
                Text("(also adds selected items on previous page)")
                    .italic()
                    .frame(width: 200)
                    .foregroundStyle(.gray)
                    .padding(.top, 15)
                Spacer()
            } .onAppear {
                fetchData()
            }
            
            
            
        }.navigationTitle("Add Custom Item")
            .navigationBarTitleDisplayMode(focusedField == nil ? .large : .inline)
            .toolbar{
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName:"keyboard.chevron.compact.down")
                    }
                }
                
            }
            
    }
}
/*
#Preview {
    Custom(mealAddingTo: mealAddingTo)
}*/

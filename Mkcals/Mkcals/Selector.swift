//
//  Selector.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/18/24.
//

import SwiftUI

import GRDB

var dbQueue: DatabaseQueue!

class DatabaseManager {

    static func setup(for application: UIApplication) throws {
        let databaseURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("datab2.sqlite")
        
        dbQueue = try DatabaseQueue(path: databaseURL.path)
        
        
        // make table
        
        try dbQueue.write { db in
            try db.create(table: "meals", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("date", .text).notNull() // yyyy-mm-dd
                t.column("mealname", .text).notNull() // breakfast, lunch, dinner, or other
            }
        }
        
        try dbQueue.write { db in
            try db.create(table: "fooditems", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("meal_id", .integer).notNull() //foriegn key links to specific meal.id
                    .references("meals", onDelete: .cascade)
                t.column("name", .text).notNull() // yyyy-mm-dd
                t.column("kcal", .integer).notNull() //Calories
                t.column("pro", .integer).notNull() //protein
                t.column("fat", .integer).notNull() //total fat
                t.column("cho", .integer).notNull() //total carbs
            }
        }
        
    }
    
    static func addMeal(date: String, mealName: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT INTO meals (date, mealname) VALUES (?, ?)",
                arguments: [date, mealName]
            
            )
            
        }
    }
    
    static func addFoodItem(meal_id: Int, name: String, kcal: Int, pro: Int, fat: Int, cho: Int) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT INTO fooditems (meal_id, name, kcal, pro, fat, cho) VALUES (?, ?, ?, ?, ?, ?)",
                arguments: [meal_id, name, kcal, pro, fat, cho]
            
            )
            
        }
    }
    
    
}

class APIHandling {
    //get url and format it
    static func getURL (diningHall: String) -> String {
        return "https://api.studentlife.umich.edu/menu/xml2print.php?controller=print&view=json&location=\(diningHall.replacingOccurrences(of: " ", with: "%20"))"
    }
    

    
    

}




struct Selector: View {
    @State var selectedDiningHall = "Mosher Jordan Dining Hall"
    @State var mealAddingTo: String
    @State private var menu: Menu? // Store the fetched menu data
    @State private var selectedItems: Set<String> = [] // Set to store selected menu items
    
    let hallNames = [
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
    
    
    //api call
    func fetchData() {
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
                    
                    //print(itemFeed)
                } catch {
                    print("error: \(error)")
                }
                
            }
            
        }
        //make the API Call
        dataTask.resume()
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
        var pro: String  // Protein
        var fat: String  // Fat
        var cho: String  // Carbohydrates
        var kcal: String // Calories
        
        // Initialize with default values
        init(from nutritionDict: [String: String]? = nil) {
            self.pro = nutritionDict?["pro"] ?? "0"
            self.fat = nutritionDict?["fat"] ?? "0"
            self.cho = nutritionDict?["cho"] ?? "0"
            self.kcal = nutritionDict?["kcal"] ?? "0"
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
        NavigationStack{
            VStack{
                HStack{
                    Picker("Select Dining Hall", selection: $selectedDiningHall) {
                        ForEach(hallNames, id: \.self) { hall in
                            Text(hall).tag(hall)
                        }
                        .onChange(of: selectedDiningHall) { oldValue, newValue in
                            fetchData()
                        }
                    }
                    .padding(.top, 12)
                    .padding(.leading,12)
                    
                    
                    
                        
                        
                    Spacer()
                }
                ScrollView{
                    if let meals = menu?.meal {
                        ForEach(meals, id: \.name) { meal in
                            if meal.course != nil {
                                Text(meal.name?.lowercased().capitalized ?? "Unnamed Meal")
                                    
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(Color.mBlue)
                                    .underline(true)
                                    .padding(.bottom, 6)
                            }
                            if let courses = meal.course?.courseitem {
                                ForEach(courses, id: \.name) { course in
                                    VStack{
                                        HStack{
                                            Text(course.name ?? "Unnamed Course")
                                                .foregroundStyle(Color.mmaize)
                                                .font(.title2)
                                                .bold()
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
                                                        .padding(.leading, 15)
                                                        .fontWeight(.semibold)
                                                    Spacer()
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
                                                            //.frame(height:25)
                                                            //.font(.largeTitle)
                                                    }
                                                    .labelsHidden()
                                                    .toggleStyle(.button)
                                                    .padding(.trailing, 15)
                                                
                                                    
                                                }
                                                Divider()
                                            }
                                        }
                                    }.padding(.bottom, 8)
                                }
                                
                            }
                        }
                    }
                }

                Spacer()
            } .onAppear{fetchData()}
            
        }.navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationLink(destination: Homepage()){
                
                Text("Add to \(mealAddingTo)")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mBlue)
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.mBlue)
            }
        }
        
            
        
    }
}

#Preview {
    Selector(mealAddingTo: "Breakfast")
}

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
        var course: [Course]?
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
    
    
    struct ItemSize: Codable {
        var nutrition: Nutrition?
    }
    struct Nutrition: Codable {
        var pro: String?
        var fat: String?
        var cho: String?
        var kcal: String?
        
    }
    
    
    

    

    
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Picker("Select Dining Hall", selection: $selectedDiningHall) {
                        ForEach(hallNames, id: \.self) { hall in
                            Text(hall).tag(hall)
                        }
                    }.padding()
                        
                        
                    Spacer()
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

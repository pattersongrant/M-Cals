//
//  Homepage.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/14/24.
//

import SwiftUI
import GRDB

struct Homepage: SwiftUI.View {


    
    var body: some SwiftUI.View {
        NavigationStack{
            TabView{
                Tracker()
                    .tabItem {
                        Label("Tracker", systemImage: "house")
                    }
                Info()
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                VStack{
                    Spacer()
                    HStack{
                        Text("M")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.mmaize)
                        Text("Cals")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.mBlue)
                    }
                    Spacer()
                    Setup()
                    Spacer()
                }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }.navigationBarBackButtonHidden()
    }
    struct Tracker: SwiftUI.View {

        // Define state variables to store food items for each meal
        @State private var breakfastItems: [FoodItem] = []
        @State private var lunchItems: [FoodItem] = []
        @State private var dinnerItems: [FoodItem] = []
        @State private var otherItems: [FoodItem] = []
        @State private var totalCalories: Int = 0
        @State private var totalProtein: Int = 0
        @State private var totalFat: Int = 0
        @State private var totalCarbs: Int = 0

        
        struct FoodItem: Identifiable {
            let id: Int64
            let name: String
            let kcal: String
            let pro: String
            let fat: String
            let cho: String
        }
        
        // Function to get current date in yyyy-MM-dd format
        public func getCurrentDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDate = Date()
            return dateFormatter.string(from: currentDate)
        }
        
        /*func GetTotalCalories(bitems: [FoodItem] = [], litems: [FoodItem] = [], ditems: [FoodItem] = [], oitems: [FoodItem] = []) -> Int {
            // Initialize the total calories counter
            var total = 0
            
            // Helper function to sum calories from an array of food items
            func sumCalories(from items: [FoodItem]) {
                for item in items {
                    // Convert the kcal string to an integer and add it to the total
                    if let kcalValue = Int(item.kcal.dropLast(4)) {
                        total += kcalValue
                    }
                }
            }
            
            // Sum calories for each meal
            sumCalories(from: bitems)  // Breakfast items
            sumCalories(from: litems)  // Lunch items
            sumCalories(from: ditems)  // Dinner items
            sumCalories(from: oitems)  // Other items
            print(total)
            
            return total
        }*/
        func GetTotalNutrient(bitems: [FoodItem] = [], litems: [FoodItem] = [], ditems: [FoodItem] = [], oitems: [FoodItem] = [], nutrientKey: String) -> Int {
            // Initialize the total counter
            var total = 0
            
            // Helper function to sum nutrient values from an array of food items
            func sumNutrient(from items: [FoodItem], key: String) {
                for item in items {
                    // Dynamically access the nutrient value based on the key
                    let nutrientValue: String
                    switch key {
                    case "kcal":
                        nutrientValue = String(item.kcal.dropLast(4))
                    case "pro":
                        nutrientValue = String(item.pro.dropLast(2))
                    case "fat":
                        nutrientValue = String(item.fat.dropLast(2))
                    case "cho":
                        nutrientValue = String(item.cho.dropLast(2))
                    default:
                        nutrientValue = "0"
                    }
                    
                    // Convert the nutrient value string to an integer and add it to the total
                    if let nutrientIntValue = Int(nutrientValue.trimmingCharacters(in: .whitespaces)) {
                        total += nutrientIntValue
                    } else {
                        print("Invalid \(key) value: \(nutrientValue)")
                    }
                }
            }
            
            // Sum nutrients for each meal
            sumNutrient(from: bitems, key: nutrientKey)  // Breakfast items
            sumNutrient(from: litems, key: nutrientKey)  // Lunch items
            sumNutrient(from: ditems, key: nutrientKey)  // Dinner items
            sumNutrient(from: oitems, key: nutrientKey)  // Other items
            
            return total
        }

        

        

        
        // Fetch food items for a specific meal
        public func getFoodItemsForMeal(mealname: String, completion: @escaping ([FoodItem]) -> Void) {
            do {
                let currentDate = getCurrentDate()
                let mealType = mealname
                
                try dbQueue.read { db in
                    let query = """
                    SELECT fooditems.*
                    FROM meals
                    JOIN fooditems ON fooditems.meal_id = meals.id
                    WHERE meals.date = ? AND meals.mealname = ?
                    """
                    
                    let fetchedItems = try Row.fetchAll(db, sql: query, arguments: [currentDate, mealType])
                    
                    // Map the fetched rows to FoodItem structs
                    let foodItems = fetchedItems.map { row in
                        FoodItem(
                            id: row["id"] as! Int64,
                            name: row["name"] as! String,
                            kcal: row["kcal"] as! String,
                            pro: row["pro"] as! String,
                            fat: row["fat"] as! String,
                            cho: row["cho"] as! String
                        )
                    }
                    completion(foodItems)
                }
            } catch {
                print("Error fetching food items: \(error.localizedDescription)")
            }
        }
        
        func DeleteItem(item: FoodItem){
            do {
                // Use the ID of the food item to delete it from the database
                try dbQueue.write { db in
                    try db.execute(
                        sql: "DELETE FROM fooditems WHERE id = ?",
                        arguments: [item.id]
                    )
                }

                // After deletion, update the local array by removing the item
                if let index = breakfastItems.firstIndex(where: { $0.id == item.id }) {
                    breakfastItems.remove(at: index)
                }

                if let index = lunchItems.firstIndex(where: { $0.id == item.id }) {
                    lunchItems.remove(at: index)
                }

                if let index = dinnerItems.firstIndex(where: { $0.id == item.id }) {
                    dinnerItems.remove(at: index)
                }

                if let index = otherItems.firstIndex(where: { $0.id == item.id }) {
                    otherItems.remove(at: index)
                }
            } catch {
                print("Error deleting food item: \(error.localizedDescription)")
            }
            totalCalories = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "kcal")
            totalProtein = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "pro")
            totalFat = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "fat")
            totalCarbs = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "cho")
            
            
        }
        var body: some SwiftUI.View {
            NavigationStack{
                VStack{
                    HStack{
                        Text("Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 25)
                            
                        Spacer()
                        Text("M")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.mmaize)
                        
                        Text("Cals")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.mBlue)
                            .padding( .trailing, 25.0)
                    }.padding(.bottom, 10)
                        .padding(.top,10)
                    HStack{
                        VStack{
                            Text("Calories")
                                .bold()
                            Text("\(totalCalories)")
                                
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                        VStack{
                            Text("Protein")
                                .bold()
                            Text("\(totalProtein)")
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                        VStack{
                            Text("Fat")
                                .bold()
                            Text("\(totalFat)")
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                        VStack{
                            Text("Carbs")
                                .bold()
                            Text("\(totalCarbs)")
                                
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                    }
                    ProgressView(value: (Double(totalCalories)/2000.0))
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 400)
                        .padding(6)
                    ScrollView{
                        VStack{
                            HStack{
                                Text("Breakfast")
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 123.0)
                                Spacer()
                                NavigationLink(destination:Selector(mealAddingTo: "Breakfast")){
                                    Image(systemName:"plus.app.fill")
                                        .resizable()
                                        .frame(width:35, height: 35)
                                        .foregroundStyle(Color.mmaize)
                                        .padding(16)
                                }
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            
                            ForEach(breakfastItems, id: \.id) { item in
                                HStack{
                                    
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash.square")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 25, height: 25)
                                    }
                                }.padding(.leading,15)
                                    .padding(.trailing,15)
                                    .padding(.vertical,8)
                                Divider()
                                    
                            }
                        }
                        VStack{
                            HStack{
                                Text("Lunch")
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 123.0)
                                Spacer()
                                NavigationLink(destination:Selector(mealAddingTo: "Lunch")){
                                    Image(systemName:"plus.app.fill")
                                        .resizable()
                                        .frame(width:35, height: 35)
                                        .foregroundStyle(Color.mmaize)
                                        .padding(16)
                                }
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            
                            ForEach(lunchItems, id: \.id) { item in
                                HStack{
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash.square")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 25, height: 25)
                                    }
                                }.padding(.leading,15)
                                    .padding(.trailing,15)
                                    .padding(.vertical,8)
                                Divider()
                                    
                            }
                        }
                        
                        VStack{
                            HStack{
                                Text("Dinner")
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 123.0)
                                Spacer()
                                NavigationLink(destination:Selector(mealAddingTo: "Dinner")){
                                    Image(systemName:"plus.app.fill")
                                        .resizable()
                                        .frame(width:35, height: 35)
                                        .foregroundStyle(Color.mmaize)
                                        .padding(16)
                                }
                                
                                
                                
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            ForEach(dinnerItems, id: \.id) { item in
                                HStack{
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash.square")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 25, height: 25)
                                    }
                                }.padding(.leading,15)
                                    .padding(.trailing,15)
                                    .padding(.vertical,8)
                                Divider()
                                    
                            }
                            
                            
                        }
                        VStack{
                            HStack{
                                Text("Other")
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 123.0)
                                Spacer()
                                NavigationLink(destination:Selector(mealAddingTo: "Other")){
                                    Image(systemName:"plus.app.fill")
                                        .resizable()
                                        .frame(width:35, height: 35)
                                        .foregroundStyle(Color.mmaize)
                                        .padding(16)
                                }
                                
                                
                                
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            ForEach(otherItems, id: \.id) { item in
                                HStack{
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")
                                    
                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            
                                        
                                    }
                                    Spacer()
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash.square")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 25, height: 25)
                                    }
                                        
                                        
 
                                }.padding(.leading,15)
                                    .padding(.trailing,15)
                                    .padding(.vertical,8)
                                    
                                Divider()
                                    
                            }
                            
                            
                        }
                        
                    } 
                }
                .onAppear {
                    // Fetch food items for each meal when the view appears
                    getFoodItemsForMeal(mealname: "Breakfast") { items in
                        breakfastItems = items
                    }
                    getFoodItemsForMeal(mealname: "Lunch") { items in
                        lunchItems = items
                    }
                    getFoodItemsForMeal(mealname: "Dinner") { items in
                        dinnerItems = items
                    }
                    getFoodItemsForMeal(mealname: "Other") { items in
                        otherItems = items
                    }
                    totalCalories = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "kcal")
                    totalProtein = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "pro")
                    totalFat = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "fat")
                    totalCarbs = GetTotalNutrient(bitems: breakfastItems, litems: lunchItems, ditems: dinnerItems, oitems: otherItems, nutrientKey: "cho")
                }
                Spacer()
            }
        }
    }
}
struct NutritionViewer: SwiftUI.View {
    @State var name: String
    @State var kcal: String
    @State var pro: String
    @State var fat: String
    @State var cho: String
    var body: some SwiftUI.View {
        NavigationStack{
            VStack{
                Text(name).bold()
                    .font(.largeTitle)
                    .foregroundStyle(Color.black)
                    .padding(12)
                    
                Divider()
                    
                VStack{
                    HStack{
                        Text("Calories: " + kcal)
                        Spacer()
                    }
                    HStack{
                        Text("Protein: " + pro)
                        Spacer()
                    }
                    HStack{
                        Text("Fat: " + fat)
                        Spacer()
                    }
                    HStack{
                        Text("Carbs: " + cho)
                        Spacer()
                    }
                } .font(.title2)
                    .padding(.leading, 15)
                    .foregroundStyle(Color.mBlue)
                Spacer()
                HStack{
                    Text("M")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.mmaize)
                    Text("Cals")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.mBlue)
                }
                Spacer()
            }
        }.navigationBarTitleDisplayMode(.inline)
    }
    
}


struct Info: SwiftUI.View {
    var body: some SwiftUI.View {
        NavigationStack{
            HStack{
                Text("M")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.mmaize)
                    .padding(.leading, 25.0)
                Text("Cals")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mBlue)
            }.padding(.top, 50.0)
            Spacer()
            Text("MCals is an application created using the \nU-M Dining API to provide a way to easily track calories & macros from foods eaten in U-M dining halls.\n\nThis is not an official U-M application and is not affiliated with U-M in any way.")
                .padding(.bottom, 60.0)
                .padding(.horizontal, 25.0)
            Spacer()
        }
    }
}



#Preview {
    Homepage()
}

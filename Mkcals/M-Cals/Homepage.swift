//
//  Homepage.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/14/24.
//

import SwiftUI
import GRDB

struct Homepage: SwiftUI.View {
    @EnvironmentObject var toggleManager: ToggleManager
    @State private var showAlert: Bool = false // Control alert visibility
    
    var body: some SwiftUI.View {
        NavigationStack{
                TabView{
                    Tracker()
                        .tabItem {
                            Label("Tracker", systemImage: "house")
                        }
                    History()
                        .tabItem {
                            Label("History", systemImage: "calendar")
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
                        }.padding(.bottom, 28)
                        Spacer()
                        Setup()
                        Spacer()
                        /*HStack{
                            Text("Developer Mode (Keep off!): ")
                                .foregroundStyle(Color.mBlue)
                            Button(action: {
                                
                                showAlert = true
                            }) {
                                
                                Text(toggleManager.demoMode ? "ON" : "OFF") // Change button label based on state
                                
                                    .padding(6)
                                    .foregroundStyle(.white)
                                    .background(toggleManager.demoMode ? Color.mmaize : Color.mBlue)
                                    .cornerRadius(10)
                                
                            }.alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("This will stop menus from being up-to-date. You probably shouldn't turn this on."),
                                    primaryButton: .destructive(Text("Yes")) {
                                        print("Dev mode activated!")
                                        toggleManager.demoMode.toggle()
                                    },
                                    secondaryButton: .cancel() {
                                        print("Action cancelled.")
                                    }
                                )
                            }
                        }*/
                        //Spacer()
                    }
                    
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    
                }
            
        }.navigationBarBackButtonHidden()
    }

    struct History: SwiftUI.View {

        // Define state variables to store food items for each meal
        @State private var breakfastItems: [FoodItem] = []
        @State private var lunchItems: [FoodItem] = []
        @State private var dinnerItems: [FoodItem] = []
        @State private var otherItems: [FoodItem] = []
        @State private var totalCalories: Int = 0
        @State private var totalProtein: Int = 0
        @State private var totalFat: Int = 0
        @State private var totalCarbs: Int = 0
        @State private var CalorieGoal: Int64 = 2000
        @State private var selectedDate: Date = Date()

        
        // Function to get the current date in "yyyy-MM-dd" format
        private func formattedCurrentDate() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: selectedDate)
        }


        
        struct FoodItem: Identifiable {
            let id: Int64
            let name: String
            let kcal: String
            let pro: String
            let fat: String
            let cho: String
            let serving: String
            let qty: String
        }
        
        // Function to get current date in yyyy-MM-dd format
        public func getCurrentDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDate = Date()
            return dateFormatter.string(from: currentDate)
        }
        
        func GetTotalNutrient(bitems: [FoodItem] = [], litems: [FoodItem] = [], ditems: [FoodItem] = [], oitems: [FoodItem] = [], nutrientKey: String) -> Int {
            // Initialize the total counter
            var total = 0
            
            // Helper function to sum nutrient values from an array of food items
            func sumNutrient(from items: [FoodItem], key: String) {
                for item in items {
                    // Dynamically access the nutrient value based on the key
                    let nutrientValue: String
                    let qty = Double(item.qty) ?? 1
                    
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
                    if let nutrientDoubValue = Double(nutrientValue.trimmingCharacters(in: .whitespaces)) {
                        total += Int(nutrientDoubValue * qty)
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

        
        func getCurrentCalorieGoal() {
            do {
                try dbQueue.read { db in
                    // Select the firstSetupComplete value from the user table
                    let result = try Row.fetchOne(db, sql: "SELECT caloriegoal FROM user WHERE id = 1")
                    
                    // If the result exists and the value is 1 (true), update the state
                    if let result = result{
                        if let goal = result["caloriegoal"]{
                            //print(goal)  // This will print calorie goal
                            CalorieGoal = goal as! Int64
                            
                        }
                        
                    }
                }
            } catch {
                print("Error fetching caloriegoal: \(error)")
            }
        }
        

        
        // Fetch food items for a specific meal
        public func getFoodItemsForMeal(mealname: String, completion: @escaping ([FoodItem]) -> Void) {
            do {
                let currentDate = formattedCurrentDate()
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
                            cho: row["cho"] as! String,
                            serving: row["serving"] as! String,
                            qty: row["qty"] as! String
                        )
                    }
                    completion(foodItems)
                }
            } catch {
                print("Error fetching food items: \(error.localizedDescription)")
            }
        }
        
        func formatNumberWithCommas(_ number: Int) -> String? {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal  // This adds commas
            return numberFormatter.string(from: NSNumber(value: number))
        }
        
        
        private func refreshView() {
            getCurrentCalorieGoal()
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
            // Recalculate totals after fetching new data
            totalCalories = GetTotalNutrient(
                bitems: breakfastItems,
                litems: lunchItems,
                ditems: dinnerItems,
                oitems: otherItems,
                nutrientKey: "kcal"
            )
            totalProtein = GetTotalNutrient(
                bitems: breakfastItems,
                litems: lunchItems,
                ditems: dinnerItems,
                oitems: otherItems,
                nutrientKey: "pro"
            )
            totalFat = GetTotalNutrient(
                bitems: breakfastItems,
                litems: lunchItems,
                ditems: dinnerItems,
                oitems: otherItems,
                nutrientKey: "fat"
            )
            totalCarbs = GetTotalNutrient(
                bitems: breakfastItems,
                litems: lunchItems,
                ditems: dinnerItems,
                oitems: otherItems,
                nutrientKey: "cho"
            )
        }

        var body: some SwiftUI.View {
            NavigationStack{
                VStack{
                    VStack {
                        HStack{
                            VStack{
                                Text("Calories")
                                    .bold()
                                Text("\(totalCalories)")
                                    
                            }.font(.title3)
                                
                                .padding(.horizontal,6)
                            VStack{
                                Text("Protein")
                                    .bold()
                                Text("\(totalProtein)")
                            }.font(.title3)
                                
                                .padding(.horizontal,6)
                            VStack{
                                Text("Fat")
                                    .bold()
                                Text("\(totalFat)")
                            }.font(.title3)
                                
                                .padding(.horizontal,6)
                            VStack{
                                Text("Carbs")
                                    .bold()
                                Text("\(totalCarbs)")
                                    
                            }.font(.title3)
                                
                                .padding(.horizontal,6)
                            VStack{
                                VStack{
                                    Text(String(formatNumberWithCommas(Int(CalorieGoal-Int64(totalCalories))) ?? ""))
                                        .bold()
                                        
                                    Text("Left")
                                        
                                        
                                }
                                .padding(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 0.5)
                                )
                                    
                                    
                                
                                
                                    
                            } .padding(.horizontal, 6)
                            
                        }
                        ProgressView(value: (Double(totalCalories)/Double(CalorieGoal)))
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 400)
                            .padding(6)

                        // DatePicker for selecting a date
                        DatePicker("Select Date:", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()

                    }

                    
                    ScrollView{
                        VStack{
                            
                            HStack{
                                Text("Breakfast")
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 123.0)
                                Spacer()
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            
                            ForEach(breakfastItems, id: \.id) { item in
                                HStack{
                                    
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)

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
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            
                            ForEach(lunchItems, id: \.id) { item in
                                HStack{
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                    
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
                                
                                
                                
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            ForEach(dinnerItems, id: \.id) { item in
                                HStack{
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                    
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
                                
                                
                                
                            }.foregroundStyle(Color.white)
                                .frame(width:360, height:60)
                                .background(Color.mBlue)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 13, height: 10)))
                            ForEach(otherItems, id: \.id) { item in
                                HStack{
                                    Text(item.name + " (\(item.kcal.dropLast(4)) Cal)")
                                    
                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                   
                                        
                                        
 
                                }.padding(.leading,15)
                                    .padding(.trailing,15)
                                    .padding(.vertical,8)
                                    
                                Divider()
                                    
                            }
                            
                            
                        }

                    }
                    
                }
                .onAppear {
                    refreshView()
                }
                .onChange(of: selectedDate) { oldValue, newValue in
                    refreshView()
                }
                
                Spacer()
            }
        }
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
        @State private var CalorieGoal: Int64 = 2000


        
        struct FoodItem: Identifiable {
            let id: Int64
            let name: String
            let kcal: String
            let pro: String
            let fat: String
            let cho: String
            let serving: String
            let qty: String
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
                    let qty = Double(item.qty) ?? 1
                    
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
                    if let nutrientDoubValue = Double(nutrientValue.trimmingCharacters(in: .whitespaces)) {
                        total += Int(nutrientDoubValue * qty)
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

        
        func getCurrentCalorieGoal() {
            do {
                try dbQueue.read { db in
                    // Select the firstSetupComplete value from the user table
                    let result = try Row.fetchOne(db, sql: "SELECT caloriegoal FROM user WHERE id = 1")
                    
                    // If the result exists and the value is 1 (true), update the state
                    if let result = result{
                        if let goal = result["caloriegoal"]{
                            //print(goal)  // This will print calorie goal
                            CalorieGoal = goal as! Int64
                            
                        }
                        
                    }
                }
            } catch {
                print("Error fetching caloriegoal: \(error)")
            }
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
                            cho: row["cho"] as! String,
                            serving: row["serving"] as! String,
                            qty: row["qty"] as! String
                        )
                    }
                    completion(foodItems)
                }
            } catch {
                print("Error fetching food items: \(error.localizedDescription)")
            }
        }
        
        func formatNumberWithCommas(_ number: Int) -> String? {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal  // This adds commas
            return numberFormatter.string(from: NSNumber(value: number))
        }
        
        func DeleteItem(item: FoodItem){
            do {
                // Use the ID of the food item to delete it from the e
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
                            
                            .padding(.horizontal,6)
                        VStack{
                            Text("Protein")
                                .bold()
                            Text("\(totalProtein)")
                        }.font(.title3)
                            
                            .padding(.horizontal,6)
                        VStack{
                            Text("Fat")
                                .bold()
                            Text("\(totalFat)")
                        }.font(.title3)
                            
                            .padding(.horizontal,6)
                        VStack{
                            Text("Carbs")
                                .bold()
                            Text("\(totalCarbs)")
                                
                        }.font(.title3)
                            
                            .padding(.horizontal,6)
                        VStack{
                            VStack{
                                Text(String(formatNumberWithCommas(Int(CalorieGoal-Int64(totalCalories))) ?? ""))
                                    .bold()
                                    
                                Text("Left")
                                    
                                    
                            }
                            .padding(5)
                            
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            
                            
                                
                        } .padding(.horizontal, 6)
                        
                    }
                    
                    
                    ProgressView(value: (Double(totalCalories)/Double(CalorieGoal)))
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

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                        
                                        
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 20, height: 25)
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

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 20, height: 25)
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

                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .font(.title)
                                            .frame(width: 20, height: 20)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 20, height: 25)
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
                                    
                                    NavigationLink(destination: NutritionViewer(name: item.name, kcal: item.kcal, pro: item.pro, fat: item.fat, cho: item.cho, serving: item.serving)){
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            
                                        
                                    }
                                    Spacer()
                                    Text("x" + item.qty)
                                        .padding(.trailing, 8)
                                    Button(action: {
                                        DeleteItem(item: item) // Call DeleteItem when the button is pressed
                                    }) {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .foregroundStyle(Color.mBlue)
                                            .frame(width: 20, height: 25)
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
                    getCurrentCalorieGoal()
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
    @State var serving: String
    var body: some SwiftUI.View {
        NavigationStack{
            VStack{
                Text(name).bold()
                    .font(.largeTitle)
                    //.foregroundStyle(Color.black)
                    .padding(12)
                    
                Divider()
                    
                VStack{
                    HStack{
                        Text("Serving: " + serving)
                        Spacer()
                    }
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
                    
                Text("Cals")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mBlue)
            }.padding(.top, 50.0)
            Spacer()
            Text("M-Cals is an application created using the \nU-M Dining API to provide a way to easily and more accurately track calories & macros from foods eaten in U-M dining halls.\n\nYou must be connected to the U-M WiFi for the app to function properly.\n\nM-Cals is not an official U-M application and is not affiliated with U-M in any way.\n\nDisclaimer: The calorie and nutrition information provided by this app is intended for general informational purposes only, and is not intended for use in managing medical conditions or making health decisions. \n\nAny questions can be directed to me at: pattgrantm@gmail.com")
                .padding(.bottom, 50.0)
                .padding(.horizontal, 25.0)
            Spacer()
            NavigationLink(destination: VStack {
                Text("We don't share any data with third-parties. The only data stored on the app are the foods and nutrients that you've tracked and your weight and calorie goal, all of which is stored locally on your device and not uploaded anywhere.\n\nDeleting the app will delete your stored data.").padding()
                Spacer()
            }.navigationTitle("Privacy Policy")
            ){
                Text("Privacy Policy")
                    .padding()
                    
                
            }
            Spacer()
        }
    }
}



#Preview {
    Homepage()
}

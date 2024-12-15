//
//  MkcalsApp.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/13/24.
//

import SwiftUI
import GRDB

@main
struct MkcalsApp: App {
    @State private var firstSetupComplete: Int64 = 0
    init() {
        setupDatabase()
    }
    
    func checkFirstSetupComplete() {
        do {
            try dbQueue.read { db in
                // Select the firstSetupComplete value from the user table
                let result = try Row.fetchOne(db, sql: "SELECT firstSetupComplete FROM user WHERE id = 1")
                
                // If the result exists and the value is 1 (true), update the state
                if let result = result{
                    if let firstSetupCompleteValue = result["firstSetupComplete"]{
                        //print(firstSetupCompleteValue)
                        firstSetupComplete = firstSetupCompleteValue as! Int64
                        
                    }
                    
                }
            }
        } catch {
            print("Error fetching firstSetupComplete: \(error)")
        }
    }
    
    private func setupDatabase() {
        do {
            try DatabaseManager.setup(for: UIApplication.shared)
            print("Database setup successfully")
        } catch {
            print("Error setting up database: \(error)")
        }
    }
    var body: some Scene {
        WindowGroup {
            ZStack{
                if firstSetupComplete==0{
                    ContentView()
                } else {
                    Homepage()
                }
            }.onAppear{
                checkFirstSetupComplete()
                
                
            }
        }
    }
} 
var dbQueue: DatabaseQueue!

class DatabaseManager {

    static func setup(for application: UIApplication) throws {
        let databaseURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("datab14.sqlite")
        
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
                t.column("kcal", .text).notNull() //Calories
                t.column("pro", .text).notNull() //protein
                t.column("fat", .text).notNull() //total fat
                t.column("cho", .text).notNull() //total carbs

            }
        }
        
        try dbQueue.write { db in
            try db.create(table: "user", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("weightplan", .text).notNull() //gain, maintain, or lose
                t.column("caloriegoal", .integer).notNull() //integer
                t.column("firstSetupComplete", .boolean).notNull()
                
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
    
    static func addFoodItem(meal_id: Int, name: String, kcal: String, pro: String, fat: String, cho: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT INTO fooditems (meal_id, name, kcal, pro, fat, cho) VALUES (?, ?, ?, ?, ?, ?)",
                arguments: [meal_id, name, kcal, pro, fat, cho]
            
            )
            
        }
    }
    
    
}

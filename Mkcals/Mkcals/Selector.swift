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
            .appendingPathComponent("datab.sqlite")
        
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
    
    
}





struct Selector: View {
    init() {
        
    }
    
    
    
    var body: some View {
        Text("Database testing.")
    }
}

#Preview {
    Selector()
}

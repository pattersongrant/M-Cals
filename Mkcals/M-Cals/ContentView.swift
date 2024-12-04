//
//  ContentView.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/13/24.
//

import SwiftUI
struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    Text("Welcome to ")
                        .font(.title)
                    Text("M")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.mmaize)
                    Text("Cals")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.mBlue)
                    Text("!")
                        .font(.title)
                    
                }
                Text("The best calorie tracker for \nU-M students.")
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 5)
                    .font(.title2)
                NavigationLink(destination: Setup().navigationBarBackButtonHidden(true))
                {
                    Text("Get Started")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                    
                        .frame(width: 200.0, height: 70.0)
                        .background(Color.mBlue)
                        .cornerRadius(13)
                        .padding()
                    
                    
                }
            }.onAppear {
                do {
                    try dbQueue.write { db in
                        // Check if the `user` table is empty
                        let rowCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM user") ?? 0
                        
                        if rowCount == 0 {
                            // Table is empty; insert default values
                            try db.execute(
                                sql: "INSERT INTO user (weightplan, caloriegoal, firstSetupComplete) VALUES ('maintain', 2000, false)"
                            )
                            print("Default user values initialized.")
                        } else {
                            print("User table already has entries; skipping initialization.")
                        }
                    }
                } catch {
                    print("Error initializing default user values: \(error)")
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    ContentView()
}

//
//  MkcalsApp.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/13/24.
//

import SwiftUI


@main
struct MkcalsApp: App {
    init() {
        setupDatabase()
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
            ContentView()
        }
    }
}

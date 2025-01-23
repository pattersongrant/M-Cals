//
//  Custom.swift
//  M-Cals
//
//  Created by Grant Patterson on 1/21/25.
//

import SwiftUI

struct Custom: View {
    @State private var name: String = ""
    @State private var kcal: String = ""
    @State private var pro: String = ""
    @State private var fat: String = ""
    @State private var cho: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Enter Int for kcal", text: $kcal)
                    .keyboardType(.numberPad)
            }
            
        }.navigationTitle("Add Custom Item")
            
    }
}

#Preview {
    Custom()
}

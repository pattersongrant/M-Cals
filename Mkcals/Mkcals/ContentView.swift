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
            }
            .padding()
        }
        
    }
}

#Preview {
    ContentView()
}

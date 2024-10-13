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
                    Text("kcals")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.mBlue)
                    Text("!")
                        .font(.title)
                        
                }
                Text("The best calorie tracker for U-M students.")
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .font(.title2)
                NavigationLink(destination: Setup().navigationBarBackButtonHidden(true)
                )
                {
                    Text("Get Started")
                        .font(.title2)
                    
                }
            }
            .padding()
        }
            
    }
}

#Preview {
    ContentView()
}

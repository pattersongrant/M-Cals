//
//  Setup.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/13/24.
//

import SwiftUI

struct Setup: View {
    var body: some View {
        NavigationStack{
            VStack {
                
                VStack{
                    NavigationLink(destination: ContentView()){
                        HStack{
                            HStack{
                                Text("Lose Weight")
                                    .frame(width: 90.0)
                                    .padding(10)
                                
                                Image(systemName:"arrowshape.up")
                                    .padding(.trailing, 10.0)
                                Spacer()
                                
                            }
                            
                            .frame(width: 150.0, height:80.0)
                            .background(Color.gray)
                            .foregroundStyle(.white)
                            .padding(10)
                            .cornerRadius(40)
                            Text("Track calories aiming for a calorie deficit.")
                                .foregroundStyle(Color.white)
                            Spacer()
                            
                            
                        }
                        
                        .frame(width: 370.0, height: 100.0)
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        
                        
                        
                    }
                    
                    NavigationLink(destination: ContentView()){
                        HStack{
                            HStack{
                                Text("Maintain Weight")
                                    .frame(width: 90.0)
                                
                                    .padding(10)
                                
                                Image(systemName:"arrowshape.right")
                                    .padding(.trailing, 10.0)
                                Spacer()
                                
                            }
                            
                            .frame(width: 150.0, height:80.0)
                            .background(Color.gray)
                            .foregroundStyle(.white)
                            .padding(10)
                            .cornerRadius(40)
                            Text("Track calories aiming for maintenance.")
                                .foregroundStyle(Color.white)
                            Spacer()
                            
                            
                        }
                        
                        .frame(width: 370.0, height: 100.0)
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        
                        
                        
                    }
                    NavigationLink(destination: ContentView()){
                        HStack{
                            HStack{
                                Text("Gain Weight")
                                    .frame(width: 90.0)
                                    .padding(10)
                                
                                Image(systemName:"arrowshape.up")
                                    .padding(.trailing, 10.0)
                                Spacer()
                                
                            }
                            
                            .frame(width: 150.0, height:80.0)
                            .background(Color.gray)
                            .foregroundStyle(.white)
                            .padding(10)
                            .cornerRadius(40)
                            Text("Track calories aiming for a calorie surplus.")
                                .foregroundStyle(Color.white)
                            Spacer()
                            
                            
                        }
                        
                        .frame(width: 370.0, height: 100.0)
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        
                        
                        
                    }
                }
                NavigationLink(destination: Unsure()){
                    HStack{
                        Image(systemName: "info.circle")
                        Text("I'm not sure")
                            .padding(.vertical, 35.0)
                    }
                    
                }
                
                
            }.navigationTitle("What is your goal?")
                .navigationBarTitleDisplayMode(.large)
                
            
        }
    }
}

struct Unsure: View {
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("We reccomend picking Maintain Weight if you're still deciding or if you're just here to track your nutrition. \n\n\nThis can always be changed in settings and is only used to tweak a few UI elements, so it's not too important.")
                    .multilineTextAlignment(.leading)
                    .padding(25)

                Spacer()
            }
        }.navigationTitle("Don't worry!")
            
        
        
    }
}

#Preview {
    Setup()
}

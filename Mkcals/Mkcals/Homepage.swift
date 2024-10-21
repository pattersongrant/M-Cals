//
//  Homepage.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/14/24.
//

import SwiftUI

import GRDB


struct Homepage: SwiftUI.View {
    var selectedItems: [String]
    var body: some SwiftUI.View {
        NavigationStack{
            TabView{
                Tracker(selectedItems: selectedItems)
                    .tabItem {
                        Label("Tracker", systemImage: "house")
                    }
                Info()
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
            }
        }.navigationBarBackButtonHidden()
        
        
    }
}
struct Tracker: SwiftUI.View {    
    var selectedItems: [String]
    var body: some SwiftUI.View {
        NavigationStack{
            
            
            VStack{
                HStack{
                    Text("Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(25)
                    Spacer()
                    Text("M")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.mmaize)
                        
                    Text("kcals")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.mBlue)
                        .padding(.trailing, 25.0)

  
 
                }
                Text("Today's Calories")
                
                ProgressView(value: 0.78)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 400)
                ScrollView{
                    VStack{
                        HStack{
                            Text("Breakfast")
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 123.0)
                            Spacer()
                            NavigationLink(destination:AddFood()){
                                Image(systemName:"plus.app.fill")
                                    .resizable()
                                    .frame(width:50, height: 50)
                                    .foregroundStyle(Color.mmaize)
                                    .padding(16)
                            }
                            
                            
                            
                        }.foregroundStyle(Color.white)
                            .frame(width:360, height:70)
                            .background(Color.mBlue)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                        
                        HStack{
                            
                            
                            
                            VStack {
                                ForEach(selectedItems, id: \.self) { item in
                                    HStack{
                                        Text(item)
                                            .padding(25)
                                        
                                        
                                        Spacer()
                                        Text("500")
                                    }.frame(width: 370.0, height: 25.0)
                                    
                                    
                                    
                                    
                                }
                            }
                            .padding(.top, 10)
                            Spacer()
                        }
                        
                    }
                    VStack{
                        HStack{
                            Text("Lunch")
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 123.0)
                            Spacer()
                            NavigationLink(destination:AddFood()){
                                Image(systemName:"plus.app.fill")
                                    .resizable()
                                    .frame(width:50, height: 50)
                                    .foregroundStyle(Color.mmaize)
                                    .padding(16)
                            }
                            
                            
                            
                        }.foregroundStyle(Color.white)
                            .frame(width:360, height:70)
                            .background(Color.mBlue)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                        
                        HStack{
                            
                            
                            
                            VStack {
                                ForEach(selectedItems, id: \.self) { item in
                                    HStack{
                                        Text(item)
                                            .padding(25)
                                        
                                        
                                        Spacer()
                                        Text("500")
                                    }.frame(width: 370.0, height: 25.0)
                                    
                                    
                                    
                                    
                                }
                            }
                            .padding(.top, 10)
                            Spacer()
                        }
                        
                    }

                    VStack{
                        HStack{
                            Text("Dinner")
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 123.0)
                            Spacer()
                            NavigationLink(destination:AddFood()){
                                Image(systemName:"plus.app.fill")
                                    .resizable()
                                    .frame(width:50, height: 50)
                                    .foregroundStyle(Color.mmaize)
                                    .padding(16)
                            }
                            
                            
                            
                        }.foregroundStyle(Color.white)
                            .frame(width:360, height:70)
                            .background(Color.mBlue)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                        
                        HStack{
                            
                            
                            
                            VStack {
                                ForEach(selectedItems, id: \.self) { item in
                                    HStack{
                                        Text(item)
                                            .padding(25)
                                        
                                        
                                        Spacer()
                                        Text("500")
                                    }.frame(width: 370.0, height: 25.0)
                                    
                                    
                                    
                                    
                                }
                            }
                            .padding(.top, 10)
                            Spacer()
                        }
                        
                    }

                }
                
                
                
                
                Spacer()
                
            }
        }
        
        
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
                Text("kcals")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mBlue)
            }.padding(.top, 50.0)
            Spacer()
            Text("Mkcals is an application created using the \nU-M Dining API to provide a way to easily track calories & macros from foods eaten in University of Michigan dining halls.\n\nThis is not an official U-M application and is not affiliated with U-M in any way.")
                .padding(.bottom, 60.0)
                .padding(.horizontal, 25.0)
            Spacer()
        }
        
        
    }
}



#Preview {
    Homepage(selectedItems: ["Tofu", "Beef & Mushroom Burger w/ Cheese", "Hot Cereal", "Pancakes", "Homemade Apple Topping", "Pancakes"])
}

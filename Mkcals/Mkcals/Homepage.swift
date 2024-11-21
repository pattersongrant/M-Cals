//
//  Homepage.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/14/24.
//

import SwiftUI
struct Homepage: SwiftUI.View {
    var body: some SwiftUI.View {
        NavigationStack{
            TabView{
                Tracker()
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
    struct Tracker: SwiftUI.View {
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
                            Text("2000")
                                
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                        VStack{
                            Text("Protein")
                                .bold()
                            Text("120")
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                        VStack{
                            Text("Fat")
                                .bold()
                            Text("100")
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                        VStack{
                            Text("Carbs")
                                .bold()
                            Text("300")
                                
                        }.font(.title3)
                            
                            .padding(.horizontal,10)
                    }
                    ProgressView(value: (30/2000.0))
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
                Text("Cals")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mBlue)
            }.padding(.top, 50.0)
            Spacer()
            Text("MCals is an application created using the \nU-M Dining API to provide a way to easily track calories & macros from foods eaten in U-M dining halls.\n\nThis is not an official U-M application and is not affiliated with U-M in any way.")
                .padding(.bottom, 60.0)
                .padding(.horizontal, 25.0)
            Spacer()
        }
    }
}



#Preview {
    Homepage()
}

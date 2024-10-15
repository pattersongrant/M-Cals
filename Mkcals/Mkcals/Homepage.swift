//
//  Homepage.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/14/24.
//

import SwiftUI


struct Homepage: View {
    var body: some View {
        NavigationStack{
            TabView{
                Tracker()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                Info()
                    .tabItem {
                        Label("Home", systemImage: "info.circle")
                    }
            }
        }.navigationBarBackButtonHidden()
        
        
    }
}
struct Tracker: View {
    var body: some View {
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
                            NavigationLink(destination:ContentView()){
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
                            
                            Text("Example food")
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 25.0)
                                .padding(.vertical, 10.0)
                            Spacer()
                        }
                        
                    }
                }
                
                
                
                Spacer()
                
            }
        }
        
        
    }
}
struct Info: View {
    var body: some View {
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
            Text("Mkcals is an application created using this michigan-dining-api (https://github.com/anders617/michigan-dining-api) to provide a way to easily track calories & macros from foods eaten in University of Michigan dining halls.\n\nThis is not an official U-M application and is not affiliated with U-M in any way.")
                .padding(.bottom, 60.0)
                .padding(.horizontal, 25.0)
            Spacer()
        }
        
        
    }
}



#Preview {
    Homepage()
}

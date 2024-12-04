//
//  Setup.swift
//  Mkcals
//
//  Created by Grant Patterson on 10/13/24.
//

import SwiftUI

struct Setup: View {
    
    
    func saveWeightPlan(plan: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE user SET weightplan = ? WHERE id = 1",
                arguments: [plan]
            
            )
            
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                
                VStack{
                    
                    NavigationLink(destination: CalCount()){
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
                            .background(Color.mmaize)
                            .foregroundStyle(.black)
                            .padding(10)
                            .cornerRadius(40)
                            Text("Track calories aiming for a calorie surplus.")
                                .foregroundStyle(Color.white)
                            Spacer()
                            
                            
                        }
                        
                        .frame(width: 370.0, height: 100.0)
                        .background(Color.mBlue)
                        .cornerRadius(13)
                        
                        
                        
                        
                    }.simultaneousGesture(TapGesture().onEnded {
                        do {
                            try saveWeightPlan(plan: "gain")
                        } catch {
                            print("error saving: \(error)")
                        }
                    })
                    NavigationLink(destination: CalCount()){
                        HStack{
                            HStack{
                                Text("Maintain Weight")
                                    .frame(width: 90.0)
                                
                                    .padding(10)
                                
                                Image(systemName:"line.3.horizontal")
                                    .padding(.trailing, 10.0)
                                Spacer()
                                
                            }
                            
                            .frame(width: 150.0, height:80.0)
                            .background(Color.mmaize)
                            .foregroundStyle(.black)
                            .padding(10)
                            .cornerRadius(40)
                            Text("Track calories aiming for maintenance.")
                                .foregroundStyle(Color.white)
                            Spacer()
                            
                            
                        }
                        
                        .frame(width: 370.0, height: 100.0)
                        .background(Color.mBlue)
                        .cornerRadius(13)
                        
                        
                        
                        
                    } .simultaneousGesture(TapGesture().onEnded {
                        do {
                            try saveWeightPlan(plan: "maintain")
                        } catch {
                            print("error saving")
                        }
                    })
                    NavigationLink(destination: CalCount()){
                        HStack{
                            HStack{
                                Text("Lose Weight")
                                    .frame(width: 90.0)
                                    .padding(10)
                                
                                Image(systemName:"arrowshape.down")
                                    .padding(.trailing, 10.0)
                                Spacer()
                                
                            }
                            
                            .frame(width: 150.0, height:80.0)
                            .background(Color.mmaize)
                            .foregroundStyle(.black)
                            .padding(10)
                            .cornerRadius(40)
                            Text("Track calories aiming for a calorie deficit.")
                                .foregroundStyle(Color.white)
                            Spacer()
                            
                            
                        }
                        
                        .frame(width: 370.0, height: 100.0)
                        .background(Color.mBlue)
                        .cornerRadius(13)
                        
                        
                        
                        
                    } .simultaneousGesture(TapGesture().onEnded {
                        do {
                            try saveWeightPlan(plan: "lose")
                        } catch {
                            print("error saving")
                        }
                    })
                    
                    
                    
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
                
                Text("We reccomend picking Maintain Weight if you're still deciding or if you're just here to track your nutrition. \n\n\nThis can always be changed in settings.")
                    .multilineTextAlignment(.leading)
                    .padding(25)
                    .foregroundStyle(Color.mBlue)

                Spacer()
            }
        }.navigationTitle("Don't worry!")
            
        
        
    }
}


struct CalCount: View {
    @State private var number: Int = 2000
    
    func saveCalorieGoal(goal: Int) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE user SET caloriegoal = ?, firstSetupComplete = ? WHERE id = 1",
                arguments: [goal, true]
            
            )
            
        }
    }
    
    
    let kcalRange = Array(stride(from: 0, through: 10000, by: 50))
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("kcals/day", selection: $number) {
                    ForEach(kcalRange, id: \.self) { value in
                        Text("\(value)")
                    }
                }.pickerStyle(.wheel)
                    
                
                
                NavigationLink(destination: Homepage()){
                    Text("Looks good!")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        
                        .frame(width: 200.0, height: 70.0)
                            .background(Color.mBlue)
                            .cornerRadius(13)
                            .padding(5)
                } .simultaneousGesture(TapGesture().onEnded {
                    do {
                        try saveCalorieGoal(goal: number)
                    } catch {
                        print("error saving: \(error)")
                    }
                })
                
                NavigationLink(destination: CalHelp()){
                    HStack{
                        Image(systemName: "info.circle")
                        Text("I'm not sure")
                            .padding(.vertical, 35.0)
                    }
                    
                    
                }
                
            }
        }.navigationTitle("Calorie goal/day?")

            
            
        
        
    }
}

struct CalHelp: View {
    @State private var weight: Int = 140;
    @State var showMaint = false;
    let Range = Array(stride(from: 0, through: 1000, by: 5))
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Enter your weight to help calculate your calorie goal. (not saved anywhere!)")
                    .foregroundStyle(Color.mBlue)
                    .padding()
                Picker("kcals/day", selection: $weight) {
                    ForEach(Range, id: \.self) { value in
                        Text("\(value)")
                    }
                }.pickerStyle(.wheel)
                
                Button("Calculate") {
                    showMaint = true;
                    
                }
                if showMaint{
                    Text("Your maintenance calories are likely around \(weight*15).\n\nTo gain weight, add 300-500 Calories.\nTo lose weight, subtract 300-500 Calories.\nMore or less depending on how quickly you want to gain/lose weight.")
                        .padding()
                        .foregroundStyle(Color.mBlue)
                    
                }
                
                Spacer()
            }
        }.navigationTitle("Calorie Goal Help")
            
        
        
    }
}

#Preview {
    Setup()
}

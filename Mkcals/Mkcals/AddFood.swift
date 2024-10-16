import SwiftUI


struct AddFood: View {
    let urlString = "https://api.studentlife.umich.edu/menu/xml2print.php?controller=print&view=json&location=Mosher%20Jordan%20Dining%20Hall"
    init() {
    
    let url = URL(string: urlString)
    
    guard url != nil else {
        return
    }
    
    let session = URLSession.shared
    
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                
                let decoder = JSONDecoder()
                do {
                    
                    let foodFeed = try decoder.decode(FoodFeed.self, from: data!)
                    print(foodFeed)
                }
                catch {
                    print("error in JSON parsing \(error)")
                }
                
            }
            
            
        }
        dataTask.resume()
    }
    struct AddFood: View {
        var body: some View{
            Text("Hello World")
        }
    }



    struct FoodFeed: Codable {
        var menu:[Menu]?
        
    }

    struct Menu: Codable {
        var meal:[Meal]?
        
        
    }

    struct Meal: Codable {
        var name:String?
        var course:[Course]?
        
        
        
    }

    struct Course: Codable {
        var name:String?
        var menuitem:[MenuItem]?

    }


    struct MenuItem: Codable {
        var name:String?
    }



    #Preview {
        AddFood()
    }

    
    var body: some View{
        Text("Hello World")
    }
}



struct FoodFeed: Codable {
    var menu:[Menu]?
    
}

struct Menu: Codable {
    var meal:[Meal]?
    
    
}

struct Meal: Codable {
    var name:String?
    var course:[Course]?
    
    
    
}

struct Course: Codable {
    var name:String?
    var menuitem:[MenuItem]?

}


struct MenuItem: Codable {
    var name:String?
}



#Preview {
    AddFood()
}

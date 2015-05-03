// Playground - noun: a place where people can play

// Genetic Algorithm to the traveling salesmang problem (TSP)

import UIKit

//**************************************
/* EXTENSIONS */

extension Array {
    func shuffled() -> [T] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }

}

public class City : NSObject {
    
    var x:Int
    var y:Int
    
    // Construct a city at chosen x, y location
    init(x:Int, y:Int){
        self.x = Int(arc4random() % 200)
        self.y = Int(arc4random() % 200)
    }
    
    //Gets the distance to given city
    public func distanceTo(city:City) -> Double {
        let xDistance = self.x - city.x
        let yDistance = self.y - city.y
        
        let distance:Double = sqrt(Double( (xDistance * xDistance) + (yDistance * yDistance) ))
        
        return distance
    }
    
    public func getCityXY(){
        println("\(self.x), \(self.y)")
    }
    
}


public class TourManager {
    
    // Holds our cities
    class var destinationCities:[City] {
        get{
            return self.destinationCities
        }set{
            self.destinationCities = newValue
        }
    }
    
    // Adds a destination city
    public class func addCity(#city: City) {
        destinationCities.append(city)
    }
    
    // Get a city
    public class func getCity(index: Int) -> City {
        return destinationCities[index]
    }
    
    // Get the number of destination cities
    public class func numberOfCities() -> Int {
        return destinationCities.count
    }
    
}

public class Tour {
    
    // Holds our tour of cities
    private(set) var tour:[City]
    
    // Cache
    private(set) var fitness:Double = 0
    private(set) var distance:Int = 0
    
    init(){
        tour = [City]()
    }
    
    init(tour: [City]) {
        self.tour = tour
    }
    
    public func generateIndividual(){
        for var cityIndex:Int = 0; cityIndex < TourManager.numberOfCities(); cityIndex++ {
            setCity(tourPosition: cityIndex, city: TourManager.getCity(cityIndex))
        }
        //Ramdomly order the tour
        tour = tour.shuffled()
    }
    
    // Gets a city from the tour
    public func getCity(tourPosition: Int) -> City {
        return tour[tourPosition]
    }
    
    // Sets a city in a certain position within a tour
    public func setCity(#tourPosition:Int, city:City) {
        tour.insert(city, atIndex: tourPosition)
        
        //If the tours been altered we need to reset the fitness and distance
        fitness = 0
        distance = 0
    }
    
    // Gets the tours fitness
    func getFitness() -> Double {
        if fitness == 0 {
            fitness = 1 / Double(getDistance())
        }
        return fitness
    }
    
    func getDistance() -> Int {
        if distance == 0 {
            var tourDistance:Int = 0
            
            //Loop through our tour's cities
            for var cityIndex:Int = 0; cityIndex < tourSize(); cityIndex++ {
                
                //Get City we're travelling from
                var fromCity:City = getCity(cityIndex)
                
                // City we're travelling to
                var destinationCity:City
                
                //Check we're not on our tour's last city, if we are set our tour's final destination city to our starting city
                if cityIndex + 1 < tourSize() {
                    destinationCity = getCity(cityIndex + 1)
                }else{
                    destinationCity = getCity(0)
                }
                
                //Get the distance between the two cities
                tourDistance = tourDistance + Int(fromCity.distanceTo(destinationCity))
            }
            distance = tourDistance
        }
        return distance
    }
    
    public func tourSize() -> Int {
        return tour.count
    }
    
    //Check if the tour contains a city
    public func containsCity(city: City) -> Bool {
        return contains(tour, city)
    }
    
    public func gerGeneString() -> String {
        var geneString:String = "|"
        
        for var i:Int = 0; i < tourSize(); i++ {
            geneString = "\(geneString)\(getCity(i))|"
        }
        
        return geneString
    }
    
}









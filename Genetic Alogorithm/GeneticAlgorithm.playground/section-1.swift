// Playground - noun: a place where people can play

// Genetic Algorithm to the traveling salesmang problem (TSP)

import UIKit

public class City {
    
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

var c = City(x: 20, y: 20)
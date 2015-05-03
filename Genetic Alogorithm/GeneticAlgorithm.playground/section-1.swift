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
//        self.x = Int(arc4random() % 200)
//        self.y = Int(arc4random() % 200)
        self.x = x
        self.y = y
    }
    
    override init(){
        self.x = Int(arc4random() % 200)
        self.y = Int(arc4random() % 200)
        //self.x = x
        //self.y = y
    }

    
    //Gets the distance to given city
    public func distanceTo(city:City) -> Double {
        let xDistance = abs(self.x - city.x)
        let yDistance = abs(self.y - city.y)
        
        let distance:Double = sqrt(Double( (xDistance * xDistance) + (yDistance * yDistance) ))
        
        return distance
    }
    
    public func getCityXY(){
        println("\(self.x), \(self.y)")
    }
    
}

public class TourManager {
    
    // Holds our cities
    var destinationCities:[City] = [City]()
    
    // Adds a destination city
    public func addCity(#city: City) {
        destinationCities.append(city)
    }
    
    // Get a city
    public func getCity(index: Int) -> City {
        return destinationCities[index]
    }
    
    // Get the number of destination cities
    public func numberOfCities() -> Int {
        return destinationCities.count
    }
    
}

var t = TourManager()

public class Tour : NSObject {
    
    // Holds our tour of cities
    private(set) var tour:[City]
    
    // Cache
    private(set) var fitness:Double = 0
    private(set) var distance:Int = 0
    
    override init(){
        tour = [City]()
    }
    
    init(tour: [City]) {
        self.tour = tour
    }
    
    public func generateIndividual(){
        for var cityIndex:Int = 0; cityIndex < t.numberOfCities(); cityIndex++ {
            setCity(tourPosition: cityIndex, city: t.getCity(cityIndex))
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

public class Population {
    // Holds population of tours
    var tours:[Tour] = [Tour]()
    
    // Constructor
    init(initialize:Bool){
        
        //if we need to initialize a population of tours do so
        for var i = 0; i < populationSize(); i++ {
            var newTour = Tour()
            newTour.generateIndividual()
            saveTour(i, tour: newTour)
        }
    }
    
    //Saves a tour
    public func saveTour(index:Int, tour:Tour){
        //tours[index] = tour
        tours.insert(tour, atIndex: index)
    }
    
    //Gets population size
    public func populationSize() -> Int{
        return 2
    }
    
    //Gets the best tour in the population
    public func getFittest() -> Tour {
        
        var fittest = tours[0]
        
        // exectution was interrupted, reason: EXC_BAD_INSTRUCTION
        //Loop through individuals to find fittest
        for var i:Int = 1; i < populationSize(); i++ {
            if fittest.getFitness() <= getTour(i).getFitness() {
                fittest = getTour(i-1)
            }
        }
        return fittest
    }
    
    //Gets a tour from population
    public func getTour(index:Int) -> Tour {
        println(index)
        return tours[index]
    }
}

public class GineticAlgorithm {
    
    class var mutationRate:Double {
        get{
        return 0.015
        }
    }
    class var tournamentSize:Int {
        get{
            return 5
        }
    }
    class var elitism:Bool {
        get{
            return true
        }
    }

    //Evolves a population over one generation
    class func evolvePopulation(pop: Population) -> Population {
        
        var newPopulation = Population(initialize: false)
        
        //Keep our best indivisual if elitism is enabled
        var elitismOffset:Int = 0
        
        if elitism {
            newPopulation.saveTour(0, tour: pop.getFittest())
            elitismOffset = 1
        }
        
        //Crossover population
        //Loop over the new populations size and create indivisuals from current population
        for var i:Int = elitismOffset; i < newPopulation.populationSize(); i++ {
            //Select Parents
            var parent1 = tournamentSelection(pop)
            var parent2 = tournamentSelection(pop)
            
            //Crossover Parents
            //let child = cro
        }
        return newPopulation

    }
    
    class func tournamentSelection(pop:Population) -> Tour {
        //Create a tournament population
        var tournament = Population(initialize: false)
        
        for var i:Int = 0; i < tournamentSize; i++ {
            var ranId = Int(arc4random() % UInt32(pop.populationSize()))
            tournament.saveTour(i, tour: pop.getTour(ranId))
        }
        
        //Get the fittest tour
        var fittest = tournament.getFittest()
        return fittest
    }
    
}

public class TSP_GineticAlgorithm {
    
    //Create and add our cities
    
    
}

var city1 = City(x: 560,y: 200)
t.addCity(city: city1)
var city2 = City()
t.addCity(city: city2)
var city3 = City()
t.addCity(city: city3)
var city4 = City()
t.addCity(city: city4)
t.addCity(city: City())
t.addCity(city: City())
t.addCity(city: City())



//Initialize Population
var pop = Population(initialize: true)

//println("Initial Distance \(pop.getFittest().getDistance())")

//Evolve population for 100 generations
pop = GineticAlgorithm.evolvePopulation(pop)
for var i:Int = 0; i < 5; i++ {
    pop = GineticAlgorithm.evolvePopulation(pop)
}

println("FINAL DISTANCE = \(pop.getFittest().getDistance())")
println("SOLUTION: \(pop.getFittest())")

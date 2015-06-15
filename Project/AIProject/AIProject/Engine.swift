
//
//  Engine.swift
//  AIProject
//
//  Created by Muhammad Raza on 15/06/2015.
//  Copyright (c) 2015 Muhammad Raza. All rights reserved.
//

import UIKit

class Engine: NSObject {
    
}

public protocol Engine {
    //evolved
    typealias Individual:IndividualType
    //Population
    typealias Poplulation = [Individual]
    //respected their fitness
    typealias EvaluatedPopulation = [Score<Individual>]
    
    //initiate new arbitrary Individual
    typealias Factory = () -> Individual
    
    typealias Evaluation = (Individual, Poplulation) -> Fitness
    
    typealias Selection = (EvaluatedPopulation, FitnessKind, Int)
    
    typealias Operator = Poplulation -> Poplulation
    
    typealias Termination = IterationData<Individual> -> Bool
    
    var fitnessKind:FitnessKind { get }
    var factory:Factory { get }
    var evaluation:Evaluation { get }
    var selection:Selection { get }
    var op:Operator { get }
    var termination:Termination? { get }
    
    //iteration
    var iteration: (IterationData<Individual> -> Void)? { get }
    
    //starts the evolution process
    func evolve() -> Individual
    
}

public enum FitnessKind {
    case Natural
    case Inverted
    
    var comparsionOp:(lhs: Fitness, rhs: Fitness) -> Bool {
        switch self {
        case .Natural:
            return (>)
        case .Inverted:
            return (<)
        }
    }
    
    func adjustedFitness(fitness: Fitness) -> Fitness {
        switch self {
        case .Natural:
            return fitness
        case .Inverted:
            if fitness == 0 {
                return Double.infinity
            }else{
                return 1.0/fitness
            }
        }
    }
}

public typealias Fitness = Double

//Evaluated Individual
public struct Score<Individual:IndividualType>:Printable {
    let fitness:Fitness
    let individual:Individual
    
    public var description:String {
        return "\(self.individual):\(self.fitness)"
    }
    
    func fitterIndividual(fitnessKind:FitnessKind, other: Score<Individual>) -> Individual {
        if fitnessKind.comparsionOp(lhs: self.fitness, rhs: other.fitness){
            return self.individual
        }else{
            return other.individual
        }
    }
}

//stats regarding current state of evolution
public struct IterationData<I : IndividualType> : Printable {
    init(iterationNum: Int, pop:[Score<I>], fitnessKind: FitnessKind, config: Configuration){
        self.iterationNum = iterationNum
        
        let bestScore = pop.first!
        
        self.bestCandidate = bestScore.individual
        self.bestCandidateFitness = bestScore.fitness
        
        let stats = Stats(pop.map { $0.fitness } )
        
        self.fitnessMean = stats.airthmeticMean
        self.fitnesstStandardDeviation = stats.standardDeviation
        
        self.fitnessKind = fitnessKind
    }
    
    public let iterationNum:Int
    
    public let bestCandidate:I
    public let bestCandidateFitness:Fitness
    
    public let fitnessMean:Fitness
    
    public var description:String {
        return "--\(iterationNum) : \(bestCandidate)"
    }
}

/*"Primordial soup" is a term introduced by the Soviet biologist Alexander Oparin. In 1924, he proposed a theory of the origin of life on Earth through the transformation, during the gradual chemical evolution of molecules that contain carbon in the primordial soup.

Biochemist Robert Shapiro has summarized the "primordial soup" theory of Oparin and Haldane in its "mature form" as follows:[1]

Early Earth had a chemically reducing atmosphere.
This atmosphere, exposed to energy in various forms, produced simple organic compounds ("monomers").
These compounds accumulated in a "soup", which may have been concentrated at various locations (shorelines, oceanic vents etc.).
By further transformation, more complex organic polymers – and ultimately life – developed in the soup.*/
//from Wikipedia
public func primordialSoup<I:IndividualType>(size: Int, factory:()->) -> [I] {
    return (0..<size).map({ _ -> in
        factory()
    })
}

//
//stride: http://www.sdsc.edu/~allans/pap255.pdf : meaning :cross (an obstacle) with one long step.
public func evaluatePopulation<I:IndividualType>(population:[I], withStride stride:Int, evaluation:(I,[I]) -> Fitness) -> [Score<I>] {
    
    //threading
    let queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
    
    var scores = [Score<I>]()
    scores.reserveCapacity(population.count)
    
    let writeQueue = dispatch_queue_create("scores write queue", DISPATCH_QUEUE_SERIAL)
    
    let group = dispatch_group_create()
    
    let iterations = Int(population.count/stride)
    func evaluatePopulationClosure(idx:Int) -> (Void) {
        var j = Int(idx) * stride
        var jStop = j + stride
        
        for i in j..<jStop {
            dispatch_group_enter(group)
            let indivi = population[i]
            let fitness = evaluation(indivi, population)
            
            dispatch_async(writeQueue){
                scores.append((Score(fitness: fitness, individual: indivi)))
                dispatch_group_leave(group)
            }
        }
    }
    dispatch_apply(iterations, queue, evaluatePopulationClosure)
    //handle remainder
    dispatch_group_enter(group)
    dispatch_async(queue) {
        let startIdx = Int(iterations) * stride
        let remainder = lazy(population[startIdx..<population.count]).map { ind -> Score<I> in
            return Score(fitness: evaluation(indivi, population), individual: indivi)
        }
        dispatch_async(writeQueue) {
            scores.extend(remainder)
            dispatch_group_leave(group)
        }
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    
    return scores
}

//sort the evaluated population by fitness kind
public func sortEvaluatedPopulation<I:IndividualType>(population: [Score<I>], fitnessKind:FitnessKind) -> [Score<I>] {
    let sorted = population.sorted{ return fitnessKind.comparsionOp(lhs: $0.fitness, rhs: $1.fitness) }
    
    let fitnesses = population.map { $0.fitness }
    
    return sorted
}

//A Simple generational genetic engine implementation
public class SimpleEngine<I:IndividualType> : Engine {
    
    //MARK: Engune
    
    typealias Individual = I
    
    typealias Factory = () -> Individual
    
    typealias Population = [Individual]
    typealias EvaluatedPopulation = [Score<Individual>]
    
    typealias Evaluation = (Individual, Population) -> Fitness
    typealias Operator = Population -> Population
    typealias Selection = (EvaluatedPopulation, FitnessKind, Int) -> Population
    
    typealias op:Operator
    
    public let factory:Factory
    public let fitnessKind:FitnessKind
    public let selection:Selection
    public let op:Operator
    
    public let evaluation:Evaluation
    public let termination:Termination?
    public var iteration: (IterationData<Individual> -> Void)?
    
    public init(factor:Factory,
        evaluation:Evaluation,
        fitnessKind: FitnessKind,
        selection:Selection,
        op: Operator) {
            self.factory = factory
            self.evaluation = evaluation
            self.fitnessKind = fitnessKind
            self.selection = selection
            self.op = op
            self.config = Configuration()
    }
    
    public var config:Configuration
    
    public func evolve() -> Individual {
        let pop = primordialSoup(self.config.size, self.factory)
        
        var evaluatedPop = evaluatePopulation(pop, withStride: 25, self.evaluation)
        var sortedEvaluatedPop = sortEvaluatedPopulation(evaluatedPop, self.fitnessKind)
        
        var iterationIdx = 0
        
        var data = IterationData(iterationNum: iterationIdx, pop: sortedEvaluatedPop, fitnessKind: self.fitnessKind, config: self.config)
        self.iteration?(data)
        
        while(self.termination == nil || self.termination!(data) == false) {
            evaluatedPop = step(sortedEvaluatedPop)
            sortedEvaluatedPop = sortEvaluatedPopulation(evaluatedPop, self.fitnessKind)
            iterationIdx++
            
            data = IterationData(iterationNum: iterationIdx, pop: sortedEvaluatedPop, fitnessKind: self.fitnessKind, config:self.config)
            self.iteration?(data)
        }
        return data.bestCandidate
    }
    
    //Evolution iteration logic
    func step(pop: EvaluatedPopulation) -> EvaluatedPopulation {
        let elites = map(pop[0..<self.config.eliteCount]) {$0.individual}
        
        let normalCount = pop.count - elites.count
        var selectedPop = self.selection(pop, self.fitnessKind, normalCount)
        
        //parametrize?
        while selectedPop.count < normalCount {
            selectedPop += Selections.Random(pop, fitnessKind: self.fitnessKind, count: normalCount - selectedPop.count)
        }
        
        var mutatedPop = self.op(Array(selectedPop[0..<selectedPop.count]))
        //parametrize?
        while mutatedPop.count < normalCount {
            mutatedPop.append(self.factory())
        }
        
        let newPop = elites + mutatedPop
        let newEvaluatedPop = evaluatePopulation(newPop, withStride: 25, self.evaluation)
        
        return newEvaluatedPop
    }
}

//Simple Engine parametrization
public struct Configuration {
    public init() {}
    
    public var size = 250
    public var eliteCount = 1
}
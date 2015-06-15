
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
}
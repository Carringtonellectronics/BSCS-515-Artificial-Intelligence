//
//  Termination.swift
//  AIProject
//
//  Created by Muhammad Raza on 15/06/2015.
//  Copyright (c) 2015 Muhammad Raza. All rights reserved.
//

import UIKit

public struct TerminationConditions {
    public static func NumberOfIterations<I:IndividualType>(maxNum: Int)(data:IterationData<I>) -> Bool {
        return data.iterationNum >= maxNum
    }
    
    public static func OnDate<I : IndividualType>(date: NSDate)(data:IterationData<I>) -> Bool {
        return NSDate().earlierDate(date) == date
    }
    
    public static func FitnessThreshold<I : IndividualType>(threshold: Fitness, fitnessKind: FitnessKind)(data:IterationData<I>) -> Bool {
        return fitnessKind.comparsionOp(lhs: data.bestCandidateFitness, rhs: threshold)
    }
    
    public static func ReferenceIndividual<I : IndividualType where I : Comparable>(reference: I)(data:IterationData<I>) -> Bool {
        return data.bestCandidate == reference
    }
    
    @inline(__always) public static func Or<I : IndividualType>(#lhs: ((data:IterationData<I>) -> Bool), rhs: ((data:IterationData<I>) -> Bool))(data:IterationData<I>) -> Bool {
        return lhs(data: data) || rhs(data: data)
    }
    
    @inline(__always) public static func And<I : IndividualType>(#lhs: ((data:IterationData<I>) -> Bool), rhs: ((data:IterationData<I>) -> Bool))(data:IterationData<I>) -> Bool {
        return lhs(data: data) && rhs(data: data)
    }
    
    //TODO: Figure out a nice way to pass down the number of iterations that haven't passed the test so far
    //    static func AverageFitnessStagnation<I : IndividualType>(stagnantIterationsThreshold: Int)(data:IterationData<I>) -> Bool {
    //        return false
    //    }
    
    //TODO: Figure out a nice way to pass down the number of iterations that haven't passed the test so far
    //    static func BestCandidateStagnation<I : IndividualType>(stagnantIterationsThreshold: Int)(data:IterationData<I>) -> Bool {
    //        return false
    //    }
}

@inline(__always) public func &&&<I : IndividualType>(lhs: ((data:IterationData<I>) -> Bool), rhs: ((data:IterationData<I>) -> Bool)) -> (IterationData<I>) -> Bool {
    return TerminationConditions.And(lhs: lhs, rhs: rhs)
}

@inline(__always) public func |||<I : IndividualType>(lhs: ((data:IterationData<I>) -> Bool), rhs: ((data:IterationData<I>) -> Bool)) -> (IterationData<I>) -> Bool {
    return TerminationConditions.Or(lhs: lhs, rhs: rhs)
}
    
    /*@inline(__always) This attribute gives the compiler inlining hints. The valid values are __always and never. I don't think I'd use this one (especially __always) unless I was absolutely certain I needed it; the rules around it are not currently known. In limited testing it seems to work but YMMV.
    
    edit: To further explain: though LLVM has the concept of forced inlining, we don't currently know if this attribute actually maps to that directly. Nor do we know if there are size limits that will cause the compiler to ignore this and skip inlining. In theory it should have this behavior but I'm not going to promise anyone that it does.
    
    Note that @inline attributes are ignored in debug builds (when optimizations are turned off).*/
    
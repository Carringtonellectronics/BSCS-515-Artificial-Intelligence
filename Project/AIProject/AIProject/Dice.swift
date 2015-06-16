
//
//  Dice.swift
//  AIProject
//
//  Created by Muhammad Raza on 16/06/2015.
//  Copyright (c) 2015 Muhammad Raza. All rights reserved.
//

import UIKit
import Foundation

public typealias Probability = Double

public func coinFlip() -> Bool {
    return arc4random_uniform(2) == 0
}

func pickRandom<T>(from array: Array<T>) -> T {
    return array[Int(arc4random_uniform(UInt32(array.count)))]
}

func randomP() -> Probability {
    return random(from:0.0, to: 1.0)
}

func random(#from:Double, #to: Double) -> Double {
    return from + (to-from)*(Double(arc4random()) / Double(UInt32.max))
}

public func roll(probability: Probability) -> Bool {
    if (probability == 1.0) {
        return true
    } else if (probability == 0.0) {
        return false
    }
    
    let roll = randomP()
    return probability > roll
}

func chooseWithProbability<Result>(probability: Probability, f: () -> Result, g: () -> Result) -> Result {
    if roll(probability) {
        return f()
    } else {
        return g()
    }
}
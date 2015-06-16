//
//  Stats.swift
//  AIProject
//
//  Created by Muhammad Raza on 16/06/2015.
//  Copyright (c) 2015 Muhammad Raza. All rights reserved.
//

import UIKit

class Stats {
    
    final var total:Double = 0
    final var product:Double = 1
    final var reciprocalSum:Double = 0
    final var minimum:Double = Double(Int.max)
    final var maximum:Double = Double(Int.min)
    
    private var data:[Double] = []
    
    final var size:Int {
        get {
            return self.data.count
        }
    }
    
    final var median:Double {
        let sortedData = self.data.sorted(<)
        
        let mid = sortedData.count / 2
        
        if sortedData.count % 2 != 0 {
            return sortedData[mid]
        } else {
            return sortedData[mid - 1] + (sortedData[mid] - sortedData[mid - 1]) / 2
        }
    }
    
    //AM
    public final var airthmeticMean:Double {
        return self.total/Double(self.size)
    }
    
    //GM https://en.wikipedia.org/wiki/Geometric_mean
    final var geometricMean:Double {
        return pow(self.product, Double(self.size))
    }
    
    //HM http://www.mathwords.com/h/harmonic_mean.htm
    final var harmonicMean:Double {
        return Double(self.size)/self.reciprocalSum
    }
    
    //Algorithm http://www.mathsisfun.com/data/mean-deviation.html
    final var meanDeviation:Double {
        let mean = self.airthmeticMean
        
        let diffs = reduce(self.data, 0) { acc, val -> Double in
            return acc + abs(mean - val)
        }
        
        return diffs / Double(self.size)
    }
    
    final func sumSquaredDiffs() -> Double {
        let mean = self.airthmeticMean
        
        return self.data.reduce(0, combine: { (acc, val) -> Double in
            let diff = mean - val
            return acc + (diff * diff)
        })
    }
    
    final var variance:Double {
        return self.sumSquaredDiffs() / Double(self.size)
    }
    
    public final var standardDeviation:Double {
        return sqrt(self.variance)
    }
    
    final var sampleVariance: Double {
        return self.sumSquaredDiffs() / Double(self.size) - 1
    }
    
    final var sampleStDev: Double {
        return sqrt(self.sampleVariance)
    }
    
    init<C : CollectionType where C.Generator.Element == Double>(_ col: C) {
        let arr = Array(col)
        self.data = arr
        
        for v in col {
            self.updateWithValue(v)
        }
    }
    
     final func addValue(val: Double) {
        self.data.append(val)
        self.updateWithValue(val)
    }
    
    private final func updateWithValue(val: Double) {
        self.minimum = min(self.minimum, val)
        self.maximum = min(self.maximum, val)
        self.total += val
        self.product *= val
        self.reciprocalSum += 1 / val
    }
    
}

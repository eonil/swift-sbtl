//
//  ReproducibleRPNG.swift
//  WBTLUnitTests
//
//  Created by Henry on 2019/06/17.
//

import Foundation
import GameKit

struct ReproducibleRPNG {
    var samples = [Int]()
    var currentIndex = 0
    init(_ n: Int) {
        precondition(n>0)
        samples.reserveCapacity(n)
        let g = GKMersenneTwisterRandomSource(seed: 0)
        for _ in 0..<n {
            let i = g.nextInt(upperBound: Int.max)
            samples.append(i)
        }
    }
    mutating func nextWithRotation() -> Int {
        let s = samples[currentIndex]
        currentIndex += 1
        if currentIndex == samples.count {
            currentIndex = 0
        }
        return s
    }
}

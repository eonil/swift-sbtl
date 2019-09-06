//
//  ReproducibleRPNG.swift
//  SBTLTest
//
//  Created by Henry on 2019/06/17.
//

import Foundation
import GameKit

struct ReproducibleRPNG {
    private(set) var samples = [Int]()
    private(set) var currentIndex = 0
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
    mutating func nextWithRotation(in r: Range<Int>) -> Int {
        let c = r.count
        guard c > 0 else { return 0 }
        let n = nextWithRotation() % c
        return r.lowerBound + n
    }
}

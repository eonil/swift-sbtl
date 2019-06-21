//
//  SBTLMapMock.swift
//  SBTLMapTest
//
//  Created by Henry on 2019/06/21.
//

import Foundation
@testable import SBTL

struct SBTLMapMock {
    private(set) var rprng = ReproducibleRPNG(1024*1024)
    private(set) var sys = [Int:SBTLMockValue]()
    private(set) var impl = SBTLMap<Int,SBTLMockValue>()
    private var insertedKeys = [Int]()
    init() {
    }
    mutating func runRandom(_ n: Int) {
        for _ in 0..<n {
            stepRandom()
        }
    }
    mutating func stepRandom() {
        switch rprng.nextWithRotation() % 3 {
        case 0:     insertRandom()
        case 1:     updateRandom()
        case 2:     removeRandom()
        default:    fatalError()
        }
    }
    mutating func insertRandom() {
        let k = rprng.nextWithRotation()
        let v = rprng.nextWithRotation()
        sys[k] = SBTLMockValue(value: v)
        impl[k] = SBTLMockValue(value: v)
        precondition(impl[k]?.value == v)
        insertedKeys.append(k)
    }
    mutating func updateRandom() {
        guard insertedKeys.count > 0 else { return }
        let i = rprng.nextWithRotation(in: 0..<insertedKeys.count)
        let k = insertedKeys[i]
        let v = rprng.nextWithRotation()
        sys[k] = SBTLMockValue(value: v)
        impl[k] = SBTLMockValue(value: v)
        insertedKeys.remove(at: i)
        precondition(impl[k]?.value == v)
    }
    mutating func removeRandom() {
        guard insertedKeys.count > 0 else { return }
        let i = rprng.nextWithRotation(in: 0..<insertedKeys.count)
        let k = insertedKeys[i]
        sys[k] = nil
        impl[k] = nil
        precondition(impl[k] == nil)
        insertedKeys.remove(at: i)
    }
    mutating func validate() {
        precondition(sys.count == impl.count)
        for (k,v) in sys {
            precondition(impl[k] == v)
        }
        for (k,v) in impl {
            precondition(sys[k] == v)
        }
    }
}
extension SBTLMapMock {
    var sysSortedKVs: [(Int,Int)] {
        return sys.map({ k,v in (k,v.value) }).sorted(by: { a,b in a.0 < b.0 })
    }
    var implSortedKVs: [(Int,Int)] {
        return impl.map({ k,v in (k,v.value) }).sorted(by: { a,b in a.0 < b.0 })
    }
}

//struct SBTLMockKey: Equatable, Comparable {
//    var value = 0
//}
struct SBTLMockValue: SBTLValueProtocol, Equatable {
    var value = 0
    var sum: Int {
        return value
    }
}

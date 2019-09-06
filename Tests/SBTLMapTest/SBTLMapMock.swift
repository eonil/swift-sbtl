//
//  SBTLMapMock.swift
//  SBTLMapTest
//
//  Created by Henry on 2019/06/21.
//

import XCTest
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
    mutating func insert(_ k: Int, _ v: Int) {
        sys[k] = SBTLMockValue(value: v)
        impl[k] = SBTLMockValue(value: v)
        XCTAssertEqual(impl[k]?.value, v)
        insertedKeys.append(k)
    }
    mutating func insertRandom() {
        let k = rprng.nextWithRotation()
        let v = rprng.nextWithRotation()
        insert(k, v)
    }
    mutating func updateRandom() {
        guard insertedKeys.count > 0 else { return }
        let i = rprng.nextWithRotation(in: 0..<insertedKeys.count)
        let k = insertedKeys[i]
        let v = rprng.nextWithRotation()
        sys[k] = SBTLMockValue(value: v)
        impl[k] = SBTLMockValue(value: v)
        insertedKeys.remove(at: i)
        XCTAssertEqual(impl[k]?.value, v)
    }
    mutating func removeRandom() {
        guard insertedKeys.count > 0 else { return }
        let i = rprng.nextWithRotation(in: 0..<insertedKeys.count)
        let k = insertedKeys[i]
        sys[k] = nil
        impl[k] = nil
        XCTAssertEqual(impl[k]?.value, nil)
        insertedKeys.remove(at: i)
    }
    mutating func validate() {
        XCTAssertEqual(sys.count, impl.count)
        for (k,v) in sys {
            let a = impl[k] as SBTLMockValue?
            XCTAssertEqual(a, v)
        }
        for (k,v) in impl {
            let a = sys[k]
            XCTAssertEqual(a, v)
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

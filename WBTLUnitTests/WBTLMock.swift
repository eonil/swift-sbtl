//
//  WBTLMock.swift
//  WBTLUnitTests
//
//  Created by Henry on 2019/06/17.
//

import GameKit
@testable import WBTL

struct WBTLMock {
    private(set) var rprng = ReproducibleRPNG(1024*1024)
    private(set) var sys = [Int]()
    private(set) var impl = WBTL<Int>()

    init() {
    }
    mutating func random() -> Int {
        return rprng.nextWithRotation()
    }
    mutating func runRandom(_ n: Int) {
        for _ in 0..<n {
            stepRandom()
        }
    }
    mutating func stepRandom() {
        switch rprng.nextWithRotation() % 3 {
        case 0: insertRandom()
        case 1: replaceRandom()
        case 2: removeRandom()
        default: fatalError()
        }
    }
    mutating func insertRandom() {
        let v = rprng.nextWithRotation()
        let i = rprng.nextWithRotation() % (sys.count+1)
        sys.insert(v, at: i)
        impl.insert(v, at: i)
    }
    mutating func replaceRandom() {
        guard sys.count > 0 else { return }
        let v = rprng.nextWithRotation()
        let i = rprng.nextWithRotation() % sys.count
        sys[i] = v
        impl[i] = v
    }
    mutating func removeRandom() {
        guard sys.count > 0 else { return }
        let i = rprng.nextWithRotation() % sys.count
        sys.remove(at: i)
        impl.remove(at: i)
    }

    func sysIndexAndOffset(for w: Int) -> (index: Int, offset: Int) {
        var wa = 0
        for i in sys.indices {
            let a = wa
            let b = wa + sys[i]
            if (a..<b).contains(w) {
                return (i, w-a)
            }
            wa = b
            print("\(w), \((a..<b)), \(wa)")
        }
        fatalError()
    }
    func implIndexAndOffset(for w: Int) -> (index: Int, offset: Int) {
        return impl.indexAndOffset(for: w)
    }
}

extension WBTLMock {
    mutating func appendRandom() {
        let v = rprng.nextWithRotation()
        sys.append(v)
        impl.insert(v, at: impl.endIndex)
    }

}

extension WBTL {
    func countHeight() -> Int {
        switch content {
        case .leaf(_):
            return 1
        case .branch(let a, let b):
            return 1 + Swift.max(a.countHeight(), b.countHeight())
        }
    }
    func unbalanceNodePath() -> IndexPath? {
        switch content {
        case .leaf(_):
            return nil
        case .branch(let a, let b):
            if let idxp = a.unbalanceNodePath() {
                return [0] + idxp
            }
            if let idxp = b.unbalanceNodePath() {
                return [1] + idxp
            }
            let dt = abs(a.count.distance(to: b.count))
            if dt > leafNodeCapacity {
                return []
            }
            return nil
        }
    }
    func isWellBalanced() -> Bool {
        switch content {
        case .leaf(_):
            return true
        case .branch(let a, let b):
            guard a.isWellBalanced() else { return false }
            guard b.isWellBalanced() else { return false }
            let dt = abs(a.count.distance(to: b.count))
            return dt <= leafNodeCapacity
        }
    }
    func containsAnyEmptyLeaf() -> Bool {
        switch content {
        case .leaf(let a): return a.isEmpty
        case .branch(let a, let b): return a.containsAnyEmptyLeaf() || b.containsAnyEmptyLeaf()
        }
    }
}

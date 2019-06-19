//
//  main.swift
//  SBTLBenchmark
//
//  Created by Henry on 2019/06/17.
//

import Foundation
import GameKit
#if SWIFT_PACKAGE
import SBTL
#endif

extension Int: SBTLValueProtocol {
    public var sum: Int {
        return self
    }
}

let averageCount = 100
let outerLoopCount = 1_00
let innerLoopCount = 1_000

///
/// returns list of nanoseconds for each outer iteration.
///
func run(_ single_op: (Int) -> Void) -> [Double] {
    var data = [Double]()
    for i in 0..<outerLoopCount {
        let startTime = DispatchTime.now()
        for j in 0..<innerLoopCount {
            let k = i * innerLoopCount + j
            single_op(k)
        }
        let endTime = DispatchTime.now()
        let timeDelta = Int(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
        let timeDeltaSingleOp = Double(timeDelta) / Double(innerLoopCount)
        data.append(timeDeltaSingleOp)

        if (i+1) % (outerLoopCount/10) == 0 {
            let d = timeDelta / innerLoopCount
            print("  \(i+1)k: \(d.metricPrefixedNanoSeconds())")
        }
        if timeDelta > 50_000_000 {
            print(" iteration takes over 50ms. and too slow. cancel test.")
            return data
        }
    }
    return data
}

var db = DB(iterationCount: averageCount)

public protocol AAPerfMeasuringProtocol {
    associatedtype Element
    init()
    var count: Int { get }
    subscript(_ i: Int) -> Element { get set }
    mutating func insert(_ e: Element, at i: Int)
    @discardableResult
    mutating func remove(at i: Int) -> Element
}
extension Array: AAPerfMeasuringProtocol {}
extension List: AAPerfMeasuringProtocol {}
extension SBTL: AAPerfMeasuringProtocol {}

struct CRUDNames {
    var get: DB.Name
    var insert: DB.Name
    var update: DB.Name
    var remove: DB.Name
}

func runCRUDPackage<T>(_: T.Type, _ ns: CRUDNames) where T: AAPerfMeasuringProtocol, T.Element == Int {
    for i in 0..<averageCount {
        do {
            let n = ns.get
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            let ks = Array(0..<m).shuffled()
            var pd = T()
            for i in 0..<m {
                pd.insert(i, at: pd.count)
            }
            precondition(pd.count == m)

            var pd1 = pd
            let ss = run { i in
                let k = ks[i]
                let v = pd[k]
                pd1 = pd
                precondition(v == k)
                precondition(pd1.count == pd.count)
            }
            precondition(pd.count == m)
            precondition(pd1.count == pd.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
        do {
            // Insert at random position.
            let n = ns.insert
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            let vs = Array(0..<m).shuffled()
            var pd = T()
            var pd1 = pd // Keep one copy to test persistency.
            let ss = run { i in
                let v = vs[i]
                let k = pd.count == 0 ? 0 : v % pd.count
                pd.insert(v, at: k)
                pd1 = pd
            }
            precondition(pd.count == pd1.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
        do {
            let n = ns.update
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            let ks = Array(0..<m).shuffled()
            var pd = T()
            for i in 0..<m {
                pd.insert(i, at: pd.count)
            }
            precondition(pd.count == m)

            var pd1 = pd
            let ss = run { i in
                let k = ks[i]
                pd[k] = i
                pd1 = pd
                precondition(pd1.count == pd.count)
            }
            precondition(pd.count == m)
            precondition(pd1.count == pd.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
        do {
            // Remove at random position.
            let n = ns.remove
            print("[\(i)] \(n)")
            print("--------------------------------------------")
            let m = outerLoopCount * innerLoopCount
            var ks = Array(0..<m).shuffled()
            var pd = T()
            for i in 0..<m {
                pd.insert(i, at: pd.count)
            }
            precondition(pd.count == m)

            var pd1 = pd
            let ss = run { i in
                let k = ks.removeLast()
                let m = pd.count == 0 ? 0 : k % pd.count
                pd.remove(at: m)
                pd1 = pd
                precondition(pd.count == ks.count)
                precondition(pd1.count == pd.count)
            }
            precondition(pd.count == ks.count)
            precondition(pd1.count == pd.count)
            db.push(name: n, samples: ss)
            print("--------------------------------------------")
        }
    }
}

runCRUDPackage(Array<Int>.self, CRUDNames(
    get: .stdGet,
    insert: .stdInsert,
    update: .stdUpdate,
    remove: .stdRemove))
runCRUDPackage(List<Int>.self, CRUDNames(
    get: .btreeGet,
    insert: .btreeInsert,
    update: .btreeUpdate,
    remove: .btreeRemove))
runCRUDPackage(SBTL<Int>.self, CRUDNames(
    get: .sbtlGet,
    insert: .sbtlInsert,
    update: .sbtlUpdate,
    remove: .sbtlRemove))
db.print()

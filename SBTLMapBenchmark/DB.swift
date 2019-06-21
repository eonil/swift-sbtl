//
//  DB.swift
//  PD4PerfTool
//
//  Created by Henry on 2019/05/22.
//

import Foundation

struct MultiSample {
    private var samples = [Double]()
    mutating func push(_ v: Double) {
        samples.append(v)
    }
    var average: Double? {
        guard samples.count > 0 else { return nil }
        return samples.reduce(0, +) / Double(samples.count)
    }
}
enum DBColumnName: CustomStringConvertible {
    case stdGet
    case stdInsert
    case stdUpdate
    case stdRemove

    case btreeGet
    case btreeInsert
    case btreeUpdate
    case btreeRemove

    case sbtlGet
    case sbtlInsert
    case sbtlUpdate
    case sbtlRemove

    var description: String {
        switch self {
        case .stdGet:       return "Swift.Dictionary Get"
        case .stdInsert:    return "Swift.Dictionary Insert"
        case .stdUpdate:    return "Swift.Dictionary Update"
        case .stdRemove:    return "Swift.Dictionary Remove"
        case .btreeGet:     return "BTree.Map Get"
        case .btreeInsert:  return "BTree.Map Insert"
        case .btreeUpdate:  return "BTree.Map Update"
        case .btreeRemove:  return "BTree.Map Remove"
        case .sbtlGet:       return "SBTLMap Get"
        case .sbtlInsert:    return "SBTLMap Insert"
        case .sbtlUpdate:    return "SBTLMap Update"
        case .sbtlRemove:    return "SBTLMap Remove"
        }
    }
}
struct DB {
    typealias Name = DBColumnName
    private let iterationCount: Int
    private var runSamples = [Name: [MultiSample]]()
    private var maxSampleCount = 0

    init(iterationCount c: Int) {
        iterationCount = c
    }
    mutating func push(name n: Name, samples newvs: [Double]) {
        let oldvs = runSamples[n] ?? []
        var newvs1 = [MultiSample]()
        for (i,newv) in newvs.enumerated() {
            var newv1 = oldvs.at(i) ?? MultiSample()
            if newv >= 0 {
                newv1.push(newv)
            }
            newvs1.append(newv1)
        }
        runSamples[n] = newvs1
        maxSampleCount = max(maxSampleCount,newvs1.count)
    }
    func print() {
        let ns = [
            .stdGet, .stdInsert, .stdUpdate, .stdRemove,
            .btreeGet, .btreeInsert, .btreeUpdate, .btreeRemove,
            .sbtlGet, .sbtlInsert, .sbtlUpdate, .sbtlRemove,
        ] as [Name]
        Swift.print(ns.map({ n in "\(n)" }).joined(separator: ","))
        Swift.print((0..<ns.count).map({ _ in "0" }).joined(separator: ","))
        for i in 0..<maxSampleCount {
            let ss = ns.map({ n in runSamples[n, default: []].at(i)?.average?.description ?? " " })
            let s = ss.joined(separator: ",")
            Swift.print(s)
        }
    }
}

extension Array {
    func at(_ i: Int) -> Element? {
        guard i < count else { return nil }
        return self[i]
    }
}

//
//  BTLEmptyWeightValueWrapper.swift
//  SBTL
//
//  Created by Henry on 2019/06/19.
//

import Foundation

struct BTLEmptySumValueWrapper<Wrapped>: SBTLValueProtocol {
    var value: Wrapped
    init(_ v: Wrapped) {
        value = v
    }
    var sum: BTLEmptySum {
        return .zero
    }
}
extension BTLEmptySumValueWrapper: Equatable where Wrapped: Equatable {
    static func == (_ a: BTLEmptySumValueWrapper, _ b: BTLEmptySumValueWrapper) -> Bool {
        return a.value == b.value
    }
}
extension BTLEmptySumValueWrapper: Comparable where Wrapped: Comparable {
    static func < (_ a: BTLEmptySumValueWrapper, _ b: BTLEmptySumValueWrapper) -> Bool {
        return a.value < b.value
    }
    static func > (_ a: BTLEmptySumValueWrapper, _ b: BTLEmptySumValueWrapper) -> Bool {
        return a.value > b.value
    }
    static func <= (_ a: BTLEmptySumValueWrapper, _ b: BTLEmptySumValueWrapper) -> Bool {
        return a.value <= b.value
    }
    static func >= (_ a: BTLEmptySumValueWrapper, _ b: BTLEmptySumValueWrapper) -> Bool {
        return a.value >= b.value
    }
}
struct BTLEmptySum: AdditiveArithmetic, Comparable {
    static let zero = BTLEmptySum()
    static func + (_ a: BTLEmptySum, _ b: BTLEmptySum) -> BTLEmptySum {
        return BTLEmptySum()
    }
    static func += (_ a: inout BTLEmptySum, _ b: BTLEmptySum) {
    }
    static func - (_ a: BTLEmptySum, _ b: BTLEmptySum) -> BTLEmptySum {
        return BTLEmptySum()
    }
    static func -= (_ a: inout BTLEmptySum, _ b: BTLEmptySum) {
    }
    static func == (_ a: BTLEmptySum, _ b: BTLEmptySum) -> Bool {
        return true
    }
    static func < (_ a: BTLEmptySum, _ b: BTLEmptySum) -> Bool {
        return false
    }
    static func > (_ a: BTLEmptySum, _ b: BTLEmptySum) -> Bool {
        return false
    }
    static func <= (_ a: BTLEmptySum, _ b: BTLEmptySum) -> Bool {
        return true
    }
    static func >= (_ a: BTLEmptySum, _ b: BTLEmptySum) -> Bool {
        return true
    }
}

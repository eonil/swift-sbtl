//
//  BTLEmptyWeightValueWrapper.swift
//  WBTL
//
//  Created by Henry on 2019/06/19.
//

import Foundation

struct BTLEmptyWeightValueWrapper<Wrapped>: WBTLValueProtocol {
    var value: Wrapped
    init(_ v: Wrapped) {
        value = v
    }
    var weight: BTLEmptyWeight {
        return .zero
    }
}
extension BTLEmptyWeightValueWrapper: Equatable where Wrapped: Equatable {
    static func == (_ a: BTLEmptyWeightValueWrapper, _ b: BTLEmptyWeightValueWrapper) -> Bool {
        return a.value == b.value
    }
}
extension BTLEmptyWeightValueWrapper: Comparable where Wrapped: Comparable {
    static func < (_ a: BTLEmptyWeightValueWrapper, _ b: BTLEmptyWeightValueWrapper) -> Bool {
        return a.value < b.value
    }
    static func > (_ a: BTLEmptyWeightValueWrapper, _ b: BTLEmptyWeightValueWrapper) -> Bool {
        return a.value > b.value
    }
    static func <= (_ a: BTLEmptyWeightValueWrapper, _ b: BTLEmptyWeightValueWrapper) -> Bool {
        return a.value <= b.value
    }
    static func >= (_ a: BTLEmptyWeightValueWrapper, _ b: BTLEmptyWeightValueWrapper) -> Bool {
        return a.value >= b.value
    }
}
struct BTLEmptyWeight: AdditiveArithmetic, Comparable {
    static let zero = BTLEmptyWeight()
    static func + (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> BTLEmptyWeight {
        return BTLEmptyWeight()
    }
    static func += (_ a: inout BTLEmptyWeight, _ b: BTLEmptyWeight) {
    }
    static func - (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> BTLEmptyWeight {
        return BTLEmptyWeight()
    }
    static func -= (_ a: inout BTLEmptyWeight, _ b: BTLEmptyWeight) {
    }
    static func == (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> Bool {
        return true
    }
    static func < (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> Bool {
        return false
    }
    static func > (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> Bool {
        return false
    }
    static func <= (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> Bool {
        return true
    }
    static func >= (_ a: BTLEmptyWeight, _ b: BTLEmptyWeight) -> Bool {
        return true
    }
}

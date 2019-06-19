//
//  BTL.swift
//  CodeView3
//
//  Created by Henry on 2019/06/17.
//

public struct BTL<Value>:
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection,
ExpressibleByArrayLiteral,
BinarySearchProtocol {
    private typealias W = BTLEmptyWeightValueWrapper<Value>
    private var wbtl = WBTL<W>()

    public init() {}
    public init(arrayLiteral elements: Element...) {
        append(contentsOf: elements)
    }
    public var startIndex: Int {
        return wbtl.startIndex
    }
    public var endIndex: Int {
        return wbtl.endIndex
    }
    public subscript(_ i: Int) -> Value {
        get { return wbtl[i].value }
        set(v) { wbtl[i] = W(v) }
    }
    public mutating func insert(_ v: Value, at i: Int) {
        wbtl.insert(W(v), at: i)
    }
    public mutating func remove(at i: Int) -> Value {
        return wbtl.remove(at: i).value
    }
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        return wbtl.replaceSubrange(subrange, with: newElements.map({ W($0) }))
    }
}

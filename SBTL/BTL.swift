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
ExpressibleByArrayLiteral {
    private typealias W = BTLEmptySumValueWrapper<Value>
    private var impl = SBTL<W>()

    public init() {}
    public init<S>(_ s: S) where S: Sequence, S.Element == Element {
        append(contentsOf: s)
    }
    public init(arrayLiteral elements: Element...) {
        append(contentsOf: elements)
    }
    public var startIndex: Int {
        return impl.startIndex
    }
    public var endIndex: Int {
        return impl.endIndex
    }
    public subscript(_ i: Int) -> Value {
        get { return impl[i].value }
        set(v) { impl[i] = W(v) }
    }
    public mutating func insert(_ v: Value, at i: Int) {
        impl.insert(W(v), at: i)
    }
    public mutating func remove(at i: Int) -> Value {
        return impl.remove(at: i).value
    }
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        return impl.replaceSubrange(subrange, with: newElements.map({ W($0) }))
    }
}

//
//  BTLSet.swift
//  SBTL
//
//  Created by Henry on 2019/06/19.
//

struct BTLSet<Element>:
RandomAccessCollection,
ExpressibleByArrayLiteral where
Element: Comparable {
    private typealias W = BTLEmptySumValueWrapper<Element>
    private var impl = SBTLSet<W>()

    public init() {}
    public init<S>(_ s: S) where S: Sequence, S.Element == Element {
        for e in s {
            insert(e)
        }
    }
    public init(arrayLiteral elements: Element...) {
        for e in elements {
            insert(e)
        }
    }
    public var startIndex: Int {
        return impl.startIndex
    }
    public var endIndex: Int {
        return impl.endIndex
    }
    public func firstIndex(of e: Element) -> Int? {
        return impl.firstIndex(of: W(e))
    }
    public subscript(_ i: Int) -> Element {
        return impl[i].value
    }

    public mutating func insert(_ e: Element) {
        return impl.insert(W(e))
    }
    public mutating func remove(_ e: Element) -> Element? {
        return impl.remove(W(e))?.value
    }
}

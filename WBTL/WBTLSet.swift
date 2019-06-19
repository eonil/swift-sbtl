//
//  WBTLSet.swift
//  WBTL
//
//  Created by Henry on 2019/06/19.
//

import Foundation

public struct WBTLSet<Element>:
RandomAccessCollection where
Element: Comparable & WBTLValueProtocol {
    private var impl = WBTL<Element>()

    public var startIndex: Int {
        return 0
    }
    public var endIndex: Int {
        return impl.count
    }
    /// Binary search.
    /// - Complexity: O(log2(n))
    public func firstIndex(of e: Element) -> Int? {
        let i = impl.findInsertionPoint(for: e, in: impl.indices, key: {$0})
        let x = impl[i]
        return x == e ? i : nil
    }
    public subscript(_ i: Int) -> Element {
        get { return impl[i] }
    }

    public mutating func insert(_ e: Element) {
        let i = impl.findInsertionPoint(for: e, in: impl.indices, key: {$0})
        impl.insert(e, at: i)
    }
    @discardableResult
    public mutating func remove(_ e: Element) -> Element? {
        guard let i = firstIndex(of: e) else { return nil }
        return impl.remove(at: i)
    }
}

//public struct WBTLSetSlice<Element>: RandomAccessCollection where
//Element: Comparable & WBTLValueProtocol {
//    private(set) var impl: Slice<WBTL<Element>>
//    public var startIndex: Int {
//        return impl.startIndex
//    }
//    public var endIndex: Int {
//        return impl.endIndex
//    }
//    public subscript(_ i: Int) -> Element {
//        return impl[i]
//    }
//    /// - Complexity:
//    ///     O(log2(n)).
//    public func firstIndex(of e: Element) -> Int? {
//        let i = count / 2
//        let x = self[i]
//        let s = e < x ? self[..<i] : self[i...]
//        return s.firstIndex(of: e)
//    }
//    public subscript(_ r: Range<Int>) -> WBTLSetSlice<Element> {
//
//    }
//}


//
//  WBTLMap.swift
//  WBTL
//
//  Created by Henry on 2019/06/19.
//

import Foundation

public struct WBTLMap<Key,Value>:
RandomAccessCollection where
Key: Comparable,
Value: WBTLValueProtocol {
    public typealias Element = (key: Key, value: Value)

    fileprivate typealias Pair = WBTLMapPair<Key,Value>
    private var impl = WBTL<Pair>()

    /// Binary search.
    /// - Complexity: O(log2(n))
    ///
    /// Internals
    /// ---------
    ///
    /// For this given dataset
    ///
    ///     0   1   2   3
    ///     22  33  88  99
    ///
    /// value `55` returns `2`.
    ///
    private func findInsertionPoint(for k: Key, in r: Range<Int>) -> Int {
        switch r.count {
        case 0:
            return r.lowerBound
        case 1:
            return r.upperBound
        default:
            let i = r.lowerBound + (r.count / 2)
            let x = impl[i]
            let s = k < x.element.key ? r[..<i] : r[i...]
            return findInsertionPoint(for: k, in: s)
        }
    }

    public var startIndex: Int {
        return impl.startIndex
    }
    public var endIndex: Int {
        return impl.endIndex
    }
    public subscript(_ i: Int) -> Element {
        return impl[i].element
    }
    public subscript(_ k: Key) -> Value? {
        get {
            guard let i = keys.firstIndex(of: k) else { return nil }
            return impl[i].element.value
        }
        set(v) {
            let i = findInsertionPoint(for: k, in: indices)
            let x = self[i]
            if x.key == k {
                // Matched.
                if let v = v {
                    // Replace.
                    impl[i] = Pair(element: (k,v))
                }
                else {
                    // Remove.
                    impl.remove(at: i)
                }
            }
            else {
                if let v = v {
                    // Insert.
                    impl.insert(Pair(element: (k,v)), at: i)
                }
                else {
                    // No-op.
                }
            }
        }
    }

    public var keys: Keys {
        return Keys(impl: self)
    }
    public struct Keys: RandomAccessCollection {
        fileprivate private(set) var impl: WBTLMap
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public func firstIndex(of key: Key) -> Int? {
            let i = impl.findInsertionPoint(for: key, in: impl.indices)
            let x = impl[i]
            guard x.key == key else { return nil }
            return i
        }
        public subscript(_ i: Int) -> Key {
            return impl[i].key
        }
    }

    public var values: Values {
        return Values(impl: self)
    }
    public struct Values: RandomAccessCollection {
        fileprivate private(set) var impl: WBTLMap
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public subscript(_ i: Int) -> Value {
            return impl[i].value
        }
    }
}

private struct WBTLMapPair<Key,Value>: Comparable, WBTLValueProtocol where
Key: Comparable,
Value: WBTLValueProtocol {
    typealias Weight = Value.Weight
    var element: (key: Key, value: Value)
    var weight: Weight {
        return element.value.weight
    }

    /// This is partial comparison based only on key.
    static func < (lhs: WBTLMapPair<Key, Value>, rhs: WBTLMapPair<Key, Value>) -> Bool {
        return lhs.element.key < rhs.element.key
    }

    /// This is partial equality based only on key.
    static func == (lhs: WBTLMapPair<Key, Value>, rhs: WBTLMapPair<Key, Value>) -> Bool {
        return lhs.element.key == rhs.element.key
    }
}

//
//  SBTLMap.swift
//  SBTL
//
//  Created by Henry on 2019/06/19.
//

import Foundation

/// Always sorted associative array.
public struct SBTLMap<Key,Value>:
RandomAccessCollection,
ExpressibleByDictionaryLiteral where
Key: Comparable,
Value: SBTLValueProtocol {
    public typealias Element = (key: Key, value: Value)

    fileprivate typealias Pair = SBTLMapPair<Key,Value>
    private var impl = SBTL<Pair>()

    public init() {}
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (k,v) in elements {
            self[k] = v
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
            let i = impl.findInsertionPoint(
                for: k,
                in: indices,
                with: {$0.element.key})
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

    public func index(for w: Value.Sum) -> Int {
        return impl.index(for: w)
    }
    public typealias IndexAndOffset = SBTL<Value>.IndexAndOffset
    public func indexAndOffset(for w: Value.Sum) -> IndexAndOffset {
        return impl.indexAndOffset(for: w)
    }

    public var keys: Keys {
        return Keys(impl: impl)
    }
    public struct Keys: RandomAccessCollection {
        fileprivate private(set) var impl: SBTL<Pair>
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public func firstIndex(of k: Key) -> Int? {
            let i = impl.findInsertionPoint(
                for: k,
                in: impl.indices,
                with: {$0.element.key})
            let x = impl[i]
            guard x.element.key == k else { return nil }
            return i
        }
        public subscript(_ i: Int) -> Key {
            return impl[i].element.key
        }
    }

    public var values: Values {
        return Values(impl: impl)
    }
    public struct Values: RandomAccessCollection {
        fileprivate private(set) var impl: SBTL<Pair>
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public subscript(_ i: Int) -> Value {
            return impl[i].element.value
        }
    }
}

private struct SBTLMapPair<Key,Value>: Comparable, SBTLValueProtocol where
Key: Comparable,
Value: SBTLValueProtocol {
    typealias Sum = Value.Sum
    var element: (key: Key, value: Value)
    var sum: Sum {
        return element.value.sum
    }

    /// This is partial comparison based only on key.
    static func < (lhs: SBTLMapPair<Key, Value>, rhs: SBTLMapPair<Key, Value>) -> Bool {
        return lhs.element.key < rhs.element.key
    }

    /// This is partial equality based only on key.
    static func == (lhs: SBTLMapPair<Key, Value>, rhs: SBTLMapPair<Key, Value>) -> Bool {
        return lhs.element.key == rhs.element.key
    }
}

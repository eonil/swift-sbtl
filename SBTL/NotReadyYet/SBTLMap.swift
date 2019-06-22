//
//  SBTLMap.swift
//  SBTL
//
//  Created by Henry on 2019/06/19.
//

import Foundation

/// Always sorted associative array.
///
/// - TODO:
///     Lookup performance is very bad now.
///     Not really ready for production.
///
public struct SBTLMap<Key,Value>:
RandomAccessCollection,
ExpressibleByDictionaryLiteral where
Key: Comparable,
Value: SBTLValueProtocol {
    public typealias Element = (key: Key, value: Value)
    fileprivate typealias Pair = SBTLMapPair<Key,Value>
    private(set) var impl = SBTL<Pair>()

    public init() {}
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (k,v) in elements {
            self[k] = v
        }
    }
}

// MARK: Indexing
public extension SBTLMap {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    subscript(_ i: Int) -> Element {
        return impl[i].element
    }
}
public extension SBTLMap {
    func element(at i: Int) -> Element {
        return impl[i].element
    }
}

// MARK: Sum Query
public extension SBTLMap {
    func index(for w: Value.Sum) -> Int {
        return impl.index(for: w)
    }
    typealias IndexAndOffset = SBTL<Value>.IndexAndOffset
    func indexAndOffset(for w: Value.Sum) -> IndexAndOffset {
        return impl.indexAndOffset(for: w)
    }
}

// MARK: Subcriptor
public extension SBTLMap {
    subscript(_ k: Key) -> Value? {
        get {
            return impl.binarySearch
                .indexAndElement(of: k, with: {$0.element.key})?
                .element.element.value
        }
        set(v) {
            if let v = v {
                // Insert or replace.
                let i = impl.binarySearch.indexToPlace(k, with: {$0.element.key})
                if i < impl.count && impl[i].element.key == k {
                    impl[i].element = (k,v)
                }
                else {
                    let p = SBTLMapPair(element: (k,v))
                    impl.insert(p, at: i)
                }
            }
            else {
                // Remove or ignore.
                let i = impl.binarySearch.indexToPlace(k, with: {$0.element.key})
                if i < impl.count && impl[i].element.key == k {
                    impl.remove(at: i)
                }
            }
        }
    }
}

// MARK: Keys and Values Collections
public extension SBTLMap {
    var keys: Keys {
        return Keys(impl: impl)
    }
    struct Keys: RandomAccessCollection {
        fileprivate private(set) var impl: SBTL<Pair>
    }
    var values: Values {
        return Values(impl: impl)
    }
    struct Values: RandomAccessCollection {
        fileprivate private(set) var impl: SBTL<Pair>
    }
}
public extension SBTLMap.Keys {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    func firstIndex(of k: Key) -> Int? {
        return impl.binarySearch.index(of: k, with: {$0.element.key})
    }
    subscript(_ i: Int) -> Key {
        return impl[i].element.key
    }
}
public extension SBTLMap.Values {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    subscript(_ i: Int) -> Value {
        return impl[i].element.value
    }
}

// MARK: Pair
struct SBTLMapPair<Key,Value>: Comparable, SBTLValueProtocol where
Key: Comparable,
Value: SBTLValueProtocol {
    typealias Sum = Value.Sum
    var element: (key: Key, value: Value)
    var sum: Sum {
        return element.value.sum
    }

    /// This is partial equality based only on key.
    static func == (lhs: SBTLMapPair<Key, Value>, rhs: SBTLMapPair<Key, Value>) -> Bool {
        return lhs.element.key == rhs.element.key
    }

    /// This is partial comparison based only on key.
    static func < (lhs: SBTLMapPair<Key, Value>, rhs: SBTLMapPair<Key, Value>) -> Bool {
        return lhs.element.key < rhs.element.key
    }
}

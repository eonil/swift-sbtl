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
            let i = impl.index(
                of: k,
                in: impl.indices,
                with: {$0.element.key})
            guard i < impl.count else { return nil }
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

public extension SBTLMap {
    func index(for w: Value.Sum) -> Int {
        return impl.index(for: w)
    }
    typealias IndexAndOffset = SBTL<Value>.IndexAndOffset
    func indexAndOffset(for w: Value.Sum) -> IndexAndOffset {
        return impl.indexAndOffset(for: w)
    }
}

public extension SBTLMap {
    subscript(_ k: Key) -> Value? {
        get {
            guard let i = keys.firstIndex(of: k) else { return nil }
            return impl[i].element.value
        }
        set(v) {
            if let v = v {
                // Insert or replace.
                let i = impl.indexToPlace(k, in: indices, with: {$0.element.key})
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
                let i = impl.indexToPlace(k, in: indices, with: {$0.element.key})
                if i < impl.count && impl[i].element.key == k {
                    impl.remove(at: i)
                }
            }

//            let i = impl.indexToPlace(
//                k,
//                in: indices,
//                with: {$0.element.key})
//            let x = indices.contains(i) ? self[i] : nil
//            if x?.key == k {
//                // Matched.
//                if let v = v {
//                    // Replace.
//                    impl[i] = Pair(element: (k,v))
//                }
//                else {
//                    // Remove.
//                    impl.remove(at: i)
//                }
//            }
//            else {
//                if let v = v {
//                    // Insert.
//                    impl.insert(Pair(element: (k,v)), at: i)
//                }
//                else {
//                    // No-op.
//                }
//            }
        }
    }
}

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
//public extension SBTLMap.Index {
//    typealias Stride = Int.Stride
//    func advanced(by n: SBTLMap.Index.Stride) -> SBTLMap.Index {
//        return Index(impl: impl.advanced(by: n))
//    }
//    func distance(to other: SBTLMap.Index) -> SBTLMap.Index.Stride {
//        return Index(impl: impl.distance(to: other))
//    }
//    static func == (lhs: SBTLMap.Index, rhs: SBTLMap.Index) -> Bool {
//        return lhs.impl == rhs.impl
//    }
//    static func < (lhs: SBTLMap.Index, rhs: SBTLMap.Index) -> Bool {
//        return lhs.impl < rhs.impl
//    }
//}

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

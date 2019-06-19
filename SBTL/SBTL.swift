//
//  SBTL.swift
//  CodeView3
//
//  Created by Henry on 2019/06/17.
//

public protocol SBTLValueProtocol {
    associatedtype Sum: AdditiveArithmetic, Comparable
    var sum: Sum { get }
}

/// Quick and simple summation B-Tree based list.
///
/// Point of B-Tree
/// ---------------
/// When compared to Binary Tree...
/// - Shorter depth.
/// - Better cache locality.
/// Therefore,
/// - Keep multiple items in leaf node.
/// - Always have 2 children for simpler balancing implementation.
/// - Provide Copy-on-Write automatically.
/// - Balancing is done for shorter depth, and for sum distribution.
///
///
///
/// Summation Attributes
/// --------------------
/// - Sum is just a property of value.
/// - `SBTL` provides automatic summation of all values in subtree.
/// - Summation is delta accumulation based.
///   (not good for floating-point types)
/// - You can find element index by sum offset.
///
public struct SBTL<Value>:
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection,
BinarySearchProtocol where
Value: SBTLValueProtocol {
    public private(set) var count = 0
    public private(set) var sum = Value.Sum.zero

    typealias Content = SBTLContent<Value>
    private(set) var content = Content.leaf([])

    var leafNodeCapacity: Int {
        // Accorgind to Károly Lőrentey, most efficient size would be
        // 16 KiB. But for the case of persistent datastructure, it is likely
        // to waste too much memory. Therefore I use 4 KiB for cache size.
        //
        // You can control time/space efficiency by setting this number.
        // Larger number up to about 16 KiB increases cache locality
        // and decreases sharing amount.
        // Smaller numbers do the opposite.
        //
        let cacheSize = 4*1024
        let maxCap = cacheSize / MemoryLayout<Value>.stride
        return Swift.max(1,maxCap)
    }
    mutating func balance() {
        switch content {
        case .leaf(_):  break
        case .branch(var a, var b):
            // Move a leaf.
            let dt = a.count - b.count
            if leafNodeCapacity < dt  {
                // Too many in `a`.
                let leaf = a.removeLastLeaf()
                b.prependLeaf(leaf)
                content = .branch(a,b)
                return
            }
            if leafNodeCapacity < -dt {
                // Too many in `b`.
                let leaf = b.removeFirstLeaf()
                a.appendLeaf(leaf)
                content = .branch(a,b)
                return
            }
            // Do not write back if not necessary.
        }
    }

    ////

    public init() {}
    public init<S>(_ s: S) where S: Sequence, S.Element == Value {
        for v in s {
            insert(v, at: count)
        }
    }

    public var startIndex: Int {
        return 0
    }
    public var endIndex: Int {
        return count
    }
    public func index(after i: Int) -> Int {
        return i + 1
    }
    public subscript(_ i: Int) -> Value {
        get {
            precondition(i < count, "Index is out of range.")
            switch content {
            case .leaf(let a):          return a[i]
            case .branch(let a, let b): return i < a.count ? a[i] : b[i-a.count]
            }
        }
        set(v) {
            precondition(i < count, "Index is out of range.")
            sum -= self[i].sum
            sum += v.sum
            switch content {
            case .leaf(var a):
                a[i] = v
                content = .leaf(a)
            case .branch(var a, var b):
                if i < a.count {
                    a[i] = v
                }
                else {
                    b[i-a.count] = v
                }
                content = .branch(a, b)
            }
        }
    }

    /// Finds index of value that contains specified sum offset.
    public func index(for w: Value.Sum) -> Int {
        return indexAndOffset(for: w).index
    }
    public typealias IndexAndOffset = (index: Int, offset: Value.Sum)
    public func indexAndOffset(for w: Value.Sum) -> IndexAndOffset {
        precondition(w < sum)
        switch content {
        case .leaf(let a):
            var c = Value.Sum.zero
            for (i,v) in a.enumerated() {
                let d = c + v.sum
                if (c..<d).contains(w) {
                    let o = w - c
                    return (i,o)
                }
                c = d
            }
            fatalError("A bug in implementation.")
        case .branch(let a, let b):
            return w < a.sum
                ? a.indexAndOffset(for: w)
                : b.indexAndOffset(for: w - a.sum)
        }
    }
//    public func weightRange(at i: Int) -> Range<Value.Weight> {
//        switch content {
//        case .leaf(let a):
//            let start = a[..<i].lazy.map({ v in v.weight }).reduce(.zero, +)
//            let end = start + a[i].weight
//            return start..<end
//        case .branch(let a, let b):
//            return i < a.count
//                ? a.weightRange(at: i)
//                : b.weightRange(at: i - a.count)
//        }
//    }
//    public func weightRange<R>(in r: R) -> Range<Value.Weight> where
//        R: RangeExpression,
//        R.Bound == Int
//    {
//        let s = r.relative(to: self)
//        let a = weightRange(at: s.lowerBound)
//        let b = weightRange(at: s.upperBound)
//        return a.lowerBound..<b.upperBound
//    }

    public mutating func insert(_ v: Value, at i: Int) {
        count += 1
        sum += v.sum
        switch content {
        case .leaf(var a):
            if a.count < leafNodeCapacity {
                a.insert(v, at: i)
                content = .leaf(a)
            }
            else {
                a.insert(v, at: i)
                let k = a.count / 2
                let x = a[0..<k]
                let y = a[k...]
                content = .branch(SBTL(x), SBTL(y))
            }
        case .branch(var a, var b):
            if i < a.count {
                a.insert(v, at: i)
            }
            else {
                let j = i - a.count
                b.insert(v, at: j)
            }
            content = .branch(a, b)
            balance()
        }
    }
    @discardableResult
    public mutating func remove(at i: Int) -> Value {
        let v = self[i]
        count -= 1
        sum -= v.sum
        switch content {
        case .leaf(var a):
            let v = a.remove(at: i)
            content = .leaf(a)
            return v
        case .branch(var a, var b):
            let v = i < a.count ? a.remove(at: i) : b.remove(at: i - a.count)
            if a.count + b.count < leafNodeCapacity / 2 {
                // Merge.
                var c = [Value]()
                c.reserveCapacity(a.count + b.count)
                c.append(contentsOf: a)
                c.append(contentsOf: b)
                content = .leaf(c)
            }
            else {
                content = .branch(a, b)
                balance()
            }
            return v
        }
    }

    ////

    mutating func prependLeaf(_ leaf: SBTL) {
        switch content {
        case .leaf(_):
            let a = leaf
            let b = self
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            balance()
        case .branch(var a, let b):
            a.prependLeaf(leaf)
            a.balance()
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            balance()
        }
    }
    mutating func appendLeaf(_ leaf: SBTL) {
        switch content {
        case .leaf(_):
            let a = self
            let b = leaf
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            balance()
        case .branch(let a, var b):
            b.appendLeaf(leaf)
            b.balance()
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            balance()
        }
    }

    @discardableResult
    mutating func removeFirstLeaf() -> SBTL {
        switch content {
        case .leaf(_):
            let leaf = self
            self = SBTL()
            return leaf
        case .branch(var a, let b):
            let leaf = a.removeFirstLeaf()
            a.balance()
            if a.isEmpty {
                self = b
                return leaf
            }
            else {
                count = a.count + b.count
                sum = a.sum + b.sum
                content = .branch(a, b)
                balance()
                return leaf
            }
        }
    }
    @discardableResult
    mutating func removeLastLeaf() -> SBTL {
        switch content {
        case .leaf(_):
            let leaf = self
            self = SBTL()
            return leaf
        case .branch(let a, var b):
            let leaf = b.removeLastLeaf()
            b.balance()
            if b.isEmpty {
                self = a
                return leaf
            }
            else {
                count = a.count + b.count
                sum = a.sum + b.sum
                content = .branch(a, b)
                balance()
                return leaf
            }
        }
    }
}
public extension SBTL {
    mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        let q = subrange.relative(to: self)
        if q.count < newElements.count {
            // Inserts more.
            for e in newElements.lazy.reversed() {
                insert(e, at: q.upperBound)
            }
        }
        else {
            // Removes more.
            let d = q.count - newElements.count
            let x = q.lowerBound + newElements.count
            for _ in 0..<d {
                remove(at: x)
            }
        }
        let m = Swift.min(q.count, newElements.count)
        var it = newElements.makeIterator()
        for i in 0..<m {
            let e = it.next()!
            let k = i + q.lowerBound
            self[k] = e
        }
    }
}
extension SBTL: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        append(contentsOf: elements)
    }
}
extension SBTL: Equatable where Element: Equatable {
    public static func == (_ a: SBTL, _ b: SBTL) -> Bool {
        guard a.count == b.count else { return false }
        for (x,y) in zip(a, b) {
            guard x == y else { return false }
        }
        return true
    }
}

enum SBTLContent<Value> where Value: SBTLValueProtocol {
    case leaf([Value])
    indirect case branch(SBTL<Value>, SBTL<Value>)
    var isLeaf: Bool {
        if case .leaf(_) = self { return true }
        return false
    }
    var isBranch: Bool {
        if case .branch(_) = self { return true }
        return false
    }
}


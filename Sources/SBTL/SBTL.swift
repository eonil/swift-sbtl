//
//  SBTL.swift
//  CodeView3
//
//  Created by Henry on 2019/06/17.
//

public protocol SBTLValueProtocol {
    associatedtype Sum: AdditiveArithmetic
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
/// Summation Attributes
/// --------------------
/// - Sum is just a property of value.
/// - `SBTL` provides automatic summation of all values in subtree.
/// - Summation is delta accumulation based.
///   (not good for floating-point types)
/// - Summation can overflow, and there's no facility to handle overflow.
///   You're responsible to prevent overflows.
/// - You can find element index by sum offset.
///
public struct SBTL<Element>:
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection,
ExpressibleByArrayLiteral where
Element: SBTLValueProtocol {
    public private(set) var count = 0
    public private(set) var sum = Element.Sum.zero

    typealias Content = SBTLContent<Element>
    private(set) var content = Content.leaf([])
    private(set) var first: Element?
    private(set) var last: Element?

    public init() {}
    public init<S>(_ s: S) where S: Sequence, S.Element == Element {
        append(contentsOf: s)
    }
    public init(arrayLiteral elements: Element...) {
        append(contentsOf: elements)
    }
}

// MARK: Configuration
extension SBTL {
    var leafNodeCapacity: Int {
        // According to Károly Lőrentey, most efficient size would be
        // 16 KiB. But for the case of persistent datastructure, it is likely
        // to waste too much memory. Therefore I use 4 KiB for bucket size.
        //
        // You can control time/space efficiency by setting this number.
        // Larger number up to about 16 KiB increases cache locality
        // and decreases sharing amount.
        // Smaller numbers do the opposite.
        //
        let cacheSize = 16*1024
        let maxCap = cacheSize / MemoryLayout<Element>.stride
        return Swift.max(1,maxCap)
    }
}

// MARK: Summation Query
public extension SBTL where Element.Sum: Comparable {
    /// Finds index of value that contains specified sum offset.
    func index(for w: Element.Sum) -> Int {
        return indexAndOffset(for: w).index
    }
    typealias IndexAndOffset = (index: Int, offset: Element.Sum)
    func indexAndOffset(for w: Element.Sum) -> IndexAndOffset {
        precondition(w < sum)
        switch content {
        case .leaf(let a):
            var c = Element.Sum.zero
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
    ///
    
//    func indexAndOffset<T>(for p: T, on access: (Element.Sum) -> T) -> (index:Int, offset:T) where T:Comparable & AdditiveArithmetic {
//        precondition(p < access(sum))
//        switch content {
//        case .leaf(let a):
//            var c = access(Element.Sum.zero)
//            for (i,v) in a.enumerated() {
//                let x = access(v.sum)
//                let d = c + x
//                if (c..<d).contains(p) {
//                    let o = p - c
//                    return (i,o)
//                }
//                c = d
//            }
//            fatalError("A bug in implementation.")
//        case .branch(let a, let b):
//            return p < access(a.sum)
//                ? a.indexAndOffset(for: p, on: access)
//                : b.indexAndOffset(for: p - access(a.sum), on: access)
//        }
//    }
    
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
}

// MARK: Binary Search
extension SBTL {
    var binarySearch: SBTLBinarySearch<Element> {
        return SBTLBinarySearch(base: self)
    }
}
struct SBTLBinarySearch<Element>:
BinarySearchProtocol,
TreeBinarySearchProtocol where
Element: SBTLValueProtocol {
    typealias Base = SBTL<Element>
    var base: Base
}
extension SBTLBinarySearch {
    typealias IndexAndElement = (index: Int, element: Element)
    func indexAndElement<C>(of x: C, with m: (Element) -> C) -> IndexAndElement? where C: Comparable {
        return base.count == 0 ? nil : base.content.indexAndElementOptimized(of: x, with: m)
    }
    func indexToPlace<C>(_ x: C, with m: (Element) -> C) -> Int where C: Comparable {
        return base.count == 0 ? 0 : base.content.indexToPlace(x, with: m)
    }
}

// MARK: Node Content
indirect enum SBTLContent<Value> where Value: SBTLValueProtocol {
    case leaf([Value])
    case branch(SBTL<Value>, SBTL<Value>)
    var isLeaf: Bool {
        if case .leaf(_) = self { return true }
        return false
    }
    var isBranch: Bool {
        if case .branch(_) = self { return true }
        return false
    }
}

// MARK: Node Binary Search
extension SBTLContent: BinarySearchProtocol {}
extension SBTLContent: TreeBinarySearchProtocol {}
extension SBTLContent {
    typealias IndexAndElement = (index: Int, element: Value)
    /// Alternative solution if caller can guarantee no emprty subnode.
    func indexAndElementOptimized<C>(of x: C, with m: (Value) -> C) -> IndexAndElement? where C: Comparable {
        switch self {
        case .leaf(let a):
            assert(a.count > 0, "Caller MUST guarantee non-zero count.")
            return a.binarySearch.indexAndElement(of: x, with: m)
        case .branch(let a, let b):
            assert(a.count > 0, "Caller MUST guarantee non-zero count.")
            assert(b.count > 0, "Caller MUST guarantee non-zero count.")
            let y = m(b.first!)
            if x < y {
                return a.binarySearch.indexAndElement(of :x, with: m)
            }
            else {
                guard let (i,e) = b.binarySearch.indexAndElement(of: x, with: m) else { return nil }
                return (a.count + i,e)
            }
        }
    }
//    @available(*,unavailable: 0, message: "DO NOT use this variant unless absolutely required.")
    func indexAndElement<C>(of x: C, with m: (Value) -> C) -> IndexAndElement? where C: Comparable {
        switch self {
        case .leaf(let a):
            return a.binarySearch.indexAndElement(of: x, with: m)
        case .branch(let a, let b):
            switch (a.count, b.count) {
            case (0,0): return nil
            case (_,0): return a.binarySearch.indexAndElement(of: x, with: m)
            case (0,_):
                guard let (i,e) = b.binarySearch.indexAndElement(of: x, with: m) else { return nil }
                return (a.count + i,e)
            default:
                let y = m(b.first!)
                if x < y {
                    return a.binarySearch.indexAndElement(of :x, with: m)
                }
                else {
                    guard let (i,e) = b.binarySearch.indexAndElement(of: x, with: m) else { return nil }
                    return (a.count + i,e)
                }
            }
        }
    }
    func indexToPlace<C>(_ x: C, with m: (Value) -> C) -> Int where C: Comparable {
        switch self {
        case .leaf(let a):
            return a.binarySearch.indexToPlace(x, with: m)
        case .branch(let a, let b):
            switch (a.count, b.count) {
            case (0,0): return 0
            case (_,0): return a.binarySearch.indexToPlace(x, with: m)
            case (0,_): return a.count + b.binarySearch.indexToPlace(x, with: m)
            default:
                let y = m(b.first!)
                if x < y {
                    return a.binarySearch.indexToPlace(x, with: m)
                }
                else {
                    return a.count + b.binarySearch.indexToPlace(x, with: m)
                }
            }
        }
    }
}

// MARK: Node Balancing
extension SBTL {
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
                first = a.first ?? b.first
                last = b.last ?? a.last
                return
            }
            if leafNodeCapacity < -dt {
                // Too many in `b`.
                let leaf = b.removeFirstLeaf()
                a.appendLeaf(leaf)
                content = .branch(a,b)
                first = a.first ?? b.first
                last = b.last ?? a.last
                return
            }
            // Do not write back if not necessary.
        }
    }
}

// MARK: Node Roatation
extension SBTL {
    mutating func prependLeaf(_ leaf: SBTL) {
        switch content {
        case .leaf(_):
            let a = leaf
            let b = self
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            first = a.first ?? b.first
            last = b.last ?? a.last
            balance()
        case .branch(var a, let b):
            a.prependLeaf(leaf)
            a.balance()
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            first = a.first ?? b.first
            last = b.last ?? a.last
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
            first = a.first ?? b.first
            last = b.last ?? a.last
            balance()
        case .branch(let a, var b):
            b.appendLeaf(leaf)
            b.balance()
            count = a.count + b.count
            sum = a.sum + b.sum
            content = .branch(a, b)
            first = a.first ?? b.first
            last = b.last ?? a.last
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
                first = a.first ?? b.first
                last = b.last ?? a.last
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
                first = a.first ?? b.first
                last = b.last ?? a.last
                balance()
                return leaf
            }
        }
    }
}

// MARK: Collection
public extension SBTL {
    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return count
    }

    subscript(_ i: Int) -> Element {
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
                first = a.first
                last = a.last
            case .branch(var a, var b):
                if i < a.count {
                    a[i] = v
                }
                else {
                    b[i-a.count] = v
                }
                content = .branch(a, b)
                first = a.first ?? b.first
                last = b.last ?? a.last
            }
        }
    }

    mutating func insert(_ v: Element, at i: Int) {
        count += 1
        sum += v.sum
        switch content {
        case .leaf(var a):
            if a.count < leafNodeCapacity {
                a.insert(v, at: i)
                content = .leaf(a)
                first = a.first
                last = a.last
            }
            else {
                a.insert(v, at: i)
                let k = a.count / 2
                let x = a[0..<k]
                let y = a[k...]
                content = .branch(SBTL(x), SBTL(y))
                first = x.first ?? y.first
                last = y.last ?? x.last
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
            first = a.first ?? b.first
            last = b.last ?? a.last
            balance()
        }
    }
    @discardableResult
    mutating func remove(at i: Int) -> Element {
        let v = self[i]
        count -= 1
        sum -= v.sum
        switch content {
        case .leaf(var a):
            let v = a.remove(at: i)
            content = .leaf(a)
            first = a.first
            last = a.last
            return v
        case .branch(var a, var b):
            let v = i < a.count ? a.remove(at: i) : b.remove(at: i - a.count)
            if a.count + b.count < leafNodeCapacity / 2 {
                // Merge.
                var c = [Element]()
                c.reserveCapacity(a.count + b.count)
                c.append(contentsOf: a)
                c.append(contentsOf: b)
                content = .leaf(c)
                first = c.first
                last = c.last
            }
            else {
                content = .branch(a, b)
                first = a.first ?? b.first
                last = b.last ?? a.last
                balance()
            }
            return v
        }
    }
}

// MARK: RangeReplaceableCollection
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

// MARK: Equality Check.
extension SBTL: Equatable where Element: Equatable {
    public static func == (_ a: SBTL, _ b: SBTL) -> Bool {
        guard a.count == b.count else { return false }
        for (x,y) in zip(a, b) {
            guard x == y else { return false }
        }
        return true
    }
}

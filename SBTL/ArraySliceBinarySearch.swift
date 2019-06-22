//
//  ArraySliceBinarySearch.swift
//  SBTL
//
//  Created by Henry on 2019/06/22.
//

extension Array {
    var binarySearch: ArraySliceBinarySearch<Element> {
        return ArraySliceBinarySearch(base: self[0...])
    }
}
extension ArraySlice {
    var binarySearch: ArraySliceBinarySearch<Element> {
        return ArraySliceBinarySearch(base: self)
    }
}

struct ArraySliceBinarySearch<Element>:
BinarySearchProtocol,
TreeBinarySearchProtocol {
    typealias Base = ArraySlice<Element>
    var base: Base
}
extension ArraySliceBinarySearch {
    typealias Index = Base.Index
    typealias Element = Base.Element
    /// Find index with associated key `x` using Binary Search.
    /// This function assumed `self` is sorted.
    /// - Parameter with m:
    ///     A functions returning comparable key.
    @inlinable
    func index<C>(of x: C, with m: (Element) -> C) -> Int? where C: Comparable {
        return indexAndElement(of: x, with: m)?.index
    }
    /// Find index to place `x` in sorted order.
    /// This returns index of `x` If equal value exists.
    /// Otherwise returning index `i` satisfyies this attributes.
    ///
    ///     self[i] < x <= self[i+1]
    ///
    /// This returns `endIndex` if `x` is larger than all elements.
    ///
    @inlinable
    func indexToPlace<C>(_ x: C, with m: (Element) -> C) -> Int where C: Comparable {
        switch base.count {
        case 0:
            return base.startIndex
        case 1:
            // Do not assume about input value `x`.
            let y = m(base[base.startIndex])
            return x <= y ? base.startIndex : base.startIndex+1
        default:
            let i = base.startIndex + (base.count / 2)
            let a = base[..<i]
            let b = base[i...]
            let y = m(base[i])
            // For given example,
            //
            //      self = [1,3,5]
            //      let result = self.indexToPlace(2)
            //      XCTAssertEqual(result,2)
            //
            //      startIndex + (count / 2) -> 1
            //
            //      a = self[0..<1]
            //      b = self[1...]
            //
            // as `2 < b.first`
            // search on `a`.
            //
            return (x < y ? a.binarySearch : b.binarySearch).indexToPlace(x, with: m)
        }
    }
    typealias IndexAndElement = (index: Int, element: Element)
    /// Find index and element with associated key `x` using Binary Search.
    /// This function assumes `self` is sorted.
    /// - Parameter with m:
    ///     A functions returning comparable key.
    @inlinable
    func indexAndElement<C>(of x: C, with m: (Element) -> C) -> IndexAndElement? where C: Comparable {
        let c = base.count
        switch c {
        case 0:
            return nil
        case 1:
            let i = base.startIndex
            let e = base[i]
            let y = m(e)
            return x == y ? (i,e) : nil
        default:
            let i = base.startIndex + (c / 2)
            let a = base[..<i]
            let b = base[i...]
            let e = b[b.startIndex]
            let y = m(e)
            return (x < y ? a.binarySearch : b.binarySearch).indexAndElement(of: x, with: m)
        }
    }
}

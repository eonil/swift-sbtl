//
//  BinarySearch.swift
//  SBTL
//
//  Created by Henry on 2019/06/19.
//

protocol BinarySearchProtocol where
Self: RandomAccessCollection,
Index == Int {
    /// Binary search.
    ///
    /// This assumes `self` is sorted.
    ///
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
    /// - Parameter with k:
    ///     A function that converts an element into key.
    ///
    func findInsertionPoint<C>(
        for x: C,
        in r: Range<Int>,
        with k: (Self.Element) -> C)
        -> Int
    where
        C: Comparable
}
extension BinarySearchProtocol {
    func findInsertionPoint<C>(
        for x: C,
        in r: Range<Int>,
        with k: (Element) -> C)
        -> Int
    where
        C: Comparable
    {
        switch r.count {
        case 0:
            return r.lowerBound
        case 1:
            return r.upperBound
        default:
            let i = r.lowerBound + (r.count / 2)
            let y = k(self[i])
            let s = x < y ? r[..<i] : r[i...]
            return findInsertionPoint(for: x, in: s, with: k)
        }
    }
}
